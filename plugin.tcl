set plugin_name "step_weight_control"

namespace eval ::plugins::step_weight_control {
    variable author "Ed Hyun"
    variable contact "Via Diaspora"
    variable version 1.0
    variable name "Step Weight Control"
    variable description "Customize step weight adjusment"

    proc main {} {
        if {[string match "v1.39.0*" $::app::version_string] == 0} {
            return
        } else {
            msg "Using step weight adj customizer (::vertical_clicker has been overwritten)"
        }

        proc ::vertical_clicker {bigincrement smallincrement varname minval maxval x y x0 y0 x1 y1 {b 0} } {
            if {$varname == "::current_adv_step(weight)"} {
                set bigincrement $::plugins::step_weight_control::settings(big_increment)
                set smallincrement $::plugins::step_weight_control::settings(small_increment)
            }

            # b = which button was tapped

            set x [translate_coordinates_finger_down_x $x]
            set y [translate_coordinates_finger_down_y $y]

            set yrange [expr {$y1 - $y0}]
            set yoffset [expr {$y - $y0}]

            set midpoint [expr {$y0 + ($yrange / 2)}]
            set onequarterpoint [expr {$y0 + ($yrange / 4)}]
            set threequarterpoint [expr {$y1 - ($yrange / 4)}]

            set onethirdpoint [expr {$y0 + ($yrange / 3)}]
            set twothirdpoint [expr {$y1 - ($yrange / 3)}]

            if {[info exists $varname] != 1} {
                # if the variable doesn't yet exist, initialize it with a zero value
                set $varname 0
            }
            set currentval [subst \$$varname]
            set newval $currentval

            # check for a fast double tap
            set b 0
            if {[is_fast_double_tap $varname] == 1} {
                #set the button to 3, which is the same as a long press, or middle button (ie button 3) on a mouse
                set b 3
            }

            if {$y < $onethirdpoint} {
                if {$b == 3} {
                    set newval [expr "1.0 * \$$varname + $bigincrement"]
                } else {
                    set newval [expr "1.0 * \$$varname + $smallincrement"]
                }
            } elseif {$y > $twothirdpoint} {
                if {$b == 3} {
                    set newval [expr "1.0 * \$$varname - $bigincrement"]
                } else {
                    set newval [expr "1.0 * \$$varname - $smallincrement"]
                }
            }

            set newval [round_to_two_digits $newval]

            if {$newval > $maxval} {
                set $varname $maxval
            } elseif {$newval < $minval} {
                set $varname $minval
            } else {
                set $varname [round_to_two_digits $newval]
            }

            update_onscreen_variables
            return
        }
    }
}