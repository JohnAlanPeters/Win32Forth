\ $Id: CONTROL.F,v 1.16 2013/12/09 21:25:16 georgeahubert Exp $

\ *D doc\classes\
\ *! Control
\ *T Control -- Class for child controls with subclassing.

Require WinMsg.f

cr .( Loading Control Window...)

\ child controls with subclassing

DEFER SUBCLASS-WNDPROC :NONAME 4DROP 0 ; IS SUBCLASS-WNDPROC

NCODE SUBCLASS-RETURN
                CODE-HERE CELL+ CODE-,          \ itc
                mov     eax, ebx                \ C return value
                mov     esp, ebp                \ restore stack
                pop     ebp                     \ restore registers
                pop     ebx
                pop     edi
                pop     esi
                ret     # 4 CELLS               \ return & discard params
                c;

CFA-CODE SUBCLASS-ENTRY  ( lparam wparam message hwnd -- result )
                push    esi                     \ save registers
                push    edi
                push    ebx
                push    ebp
                mov     ebx, ecx                \ address of object
                mov     ebp, esp                \ make forth stacks
                sub     esp, # 4000             \ room for return stack
                push    5 CELLS [ebp]           \ hwnd
                push    6 CELLS [ebp]           \ message
                push    7 CELLS [ebp]           \ wparam
                push    8 CELLS [ebp]           \ lparam
                xor     edi, edi                \ EDI is constant 0
                mov     edx, fs: 0x14           \ edx is now ptr from TIB pvArbitrary
                mov     esi, # ' SUBCLASS-RETURN
                mov     eax, # ' SUBCLASS-WNDPROC
                exec    c;

: CallWindowProc  ( hwnd msg wparam lparam wndproc -- result )
        >r 4reverse r> Call CallWindowProc ;


\ -------------------- Control Class --------------------

\ Support for displaying tool tips; used by the oldstyle buttonbars (e.g. in WinEd).
\ Since we have a much better toolbar class in Win32Forth for some time now, I
\ (dbu) didn't spend the time to see how this works. And so I didn't document it.

INTERNAL        \ definitions accessible while defining a buttonbar

0 value &binfo                  \ pointer to latest defined button
     create &ButtonRect  4 cells allot  \ temp rectangle for current info msg
            &ButtonRect  4 cells erase
255 constant max-binfo          \ longest info message allowed

: ButtonInfo"   ( -- )          \ set the info for latest button or control
                &binfo 0= abort" Must follow a button definition"
                '"' word count max-binfo min &binfo place
                &binfo count \n->crlf ;

EXTERNAL        \ definitions always accessible

TRUE  value info-flag           \ are we displaying tool tips
FALSE value mouse-is-down?

: in-button?    { x y hWnd -- f1 }
                &ButtonRect hWnd Call GetClientRect drop
                y &ButtonRect 1 cells+ @ \ 2 +   \ top
                  &ButtonRect 3 cells+ @ \ 2 -   \ bottom
                between
                x &ButtonRect          @ \ 2 +   \ left
                  &ButtonRect 2 cells+ @ \ 2 -   \ right
                between and ;

in-system

\ *W <a name="Control"></a>
\ *S Generic Control class
|Class Control          <Super Generic-Window
\ *G Generic control class. \n
\ ** Since Control is a generic class it should not be used to create
\ ** any instances.

in-previous

\ The following definition must directly precede old-wndproc to work correctly
code (old-wndproc) ( ^control -- old-wndproc ) \ address of old window prodedure
     add ebx, # ^class DFA @
     mov ebx, [ebx]
     next
     ;c
int old-wndproc         \ address of old window procedure
int parent              \ address of parent object
int id                  \ the control's ID
int title               \ the counted title string
int handleofparent      \ the frame window handle
short Horizontal
short Vertical
' wStatus0 alias timering?           \ are we opening a popup info window
' wStatus1 alias timerclosed?        \ has popup been closed
' wStatus2 alias auto-close?         \ does info window automatically close after a time?
int style
max-binfo 1+ bytes binfo

32768 value unique-id#

: unique-id     ( -- id )       \ get a unique initial ID for this control
                unique-id#
                1 +to unique-id# ;

\ -------------------- Subclassed Window Procedure --------------------

: _subclass-WndProc   ( hwnd msg wparam lparam window -- res )
        3 pick ( msg ) over obj>class MFA ((findm))
        if      sp0 @ >r sp@ 4 cells+ sp0 !
                dup>r catch
                ?dup
                if      r@ WndProcError
                then    rdrop
                r> sp0 !
        else
                (old-wndproc) CallWindowProc
        then ;

' _subclass-WndProc is subclass-WndProc

\ -------------------- SubClassing --------------------

: subclass      ( -- )
                (controllock)
                code-here                        \ for SetWindowLong to pick up
                0xC790 code-w, 0xC1 code-c, self code-,      \ nop  mov ecx, # object
                0xE9 code-c, SUBCLASS-ENTRY code-here CELL+ - code-, \ jmp (long) SUBCLASS-ENTRY
                (controlunlock)
                GWL_WNDPROC hWnd Call SetWindowLong to old-wndproc \ set
                ;

:M ClassInit:   ( -- )
                ClassInit: super
                0 to parent
                0 to handleofparent
                0 to old-wndproc
                0 to style
                unique-id to id
                z" " to title
                binfo off
                binfo to &binfo                 \ so we can set it later
                FALSE to timering?
                FALSE to timerclosed?
                TRUE  to auto-close?
                ;M

:M GetParent:   ( -- parent )
\ *G Get the parent window of this control.
                parent ;M

:M GetHandleOfParent: ( -- handleofparent )
\ *G Get the window handle of the parent window of this control.
                handleofparent ;M

:M SetID:       ( id -- )
\ *G Set the ID of this control. Normaly you don't need to do this, because
\ ** every control get's an unique ID when it's created.
                to id ;M

:M GetID:       ( -- id )
\ *G Get the ID of this control
                id ;M

:M ExWindowStyle: ( -- exstyle )
\ *G Get the extended window style of this control
                0 ;M

:M WindowStyle: ( -- style )
\ *G Get the window style of this control
                [ WS_CHILD WS_VISIBLE or ] literal style or ;M

:M AddStyle:    ( n -- )
\ *G Set any additional style of the control. Must be done before the control
\ ** is started. Use +Style: to add to a running control.
                to style ;M

:M StartSize:   ( -- width height )
\ *G Get the start size of this control. \n
\ ** Override this method to change it.
                0  0 ;M      \

:M StartPos:    ( -- left top )
\ *G Get the start position of this control. \n
\ ** Override this method to change it.
                0  0 ;M

:M AutoSize:    ( -- )
\ *G Size the window to fit into the client area of the parent window.
                winRect GetClientRect: Parent
                0 0 Right: winRect Bottom: winRect   \ x,y,h,w
                Move: self
                ;M

:M CreateStruct: ( -- CreateStrucPointer )
\ *G This pointer to a structure, depends on what kind of window you are
\ ** creating, so we just default it to NULL.
                NULL ;M

: create-control  ( z"classname" -- )
                >r
                CreateStruct: [ self ]          \ override if needed
                appInst
                ID
                GetHandle: Parent dup to handleofparent
                StartSize:     [ self ] swap    \ height, width
                StartPos:      [ self ] swap    \ y, x starting position
                WindowStyle:   [ self ]         \ you can override these
                title 1+                        \ the control's text
                r>                              \ the class name zstring
                ExWindowStyle: [ self ]         \ the extended window style
                Call CreateWindowEx to hWnd
                hWnd
                if      subclass
                then
                ;

\ Support for displaying tool tips; used by the oldstyle buttonbars (e.g. in WinEd).
\ Since we have a much better toolbar class in Win32Forth for some time now, I
\ (dbu) didn't spend the time to see how this works. And so I didn't document it.

1 constant INFO_START_TIMER              \ timer constant
2 constant INFO_END_TIMER                \ timer constant
3 constant INFO_CLOSE_TIMER              \ timer constant

: clear-info    ( -- )
                INFO_START_TIMER hWnd Call KillTimer drop
                INFO_END_TIMER   hWnd Call KillTimer drop
                INFO_CLOSE_TIMER hWnd Call KillTimer drop
                FALSE to timering?
                FALSE to timerclosed?
                Close: InfoWindow ;

:M BInfo:       ( -- a1 )       \ return the counted string of button info
                binfo ;M

:M SetAutoClose: ( flag -- )    \ set the state of the automatic info close feature
                to auto-close? ;M

:M GetAutoClose: ( -- flag )
                auto-close? 0<> ;M

:M WM_TIMER     ( h m w l -- res )
                hWnd get-mouse-xy to Vertical to Horizontal
                over INFO_START_TIMER =
                mouse-is-down? 0= and
                IF      INFO_START_TIMER hWnd Call KillTimer drop
                        Horizontal Vertical hWnd in-button?   \ if timer and still on button
                        timering? and
                        IF      1 to timering?
                                BInfo: [ self ]
                                &ButtonRect hWnd Call GetWindowRect drop
                                &ButtonRect       @ Horizontal +
                                &ButtonRect cell+ @ Vertical   + 25 +
                                Start: InfoWindow
                                NULL  100 INFO_END_TIMER   hWnd Call SetTimer drop
                                GetAutoClose: [ self ]
                                IF      NULL 4000 INFO_CLOSE_TIMER hWnd Call SetTimer drop
                                THEN
                        ELSE    FALSE to timering?
                        THEN
                THEN
                over INFO_END_TIMER =
                IF      Horizontal Vertical hWnd in-button? 0=
                        IF      INFO_END_TIMER   hWnd Call KillTimer drop
                                INFO_CLOSE_TIMER hWnd Call KillTimer drop
                                FALSE to timering?
                                Close: InfoWindow
                                FALSE to timerclosed?
                        THEN
                THEN
                over INFO_CLOSE_TIMER =
                IF      INFO_CLOSE_TIMER hWnd Call KillTimer drop
                        FALSE to timering?
                        TRUE  to timerclosed?
                        Close: InfoWindow
                THEN
                0 ;M

:M amForground?: ( -- f1 )
                TRUE ;M

:M On_MouseMove: ( h m w -- )
                info-flag                       \ are we displaying tool tips?
                BInfo: [ self ] c@ and          \ and there is text to display
                IF      hWnd get-mouse-xy hWnd in-button?       \ in the button
                        amForground?: [ self ] and              \ and the forground window
                        mouse-is-down? 0= and                   \ and mouse isn't down
                        IF      timering? 1 <                   \ if timering? is 0 or -1
                                timerclosed? 0= and
                                IF
                                        TRUE to timering?
                                        NULL
                                        700 INFO_START_TIMER
                                        hWnd Call SetTimer drop
                                THEN
                        ELSE    clear-info
                        THEN
                THEN
                0 ;M

:M WM_MOUSEMOVE { h m w l -- res }
                l word-split to Vertical  to Horizontal
                h m w On_MouseMove: [ self ]
                old-WndProc
                IF      h m w l old-WndProc CallWindowProc
                THEN
                ;M

:M ToolString:  ( addr cnt -- )
                binfo place
                binfo count \n->crlf
                ;M

:M WM_DESTROY
                On_Done: [ self ]
                old-wndproc CallWindowProc
                0 to hWnd
                ;M

:M Enable:      ( f -- )
\ *G Enable the control.
                ID EnableDlgItem: parent ;M

:M Disable:     ( -- )
\ *G Disable the control.
                false Enable: self ;M

;Class
\ *G End of Control class

module

\ *Z
