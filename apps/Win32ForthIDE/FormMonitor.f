\ FormMonitor.f

:Object MiniWin             <Super child-window

int WasMoved?
int wx
int wy
ffPoint MyPoint

:M ClassInit:   ( -- )
                ClassInit: super
                0 to WasMoved?
                0 to wx
                0 to wy
                1 to ID ;M

:M WindowStyle: ( -- style )
                WindowStyle: super
                WS_CAPTION or WS_BORDER or
                ;M

:M WindowTitle: ( -- zstring )
                z" Window" ;M

:M StartSize:   ( -- width height )
                screen-size >r 10 / r> 10 /  ;M

:M StartPos:    ( -- x y )
                0 0 ;M

:M WM_MOVING    ( h m w l -- )
                true to WasMoved?
                DefWindowProc: self
                ;M

\ WM_MOVE returns origin of window's client area only, but we are using the
\ whole window as a replica
: GetWindowXY   ( -- x y )
                GetWindowRect: self 2drop SetPoint: MyPoint
                MyPoint GetHandle: Parent
                Call ScreenToClient ?win-error
                MyPoint.x MyPoint.y ;

:M WM_MOVE      ( h m w l -- res )
                wasMoved?
                if      GetWindowXY 2dup to wy to wx
                        WindowWasMoved: parent      \ let parent know
                        false to WasMoved?           \ reset
                then    WM_MOVE WM: Super       \ send to super class
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self WHITE FillArea: dc
                ;M

;Object

:Object Monitor                <Super Child-Window

Rect mBox

:M ClassInit:        ( -- )
                ClassInit: super
                ;M

:M On_Init:	( -- )
		On_Init: Super
		CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop
		;M

:M WindowStyle:        ( -- style )
               WindowStyle: Super WS_CAPTION or
                ;M

:M ExWindowStyle:  ( -- exstyle )
                   ExWindowStyle: super
                   WS_EX_TOOLWINDOW or
                   ;M

:M WindowTitle:        ( -- ztitle )
                z" Monitor"
                ;M

:M StartSize:   ( -- width height )
                screen-size 5 / swap 5 / swap
                ;M

:M StartPos:    ( -- x y )
                MonitorLeft MonitorTop
                ;M

:M Close:        ( -- )
                Close: MiniWin
                Close: super
                ;M

:M SaveOrigin:	( -- )
		hwnd 0= ?exitm
		GetWindowRect: self SetRect: winRect
		Addr: winRect GetHandle: parent Call ScreenToClient
		Left: winRect to MonitorLeft Top: winRect to MonitorTop
		;M

:M On_Paint:        ( -- )
                0 0 GetSize: self CYAN FillArea: dc
                1 1 StartSize: self 1 1 d- SetRect: mBox
                addr: dc SetDC: mBox
                Red Green Sunken: mBox
                ;M

: >screen-coord ( wx wy -- x y )      \ convert to screen coordinates for form
                screen-size StartSize: self
                { wx wy scrw scrh pw ph -- }
                scrw pw / wx *
                scrh ph / wy * ;

: screen-coord> ( x y -- wx wy )  \ convert to form coordinates
                screen-size StartSize: self
                { x y scrw scrh pw ph -- }
                x scrw pw / /  ( wx )
                y scrh ph / /  ( wy )
                ;

:M SetPosition: { x y -- }
                GetHandle: MiniWin 0=          \ if not shown
                if      self Start: MiniWin    \ start it up
                then    x y screen-coord> SetWindowPos: MiniWin
                ;M

:M GetPosition: ( -- wx wy )
                MiniWin.wx MiniWin.wy >screen-coord
                ;M

:M Blank:       ( -- )
                Close: MiniWin
                ;M

:M Update:      ( -- )
                ActiveForm
                if       Origin: ActiveForm SetPosition: self
                         FormTitle: ActiveForm count SetText: MiniWin
                then    ;M

:M WindowWasMoved:    { x y -- }
                ActiveForm
                if      Locked?: ActiveForm
                        if      Origin: ActiveForm SetPosition: self    \ ignore move
                                exitm
                        then    x y >screen-coord SetOrigin: ActiveForm
                        IsModified: ActiveForm
                  doupdate \     UpdateProperties++
                then    ;M

;Object

: Adjust-Monitor	( -- )
		StartPos: Monitor StartSize: Monitor Move: Monitor ;

\s
