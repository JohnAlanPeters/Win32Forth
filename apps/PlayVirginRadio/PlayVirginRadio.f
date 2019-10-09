\ $Id: PlayVirginRadio.f,v 1.20 2013/12/09 21:34:02 georgeahubert Exp $
\
\  Authors: Dirk Busch      dirk@win32forth.org
\
\ Created: Montag, Mai 16 2005 - dbu
\ Updated: Sonntag, Januar 15 2006 - dbu
\
\ Simple application that plays the "Virgin Radio Classic Rock"
\ Radio statio over the internet.
\
\ It also shows how to use the 'TrayWindow' and 'HtmlControl' classes.

cr .( Loading Play Virgin Radio...)

anew -PlayVirginRadio.f

needs TrayWindow.f
needs HtmlControl.f
needs SoundVolume.f
needs Resources.f

true value turnkey?

\ -----------------------------------------------------------------------------
\       Define the Main Window
\ -----------------------------------------------------------------------------
:Object MainWindow  <super TrayWindow

HtmlControl Player

:M WindowTitle: ( -- Zstring ) \ window caption
        z" Virgin Radio Player" ;M

:M WindowStyle: ( -- n )
        [ WS_OVERLAPPED WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or ] literal
        ;M

:M StartSize:   ( -- w h )
        840 380 ;M

:M StartPos:   ( -- w h )
        100 100 ;M

:M On_Size:     ( -- )
        On_Size: super
        AutoSize: Player
        ;M

:M WM_CLOSE     ( h m w l -- res )
        bye 0 ;M

:M On_Done:     ( h m w l -- res )
        SoundOff
        Stop: Player
        SoundOn
        0 call PostQuitMessage drop     \ terminate application
        On_Done: super                  \ cleanup the super class
        0 ;M

:M GetTooltip:  ( -- addr len )
        WindowTitle: self zcount ;M

:M Play:        ( -- )
\ They changed the URL!
\        z" http://www.smgradio.com/core/player/index.html?service=vc"
\        z" http://player.absoluteradio.co.uk/core/player/?service=abc"
        z" http://player.absoluteradio.co.uk/core/radioplayer/ar/"
        SetURL: Player ;M

:M On_Init:     ( -- )
        On_Init: super
        self Start: Player
        ;M

:M DefaultIcon: ( -- hIcon )
        LoadAppIcon ;M

;Object

\ ------------------------------------------------------------------------------
\       Define the "About" dialog
\ ------------------------------------------------------------------------------

:Object AboutDialog <SUPER dialog

IDD_ABOUT_FORTH forthdlg find-dialog-id constant template

create about-head
         z," Play Virgin Radio"

create about-msg1
         z," Written in 2005/2006 by:\n"
        +z,"   Dirk Busch - dirk@win32forth.org\n"

create about-msg2
         z," This Application plays the 'Virgin Radio Classic Rock'\n"
        +z," Radio statio over the internet."

create about-msg3
         z," This application was build with Win32Forth\n"
        +z," Version " -null, version# ((version)) +z",
        +z," . See www.win32forth.org for\n"
        +z," more information about Win32Forth."

:M On_Init:     ( hWnd-focus -- f )
        about-head zcount IDD_ABOUT_HEAD  SetDlgItemText: self
        about-msg1 zcount IDD_ABOUT_TEXT  SetDlgItemText: self
        about-msg2 zcount IDD_ABOUT_TEXT2 SetDlgItemText: self
        about-msg3 zcount IDD_ABOUT_TEXT3 SetDlgItemText: self
        1 ;M

:M On_Command:  ( hCtrl code ID -- f1 )
        CASE
        IDCANCEL OF     0 end-dialog    ENDOF
                        false swap ( default result )
        ENDCASE ;M

:M Start:       ( -- f )
        Addr: MainWindow template run-dialog ;M

;Object


\ -----------------------------------------------------------------------------
\ -----------------------------------------------------------------------------

: ExitPlayer   ( -- )
\ *G Exit the player.
        SoundOff
        Close: MainWindow
        SoundOn bye ;

popupbar player-popup-bar
\ *G Define the Popup menu for the player.
    popup " "
        menuitem     "&Turn sound on/off"          SoundOnOff ;
        menuseparator
        menuitem     "&Close Virgin Radio Player"  ExitPlayer ;
        menuseparator
        menuitem     "&About Virgin Radio Player"  Start: AboutDialog ;
endbar

: StartPlayer   ( -- )
\ *G Start the player.
        Start: MainWindow
        Play: MainWindow \ start playing radio...
        Sound? 0= if 100 100 volume! then \ turn the sound on
        HideWindow: MainWindow \ hide the window in the traybar
        player-popup-bar SetPopupBar: MainWindow
        ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ The application \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


turnkey? [if]

        \ Create the exe-file
        &forthdir count &appdir place
        ' StartPlayer turnkey PlayVirginRadio.exe

        \ add the resources to the EXE file

        \ add the resources to the exe file
version# ((version)) 0. 2swap >number 3drop 7 < dup [if] winver winnt4 < and [then] 0=
[if]

                &forthdir count pad place
                s" PlayVirginRadio.exe" pad +place
                pad count "path-file drop AddToFile

                CREATEPROCESS_MANIFEST_RESOURCE_ID RT_MANIFEST s" apps\PlayVirginRadio\PlayVirginRadio.exe.manifest" "path-file drop  AddResource
                101 s" apps\PlayVirginRadio\Virgin.ico" "path-file drop AddIcon

                false EndUpdate

        [else]  \ For V6.xx.xx older OSs
               s" apps\PlayVirginRadio\Virgin.ico" s" PlayVirginRadio.exe" Prepend<home>\ AddAppIcon
        [then]
        Require Checksum.f
        s" PlayVirginRadio.exe" prepend<home>\ (AddCheckSum)

        1 pause-seconds bye
[else]
        s" apps\PlayVirginRadio\Virgin.ico" s" PlayVirginRadio.exe" Prepend<home>\ AddAppIcon
        StartPlayer
[then]
