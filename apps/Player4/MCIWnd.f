\ MCIWnd.f          Window class for controlling multimedia devices.   Rod Oakford April 2005
\                   This control plays any device that uses the media control interface (MCI).
\                   These devices include CD audio, waveform-audio, MIDI, and video devices.
\                   See the Windows Multimedia SDK for more information.
\
\ Changed for use in Player4th by Dirk Busch (Donnerstag, Mai 05 2005)

cr  .( Loading MCIWnd class...)

needs Pl_Toolset.f

WinLibrary msvfw32.dll

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ MCI Control class \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class MciControl  <Super control

256 bytes Filename
256 bytes ReturnString
int ReturnInt
Rectangle Dest
Rectangle Source

:M ClassInit: ( -- )
        ClassInit: super
        Filename off
        AppInst Call MCIWndRegisterClass 2drop
        ;M

:M SetFilename: ( z" -- )   Filename 256 move ;M

: SendMessage ( lParam wParam message -- result )   hWnd Call SendMessage ;
: SendMessageDrop ( lParam wParam message -- )   SendMessage drop ;

:M Play: ( -- )   0 0 MCI_PLAY SendMessageDrop ;M
:M PlayReverse: ( -- )   0 0 MCIWNDM_PLAYREVERSE SendMessageDrop ;M
:M Eject: ( -- )   0 0 MCIWNDM_EJECT SendMessageDrop ;M
:M GetEnd: ( -- n )   0 0 MCIWNDM_GETEND SendMessage ;M
:M PlayTo: ( n -- )   0 MCIWNDM_PLAYTO SendMessageDrop ;M
:M PlayFrom: ( n -- )   0 MCIWNDM_PLAYFROM SendMessageDrop ;M
:M GetZoom: ( -- n )   0 0 MCIWNDM_GETZOOM SendMessage ;M
:M SetZoom: ( n -- )   0 MCIWNDM_SETZOOM SendMessageDrop ;M
:M GetMode: ( -- n )   0 0 MCIWNDM_GETMODE SendMessage ;M
:M GetLength: ( -- n )   0 0 MCIWNDM_GETLENGTH SendMessage ;M
:M GetVolume: ( -- n )   0 0 MCIWNDM_GETVOLUME SendMessage ;M
:M SetVolume: ( n --  )   0 max 1000 min 0  MCIWNDM_SETVOLUME SendMessageDrop ;M
:M GetStart: ( -- n )   0 0 MCIWNDM_GETSTART SendMessage ;M
:M GetDest: ( -- l t r b )   Dest 0 MCIWNDM_GET_DEST SendMessageDrop
        left: Dest top: Dest right: Dest Bottom: Dest ;M
:M PutDest: ( l t r b -- )   SetRect: Dest Dest 0 MCIWNDM_PUT_DEST SendMessageDrop ;M
:M GetSource: ( -- l t r b )  Source 0 MCIWNDM_GET_SOURCE SendMessageDrop
        left: Source top: Source right: Source Bottom: Source ;M
:M PutSource: ( l t r b -- )   SetRect: Source Source 0 MCIWNDM_PUT_SOURCE SendMessageDrop ;M
:M SetOwner: ( h -- )   0 swap MCIWNDM_SETOWNER SendMessageDrop ;M
:M GetStyles: ( -- n )   0 0 MCIWNDM_GETSTYLES SendMessage ;M
:M SetStyles: ( value mask -- )   MCIWNDM_CHANGESTYLES SendMessageDrop ;M
:M CanWindow: ( -- f )   0 0  MCIWNDM_CAN_WINDOW SendMessage ;M
:M GetPosition: ( -- n )   0 0 MCIWNDM_GETPOSITION SendMessage ;M
:M GetAlias: ( -- n )   0 0 MCIWNDM_GETALIAS SendMessage ;M
:M GetDeviceID: ( -- n )   0 0 MCIWNDM_GETDEVICEID SendMessage ;M
:M ValidateMedia: ( -- )   0 0 MCIWNDM_VALIDATEMEDIA SendMessageDrop ;M
:M ReturnString: ( -- z" )   ReturnString  dup 256 MCIWNDM_RETURNSTRING SendMessage to ReturnInt ;M
:M GetFilename: ( -- z" )   ReturnString  dup 256 MCIWNDM_GETFILENAME SendMessageDrop ;M
:M GetDevice: ( -- z" )   ReturnString  dup 256 MCIWNDM_GETDEVICE SendMessageDrop ;M
:M GetTimeFormat: ( -- n )   0 0 MCIWNDM_GETTIMEFORMAT SendMessage ;M
:M GetTimeFormatString: ( -- z" )   ReturnString  dup 256 MCIWNDM_GETTIMEFORMAT SendMessageDrop ;M
:M GetError: ( -- n )   0 0 MCIWNDM_GETERROR SendMessage ;M
:M GetErrorString: ( -- z" )   ReturnString  dup 256 MCIWNDM_GETERROR SendMessageDrop ;M
:M SetTimeFormat: ( z" --  )   0 MCIWNDM_SETTIMEFORMAT SendMessageDrop ;M
:M GetActiveTimer: ( -- n )   0 0 MCIWNDM_GETACTIVETIMER SendMessage ;M
:M SetActiveTimer: ( n --  )   0 MCIWNDM_SETACTIVETIMER SendMessageDrop ;M
:M GetInactiveTimer: ( -- n )   0 0 MCIWNDM_GETINACTIVETIMER SendMessage ;M
:M SetInactiveTimer: ( n --  )   0 MCIWNDM_SETINACTIVETIMER SendMessageDrop ;M
:M SetTimers: ( inactive active -- )   MCIWNDM_SETTIMERS SendMessageDrop ;M
:M Open: ( z" -- )   dup SetFilename: self  0 MCIWNDM_OPEN  SendMessageDrop ;M
:M CloseDevice: ( -- )   Filename off  0 0 MCI_CLOSE SendMessageDrop ;M
:M Pause: ( -- )   0 0 MCI_PAUSE SendMessageDrop ;M
:M Resume: ( -- )   0 0 MCI_RESUME SendMessageDrop ;M
:M Stop: ( -- )   0 0 MCI_STOP SendMessageDrop ;M
:M Home: ( -- )   MCIWND_START 0 MCI_SEEK SendMessageDrop ;M
:M End: ( -- )   MCIWND_END 0 MCI_SEEK SendMessageDrop ;M
:M Seek: ( n -- )   0 MCI_SEEK SendMessageDrop ;M
:M Step: ( n -- )   0 MCI_STEP SendMessageDrop ;M
:M SetRepeat: ( f -- )   0 MCIWNDM_SETREPEAT SendMessageDrop ;M
:M SendString: ( z" -- )   0 MCIWNDM_SENDSTRING SendMessageDrop ;M
:M PlayFullScreen: ( -- )   z" Play FullScreen" SendString: self ;M
:M AudioOn: ( -- )   z" Set audio all on" SendString: self ;M
:M AudioOff: ( -- )   z" Set audio all off" SendString: self ;M
:M WM_TIMER ( h m w l -- res )   old-WndProc CallWindowProc ;M
:M WM_MOUSEMOVE ( h m w l -- res )   old-WndProc CallWindowProc ;M

\ Window Styles: \
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ MCIWNDF_NOAUTOSIZEWINDOW Will not change the dimensions of an MCIWnd window when the image size changes.
\ MCIWNDF_NOAUTOSIZEMOVIE Will not change the dimensions of the destination rectangle when an MCIWnd window size changes.
\ MCIWNDF_NOERRORDLG Inhibits display of MCI errors to users.
\ MCIWNDF_NOMENU Hides the Menu button from view on the toolbar and prohibits users from accessing its pop-up menu.
\ MCIWNDF_NOOPEN Hides the open and close commands from the MCIWnd menu and prohibits users from accessing these choices in the pop-up menu.
\ MCIWNDF_NOPLAYBAR Hides the toolbar from view and prohibits users from accessing it.
\ MCIWNDF_NOTIFYANSI Causes MCIWnd to use an ANSI string instead of a Unicode string when notifying the parent window of device mode changes. This flag is used in combination with MCIWNDF_NOTIFYMODE and is exclusive to Windows NT/Windows 2000.
\ MCIWNDF_NOTIFYMODE Causes MCIWnd to notify the parent window with an MCIWNDM_NOTIFYMODE message whenever the device changes operating modes. The lParam parameter of this message identifies the new mode, such as MCI_MODE_STOP.
\ MCIWNDF_NOTIFYPOS Causes MCIWnd to notify the parent window with an MCIWNDM_NOTIFYPOS message whenever a change in the playback or record position within the content occurs. The lParam parameter of this message contains the new position in the content.
\ MCIWNDF_NOTIFYMEDIA Causes MCIWnd to notify the parent window with an MCIWNDM_NOTIFYMEDIA message whenever a new device is used or a data file is opened or closed. The lParam parameter of this message contains a pointer to the new filename.
\ MCIWNDF_NOTIFYSIZE Causes MCIWnd to notify the parent window when the MCIWnd window size changes.
\ MCIWNDF_NOTIFYERROR Causes MCIWnd to notify the parent window when an MCI error occurs.
\ MCIWNDF_NOTIFYALL Causes all MCIWNDF window notification styles to be used.
\ MCIWNDF_RECORD Adds a Record button to the toolbar and adds a new file command to the menu if the MCI device has recording capability.
\ MCIWNDF_SHOWALL Causes all MCIWNDF_SHOW styles to be used.
\ MCIWNDF_SHOWMODE Displays the current mode of the MCI device in the window title bar. For a list of device modes, see the MCIWndGetMode macro.
\ MCIWNDF_SHOWNAME Displays the name of the open MCI device or data file in the MCIWnd window title bar.
\ MCIWNDF_SHOWPOS Displays the current position within the content of the MCI device in the window title bar.

:M WindowStyle: ( -- style )   \ override as necessary
        WindowStyle: super
        [ MCIWNDF_NOOPEN MCIWNDF_NOTIFYALL or ] literal or
        ;M

:M StartSize: ( -- width height )   200 26 ;M   \ override to change

:M Start: ( Parent -- )    \ creates an MCI window in parent window
        to Parent
        z" MCIWndClass" create-control
        GCL_STYLE hWnd Call GetClassLong -4 and GCL_STYLE hWnd Call SetClassLong drop
        ( remove CS_HREDRAW and CS_VREDRAW to eliminate flicker on sizing )
        ;M

:M Width: ( -- width )
        GetWindowRect: self drop nip - ;M

:M Height: ( -- width )
        GetWindowRect: self nip - nip ;M

;Class


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ MCI Child Window class \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:class MciChildWindow  <super child-window

int MCI

int VideoSize
int vWidth
int vHeight
int fullscreen?
int Video?

maxstring 2 + bytes buf$

:M Classinit:   ( -- )
        ClassInit: super
            0 to MCI
            0 to VideoSize
            0 to vWidth
            0 to vHeight
        false to FullScreen?
        false to Video?
        ;M

:M On_Init:     ( -- )
        On_Init: super   \ initialize the class

        new> MciControl to MCI
        self Start: MCI  \ then startup child window

          100 to VideoSize
            0 to vWidth
            0 to vHeight
        false to FullScreen?
        false to Video?

        ;M

:M ExWindowStyle:    ( -- style )
        ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M

:M WndClassStyle: ( -- style )
         CS_DBLCLKS ;M

:M FullScreen:  ( f -- )
        to fullscreen? ;M

:M FullScreen?: ( -- f )
        fullscreen? ;M

:M Video?:      ( -- f )
        Video? ;M

:M Play:        ( n -- )
        PlayFrom: MCI ;M

:M Pause:       ( -- )
        Pause: MCI ;M

:M Resume:      ( -- )
        Resume: MCI ;M

:M GetLength:   ( -- n )
        GetLength: MCI ;M

:M GetPosition: ( -- n )
        GetPosition: MCI ;M

:M AudioOn:     ( -- )
        AudioOn: MCI ;M

:M AudioOff:    ( -- )
        AudioOff: MCI ;M

:M Forward:     ( n -- )
        abs GetPosition: self + GetLength: self min
        Play: self ;M

:M Rewind:      ( n -- )
        GetPosition: self swap abs - 0max
        Play: self ;M

: (CalcPos)     ( n1 n2 -- n3 )
        - 0max 2/ ALIGNED ;

: CalcPos       ( vWidth vHeight -- x y )
        Width:  super rot (CalcPos)
        Height: super rot (CalcPos) ;

: CalcSize      ( -- width height )
        VideoSize
        case     50 of vWidth 2/ vHeight 2/ endof
                100 of vWidth    vHeight    endof
                200 of vWidth 2* vHeight 2* endof
        endcase

        ALIGNED Height: super min swap
        ALIGNED Width: super  min swap ;

: (((SetVideoSize))) ( x y width height -- )
        xywh>ltrb PutDest: MCI ;

: ((SetVideoSize)) ( x y width height -- )
        FullScreen?: self 0=
        if   (((SetVideoSize)))
        else 2drop 2drop
        then ;

: (SetVideoSize) ( -- )
        AutoSize: MCI \ set size of MCI control
	Video?: self
	if   CalcSize 2dup CalcPos 2swap ((SetVideoSize))
	then ;

: SetZoom	( n -- )
	dup GetZoom: MCI <>
	if   SetZoom: MCI
	else drop
	then ;

:M SetVideoSize:  ( n -- )
\ should check for valid size (50, 100 and 200) here...
	dup to VideoSize
	SetZoom
        (SetVideoSize)
	;M

:M MinSize:     ( -- width height )
        VideoSize 0=
        if   MinSize: super
        else CalcSize
             32 + \ should calc menu and window title height here...
        then ;M

:M On_Size:     ( h m w -- ) \ handle resize message
        On_Size: super
	(SetVideoSize) ;M

: GetHeightAndWidth ( -- )
        Video?
        if   GetSource: MCI ( -- l t r b )
             rot  - dup 0= if drop 240 then to vHeight
             swap - dup 0= if drop 320 then to vWidth
        then ;

: (open)        ( addr len f -- )
        to Video?
        buf$ place buf$ +null buf$ 1+ Open: MCI
        GetHeightAndWidth
        z" ms" SetTimeFormat: MCI ;

:M OpenVideo:   ( addr len -- )
        true (open) (SetVideoSize) ;M

:M OpenAudio:   ( addr len -- )
        false (open) ;M

:M Close:       ( -- )
        CloseDevice: MCI ;M

:M FullScreenToggle:    ( -- )
        FullScreen?: self 0= FullScreen: self
        GetPosition: self Play: self
        ;M

:M On_Done:     ( h m w l -- res )
        Close: self
        On_Done: super
        ;M

;class

\ ---------------------------------------------------------------
\ MciWindow - class
\ ---------------------------------------------------------------
((
:class MciWindow  <super window

int MCI

:M Classinit:   ( -- )
        ClassInit: super
        0 to MCI
        ;M

:M On_Init:     ( -- )          \ initialize the class
        On_Init: super

        new> MciChildWindow to MCI
        2    SetId: MCI  \ then the child window
        self Start: MCI  \ then startup child window
        ;M

:M FullScreen:  ( f -- )
        FullScreen: MCI ;M

:M FullScreen?: ( -- f )
        FullScreen?: MCI ;M

:M Video?:      ( -- f )
        Video?: MCI ;M

:M Play:        ( n -- )
        Play: MCI ;M

:M Pause:       ( -- )
        Pause: MCI ;M

:M Resume:      ( -- )
        Resume: MCI ;M

:M GetLength:   ( -- n )
        GetLength: MCI ;M

:M GetPosition: ( -- n )
        GetPosition: MCI ;M

:M AudioOn:     ( -- )
        AudioOn: MCI ;M

:M AudioOff:    ( -- )
        AudioOff: MCI ;M

:M VideoOn:     ( -- )
        VideoOn: MCI ;M

:M VideoOff:    ( -- )
        VideoOff: MCI ;M

:M Forward:     ( n -- )
        Forward: MCI ;M

:M Rewind:      ( n -- )
        Rewind: MCI ;M

:M PlayAudioCD: ( -- )
        PlayAudioCD: MCI ;M

:M SetVideoSize:  ( n -- )
        SetVideoSize: MCI ;M

:M MinSize:     ( -- width height )
        MinSize: MCI ;M

:M On_Size:     ( h m w -- ) \ handle resize message
        On_Size: super
        On_Size: MCI ;M

:M OpenVideo:   ( addr len -- )
        OpenVideo: MCI ;M

:M OpenAudio:   ( addr len -- )
        OpenAudio: MCI ;M

:M Close:       ( -- )
        Close: MCI ;M

:M FullScreenToggle:    ( -- )
        FullScreenToggle: MCI ;M

:M On_Done:     ( h m w l -- res )
        Close: self
        On_Done: super
        ;M

;class
))
