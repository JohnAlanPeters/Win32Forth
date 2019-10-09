\    File: MciInterface.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Donnerstag, März 31 2005 - dbu
\ Updated: Freitag, April 01 2005 - dbu
\
\ A class to play Audio and Video-Files using
\ the Windows Media Control Interface (MCI).
\
\ Based on PLAYER4.F written by Bruno Gauthier

cr .( Loading Media Control Interface MCI class...)

ANEW -MciInterface.f

internal

WinLibrary winmm.dll
4 proc mciSendString

external


\ ---------------------------------------------------------------
\ MciClass - class
\ ---------------------------------------------------------------
:Class MciClass <Super object

maxstring bytes DeviceID
int fullscreen?
int hWnd
int vWidth
int vHeight
int Video?
int Length

maxstring 2 + bytes buf$
maxstring 2 + bytes buf1$

:M ClassInit:   ( -- )
        ClassInit: super

        DeviceID maxstring erase
        false to fullscreen?
        0 to hWnd
        0 to vWidth
        0 to vHeight
        0 to Video?
        0 to Length
        buf$ maxstring erase
        buf1$ maxstring erase
        ;M

\ ----------------------------------------------------------------------------
\ ----------------------------------------------------------------------------
: ((MciError))  ( n -- ) \ diplay MCI error message in the console window
        dup MciDebug? and
        if   cr ." MciError: "
             >r maxstring buf$ r> call mciGetErrorString
             if buf$ zcount type else ." [UNKNOWEN]" then
        else drop
        then ;

: ((MciSendString)) ( n1 n2 n3 addr -- ) \ send a MCI-command string
        Call mciSendString ((MciError)) ;

: (MciSendString) ( n1 n2 n3 addr -- ) \ send a MCI-command string
        MciDebug? if cr ." MciCmd: " 4dup zcount type space h. h. h. then
        ((MciSendString)) ;

: zMciSendString ( addr -- ) \ send a MCI-command string
        >r 0 0 0 r> (MciSendString) ;

: MciSendString ( addr -- ) \ send a MCI-command string
        dup +null 1+ zMciSendString ;

\ ----------------------------------------------------------------------------
\ ----------------------------------------------------------------------------
: PlaceCommand  ( addr len -- )
        buf$ place ;

: +PlaceCommand ( addr len -- )
        buf$ +place ;

: +PlaceDeviceID ( -- )
        DeviceID count +PlaceCommand ;

: +PlaceNum     ( n -- )
        0 <# #s #> +PlaceCommand s"  " +PlaceCommand ;

: SendCommandBuf ( -- )
        buf$ MciSendString ;

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

:M Width:       ( -- width )
        vWidth ;M

:M Height:      ( -- height )
        vHeight ;M

: GetStatus     ( addr len -- n )
        s" status " PlaceCommand +PlaceDeviceID
        s"  " +PlaceCommand +PlaceCommand
        buf$ +null

        0 255 buf1$ 0 buf1$ !
        buf$ 1+ ((MciSendString))

        buf1$ 256 2dup 0 scan nip - number? >r d>s r>
        0= if drop 0 then ;

: GetLength     ( -- ) \ get video length
        s" length" GetStatus to Length ;

:M GetLength: ( -- n ) \ get video length
        Length ;M

:M GetPosition: ( -- n ) \ get current video position
        s" position" GetStatus ;M

:M SetTimeFormat: ( addr len -- n )
        s" Set " PlaceCommand +PlaceDeviceID
        s"  time format " +PlaceCommand +PlaceCommand
        SendCommandBuf
        GetLength ;M

: GetHeightAndWidth ( -- )
        Video?
        if
             s" where " PlaceCommand +PlaceDeviceID
             s"  destination" +PlaceCommand
             buf$ +null

             0 255 buf1$ 0 buf1$ !
             buf$ 1+ ((MciSendString))

             buf1$ zcount ?dup
             if   BL /get 2nip BL /get 2nip BL /get BL /get 2drop \ split string
                  number? if d>s else 2drop 0 then to vHeight
                  number? if d>s else 2drop 0 then to vWidth
             else drop
             then
        then ;

: (open)        ( f -- )
        to Video?
        SendCommandBuf
        GetHeightAndWidth
        s" ms" SetTimeFormat: self ;

:M OpenVideo:   ( addr len -- )
        s" Open " PlaceCommand +PlaceCommand
        s"  Alias " +PlaceCommand +PlaceDeviceID
        s"  parent " +PlaceCommand     hWnd +PlaceNum
        s"  Style "  +PlaceCommand WS_CHILD +PlaceNum

        true (open) ;M

:M OpenAudio:   ( addr len -- )
        s" Open " PlaceCommand +PlaceCommand
        s"  Alias " +PlaceCommand +PlaceDeviceID

        false (open) ;M

:M PlayAudioCD: ( -- ) \ doesn't work on my system (dbu)
        false to Video?
        s" open cdaudio" PlaceCommand
        SendCommandBuf
        s" set cdaudio time format tmsf" PlaceCommand
        SendCommandBuf
        s" play cdaudio from 1" PlaceCommand
        SendCommandBuf
\         s" close cdaudio" PlaceCommand
\         SendCommandBuf
        ;M

:M PutWindowAt: ( x y w h -- )
        Video?
        if   s" put " PlaceCommand +PlaceDeviceID
             s"  window at " +PlaceCommand 2swap
             swap +PlaceNum +PlaceNum
             swap +PlaceNum +PlaceNum
             SendCommandBuf
        else 2drop 2drop
        then ;M

:M PlayFullScreen: ( n -- ) \ play video in fullscreen mode
        Video?
        if   s" play " PlaceCommand +PlaceDeviceID
             s"  fullscreen from " +PlaceCommand +PlaceNum
             SendCommandBuf
        else drop
        then ;M

:M PlayWindow:  ( n -- ) \ play video in window mode
        Video?
        if   s" play " PlaceCommand +PlaceDeviceID
             s"  window from " +PlaceCommand +PlaceNum
             SendCommandBuf
        else drop
        then ;M

:M PlayAudio:   ( n -- ) \ play audio
        Video? 0=
        if   s" play " PlaceCommand +PlaceDeviceID
             s"  from " +PlaceCommand +PlaceNum
             SendCommandBuf
        else drop
        then ;M

:M Play:        ( n -- ) \ play video
        Video?
        if   fullscreen?
             if   PlayFullScreen: self
             else PlayWindow: self
             then
        else PlayAudio: self
        then ;M

:M Pause:       ( -- ) \ pause video
        s" pause " PlaceCommand +PlaceDeviceID
        SendCommandBuf ;M

:M Resume:      ( -- ) \ resume video
        s" resume " PlaceCommand +PlaceDeviceID
        SendCommandBuf ;M

:M Close:       ( -- ) \ close video
        s" close " PlaceCommand +PlaceDeviceID
        SendCommandBuf ;M

: Audio         ( addr len -- )
        s" set " PlaceCommand +PlaceDeviceID
        s"  audio all " +PlaceCommand +PlaceCommand
        SendCommandBuf ;

:M AudioOn:     ( -- ) \ turn sound on
        s" on" Audio ;M

:M AudioOff:    ( -- ) \ turn sound off
        s" off" Audio ;M

: Video         ( addr len -- )
        Video?
        if   s" set " PlaceCommand +PlaceDeviceID
             s"  video " +PlaceCommand +PlaceCommand
             SendCommandBuf
        else 2drop
        then ;

:M VideoOn:     ( -- ) \ turn video on
        s" on" Video ;M

:M VideoOff:    ( -- ) \ turn video off
        s" off" Video ;M

:M Video?:      ( -- f )
        Video? ;M

\ ---------------------------------------------------------------
\ ---------------------------------------------------------------
:M Forward:     ( n -- )
        abs GetPosition: self + GetLength: self min
        Play: self ;M

:M Rewind:      ( n -- )
        GetPosition: self swap abs - 0max
        Play: self ;M

\ ---------------------------------------------------------------
\ ---------------------------------------------------------------
:M ~:           ( -- )
        Close: self
        ~: super
        ;M

;class

\ ---------------------------------------------------------------
\ MciChildWindow - class
\ ---------------------------------------------------------------
:class MciChildWindow  <super child-window

MciClass MCI
int VideoSize

:M Classinit:   ( -- )
        ClassInit: super
        0 to VideoSize
        ;M

:M On_Init:     ( -- )          \ initialize the class
        On_Init: super

        GetHandle: self SetHandle: MCI
        GetHandle: self (.) SetDeviceID: MCI
        false FullScreen: MCI
        100 to VideoSize
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

: (CalcPos)     ( n1 n2 -- n3 )
        - 0max 2/ ALIGNED ;

: CalcPos       ( width height -- x y )
        Width:  super rot (CalcPos)
        Height: super rot (CalcPos) ;

: CalcSize      ( -- width height )
        VideoSize
        case
            0 of Width Height                   endof
           50 of Width: MCI 2/ Height: MCI 2/   endof \ doesn't work as expected (dbu)
          100 of Width: MCI Height: MCI         endof
          200 of Width: MCI 2* Height: MCI 2*   endof
        endcase ALIGNED Height: super min swap
                ALIGNED Width: super  min swap ;

: ((SetVideoSize)) ( x y width height -- )
        FullScreen?: self 0=
        if   PutWindowAt: MCI
        else 2drop 2drop
        then ;

: (SetVideoSize) ( -- )
        CalcSize 2dup CalcPos 2swap ((SetVideoSize)) ;

:M SetVideoSize:  ( n -- )
        to VideoSize \ should check for valid size (0, 50, 100 and 200) here...
        (SetVideoSize) ;M

:M MinSize:     ( -- width height )
        VideoSize 0=
        if   MinSize: super
        else CalcSize
             32 + \ should calc menu and window title height here...
        then ;M

:M On_Size:     ( h m w -- ) \ handle resize message
        On_Size: super
        Video?: self if (SetVideoSize) then ;M

:M OpenVideo:   ( addr len -- )
        OpenVideo: MCI (SetVideoSize) ;M

:M OpenAudio:   ( addr len -- )
        OpenAudio: MCI ;M

:M Close:       ( -- )
        Close: MCI ;M

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

module
