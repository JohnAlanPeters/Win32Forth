\ $Id: WinEd.f,v 1.28 2013/12/09 21:34:03 georgeahubert Exp $
\
((
    ***********************************************************************
     *                                                                   *
      *     An Editor for Win32Forth    Originated by Tom Zimmer        *
      *     Win-Editor is a multiple file text editor for Win32Forth.   *
     *                                                                   *
    ***********************************************************************
))

cr .( Loading WinEd... )

anew -wined.f

  1 value CreateTurnkey
\ 1 value (WinEdDbg)     \ Enable to debug

CreateTurnkey [if] >WinEd [then]

s" apps\WinEd"     "fpath+
s" apps\WinEd\res" "fpath+

only forth also editor definitions \ put all words into the EDITOR vocabulary

\ So we can rename it as part of an application  jap rda
create Edname$ 32 allot
s" WinEd " Edname$ place

needs Ed_Version.f           \ This version of Win-Ed
needs Ed_Colorize.f          \ Brad Eckert's colorization support
needs Ed_FileStack.f         \ Multiple File Support Data Structure
needs Ed_Globals.f
needs Ed_Sfont.f             \ Define a fonts for Win-Ed to use
needs Ed_EditorWords.f
needs Ed_Statbar.f           \ Simple Statusbar Class
needs Ed_EditWindowObj.f
needs Ed_MiscFunc.f
needs Ed_About.f             \ Win-Ed about Dialog
needs Ed_LineFuncs.f         \ Setup the line pointers and scroll bar for a new file
needs Sub_Dirs.f             \ Multi-Directory File processing
needs Ed_Search.f            \ Text Search functions
needs Ed_KeyCMD.f            \ Scrolling, ins/del lines & characters
needs Ed_Findrepl.f
needs Ed_Gotoline.f          \ Goto line DiaLog
needs Ed_Clipboard.f         \ Text Copy Functions
needs Ed_FileFuncs.f         \ Change to PC and Change to Apple
needs Ed_Url.f
needs Ed_HyperLink.f         \ Hyper Text linkage words
needs Ed_FindInFiles.f       \ Search Files for text dialog Object
needs Ed_Debug.f             \ Debug a Forth application
needs Ed_MenuFuncs.f         \ Select Font and Size dialog
needs Ed_SubjectListObj.f    \ Select List Class
needs Ed_LoadFileFuncs.f
needs Ed_Toolbar.f
needs Ed_Menu.f              \ Define the Editor Popup Menu for the application
needs Ed_FrameWindowObj.f    \ Define the Main Window for the application
needs Ed_Remote.f            \ Message support, allows files to be opened remotely
needs Ed_MouseHighLight.f
needs Ed_Do-Html-Link.f
needs Ed_Defaults.f          \ Save & Restore default settings for Win-Ed
needs Ed_Keys

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 75    Initialization
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: strip-cmdline ( addr cnt -- addr2 cnt2 )
                [CHAR] " skip [CHAR] ' skip BL skip
                [CHAR] " -TRAILCHARS [CHAR] ' -TRAILCHARS BL -TRAILCHARS ;

: Edit-init  ( -- xxx )
        ['] view-before-bye is before-bye       \ called by WM_CLOSE
        ['] viewbye         is bye
        ['] "viewmessage    is "message
        ['] "topviewmessage is "top-message

        edit-window    to EditWindow
        edit-window    to DocWindow

        ['] Mhedit-click        SetClickFunc: EditWindow
        ['] Mhedit-unclick    SetUnClickFunc: EditWindow
        ['] Mhedit-track        SetTrackFunc: EditWindow
        ['] Mhedit-dblclick  SetDblClickFunc: EditWindow

        GetFilter: ViewText filter-save place  \ preserve unmodified filter string
        FALSE         to browse?
        0             to left-margin
        WinVer 4 >= ( NT? )
        winver 2 3 between ( Win98? ) or to using98/NT?
        0             to right-edge
        false         to edit-changed?
        cur-buf off
        ;

[UNDEFINED] (WinEdDbg) [IF]
        1 to CreateTurnkey
[else]
        (WinEdDbg) not to CreateTurnkey
[then]

: WinEd ( -- )
        w32fsharep 0=
              if w32fshareName 1024 open-share ?dup
                 if  to w32fshareh
                     to w32fsharep
                 then
                 CmdLine strip-cmdline
                 pad place 0 pad $edit
                 CloseSharedMemory
                 bye
                then
        Edit-init
        load-defaults
        command-options
        Start: FrameWindow
CreateTurnkey if GetHandle: FrameWindow Enablew32fMsg then
        floating-bar?
        IF      Float: Win-EdToolbar
        THEN
        load-more-defaults
        new-text
        make-new-text
        open-initial-file
        cursor-line find-top-margin - VPosition: EditWindow

        SetFocus: EditWindow
        EditWindow to DocWindow

        GetStack: DocWindow to entry#
        refresh-screen
        no-highlight
        view-key-loop
        EXIT ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 77    Create WinEd.exe
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

        CreateTurnkey [if]

(( [cdo] removed for new console
   if disable for image then need reenable after save
                w32fmsg-chain @     nostack
                w32fmsg-chain off       \ disable WinEd's ability to recognize windows
                                        \ messages through the console.
                                        \ We don't want the editor trying to insert a breakpoint
                                        \ into itself.
))
                .free                   \ how much memory did we really use?
                &forthdir count &appdir place

                w32fWined To NewAppID  \ handle inter-process messaging and launching
                false to RunUnique
                ConsoleHiddenBoot
                ' wined ' SAVE catch WinEd.exe checkstack  \ save WinEd.exe
                &appdir off
(( [cdo] removed for new console
                swap w32fmsg-chain !
))
                throw

                \ add the resources to the exe file

version# ((version)) 0. 2swap >number 3drop 7 < dup [if] winver winnt4 < and [then] 0=
[if]

                        &forthdir count pad place
                        s" WinEd.exe" pad +place
                        pad count "path-file drop AddToFile

                        CREATEPROCESS_MANIFEST_RESOURCE_ID RT_MANIFEST s" WinEd.exe.manifest" "path-file drop  AddResource
                        101 s" src\res\WinEd.ico" "path-file drop AddIcon

                        false EndUpdate

                [else]  \ For V6.xx.xx older OSs
                        s" src\res\WinEd.ico"  s" WinEd.exe" Prepend<home>\ AddAppIcon
                [then]
                Require Checksum.f
                s" WinEd.exe" prepend<home>\ (AddCheckSum)
                1 pause-seconds bye
        [else]
                WinEd
        [then]

\s
the above look's a bit strange but if you add this to your 'Win32Forth.cfg'
file:

        false value (WinEdDbg)
        : WinEdDbg ( -- ) \ load WinEd in 'debug-mode'
            true to (WinEdDbg) \ turn debug mode for WinEd on
            s" apps\wined\wined.f " Prepend<home>\ "Fload ; \ and load it

you can run WinEd from the forth console by typing: WinEdDbg <cr>
This makes it easier to debug WinEd, because you can do thing's like this:

WinEdDbg \ load WinEd
debug WinEd-init \ set breakpoint
WinEd \ and run WinEd


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 78    Bug and Wish list, # indicates relative importance, or latest on top.
\  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

90 Overstrike mode needs a new different cursor

79 Sometimes WinEd crashes when changeing to colons only mode (F2)
   February 29th, 2004 - 12:01 dbu

79 Sometimes WinEd is closed when you change the active file using the filelist
   on the left. I'm not sure but I think this only happens after
   "Find Text in Files" is used.

78 Make WinEdColorize.f stop coloring words between a (( and a )) or after
   a \ as if they were Forth words.

70 Enable the use of the ALT key in combination with the letter keys.
   This would open up a bunch of keystrokes for new commands. jap

42 Add ability to colorize words with italics, underline, and bold even though
   bold messes up the cursor location as it looses track with wider chars. jap

40 Make colorize quit coloring words after a  \s  at the end of the file. jap

11 A smart combination of ED <file> and EDIT <word>  Some code sent in by rda
   which is yet to be understood and implemented by jap. jap

10 Ctrl+PgDn should go to the bottom of the file, not stop at last paragraph

02 F2 colons-only mode is very nice.
        It should allow jumping to a line.
        Scrolling and Wheelmouse doesn't work.
        "Key up" or "Key down" dispaly wrong text.

02 Mocro document every word, state what it does not how it does it.

10 BOLD needs an icon and necessary code similar to MS applications

02 HTML interpreter to display XML files in browse mode like VIM editor does.

04 COLORIZATION (( to turn off Colorizaton and )) to turn it back on.

04 COLORIZATON  All text from a ((( till the next ))) to be in red.

99 Add the ability to VIEW the source of words in Objects and :M

   When the "Find Text in Files" function is called, and then one of the files
   is invoked by clicking on the file name, the file comes up in WinEd with the
   ENTIRE line containing the text is highlighted.  That in itself is not too
   bad.  BUT secondary problems develop if you do not carefully un-highlight
   that line before searching for additional occurrences of that text in the
   same file.  It seems preferable to me that ONLY the desired text should be
   highlighted. rls

