\ $Id: Menu.f,v 1.10 2013/03/08 20:43:04 georgeahubert Exp $
\ MENU.F                Menu objects                    by Tom Zimmer
\ menu.f beta 2002/11/05 ron Added support for multiple instances capability

cr .( Loading Window Menus...)

\ Menu class

only forth also definitions

needs GdiTools

INTERNAL        \ internal definitions start here

: menu-append  ( hmenu flags id string -- )
        4reverse
        Call AppendMenu ?win-error ;

: _execute-menufunc ( cfa -- )
                execute ;

defer execute-menufunc
   ' _execute-menufunc is execute-menufunc

in-system

0 value BuildMenu

in-application

VARIABLE menubar-link
         menubar-link OFF

EXTERNAL

200 constant IdStart
IdStart value IdCounter

: NextId        ( -- bid )
                IdCounter dup 1+ to IdCounter ;

INTERNAL

in-system

: ENDBAR        ( -- )          \ finish defining a menubar
                context @ ['] hidden vcfa>voc =
                if      previous
                then    ;

in-application

EXTERNAL        \ externally available definitions start here

:CLASS MENUBAR  <Super Object   \ start defining a menubar

\ hmb   ->      menu
\ mb            used for menu bar traversal

int hmb         \ head pointer of the menubar's menu list
int mb          \ temporary variable used for menubar traversal
int hmenu       \ handle to the menubar
int prevbar
int parent      \ the parent window

in-system

: trim-menus   ( nfa -- nfa )
               dup menubar-link full-trim ;

forget-chain chain-add trim-menus

: (ClassInit:)  ( -- )
                self to BuildMenu
                0    to hmb
                0    to hmenu
                menubar-link link,      \ link into list
                self ,
                also hidden ;           \ also search the menus vocabulary

in-application

:M ClassInit:   ( -- )
\in-system-ok   (ClassInit:) ;M

:M GetBar:      ( -- hmb )
                hmb  ;M

:M PutBar:      ( hmb -- )
                to hmb  ;M

:M MenuHandle:  ( -- hmenu )
                hmenu ;M

:M ReDrawMenu:  ( -- )
                conhndl parent =
                if      conhndl
                else    GetHandle: parent
                then    Call DrawMenuBar drop
                ;M

:M PosEnable:   ( flag pos -- )
                swap
                if      [ MF_ENABLED MF_BYPOSITION or ] literal
                else    [ MF_GRAYED  MF_BYPOSITION or ] literal
                then     swap hmenu Call EnableMenuItem drop
                ReDrawMenu: self
                ;M

:M CurrentId:   ( -- bid )
                IdCounter
                ;M

:M LoadMenu:    ( parent -- )
                to parent
                Call CreateMenu to hmenu
                hmb to mb
                begin   mb
                while   hmenu parent LoadMenu: mb
                               GetPrev: mb to mb
                repeat   ;M

:M Start:       ( parent -- )
                LoadMenu: self
                hmenu -1 <>
                if      hmenu SetMenu: parent
                then
                ;M

:M DoMenu:      ( ID -- )       \ called from a WINDOW
                mb >r           \ save in case we are reentered while running
                hmb to mb
                begin   mb
                while   dup DoMenu: mb
                           GetPrev: mb to mb
                repeat  drop
                r> to mb
                ;M

:M CloseMenu:   ( -- )
                ;M

:M ZeroMenu:    ( -- )
                0 to hmenu
                ;M

;CLASS

:CLASS POPUPBAR <Super MENUBAR

:M Start:       ( parent -- )
                LoadMenu: self
                ;M

:M Track:       { win-handle | point -- }
                2 cells localalloc: point swap point 2!
                hmenu -1 <>
                if      0
                        hmenu
                        Call GetSubMenu >r
                        point           \ ClientToScreen begin here
                        win-handle      \ convert relative to absolute coords
                        Call ClientToScreen drop
                        0               \ TrackPopupMenu begin here
                        win-handle
                        0
                        point 2@        \ recover absolute screen coordinates
                        [ TPM_LEFTALIGN TPM_RIGHTBUTTON or ] literal
                        r>
                        Call TrackPopupMenu drop
                then
                ;M

;CLASS

INTERNAL

0 value BuildPopup
0 value BREAK_FLAG

: BREAKPOPUP    ( -- )  \ make the next POPUP break on a new line
                MF_MENUBARBREAK to BREAK_FLAG ;

|Class POPUP    <Super  Object

int pprev
int popid
int pid
int mid
int hpm     \ handle for the popup menu head pointer
int pm      \ temp for popup menu list processing
int ptext
int BROKEN_FLAG
int parent

:M GetPopup:    ( -- hpm )  hpm  ;M
:M PutPopup:    ( hpm -- )  to hpm  ;M

:M SetPrev:     ( pprev -- ) to pprev ;M
:M GetPrev:     ( -- pprev ) pprev ;M

in-system

: (ClassInit)   ( -- )
                   self to BuildPopup
                   GetBar: BuildMenu to pprev           \ end of link is NULL
                pprev 0=                                \ if i'm the first one
                if      self PutBar: BuildMenu          \ put me in the bar
                else    begin   pprev
                        while   pprev to pid            \ save here temp
                                GetPrev: pprev to pprev
                        repeat  self SetPrev: pid       \ temp use
                        0 SetPrev: self
                then
                here to ptext ,"text"
                0 to popid
                BREAK_FLAG to BROKEN_FLAG
                0 to BREAK_FLAG
                ;

in-application

\in-system-ok :M ClassInit: (ClassInit) ;M

:M LoadMenu:    ( mb parent -- )
                to parent
                >r
                Call CreatePopupMenu to pid
                hpm to pm
                begin   pm
                while   pid parent LoadMenu: pm
                                    GetPrev: pm to pm
                repeat
                r@ to popid
                r> MF_POPUP BROKEN_FLAG or pid ptext 1+ menu-append
                ;M

:M DoMenu:      ( ID -- )
                pm >r           \ save in case we are reentered while running
                hpm to pm
                begin   pm
                while   dup DoMenu: pm
                           GetPrev: pm to pm
                repeat  drop
                r> to pm
                ;M

;Class


|Class POPUPITEM <Super  POPUP

int mfunc       \ the menu function

in-system

warning off

: (ClassInit)   ( -- )
                [ warning on ]
                ClassInit: super
                NextId to mid
                :noname to mfunc
                !csp
                BREAK_FLAG to BROKEN_FLAG
                0 to BREAK_FLAG
                ;

in-application

\in-system-ok :M ClassInit: (ClassInit) ;M

:M LoadMenu:    ( mb parent -- )
                to parent
                >r
                Call CreatePopupMenu to pid
                hpm to pm
                begin   pm
                while   pid LoadMenu: pm
                             GetPrev: pm to pm
                repeat
                r@ to popid
\ this "menu-append" MUST use "mid" NOT "pid" to be selectable
                r> MF_STRING BROKEN_FLAG or mid ptext 1+ menu-append
                ;M

:M DoMenu:      ( IDM -- )
                mid =
                if      mfunc execute-menufunc
                then    ;M

;Class

|Class SYSPOPUP  <Super  Object

int pprev
int popid
int pid
int mid
int hpm     \ handle for the popup menu head pointer
int pm      \ temp for popup menu list processing
int parent
cell bytes &anull

:M GetPopup:    ( -- hpm )  hpm  ;M
:M PutPopup:    ( hpm -- )  to hpm  ;M

:M SetPrev:     ( pprev -- ) to pprev ;M
:M GetPrev:     ( -- pprev ) pprev ;M

in-system

: (ClassInit)   ( -- )
                0 &anull !
                self to BuildPopup
                GetBar: BuildMenu to pprev      \ end of link is NULL
                pprev 0=                        \ if i'm the first one
                if      self PutBar: BuildMenu  \ put me in the bar
                else    begin   pprev
                        while   pprev to pid            \ save here temp
                                GetPrev: pprev to pprev
                        repeat  self SetPrev: pid       \ temp use
                        0 SetPrev: self
                then
                0 to popid
                0 to BREAK_FLAG
                ;

in-application

\in-system-ok :M ClassInit: (ClassInit) ;M

:M LoadMenu:    ( mb parent -- )
                to parent
                >r
                conhndl parent =
        if      conhndl
        else    GetHandle: parent
        then    true  over Call GetSystemMenu drop   \ reset sysmenu
                false swap Call GetSystemMenu to pid \ get handle
                hpm to pm
                begin   pm
                while   pid parent LoadMenu: pm
                                    GetPrev: pm to pm
                repeat
                r> to popid
                ;M

:M DoMenu:      ( ID -- )
                pm >r           \ save in case we are reentered while running
                hpm to pm
                begin   pm
                while   dup DoMenu: pm
                           GetPrev: pm to pm
                repeat  drop
                r> to pm
                ;M

;Class


0 value prevpop

|Class SUBMENU  <Super  POPUP

int subpopup

:M ClassInit:   ( -- )
                prevpop    to subpopup
                BuildPopup to prevpop
                GetPopup: BuildPopup to pprev           \ end of link is NULL
                pprev 0=                                \ if i'm the first one
                if      self PutPopup: BuildPopup       \ put me in the bar
                else    begin   pprev
                        while   pprev to pid            \ save here temp
                                GetPrev: pprev to pprev
                        repeat  self SetPrev: pid       \ temp use
                        0 SetPrev: self
                then
                NextId to mid
                here to ptext ,"text"
                self to BuildPopup
                ;M

:M UnSUBMENU:   ( -- )
                prevpop to BuildPopup
                subpopup to prevpop
                0 to subpopup
                ;M

;Class

in-system

: ENDSUBMENU    ( -- )
                UnSUBMENU: BuildPopup ;


\ MENUBAR SampleMenuBar
\       POPUP "&File"
\               MENUITEM "&Open"  'O' +k_control pushkey ;
\               MENUITEM "E&xit"  'X' +k_control pushkey ;

\ MENUITEMS is the generic class for containing the common code for it's
\ subclasses. DO NOT create any instances of it ( which wouldn't be a lot of use anyway )

:Class MENUITEMS <Super  Object

in-application

int mprev
int mid         \ menu ID and also used as a temp for PREV menu item
int mtext
int popid       \ handle of this items popup menu
int parent

:M SetPrev:     ( mprev -- ) to mprev ;M
:M GetPrev:     ( -- mprev ) mprev ;M

in-system

: (ClassInit)   ( -- )
                GetPopup: BuildPopup to mprev           \ end of link is NULL
                mprev 0=                                \ if i'm the first one
                if      self PutPopup: BuildPopup       \ put me in the bar
                else    begin   mprev
                        while   mprev to mid            \ save here temp
                                GetPrev: mprev to mprev
                        repeat  self SetPrev: mid       \ temp use
                        0 SetPrev: self
                then
                NextId to mid
                0 to mtext
                0 to popid
                ;

: m"text"       ( -<"text">- )
                here to mtext ,"text" ;

in-application

\in-system-ok :M ClassInit: (ClassInit) ;M


:M Check:       ( f1 -- )
                if      MF_CHECKED
                else    MF_UNCHECKED
                then    mid popid Call CheckMenuItem drop
                ;M

:M Enable:      ( f1 -- )
                if      MF_ENABLED
                else    [ MF_DISABLED MF_GRAYED or ] literal
                then    mid popid Call EnableMenuItem drop
                ;M

:M SetMenuText: ( z$ -- )
                mid
                [ MF_BYCOMMAND MF_STRING or ] literal
                mid popid Call ModifyMenu ?win-error
                ;M

:M LoadMenu:    ( pid parent -- )
                to parent
                mtext 0= abort" Empty Menu Text String"
                dup to popid
                MF_STRING mid mtext 1+ menu-append
                ;M

:M DoMenu:      ( IDM -- )
                drop ;M

;Class


|Class MENUSEPARATOR <Super  MENUITEMS

:M LoadMenu:    ( pid parent -- )
                to parent
                dup to popid
                MF_SEPARATOR 0 0 menu-append
                ;M

;Class

\ MENUBAR SampleMenuBar
\       POPUP "&File"
\               MENULINE "&Open" "BYE"

|Class MENULINE <Super  MENUITEMS

:M ClassInit:   ( -- )
                ClassInit: super
\in-system-ok   m"text" ,"text"
                ;M

:M DoMenu:      ( IDM -- )
                mid =
                if      mtext count + 1+ count bounds
                        do      i c@ pushkey
                        loop    13 pushkey
                then    ;M

;Class

|Class MENUMESSAGE  <Super  MENUITEMS

int check_flag

:M ClassInit:   ( check_flag -- )
                ClassInit: super
\in-system-ok   m"text"
                to check_flag
                ;M

:M LoadMenu:    ( pid parent -- )
                to parent
                [ MF_STRING MF_GRAYED or ] literal
                check_flag
                if      MF_CHECKED or
                then    mid mtext 1+ menu-append
                ;M

;Class

\ MENUBAR SampleMenuBar
\       POPUP "&File"
\               MENUITEM "&Open"  'O' +k_control pushkey ;
\               MENUITEM "E&xit"  'X' +k_control pushkey ;

|Class MENUITEM <Super  MENUITEMS

int mfunc               \ the menu function

in-system warning off

: (ClassInit)   ( -- )
                [ warning on ]
                ClassInit: super
                m"text"
                :noname to mfunc
                !csp
                ;

in-application

\in-system-ok :M ClassInit: (ClassInit) ;M

:M DoMenu:      ( IDM -- )
                mid =
                if      mfunc execute-menufunc
                then    ;M

;Class

\ define a menu item that has a name, so we can manipulate it
\               :MENUITEM chkm1 "E&xit"  'X' +k_control pushkey ;
\ then check it with:   true Check: chkm1

:Class :MENUITEM <Super MENUITEM
;Class

:Class :MENUFUNC <Super  MENUITEM

MAXSTRING bytes mstring          \ the menu text

:M "SetMenuText: ( a1 n1 -- )
                mstring place
                mstring +NULL
                mstring 1+ SetMenuText: super
                mstring to mtext
                ;M

:M SetMenuText: ( z$ -- )
                dup SetMenuText: super
                1- to mtext
                ;M

:M GetMenuText: ( -- a1 n1 )
                mstring count
                ;M

:M SetMenuFunc: ( cfa -- )
                to mfunc
                ;M

:M DoMenu:      ( IDM -- )              \ function receives the address of the menu object
                mid =                   \ which it should discard before returning
                if      Addr: self mfunc execute-menufunc
                then    ;M

:M LoadMenu:    ( pid parent -- )
                to parent
                dup to popid
                MF_STRING mid mtext 1+ menu-append
                ;M

;Class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Global default menubar
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

INTERNAL        \ internal definitions start here

|Class MENUCONSOLE <Super  MENUITEM   \ Only for use with the console window

:M DoMenu:      ( IDM -- )
                mid =
                if      mfunc execute-menufunc
                        cr
[DEFINED] ledit-y [IF]  getxy to ledit-y to ledit-x  \ move lineeditor down
[THEN]          then    ;M

;Class

EXTERNAL

MENUBAR Min-Menu-bar
        POPUP "&File"
        MENUCONSOLE "E&xit" bye ;
ENDBAR

Min-Menu-Bar to DefaultMenuBar

MODULE          \ end of the module
