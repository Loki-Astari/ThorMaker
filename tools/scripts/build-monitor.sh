#!/usr/bin/env bash
# build-monitor.sh  <pipe-path> <num-slots> [line-width] [make-pid]
#
# Reads START:<target>, UPDATE:<target>, DONE:<target>, STATUS, EXIT from the
# named pipe and maintains a fixed "live" block at the bottom of the terminal:
#
#   <completed item 1>
#   <completed item 2>
#   ...                                  <- scrolls up naturally into history
#   ================================
#   [slot 0] foo.o            building...
#   [slot 1] bar.o            building...
#   [slot 2] <empty>
#   --------------------------------
#   Executing <N> Items Completed <M> Items.
#   <cursor parks here (home)>
#
# On DONE, the ==== separator line is overwritten with the completed item —
# that line then scrolls up into scrollback as we redraw the block below it.
# All terminal writes happen in this single process, so no interleaving.

PIPE="${1:?pipe path required}"
trap 'rm -f "${PIPE}"' EXIT
SlotCount="${2:-8}"
LineWidth="${3:-80}"
MAKE_PID="${4:-}"
activeConnection=0
startupCountDown=5

declare -a slot_target   # slot_target[i] = target currently in slot i, or ""
declare -a slot_info     # slot_info[i]   = info text for slot i
declare -a slot_state    # slot_state[i]  = state (suffix with escapes) for slot i
declare -a slot_tick     # slot_tick[i]   = tick count for slot i (read-loop iterations)

TickWidth=5              # fixed-width field for the tick count column
VisibleSlots=0           # currently-displayed slot rows; grows up to SlotCount
active_count=0
done_count=0
initialized=0
sep_eq=""
sep_dash=""

# ── Helpers ───────────────────────────────────────────────────────────────────
make_separators() {
    local w=$(( LineWidth + 20 ))
    local i s=""
    for ((i = 0; i < w; i++)); do s+='='; done; sep_eq="$s"
    s=""
    for ((i = 0; i < w; i++)); do s+='-'; done; sep_dash="$s"
}

find_free_slot() {
    for ((i = 0; i < VisibleSlots; i++)); do
        [[ -z "${slot_target[$i]}" ]] && { printf '%d' "$i"; return 0; }
    done
    printf -- '-1'
}

find_slot_for() {
    local t="$1"
    for ((i = 0; i < VisibleSlots; i++)); do
        [[ "${slot_target[$i]}" == "$t" ]] && { printf '%d' "$i"; return 0; }
    done
    printf -- '-1'
}

# Print one "row" of content: tick column + padded info + state + newline.
# If tick is empty, the tick column is filled with spaces (used for STATUS lines).
print_row() {
    local tick="$1"
    local info="$2"
    local state="$3"
    if [[ -z "$tick" ]]; then
        printf "%${TickWidth}s " ""
    else
        printf "%${TickWidth}d " "$tick"
    fi
    printf "%-${LineWidth}s" "$info"
    printf "${state}\n"
}

# Increment the tick counter on every active slot. Called once per read-loop
# iteration (both on successful reads and on read timeouts) so stalled builds
# still age.
tick_all_active() {
    local i
    for ((i = 0; i < SlotCount; i++)); do
        if [[ -n "${slot_target[$i]}" ]]; then
            slot_tick[$i]=$(( ${slot_tick[$i]:-0} + 1 ))
        fi
    done
}

# Reserve the VisibleSlots+3 bottom lines and park cursor at "home"
# (one line below the footer). VisibleSlots starts at 0; slot rows are
# added on demand up to the SlotCount maximum.
init_block() {
    local i
    printf '%s\n' "$sep_eq"
    for ((i = 0; i < VisibleSlots; i++)); do printf '\n'; done
    printf '%s\n' "$sep_dash"
    printf 'Executing 0 Items Completed 0 Items.\n'
    initialized=1
}

# Grow the visible block by one slot row. Must be called with cursor at home.
# We print a blank line at home to reserve a new terminal line; the subsequent
# redraw_block (using the new VisibleSlots) then repaints from the ==== line
# down and parks the cursor at the new home.
expand_block() {
    VisibleSlots=$(( VisibleSlots + 1 ))
    printf '\n'
}

# Draw the full bottom block starting from the top (==== line).
# Caller is responsible for positioning the cursor at the ==== line first.
draw_block_here() {
    local i
    printf '\e[2K%s\n' "$sep_eq"
    for ((i = 0; i < VisibleSlots; i++)); do
        printf '\e[2K'
        if [[ -n "${slot_target[$i]}" ]]; then
            print_row "${slot_tick[$i]:-0}" "${slot_info[$i]}" "${slot_state[$i]}"
        else
            printf '\n'
        fi
    done
    printf '\e[2K%s\n' "$sep_dash"
    printf '\e[2KExecuting %d Items Completed %d Items.\n' "$active_count" "$done_count"
}

# Redraw the block in place. Cursor starts and ends at home.
redraw_block() {
    printf '\e[%dA\r' $(( VisibleSlots + 3 ))
    draw_block_here
}

# Push a line into scrollback (above the ==== separator) and redraw the
# block below it. Cursor starts and ends at home.
# `tick` may be empty to leave the tick column blank (STATUS lines).
push_line_and_redraw() {
    local tick="$1"
    local info="$2"
    local state="$3"
    # Move up to the current ==== line.
    printf '\e[%dA\r' $(( VisibleSlots + 3 ))
    # Overwrite it with the completed/status line — this line then scrolls
    # into history as we redraw the block on the lines below.
    printf '\e[2K'
    print_row "$tick" "$info" "$state"
    # Cursor is now on what used to be slot 0. Redraw the block from here.
    draw_block_here
}

# ── Event loop ────────────────────────────────────────────────────────────────
# Open the FIFO read-write (O_RDWR) on fd 3.  This does not block (unlike a
# write-only open which waits for a reader, or a read-only open which waits
# for a writer).  Crucially, fd 3 keeps one write-end permanently open, so
# the reader never gets a spurious EOF between compile-job writes.
make_separators
exec 3<> "$PIPE"

while true; do
    if ! IFS= read -t 1 -r line <&3; then
        # read timed out — tick active slots so their age advances, then
        # check if make is still alive.
        tick_all_active
        (( initialized == 1 )) && redraw_block
        if [[ -n "$MAKE_PID" ]] && ! kill -0 "$MAKE_PID" 2>/dev/null; then
            break
        fi
        startupCountDown=$(( startupCountDown - 1 ))
        if [[ ${activeConnection} == 0 && ${startupCountDown} == 0 ]]; then
            # If the make script is stalled out then exit.
            break
        fi
        continue
    fi
    activeConnection=1
    tick_all_active
    IFS=':' lineArray=(${line})
    cmd="${lineArray[0]}"
    target="${lineArray[1]}"
    info="${lineArray[2]}"
    state="${lineArray[3]}"

    (( initialized == 0 )) && init_block

    case "$cmd" in
        START)
            slot=$(find_free_slot)
            if (( slot < 0 )); then
                if (( VisibleSlots < SlotCount )); then
                    expand_block
                    slot=$(( VisibleSlots - 1 ))
                else
                    slot=0   # hard cap reached: reuse slot 0
                fi
            fi
            slot_target[$slot]="$target"
            slot_info[$slot]="$info"
            slot_state[$slot]="$state"
            slot_tick[$slot]=0
            active_count=$(( active_count + 1 ))
            redraw_block
            ;;
        UPDATE)
            slot=$(find_slot_for "$target")
            if (( slot >= 0 )); then
                slot_info[$slot]="$info"
                slot_state[$slot]="$state"
                redraw_block
            fi
            ;;
        DONE)
            slot=$(find_slot_for "$target")
            final_tick=0
            if (( slot >= 0 )); then
                final_tick="${slot_tick[$slot]:-0}"
                slot_target[$slot]=""
                slot_info[$slot]=""
                slot_state[$slot]=""
                slot_tick[$slot]=0
                active_count=$(( active_count - 1 ))
                done_count=$(( done_count + 1 ))
            fi
            push_line_and_redraw "$final_tick" "$info" "$state"
            ;;
        STATUS)
            push_line_and_redraw "" "$info" "$state"
            ;;
        EXIT)
            break
            ;;
    esac
done
echo
