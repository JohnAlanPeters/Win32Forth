\ $Id: Setup.f,v 1.34 2016/01/09 14:45:21 jos_ven Exp $

\    File: setup.f
\  Author: Andrew Stephenson
\ Created: February 14th, 2004 - andrew
\ Updated: Samstag, Dezember 02 2006 - dbu
\
\ Setup for Win32Forth

\ ------------------------------------------------------------------------------
\ This is all we need of win32forth to create a small Setup.exe
\ ------------------------------------------------------------------------------
    FLOAD ..\..\src\comment.f
    FLOAD ..\..\src\numconv.f
    FLOAD ..\..\src\console\console1.f  \ Console I/O part 1
    FLOAD ..\..\src\primutil.f          \ primitive utilities
    FLOAD ..\..\src\console\console2.f  \ Console I/O part 1
SYS-FLOAD ..\..\src\nforget.f
SYS-FLOAD ..\..\src\dthread.f      \ display threads
SYS-FLOAD ..\..\src\order.f        \ vocabulary support
SYS-FLOAD ..\..\src\module.f       \ scoping support for modules
    FLOAD ..\..\src\paths.f        \ multi path support words
SYS-FLOAD ..\..\src\interpif.f     \ interpretive conditionals
sys-FLOAD ..\..\src\NumberAlloc.f
SYS-FLOAD ..\..\src\486asm.f       \ Jim's 486 assembler
SYS-FLOAD ..\..\src\asmmac.f       \ Jim's 486 macros
SYS-FLOAD ..\..\src\asmwin32.f     \ NEXT for Win32forth

    FLOAD ..\..\src\pointer.f
    FLOAD ..\..\src\registry.f     \ Win32 Registry support
    FLOAD ..\..\src\winversion.f   \
    FLOAD ..\..\src\ansfile.f
    FLOAD ..\..\src\callback.f
    FLOAD ..\..\src\shell.f
SYS-FLOAD ..\..\src\imageman.f
    FLOAD ..\..\src\Keyboard.f     \ function and special key constants

\ ------------------------------------------------------------------------------
\ the Setup starts here...
\ ------------------------------------------------------------------------------

: ?win-error ( f -- ) drop ;
: seconds    ( n -- ) drop ;

FLOAD sub_dirs.f
FLOAD array.f            \ array words
FLOAD hyper.f            \ build hyper link index
FLOAD setup_dtop_lnk.f   \ create destop shortcuts

: allot-erase ( n -- )
        here over allot swap erase ;

create regsett maxstring allot-erase
create SystemDirectory$ MAX-PATH allot-erase

2 proc GetSystemDirectory
: GetSystemDirectory ( -- )   \ get Windows system folder
        MAX-PATH SystemDirectory$ char+ Call GetSystemDirectory
        SystemDirectory$ c! ; \ make counted string

\ Already in kernel

\ : .version      ( -- )
\                 base @ decimal
\                 ." Version: "
\                 version# ((version)) type
\                 ."  Build: " build# .
\                 base ! ;

: setupinit
\in-system-ok        3 Show-Window
        cls
        ." Win32Forth " .version ." - Setup Program" cr cr

        &forthdir ?-\
        &forthdir +null
        &forthdir count drop $current-dir! drop

        cmdline
        -if   ."   invoked with commandline <" type ." >" cr
        then
        s" console" getsetting regsett place \ save current console window size
        s" 80,80,600,400" s" console" setsetting
        GetSystemDirectory ;


: setup-bye     ( -- )
        \ make BYE a noop; so that destroying the console
        action-of bye ['] noop is bye \ window will not terminate the setup
        d_uninit-console                 \ destroy DOS Console if any
        _conHndl call DestroyWindow drop \ destroy new Console if any
        regsett count s" console" setsetting \ restore console window size in registry
        unload-forth 0 Call ExitProcess ; \ exit setup

: wait&bye
        cr ." Press any key to exit..." ekey drop setup-bye ;

3 proc CopyFile
: filecopy                              \ copy file ( from to -- )
          2dup swap
          ." Copying " count type ."  to " count type cr
          1+ swap 1+
          2>r 0 2r>
          call CopyFile 0=
          if ." *** filecopy failed ***" wait&bye then
          ;

: filedelete                            \ delete file
          ." Deleting file " count 2dup type cr
          delete-file
          drop ;

: filecheck                             \ check file exists
          ." Checking for built file " count 2dup type cr
          file-status
          if ." *** Process failed to complete successfully ***" wait&bye
          else ." Process completed successfully" cr then
          drop ;

: dashline
        ." ----------------------------------------------------------------------- " cr ;

1 #lexicon commands \ for commandline arguments

: SetUpForth    ( -- f )
        cmdline nip
        if ['] commands vcfa>voc 1 set-order cmdline empty-command-line evaluate false
        else
             dashline
             ." To Install Win32Forth Press one of these Keys" cr
             dashline cr
             ."      I  (Re)Install the entire Win32Forth system from scratch." cr
             ."      M  Same as install but, you can change the size of the" cr
             ."         Application-, System- and Codespace." cr
             ."      K  Meta compile a new Kernel (builds fkernel.exe) only." cr
             ."      E  Extend the kernel (builds a new win32for.exe)" cr
             ."      B  Rebuild win32for.exe (same as 'K' with setsize and 'E')" cr
             ."      W  Rebuild WinEd." cr
             ."      G  Rebuild Win32forth IDE." cr
             ."      A  Rebuild sample applications" cr
             ."      H  Rebuild the Hyper link indices used by WinEd and the Win32Forth IDE." cr
             ."      T  Rebuild Help program." cr
             ."      U  Rebuild Help words database (this is not done by default)." cr
             ."      R  Rebuild Help dexh HTML files (this is not done by default)." cr
             ."      D  Copy Win32Forth dll files (w32fScintilla.dll," cr
             ."         wincon.dll and Zip32.dll) into the Windows system folder:" cr
             ."         '" SystemDirectory$ count type ." ' (this is not done by default)." cr
             ."      X  Exit setup."
             true
        then ;

: checkend ( f -- )                     \ do we want to continue
          ." Press CTRL-C or ESC to abort..." cr
          ." Or press any other key to continue..." cr
          ekey dup 'C' +K_control =     \ ctrl-c
          swap k_ESC = or               \ esc
          if setup-bye                  \ exit
          then
          ;

: (checkcont) ( f -- )                  \ do we want to continue
          dashline
          cr if
          ." System will be built in directory " current-dir$ count type cr then
          cr
          ." Press CTRL-C or ESC to abort..." cr
          ." Or press any other key to continue..." cr
          ekey dup 'C' +K_control =     \ ctrl-c
          swap k_ESC = or               \ esc
          if
            ." *** Installation terminated ***" setup-bye
          then dashline cr
          ;

: checkcont                             \ do we want to continue
          true (checkcont) ;

: endedok
      cr dashline
      ." Requested build completed successfully" cr beep
      ." The rebuilt version is ready to load." cr cr
       checkend cls SetUpForth ;

: procexec                      \ pass to NT without any interpretation
                                \ f1 = TRUE on error
                [ also hidden ]
                dup ." Executing process <" count type ." >" cr

                ProcInfo 4 cells erase  \ clear procinfo
                >r                      \ null terminated parameter string
                ProcInfo                \ lppiProcInfo
                StartupInfo             \ lpsiStartInfo
                &forthdir count drop    \ lpszCurDir
                0                       \ lpvEnvironment
                0                       \ fdwCreate
                0                       \ fInheritHandles
                0                       \ lpsaThread
                0                       \ lpsaProcess
                r> 1+                   \ lpszCommandLine
                0                       \ lpszImageName
                call CreateProcess 0=
                if   ." *** CreateProcess failed ***"
                     wait&bye
                else
                     ." Waiting for process to finish..."
                     CloseThread           \ close the thread handle
                     EXEC-PROCESS-WAIT     \ wait for the process
                     CloseProcess          \ and close the process handle

                     _conHndl call SetForegroundWindow drop
                     ." process finished" cr
                     key? drop
                then

                [ previous ] ;

: cleanbuild ( f -- ) \ clean up the files before install
        cls cr
        if   c" HYPER.NDX" filedelete
\              c" HELP.NDX"  filedelete
        then
        c" FORTHFORM.EXE"       filedelete
        C" Player4.exe"         filedelete
        C" PlayVirginRadio.exe" filedelete
        c" PROJECT.EXE"         filedelete
        C" SciEditMdi.EXE"      filedelete
        C" solipion.exe"        filedelete
        C" Sudoku.exe"          filedelete
        c" WIN32FOR.EXE"        filedelete
        c" WIN32FOR.DBG"        filedelete
        c" Win32ForthIde.exe"   filedelete
        c" WINED.EXE"           filedelete
        c" PictureViewer.EXE"   filedelete
        c" Help.EXE"            filedelete
;

: buildstage1
        ." -- Stage 1" cr
        c" FKERNEL.EXE  fload src\extend.f bye"       procexec
        c" WIN32FOR.EXE"  filecheck
;

: buildmeta
        ." -- Meta Compile" cr
        c" WIN32FOR.EXE fload src\kernel\meta.f bye"  procexec
        c" FKERNEL.EXE"   filecheck
;

: buildmetafixed
        ." -- Meta Compile (fixed loadpoint)" cr
        c" WIN32FOR.EXE fload src\kernel\meta.f setsize bye" procexec
        c" FKERNEL.EXE"   filecheck
;

: buildextend
        ." -- Extend" cr
        c" FKERNEL.EXE  fload src\extend.f bye"       procexec
        c" WIN32FOR.EXE"  filecheck
;

: buildwined
        ." -- WinEd" cr
        c" WIN32FOR.EXE chdir apps\wined fload wined.f bye"  procexec
        c" WINED.EXE"     filecheck
;

: buildindex
        ." -- Hyper link indices" cr
\         ." -- building HELP.NDX" cr
\         s" HELP.CFG" PREPEND<HOME>\ &WINED.CFG place
\         s" HELP.NDX" PREPEND<HOME>\ &WINED.NDX place
\         build-index c" HELP.NDX" filecheck
        ." -- building HYPER.NDX" cr
        s" HYPER.CFG" &WINED.CFG place
        s" HYPER.NDX" &WINED.NDX place
        build-index c" HYPER.NDX" filecheck
;

: buildide
        ." -- Win32Forth IDE" cr
        c" WIN32FOR.EXE chdir apps\Win32ForthIDE fload main.f bye"     procexec
        c" Win32ForthIde.exe" filecheck
;

: buildsamples

        ." -- Sample applications" cr
        c" WIN32FOR.EXE chdir apps\Player4 fload Player4.f bye"   procexec
        c" Player4.EXE" filecheck

        c" WIN32FOR.EXE chdir apps\Solipon2 fload SOLIPION.F bye" procexec
        c" SOLIPION.EXE" filecheck

        c" WIN32FOR.EXE chdir apps\Sudoku fload Sudoku.F bye" procexec
        c" Sudoku.EXE" filecheck

        c" WIN32FOR.EXE chdir apps\PlayVirginRadio fload PlayVirginRadio.F bye" procexec
        c" PlayVirginRadio.EXE" filecheck

        c" WIN32FOR.EXE chdir apps\PictureViewer fload PictureViewer.f bye" procexec
        c" PictureViewer.EXE" filecheck

;

: buildhelp
        ." -- Help" cr
        c" WIN32FOR.EXE chdir help fload helpmain.f bye"     procexec
        c" HELP.EXE" filecheck
;

: buildWordDatabase
        ." -- Help" cr
        c" WIN32FOR.EXE chdir help fload helpbuildHDB.f bye"     procexec
        c" HELP.EXE" filecheck
;

: builddexhhelp
        ." -- Help" cr
        c" WIN32FOR.EXE chdir help fload helpCreateDexhDocs.f bye"     procexec
        c" HELP.EXE" filecheck
;

: copydll { addr \ buf$ } \ copy a dll into the windows system folder
        SystemDirectory$ c@
        if   MAX-PATH LocalAlloc: buf$
             SystemDirectory$ count buf$ place
             s" \" buf$ +place
             addr count buf$ +place buf$ +null
             addr buf$ filecopy
             buf$ filecheck
        then
;

: copywindowdll ( -- ) \ copy the win32forth dll's to the windows system folder
        c" w32fScintilla.dll"   copydll
        c" wincon.dll"          copydll
        c" Zip32.dll"           copydll
;

\ install processing
: (install)	 ( f -- )
        dup cleanbuild \ delete old EXE, DBG and NDX files
        buildstage1    \ create a temporary win32for.exe (used to metacompile the kernel)
        buildmeta      \ metacompile the kernel (build fkernel.exe)
        buildextend    \ extend the kernel (build win32forth.exe)
        buildwined     \ build WinEd
        if  buildindex \ build the index files for WinEd
        then
        buildsamples   \ build sample applications
        buildhelp      \ build help program (no database building there)
        buildide       \ build Win32Forth IDE
;

private commands internal

\ following words can be used on the commandline

' true  alias true  \ needed for commandline in commands lexicon
' false alias false \ needed for commandline in commands lexicon

: install-silent ( f -- )
        cls cr
        ." INSTALL SILENT requested" cr cr
        dashline cr
        (install)
        setup-bye
;

\ install processing
: install
        cls cr
        ." INSTALL requested" cr cr
        dashline cr
        ." We are going to briefly recompile Win32Forth from scratch. " cr
        ." If you don't wish to do this right now you can press ESC or" cr
        ." CTRL-C to abort now.                                       " cr
        cr
        ." GO AHEAD, touch enter, we think you will enjoy it. There is" cr
        ." an active group of us here to answer questions & help you. " cr
        ." Some do it for fun, some do it for intellectual stimulation." cr
        ." You can try again when ever you want, by running Setup.exe" cr
        ." again before using Win32Forth as this is a required step.  " cr
        cr dashline cr
        ." During the setup process, you will NOT be required to make " cr
        ." any interaction with the process. We will set your internal" cr
        ." user paths to your new configuration. We will be surprised " cr
        ." if it does not complete successfully.                      " cr
        cr
        ." Please make sure you're not running any other versions of  " cr
        ." Win32Forth; that is, you should save your work and end any " cr
        ." WIN3FOR.EXE, WINED.EXE, or FORTHFORM.EXE that might be     " cr
        ." running.  This is required for a successful meta-compile.  " cr
        cr
        ." If the above is not the cause of the problem, the task in  " cr
        ." error will wait for you to acknowledge it by pressing the  " cr
        ." <enter> key. Please note the error information (use copy)  " cr
        ." and paste into an email. Send this to us at the news group " cr
        ." win32forth@yahoogroups.com, where we will attempt to fix   " cr
        ." the problem.  Generally all goes well. :-)                 " cr
        cr
        ." Your USER PREFERENCES are set by clicking on the little man" cr
        ." in the green shirt on the menu bar at the top of WinEd.    " cr
        cr
        checkcont
        true (install)
        endedok
;

\ meta compile, full processing
: makeall
        cls cr
        ." MAKEALL requested" cr
        dashline
        ." Your system will be rebuilt, and you can change the size of the" cr
        ." Application-, System- and Codespace." cr
        checkcont
        buildmetafixed
        buildextend
        buildwined
        buildindex
        buildsamples   \ build sample applications
        buildide       \ build Win32Forth IDE
        buildhelp      \ build help program (no database building there)
        endedok
;

\ meta only
: meta  ( -- )
        cls cr
        ." META requested" cr
        dashline
        ." Rebuilding FKERNEL.EXE" cr
        checkcont
        buildmeta
        endedok
;

\ extend
: extend
        cls cr
        ." EXTEND requested" cr
        dashline
        ." Rebuilding WIN32FOR.EXE" cr
        checkcont
        buildextend
        endedok
;

\ metaextend
: metaextend
        cls cr
        ." METAEXTEND requested" cr
        dashline
        ." Rebuilding FKERNEL.EXE and" cr
        ." Rebuilding WIN32FOR.EXE" cr
        checkcont
        buildmetafixed
        buildextend
        endedok
;

\ wined
\ changed September 10th, 2003 - 12:51 dbu
: wined
        cls cr
        ." WINED requested" cr
        dashline
        ." Rebuilding WINED.EXE" cr
        checkcont
        buildwined
        endedok
;

\ index
\ new September 10th, 2003 - 12:51 dbu
: index
        cls cr
        ." INDEX requested" cr
        dashline
        ." Rebuilding index files" cr
        checkcont
        buildindex
        endedok
;

\ Win32ForthIDE Editor
\ Mittwoch, Juni 07 2006 - 18:01 dbu
: ide
        cls cr
        ." Win32Forth IDE requested" cr
        dashline
        ." Rebuilding Win32Forth IDE" cr
        checkcont
        buildide       \ build Win32Forth IDE
        endedok
;

\ Sample applications
\ new Samstag, Juni 11 2005 - 8:41  dbu
        : samples
        cls cr
        ." Sample applications requested" cr
        dashline
        ." Rebuilding Sample applications" cr
        checkcont
        buildsamples
        endedok
;

: help
        cls cr
        ." Help program requested" cr
        dashline
        ." Rebuilding Help program" cr
        checkcont
        buildhelp       \ build help program
        endedok
;
: WordDatabase
        cls cr
        ." Help words databse requested" cr
        dashline
        ." Rebuilding Help words database" cr
        checkcont
        buildWordDatabase      \ build help words database
        endedok
;
: dexhhelp
        cls cr
        ." Help dexh html requested" cr
        dashline
        ." Rebuilding Help dexh html" cr
        checkcont
        builddexhhelp       \ build help dexh html files
        endedok
;

: dllcopy
        cls cr
        ." DLL copy requested" cr
        dashline
        ." Copy Win32Forth dll's to the windows system folder '"
        SystemDirectory$ count type ." '" cr
        false (checkcont)
        copywindowdll
        endedok
;

: create-links
        cls cr
        ." Createing of shortcuts requested" cr
        false (checkcont)
        create_links_on_desktop
        endedok
;

external

2 PROC SetWindowText

: setup ( -- ) \ Install win32forth
        show-console normal-console

        z" Win32Forth Setup" CONHNDL call SetWindowText drop

        cls setupinit SetUpForth
        if   begin key upc         \ handle keyboard interpretation
                   case
                     'I'            of install        endof
                     'M'            of makeall        endof

                     'K'            of meta           endof
                     'E'            of extend         endof

                     'B'            of metaextend     endof

                     'W'            of wined          endof
                     'H'            of index          endof
                     'G'            of ide            endof
                     'A'            of samples        endof

                     'T'            of help           endof
                     'U'            of WordDatabase   endof
                     'R'            of DexhHelp       endof

                     'D'            of dllcopy        endof

                     'X'            of setup-bye      endof

                      \ 'Hidden' command's
                     'L'            of create-links   endof
                     'C'            of true  install-silent endof
                     'V'            of false install-silent endof
                   endcase
             again
        then ;

module

\ create setup.exe

DosConsoleBoot

' setup s" Setup.exe" Prepend<home>\ \ "SAVE
s" '" pad place pad +place s" '" pad +place pad count ' turnkey execute-parsing \ cludgy but it works

Require Resources.f

s" src\res\Win32For.ico" Prepend<home>\ pad place pad count s" Setup.exe" Prepend<home>\ AddAppIcon

Require Checksum.f

s" Setup.exe" prepend<home>\ (AddCheckSum)

\ wait&bye  \ Was hanging the installation
setup-bye

\s
