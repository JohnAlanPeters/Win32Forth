aNew RtfLogger.f  \ January 8th, 2016

needs RichEdit.f
\- textbox needs excontrols.f
needs multiopen.f
needs Resources.f
needs MultiTaskingClass.f
needs RtfGenerator.f

\ Notes:
\ Word and Wordpad show the colors of the hightlighted texts right.
\ OpenOffice Writer not. It lacks the command \highlightN.

Variable _x
Variable _y
Variable _width
Variable _Height

defer ExitAppl
defer ExitLogfile
maxstring create logfile$ allot
s" logging.rtf" logfile$ place

map-handle logfile-mhndl

: MapLogFile	( -- )	logfile$ count logfile-mhndl open-map-file throw	;
: UnmapLogFile	( -- )	logfile-mhndl  close-map-file drop ;

 MENUBAR Nomenu
    POPUP " Installing... "
    menuitem " Close this menu to continue" noop ;
 ENDBAR


 MENUBAR  ApplicationBar
    POPUP "File"
        menuitem "Exit " ExitLogfile ;
    ENDBAR


wTasks LogTasks		\ Make the object LogTasks.

: MessageLoopThread ( -- )
\ This word launches a message loop. It will exit when it receives a WM_QUIT message.
	BEGIN	0 0 0 MessageStructure Call GetMessage
	WHILE	MessageStructure HandleMessages drop
	REPEAT
 ;

0 value #snapshots
String: SnapshotTitle$ s" Snapshot" SnapshotTitle$ place

:Class SnapshotWindow   <Super Window \ To view a snapshot of the logfile in a separate thread.
RichEdit RichEdit_logFile

:M On_Init:     ( -- )
                On_Init: super
                ApplicationBar	SetMenuBar: 	Self
	                self	Start:          RichEdit_logFile
                        true	ReadOnly:       RichEdit_logFile
                ;M

:M On_Size:     ( s -- )
                  SIZE_MINIMIZED <>
                     if  Width  Height 0 0 2swap Move: RichEdit_logFile
                         Update:  RichEdit_logFile
                      then
                ;M

:M StartSize:   ( -- w h )
                 _width @ _Height @ 2dup or 0=
                       if  2drop  800 250
                       then
                  80 max
                ;M

:M StartPos:	( -- x y )	#snapshots 30 * CenterWindow: Self >r over + swap r> +	;M

:M WindowTitle:	( -- Zstring )  s" Snapshot: " SnapshotTitle$ place
                                logfile$ count SnapshotTitle$ +place
                                SnapshotTitle$ +null SnapshotTitle$ 1+ ;M

:M Close:  	( - )
		-1 +to #snapshots
		UnmapLogFile  call GetActiveWindow
		0 0 WM_QUIT 3 pick Call PostMessage drop \ To end the Job, preventing pending jobs
		call DestroyWindow  ?winerror
		;M

:M Start:	( - )
          logfile$ count file-status  nip
          if    true s" Logfile does niet exist" ?MessageBox
          else  Start: Super
                #snapshots GetThreadcount: LogTasks  <
	           if	MapLogFile logfile-mhndl  >hfileLength @

				SetTextLimit: 	RichEdit_logFile
                        logfile-mhndl >hfileAddress @
                                SetTexTex:      RichEdit_logFile
				ToLastLine: RichEdit_logFile
                   else	beep  true  s" No threads left.\nClose a previous snapshot" ?MessageBox
			Close: Self
                   then
          then
		;M

:NoName 	( - )   	Close: Self ;  is ExitLogfile

;Class


: StartSnapshotWindow	( - )
      1 +to #snapshots   New> SnapshotWindow start: [ ]  MessageLoopThread ;

: .tblk  .ThreadBlock: LogTasks ;	\ To check if all threads are complete


 MENUBAR  LiveLogWindowMenuBar
    POPUP "File"
        menuitem "Show the complete logfile" ['] StartSnapshotWindow Submit: LogTasks ;
        menuitem "Exit"  bye ;
    ENDBAR


:OBJECT LiveLogWindow <Super Window	\ To view the logging as it happens
RichEdit RichEdit_1

Font WinFont
ColorObject FrmColor

:M ClassInit:  ( -- )	ClassInit: super ;M

: windowposition ( - )
    WndRect.AddrOf hWnd Call GetWindowRect
                     if      WndRect.Left _x !
                             WndRect.Top  _y !
                     then
 ;

:M UpdateText: ( -- )	&buffer cell+ SetTexTex: RichEdit_1	;M

:M UpdateLogText: ( -- )
                UpdateText: Self
                ToLastLine: RichEdit_1
                winpause
  ;M

:M WindowHasMenu:       ( -- f )                true                    ;M

:M On_Init:     ( -- )
                On_Init: super
                Start: LogTasks		\ Initialize the object myTasks.
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor
                LiveLogWindowMenuBar SetMenuBar: Self

                self		Start:          RichEdit_1
                true		ReadOnly:       RichEdit_1
                false		AutoUrlDetect:  RichEdit_1
                /buffer		SetTextLimit: 	RichEdit_1
                &buffer cell+	SetTexTex:      RichEdit_1
                ;M

:M On_Size:     ( s -- )
                 SIZE_MINIMIZED <>
                     if  Width  dup _Width !
                         Height dup _Height !
                         0 27 2swap 27 - Move: RichEdit_1
                     then
                ;M

:M WM_MOVE	( wparam lparam -- res )	2drop windowposition 0	;M

:M Close:       ( -- )
		Delete: WinFont
		bye
               ;M


:M StartSize:     ( -- width height )
                 _width @ _Height @ 2dup or 0=
                       if  2drop  800 250
                       then
                  80 max
                 ;M

:NoName			( - )		Close: 		Self ;  is ExitAppl
:M ExWindowStyle:	( -- style )	ExWindowStyle:	SUPER ;M
:M WindowTitle:		( -- title )	z" Win32Forth Installer" ;M

:M StartPos:		( -- x y )
         _width @ _Height @ or 0=
                if      CenterWindow: Self drop 50
                else    _x @ _y @
                then
          ;M

;OBJECT


0 value hLogfile	\ Should contain 0 when not used

: OpenLogfile ( - )   	\ creates one when it does not exist
    logfile$ count  2dup file-status  nip
        if      r/w create-file abort" Can't create the file"
        else    r/w   open-file	abort" Can't open the file for writing"
                dup file-append abort" Can't extend/write the logfile"
        then
  to hLogfile
 ;

: CloseLogFile  ( - )
  hLogfile dup 0<>
    if    close-file drop
    else  drop
    then
 ;

: WriteLogline  ( adr cnt -- )
   hLogfile file-size drop 1 s>d d-  hLogfile resize-file drop \ remove the previous closing char
   hLogfile write-file abort" Can't write to logfile."
   s" }" hLogfile write-file drop     \ Adding the closing char
   hLogfile flush-file drop
 ;

0 value &logline \ Start of the last logline
0 value /logline \ Size of the last logline

: Logline[ ( -- )  &buffer lcount + to &logline ;

: ]Logline ( -- )
    hLogfile 0<>
       if  &buffer lcount + &logline - to /logline
           &logline /logline writeLogline
       then
 ;


: PromptTime	( - )	.date space  .time time-buf 14 + w@ ." ."  3 .#" type ;
: .Complete 	( - )	."  COMPLETE " ;
: .Failed   	( - )	\bullet \ltred \highlight \ulwave ."  failed " \ulnone 0 \highlight \bullet ;

: Logline   ( n - )     \ To put some text in a window and save it ( optional ) in a logfile
    >r cr 15 \fs  PromptTime  ."  - " 20 \fs
    r> 0 u,.r space ." test:"
    100 random 1 and    \ Perform some test
       if    .Complete  \ Print the result
       else  .Failed
       then
 ;

: IncludeRtfHeader ( -- )
    Rtf_clr  hLogfile 0<>  \ To the logfile when a logfile is opened
        if hLogfile file-size drop 10 s>d du<
               if     s" -" hLogfile write-file drop \ hLogfile flush-file drop
                      Logline[  RtfHeader  ]Logline
               else   RtfHeader
               then
           else   RtfHeader
           then
 ;

previous

: UpdateLog ( - )  UpdateLogText: LiveLogWindow ;

: Rtf_cr_logging	( -- )
   ." \line" 1 +to #lines +Ctrl_cr
   #lines /linesScreen >
      if    1 FindLine  dup 2 + negate +to &logline
            DeleteLine
      then
   UpdateLogText: LiveLogWindow ;

 ' Rtf_cr_logging is Rtf_cr \ To update the window with the rft colntrol

\s Eg:

also rtf
: test
    OpenLogfile   \ Optional. Disable this line to prevent the use of a logfile.
     Rtf[ IncludeRtfHeader
     Logline[  0 \f 20 \fs
               cr  PromptTime  \ltyellow \highlight ."  Start testing " 0 \highlight ]Logline
         44 0  do   Logline[ i Logline ]Logline
               loop
    Logline[  cr PromptTime  \ltyellow \highlight  ."  End testing "  0 \highlight \par ]Logline
    ]Rtf CloseLogFile
;

previous

: StartLogger          ( -- )
    Start: LiveLogWindow
    test
;

StartLogger abort
