#!/usr/bin/env bash
# build-monitor.sh  <pipe-path> <num-slots>
#
# Reads START:<target>, OK:<target>, FAIL:<target>, EXIT from the named pipe
# and keeps N "slot" lines updated in the terminal.
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
N="${2:-8}"

declare -a slot_target   # slot_target[i] = target currently in slot i, or ""

# ── Reserve N lines in the terminal ──────────────────────────────────────────
for ((i = 0; i < N; i++)); do printf '\n'; done

# ── Helpers ───────────────────────────────────────────────────────────────────
find_free_slot() {
    for ((i = 0; i < N; i++)); do
        [[ -z "${slot_target[$i]}" ]] && { printf '%d' "$i"; return 0; }
    done
    printf '0'   # fallback: reuse slot 0
}

find_slot_for() {
    local t="$1"
    for ((i = 0; i < N; i++)); do
        [[ "${slot_target[$i]}" == "$t" ]] && { printf '%d' "$i"; return 0; }
    done
    printf '-1'
}

render() {
    local slot="$1"
    local format="$2"
    local info="$3"
    local state="$4"
    local up=$(( N - slot ))

    # Move to the slot line, erase it, print new content, return.
    printf '\e[%dA\r\e[2K' "$up"
    printf "${format}" "${info}" "${state}"
#    case "$state" in
#        building) printf '  %-50s building...'        "$target" ;;
#        ok)       printf '  %-50s \e[32mOK\e[0m'     "$target" ;;
#        fail)     printf '  %-50s \e[31mFAIL\e[0m'   "$target" ;;
#    esac
    printf '\e[%dB\r' "$up"
}

# ── Event loop ────────────────────────────────────────────────────────────────
# Open the FIFO read-write (O_RDWR) on fd 3.  This does not block (unlike a
# write-only open which waits for a reader, or a read-only open which waits
# for a writer).  Crucially, fd 3 keeps one write-end permanently open, so
# the reader never gets a spurious EOF between compile-job writes.
exec 3<> "$PIPE"

while IFS= read -r line <&3; do
    IFS=':' lineArray=(${line})
    cmd="${lineArray[0]}"
    format="${lineArray[1]}"
    target="${lineArray[2]}"
    info="${lineArray[3]}"
    state="${lineArray[4]}"

    case "$cmd" in
        START)
            slot=$(find_free_slot)
            slot_target[$slot]="$target"
            render "$slot" "${format}" "${info}" "${state}"
            ;;
        OK)
            slot=$(find_slot_for "$target")
            if (( slot >= 0 )); then
                render "$slot" "${format}" "${info}" "${state}"
                slot_target[$slot]=""   # free slot; line stays visible until reused
            fi
            ;;
        FAIL)
            slot=$(find_slot_for "$target")
            if (( slot >= 0 )); then
                render "$slot" "${format}" "$info" "${state}"
                slot_target[$slot]=""
            fi
            ;;
        EXIT)
            break
            ;;
    esac
done
