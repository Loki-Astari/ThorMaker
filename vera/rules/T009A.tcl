#!/usr/bin/tclsh
# Comma should not be preceded by whitespace, but should be followed by one

foreach f [getSourceFileNames] {
    foreach t [getTokens $f 1 0 -1 -1 {comma}] {
        set line [lindex $t 1]
        set column [lindex $t 2]
        set preceding [getTokens $f $line 0 $line $column {}]
        if {$preceding == {}} {
            report $f $line "XX comma should not be preceded by whitespace"
        } else {
            set lastValue     [lindex [lindex $preceding end] 0]
            set lastPreceding [lindex [lindex $preceding end] 3]
            set colOfComma    [lindex $t 2]
            if {$lastPreceding == "space"} {
                if {[string length $lastValue] != $colOfComma} {
                    report $f $line "comma should not be preceded by whitespace"
                }
            }
        }
        set following [getTokens $f $line [expr $column + 1] [expr $line + 1] -1 {}]
        if {$following != {}} {
            set firstFollowing [lindex [lindex $following 0] 3]
            if {$firstFollowing != "space" && $firstFollowing != "newline" &&
                !($lastPreceding == "operator" && $firstFollowing == "leftparen")} {
                report $f $line "comma should be followed by whitespace"
            }
        }
    }
}
