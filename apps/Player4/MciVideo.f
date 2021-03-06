\    File: MciVideo.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Donnerstag, M�rz 31 2005 - dbu
\ Updated: Donnerstag, M�rz 31 2005 - dbu
\
\ A class to play Video-Files using the winmm.dll
\ Based on PLAYER4.F written by Bruno

cr .( Loading MciVideo class...)

ANEW -MciVideo.f

internal

WinLibrary winmm.dll
4 proc mciSendString

external

\ ---------------------------------------------------------------
\ MciVideo - class
\ ---------------------------------------------------------------
:Class MciVideo <Super object

128 bytes DeviceID
int fullscreen?
int hWnd

maxstring 2 + bytes buf$
maxstring 2 + bytes buf1$

:M ClassInit:   ( -- )
        ClassInit: super
        DeviceID 128 erase
        false to fullscreen?
        0 to hWnd
        ;M

\ ----------------------------------------------------------------------------
\ ----------------------------------------------------------------------------
: (MciSendString) ( n1 n2 n3 addr -- ) \ send a MCI-command string
        MciDebug? if cr ." MciVideo: " 4dup zcount type . . . then
        call mciSendString drop ;

\ ----------------------------------------------------------------------------
\ ----------------------------------------------------------------------------
: zMciSendString ( addr -- ) \ send a MCI-command string
        >r 0 0 0 r> (MciSendString) ;

: MciSendString ( addr -- ) \ send a MCI-command string
        dup +null 1+ zMciSendString ;

: NumToMci      ( n -- addr len )
        0 <# #s #> ;

\ ----------------------------------------------------------------------------
\ ----------------------------------------------------------------------------
:M SetDeviceID: ( addr len -- ) \ set the DeviceID
        DeviceID place ;M

:M SetHandle:   ( hWnd -- ) \ set the Window handle
        to hWnd ;M

:M FullScreen:  ( f -- )
        to fullscreen? ;M

:M FullScreen?: ( -- f )
        fullscreen? ;M

:M SetTimeFormat:   ( addr len -- n )
        s" Set " buf$ place DeviceID count buf$ +place
        s"  time format " buf$ +place buf$ +place
        buf$ MciSendString ;M

:M Open:        ( addr len -- )
        s" Open " buf$ place
        buf$ +place
        s"  Alias " buf$ +place
        DeviceID count buf$ +place
        fullscreen? 0=
        if   s"  parent " buf$ +place hWnd NumToMci buf$ +place
             s"  Style " buf$ +place WS_CHILD NumToMci buf$ +place
        then buf$ MciSendString
        s" ms" SetTimeFormat: self
        ;M

:M PutAt:       ( w h -- )
        s" put " buf$ place DeviceID count buf$ +place
        s"  window at 0 0 " buf$ +place
        swap NumToMci buf$ +place s"  " buf$ +place \ w
             NumToMci buf$ +place \ h
        buf$ MciSendString
        ;M

:M PlayFullScreen: ( n -- )
        s" play " buf$ place DeviceID count buf$ +place
        s"  fullscreen from " buf$ +place 
        NumToMci buf$ +place
        buf$ MciSendString
        ;M

:M PlayWindow:  ( n -- )
        s" play " buf$ place DeviceID count buf$ +place
        s"  window from " buf$ +place 
        NumToMci buf$ +place
        buf$ MciSendString
        ;M

:M Play:        ( n -- )
        fullscreen?
        if   PlayFullScreen: self
        else PlayWindow: self 
        then ;M

:M Pause:       ( -- ) 
        s" pause " buf$ place DeviceID count buf$ +place
        buf$ MciSendString ;M

:M Resume:      ( -- ) 
        s" resume " buf$ place DeviceID count buf$ +place
        buf$ MciSendString ;M

:M Close:       ( -- ) 
        s" close " buf$ place DeviceID count buf$ +place
        buf$ MciSendString ;M

: GetStatus     ( addr len -- n )

        s" status " buf$ place DeviceID count buf$ +place
        s"  " buf$ +place buf$ +place 
        buf$ +null

        0 255 buf1$ 
        buf$ 1+ (MciSendString)

        buf1$ 256 2dup 0 scan nip - number? >r d>s r>
        0= if drop 0 then ;

:M GetLength:   ( -- n )
        s" length" GetStatus ;M

:M GetPosition:   ( -- n )
        s" position" GetStatus ;M

:M SoundOn:     ( -- )
        s" set " buf$ place DeviceID count buf$ +place
        z"  audio all on" buf$ +place
        buf$ MciSendString ;M

:M SoundOff:    ( -- )
        s" set " buf$ place DeviceID count buf$ +place
        z"  audio all off" buf$ +place
        buf$ MciSendString ;M

:M VideoOn:     ( -- )
        s" set " buf$ place DeviceID count buf$ +place
        z"  video on" buf$ +place
        buf$ MciSendString ;M

:M VideoOn:     ( -- )
        s" set " buf$ place DeviceID count buf$ +place
        z"  video off" buf$ +place
        buf$ MciSendString ;M

:M ~:           ( -- )
        Close: self
        ~: super
        ;M

;class

\ ---------------------------------------------------------------
\ MciVideoWindow - class
\ ---------------------------------------------------------------
:class MciVideoWindow  <super window

        MciVideo Video

:M Classinit:   ( -- )
        ClassInit: super
        ;M

:M On_Init:     ( -- )          \ initialize the class
        On_Init: super 

        GetHandle: self SetHandle: Video
        GetHandle: self (.) SetDeviceID: Video
        false FullScreen: Video
        ;M

:M On_Done:     ( h m w l -- res )
        Close: Video
        On_Done: super
        ;M

:M FullScreen:  ( f -- )
        FullScreen: Video ;M

:M FullScreen?: ( -- f )
        FullScreen?: Video ;M

: ResizeVideo   ( -- ) \ set size of the video display
        FullScreen?: self 0=
        if   Width Height PutAt: Video
        then ;

:M On_Size:     ( h m w -- )                  \ handle resize message
        On_Size: super
        ResizeVideo ;M 

:M Open:        ( addr len -- )
        Open: Video
        ResizeVideo ;M

:M Close:       ( -- )
        Close: Video ;M

:M PutAt:       ( w h -- )
        FullScreen?: self 0=
        if   PutAt: Video
        else 2drop
        then ;M

:M Play:        ( n -- )
        Play: Video ;M

:M Pause:       ( -- )
        Pause: Video ;M

:M Resume:      ( -- )
        Resume: Video ;M

:M GetLength:   ( -- n )
        GetLength: Video ;M
        
:M GetPosition: ( -- n )
        GetPosition: Video ;M

:M SoundOn:     ( -- )
        SoundOn: Video ;M
        
:M SoundOff:    ( -- )
        SoundOff: Video ;M
        
:M VideoOn:     ( -- )
        VideoOn: Video ;M
        
:M VideoOn:     ( -- )
        VideoOn: Video ;M

:M FullScreenToggle:    ( -- )
        FullScreen?: self 0= FullScreen: self
        GetPosition: self Play: self
        ;M

;class

module
 