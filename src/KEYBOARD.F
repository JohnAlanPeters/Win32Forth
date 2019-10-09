\ $Id: KEYBOARD.F,v 1.3 2013/04/22 19:53:53 georgeahubert Exp $
\ KEYBOARD.F            functon key constants           by Tom Zimmer

  cr .( Loading Function Key Words...)

in-system

\ ' CONSTANT alias LITKEY     \ made a colon def - [cdo-2008May13]
: litkey        ( -- n )
                constant ;

in-application

0x1B litkey K_ESC       0x09 litkey K_TAB       0x08 litkey K_BACKSPACE
0x0D litkey K_CR        0x0A litkey K_LF

in-system

: fkey          ( n1 -<name>- )
                function_mask or constant ;

in-application

0x01 fkey K-F1          0x02 fkey K-F2          0x03 fkey K-F3
0x04 fkey K-F4          0x05 fkey K-F5          0x06 fkey K-F6
0x07 fkey K-F7          0x08 fkey K-F8          0x09 fkey K-F9
0x10 fkey K-F10         0x11 fkey K-F11         0x12 fkey K-F12

SYNONYM K_F1  K-F1
SYNONYM K_F2  K-F2
SYNONYM K_F3  K-F3
SYNONYM K_F4  K-F4
SYNONYM K_F5  K-F5
SYNONYM K_F6  K-F6
SYNONYM K_F7  K-F7
SYNONYM K_F8  K-F8
SYNONYM K_F9  K-F9
SYNONYM K_F10 K-F10
SYNONYM K_F11 K-F11
SYNONYM K_F12 K-F12


in-system

: splkey        ( n2 -<name>- )
                special_mask or constant ;

in-application

0x00 splkey K-HOME      0x01 splkey K-END       0x02 splkey K-INSERT
0x03 splkey K-DELETE    0x04 splkey K-LEFT      0x05 splkey K-RIGHT
0x06 splkey K-UP        0x07 splkey K-DOWN      0x08 splkey K-SCROLL
0x09 splkey K-PAUSE     0x10 splkey K-PRIOR     0x11 splkey K-NEXT


SYNONYM K_HOME   K-HOME
SYNONYM K_END    K-END
SYNONYM K_INSERT K-INSERT
SYNONYM K_DELETE K-DELETE
SYNONYM K_LEFT   K-LEFT
SYNONYM K_RIGHT  K-RIGHT
SYNONYM K_UP     K-UP
SYNONYM K_DOWN   K-DOWN
SYNONYM K_SCROLL K-SCROLL
SYNONYM K_PAUSE  K-PAUSE
SYNONYM K_PGDN   K-NEXT
SYNONYM K_PGUP   K-PRIOR


: +K_SHIFT      ( c1 -- c2 )  K-SHIFT-MASK or ;   \ add in shift bit
\ 07/18/95 08:56 tjz ALT keys are for Windows Use ONLY!"
: +K_ALT        ( c1 -- c2 )    K-ALT-MASK or ;   \ add in the Alt bit

: +K_CONTROL    ( c1 -- c2 )
                dup proc_mask 0x7FF or and upc 'A' 'Z' between
                if      0xFF1F and              \ handle control letters
                else    K-CTRL-MASK or         \ add in control bit
                then    ;

\S

\ The above words are used as shown in the following example:



: key_test      ( -- )
        begin   cr ." Press a key, Enter to stop: "
                key
        case    k_f1            of      ."  F1"                 endof
                k_f2            of      ."  F2"                 endof
                k_f3            of      ."  F3"                 endof
                k_f4            of      ."  F4"                 endof
                k_f5            of      ."  F5"                 endof
                k_f6            of      ."  F6"                 endof
                k_f7            of      ."  F7"                 endof
                k_f8            of      ."  F8"                 endof
                k_f9            of      ."  F9"                 endof
                k_f10           of      ."  F10"                endof
                k_f11           of      ."  F11"                endof
                k_f12           of      ."  F12"                endof
                k_f1 +k_control of      ."  Control F1"         endof
                k_f2 +k_control of      ."  Control F1"         endof
                k_f3 +k_control of      ."  Control F1"         endof
                k_f4 +k_control of      ."  Control F1"         endof
                k_f5 +k_control of      ."  Control F1"         endof
                k_f6 +k_control of      ."  Control F1"         endof
                k_f7 +k_control of      ."  Control F1"         endof
                k_f8 +k_control of      ."  Control F1"         endof
                k_f9 +k_control of      ."  Control F1"         endof
               k_f10 +k_control of      ."  Control F10"        endof
               k_f11 +k_control of      ."  Control F11"        endof
               k_f12 +k_control of      ."  Control F12"        endof
                k_f1 +k_shift   of      ."  Shift F1"           endof
                k_f2 +k_shift   of      ."  Shift F1"           endof
                k_f3 +k_shift   of      ."  Shift F1"           endof
                k_f4 +k_shift   of      ."  Shift F1"           endof
                k_f5 +k_shift   of      ."  Shift F1"           endof
                k_f6 +k_shift   of      ."  Shift F1"           endof
                k_f7 +k_shift   of      ."  Shift F1"           endof
                k_f8 +k_shift   of      ."  Shift F1"           endof
                k_f9 +k_shift   of      ."  Shift F1"           endof
               k_f10 +k_shift   of      ."  Shift F10"          endof
               k_f11 +k_shift   of      ."  Shift F11"          endof
               k_f12 +k_shift   of      ."  Shift F12"          endof
                          0x0D  of      ." Stopping" exit       endof
                                        dup h.
                                        ." Unknown key"
        endcase ."  pressed."
        again   ;



