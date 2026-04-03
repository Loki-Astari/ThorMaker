#!/usr/bin/env bash
# build-monitor.sh  <pipe-path> <num-slots>
#
# Reads START:<target>, OK:<target>, FAIL:<target>, EXIT from the named pipe
# and keeps SlotCount "slot" lines updated in the terminal.
#
# Layout (n=3 slots):
#   [slot 0] foo.o                                    building...
#   [slot 1] bar.o                                    OK
#   [slot 2] baz.o                                    FAIL
#   <cursor lives here — one line below the last slot>
#
# Cursor arithmetic: to reach slot s, move up (n - s) lines; to return, move
# down the same amount.  All output is serialised through this single process
# so there are no interleaving writes to the terminal.

PIPE="${1:?pipe path required}"
SlotCount="${2:-8}"
LineWidth="${3:-80}"
MAKE_PID="${4:-}"
SlotsUsed=0

declare -a slot_target   # slot_target[i] = target currently in slot i, or ""

# ── Reserve SlotCount lines in the terminal ──────────────────────────────────────────
# for ((i = 0; i < SlotCount; i++)); do printf '\n'; done

# ── Helpers ───────────────────────────────────────────────────────────────────
find_free_slot() {
    for ((i = 0; i < SlotCount; i++)); do
        [[ -z "${slot_target[$i]}" ]] && { printf '%d' "$i"; return 0; }
    done
    printf '0'   # fallback: reuse slot 0
}

find_slot_for() {
    local t="$1"
    for ((i = 0; i < SlotCount; i++)); do
        [[ "${slot_target[$i]}" == "$t" ]] && { printf '%d' "$i"; return 0; }
    done
    printf '-1'
}

renderOutput() {
    local info="$1"
    local state="$2"

    # print the main message with a set width
    # So the following state information lines up correctly.
    printf "%-${LineWidth}s" "${info}"
    # This will make sure we print any escaped colour codes.
    printf "${state}\n"

}
render() {
    local slot="$1"
    local info="$2"
    local state="$3"

    for ((i = SlotsUsed; i < slot; i++)) do printf '\n'; SlotsUsed=$(( SlotsUsed + 1 )); done

    local up=$(( SlotsUsed - slot + 1 ))

# Move to the slot line, erase it, print new content, return.
    printf '\e[%dA\r\e[2K' "$up"

    renderOutput "${info}" "${state}"

    printf '\e[%dB\r' "$up"
}

# ── Event loop ────────────────────────────────────────────────────────────────
# Open the FIFO read-write (O_RDWR) on fd 3.  This does not block (unlike a
# write-only open which waits for a reader, or a read-only open which waits
# for a writer).  Crucially, fd 3 keeps one write-end permanently open, so
# the reader never gets a spurious EOF between compile-job writes.
exec 3<> "$PIPE"

# Poll make's PID to detect if it dies (e.g. Ctrl-C).
# In non-interactive shells, & causes SIGINT to be ignored, so the
# monitor won't be killed by Ctrl-C directly — we must poll instead.

while true; do
    if ! IFS= read -t 5 -r line <&3; then
        # read timed out — check if make is still alive
        if [[ -n "$MAKE_PID" ]] && ! kill -0 "$MAKE_PID" 2>/dev/null; then
            break
        fi
        continue
    fi
    IFS=':' lineArray=(${line})
    cmd="${lineArray[0]}"
    target="${lineArray[1]}"
    info="${lineArray[2]}"
    state="${lineArray[3]}"

    case "$cmd" in
        START)
            slot=$(find_free_slot)
            slot_target[$slot]="$target"
            render "$slot" "${info}" "${state}"
            ;;
        UPDATE)
            slot=$(find_slot_for "$target")
            if (( slot >= 0 )); then
                render "$slot" "${info}" "${state}"
            fi
            ;;
        DONE)
            slot=$(find_slot_for "$target")
            if (( slot >= 0 )); then
                render "$slot" "$info" "${state}"
                slot_target[$slot]=""
            fi
            ;;
        STATUS)
            SlotCount=$(( SlotCount + 1 ))
            renderOutput "${info}" "${state}"
            ;;
        EXIT)
            break
            ;;
    esac
done
