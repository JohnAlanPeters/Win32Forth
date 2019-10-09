Anew -Win32ForthInstaller.f

vocabulary installer
only forth also installer definitions

    needs mkdir.f
    needs sub_dirs.f
    needs RtfWindow.f
    needs lz77files.f
    needs Browsefld.f
    needs Installerform.f

only forth also installer also forth definitions
   0 value pidlRoot    here 0 , to pidlRoot
   0 value lpszTitle   here 0 , to lpszTitle
   0 value pszDisplayName   here 0 , to pszDisplayName


: filecheck ( adr$ - )                        \ check file exists
    cr ." Checking for built file " count 2dup &\\convert type cr
    file-status
          if ." *** Process failed to complete successfully ***"  cr cr
          else ." Process completed successfully" cr then
          drop
 ;

: +temp$ ( adr count -- ) temp$ +place ;

: filecheckNew ( file count - )
   target-dir count temp$ place
   s" \" +temp$ +temp$ temp$ filecheck
 ;

string: new-dir$
string: saved-target-dir

: install-dir    ( adr - flag )
  new-dir$ off z" \_Win32Forth_" new-dir$ LiveLogWindow.hwnd  BrowseForFolder not
    if    drop false
    else  new-dir$ count rot +place true
    then
 ;

: procexec    ( - )                  \ pass to NT without any interpretation
                [ also hidden ]
                dup  cr ." Executing process <" count  &\\convert type ." >"  \ **
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
                      5000 ms bye
                else
                      cr ." Waiting for process to finish..."
                     CloseThread           \ close the thread handle
                     EXEC-PROCESS-WAIT     \ wait for the process
                     CloseProcess          \ and close the process handle
                     _conHndl call SetForegroundWindow drop
                    cr ." process finished"
                     key? drop
                then
                [ previous ]
 ;

create quote$ 1 c, ascii " c,

: [cr]  ( - )
  ['] noop is PrepareRtfOut$  Rtf_cr
  ['] &\\convert is PrepareRtfOut$
 ;

: chdir-install-dir  ( - )  saved-target-dir count "chdir ;

: MetacompileKernel ( - )
    ." -- Metacompiling the kernel..." cr
    target-dir dup +NULL count  &prognam place
    ['] &\\convert is PrepareRtfOut$   ['] [cr]  is cr
\in-system-ok  s" src\kernel\meta.f" included
    ['] noop is PrepareRtfOut$  ['] Rtf_cr is cr
 ;

: ProcexecOnKernelNew ( - )
    s" fkernel.exe z" temp$ place
    quote$ count +temp$  s"  " +temp$ target-dir count +temp$ quote$ count +temp$
    s"  $current-dir! drop current-dir$ count cr type " +temp$
    +temp$ temp$ procexec
 ;

: CompileWin32Forth ( - )
    ." -- Compiling Win32Forth..." cr
    s" fload src\extend.f bye " ProcexecOnKernelNew
    s" Win32for.exe" 		filecheckNew
 ;

: ProcexecNew  ( command count - )
    target-dir count temp$ place
    s" \WIN32FOR.EXE " +temp$ +temp$  s"  " +temp$
    temp$ procexec
 ;


: BuildApps ( - )
    cr ." -- Win32Forth support files:" cr

    cr ." -- Setup" cr
     ." Executing apps\\Setup\\MakeSetup.bat"
    s" apps\Setup" "chdir
    s" MakeSetup.bat" dos$ place dos$ $exec drop 3000 ms
    s" Setup.exe" 		filecheckNew

    cr ." -- Win32Forth IDE"
    s"  idir apps\Win32ForthIDE fload Main.f bye" ProcexecNew
    s" Win32ForthIde.exe" 	filecheckNew

    cr ." -- WinEd"
    s" idir apps\wined fload wined.f bye"  ProcexecNew
    s" WINED.EXE"     filecheckNew

    cr ." -- Help"
    s" idir help fload helpmain.f bye"		  ProcexecNew
    s" HELP.EXE" 		filecheckNew

    cr ." -- Build HYPER.NDX"
    s" fload apps\setup\Hyper.f build-index bye"  ProcexecNew
    s" HYPER.NDX" 		filecheckNew

    cr ." -- Create Dexh files "
    s" idir help fload helpCreateDexhDocs.f bye"  ProcexecNew
    s" Help\html\dexh-ansfile.htm" filecheckNew

    cr ." -- Build Help Database"
    s" idir help fload helpbuildHDB.f bye"	   ProcexecNew
    s" Help\hdb\HelpWrd.tv" filecheckNew


    cr ." -- Sample applications:" cr

    s" idir apps\Player4 fload Player4.f bye"     ProcexecNew
    s" Player4.EXE"       	filecheckNew

    s" idir apps\Solipon2 fload SOLIPION.F bye"   ProcexecNew
    s" SOLIPION.EXE"		filecheckNew

    s" idir apps\Sudoku fload Sudoku.F bye"       ProcexecNew
    s" Sudoku.EXE" 		filecheckNew

    s" idir apps\PlayVirginRadio fload PlayVirginRadio.F bye" ProcexecNew
    s" PlayVirginRadio.EXE" 	filecheckNew

    s" idir apps\PictureViewer fload PictureViewer.f bye"    ProcexecNew
    s" PictureViewer.EXE" 	filecheckNew
 ;

: create-links ( - )
    cr ." -- Create links"
    LinksOnDesktop-
       if   s" idir apps\Setup fload Setup_dtop_lnk.f create_links_on_desktop bye"
            ProcexecNew
       then
    LinksInMenu-
       if   s" idir apps\Win32ForthInstaller fload LinksInGroup.f create_links_in_group bye"
            ProcexecNew
       then
 ;

: filedelete   ( name$ count - )    \ delete existing file
    2dup file-exist?
     if    ." Deleting file " 2dup type cr delete-file drop
     else  2drop
     then
 ;

: cleanbuild (  -- ) \ clean up the files before install
        s" HYPER.NDX"           filedelete
        s" HELP.NDX"            filedelete
        s" FORTHFORM.EXE"       filedelete
        s" Player4.exe"         filedelete
        s" PlayVirginRadio.exe" filedelete
        s" PROJECT.EXE"         filedelete
        s" SciEditMdi.EXE"      filedelete
        s" solipion.exe"        filedelete
        s" Sudoku.exe"          filedelete
        s" WIN32FOR.EXE"        filedelete
        s" WIN32FOR.DBG"        filedelete
        s" Win32ForthIde.exe"   filedelete
        s" WINED.EXE"           filedelete
        s" PictureViewer.EXE"   filedelete
        s" Help.EXE"            filedelete
 ;

: Win32Folder" ( - adr cnt )   s" \Win32Forth" ;

: MakeInstallDir ( - )
   Win32Folder" target-dir +place target-dir count
   2dup dir-exist? not
      if   ." Creating the install directory "  2dup  mkdir
      then
   saved-target-dir place cr UpdateLog
 ;

: .fail ( - ) cr ." The installation failed. " ;

\ Status for SetupInstallDir:
\ True  when a folder is selected
\ False when no folder is selected
\ idcancel When no folder selected.
: SetupInstallDir ( - Status )
    target-dir install-dir dup not
      if    drop cr ." No folder selected." .fail idcancel
      else  target-dir count + 1- c@ ascii \ =
               if  target-dir count 1- swap 1- c!  then
            cr ." Install directory: " target-dir count &\\convert type cr cr
      then
 ;

: OverwriteTest ( - Flag ) \ True when a *.cfg file exist
    target-dir count temp$ place
       Win32Folder" temp$ +place
    s" \*.cfg" temp$ +place temp$ count file-exist?
 ;

: WaitOnStartInstallForm ( - Flag )
    begin   200 ms winpause IdOnClose 0<>   until  IdOnClose IDOK =
 ;

: Install_Y/N? ( - )
    0 to IdOnClose  OverwriteTest
      if   s" Warning: OVERWRITING a previous Win32Forth installation."
           ." Warning: Found a previous Win32Forth installation." cr
           ." The install directory should be empty." cr cr
      else s" Installing Win32Forth."
      then TitleInstallForm place
    Start: InstallForm WaitOnStartInstallForm
 ;

create logfilename$ ," \logging.rtf"

: unpack/install ( - )
   ['] buffer-char   is Write-Char  target-dir off
\in-system-ok    .version  .platform cr
   ." Current directory: " current-dir$ count &\\convert type cr
   cr ." -- Creating the Win32Forth environment"  cr
   SetupInstallDir idcancel = if  exit  then
   Install_Y/N?
         if Nomenu SetMenuBar: LiveLogWindow  update: LiveLogWindow
            MakeInstallDir
            target-dir count  dir-exist? not
                if  cr ." The install direcory does not exist."  cr .fail exit then
            decompress
            saved-target-dir count target-dir place
            cr ." -- Setting up the system: " cr cr  UpdateLog
            chdir-install-dir program-path-init
            cleanbuild         MetacompileKernel   chdir-install-dir
            CompileWin32Forth  BuildApps           create-links
            LiveLogWindowMenuBar SetMenuBar: LiveLogWindow
      else  ." Installation canceled."
      then
 ;

also rtf

: InstallWin32Forth ( - )
    current-dir$ count logfile$ place logfilename$ count logfile$ +place
    OpenLogfile   \ Optional. Disable this line to prevent the use of a logfile.
    Rtf[ IncludeRtfHeader
    Logline[ cr \ltyellow \highlight PromptTime ."  Start installation " 0 \highlight \par
    unpack/install
    logfile$ count logfilename$ count  nip - "chdir
    cr cr ." Location logfile: " logfile$ count &\\convert type
    cr \ltyellow \highlight  PromptTime  ."  End installation "  0 \highlight \par
    ]Logline ]Rtf CloseLogFile
 ;

previous

: StartInstallWin32Forth ( - )
   Start: LiveLogWindow
   GetHandle: LiveLogWindow SetParent: InstallForm
   InstallWin32Forth
 ;

chdir ..
chdir ..

compress-forth \ compress and move the files into the dictionary

Wf32LzFile"  DELETE-FILE DROP

String: Progname$
s" w32f" Progname$ place VERSION# (.) Progname$ +place s" .exe" Progname$ +place

NoConsoleBoot        ' StartInstallWin32Forth  Progname$ count "SAVE
s" apps\Win32ForthInstaller\W32FInstaller.ico" Progname$ count AddAppIcon
5 pause-seconds bye

\s
