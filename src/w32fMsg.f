\ $Id: w32fMsg.f,v 1.22 2013/11/15 19:35:03 georgeahubert Exp $

\ w32fmsg.f

\ By Camille Doiteau [cdo] - 2008/05/20
\ Based on the work of some "unknowned" authors + dbu + gah + Jos


cr .( Loading w32fmsg.f : w32f applications communication words...)
\ only forth also definitions
\ IN-APPLICATION
\ anew -w32fmsg.f
\ needs w32fMsgList.f  ( but is already loaded in extend.f )
\ needs MapFile.f      ( but is already loaded in extend.f )


\ *T Inter-process interaction & communication

\ *Q Abstract
\ ** This module provides a flexible and reasonnably robust way of dealing with
\ ** inter-process interaction and communication.


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ----------------------- PART ONE : SHARED MEMORY -----------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

\ *S Enabling inter-win32forth-process interaction & communication

\ *P In the following, a "win32forth application" is either win32for.exe
\ ** itself or any program saved using \tSAVE\d or \tTURNKEY\d and
\ ** having its own main window or using the Console window.

\ *P Saying that a win32forth application has its "inter-process interaction and
\ ** communication" features enabled means :
\ *B It has a unique application identifier
\ *B It can exchange messages with other win32forth applications whose
\ ** inter-process features are activated too.
\ *B It can run as a single instance if it wants
\ *B it can be launched by another win32forth application, ready for communication

\ *P Technical note: Internally, these features are implemented through
\ ** "shared memory" or "file memory mapping against paging".

\ *P Example :
\ ** Here is a typical sequence of code you will have at the end of your
\ ** source : a MAIN word for starting your application, which creates your
\ ** main window, and a sequence to create a \tTURNKEY\ded app (\tSAVE\d can
\ ** be used too, as well as you can use the Console window instead of a
\ ** window of your own) :

\ *E true/false value Turnkey?
\ **
\ ** : Main   ( -- )
\ **          ...
\ **          Start: MyMainWindow
\ **          turnkeyed? if GetHandle: MyMainWindow EnableW32FMsg then  \ line (*3*)
\ **          ...
\ **          ;
\ **
\ **
\ ** turnkey? Nostack
\ ** [if]   &forthdir count &appdir place
\ **        9999 to NewAppID                           \ line (*1*)
\ **        true to RunUnique                          \ line (*2*)
\ **        ' Main turnkey MyApp.exe
\ **        1 pause-seconds bye
\ ** [else]
\ **        Main
\ ** [then]

\ *P The lines marked (*1*) (*2*) and (*3*) are all you need to set your
\ ** application's inter-process identification & communication capabilities.

\ *P The default action is using none of these lines, the result in this case is:
\ *B While developping, your program is considered to be win32Forth itself.
\ ** It is able to communicate with Help and IDE, for example for using the debugger.
\ *B If you save your program (using either \tSAVE\d or \tTURNKEY\d )
\ ** its application ID will be set to 0 and its communication features disabled.

\ *P For the next options, you have to provide a unique ID for your application.
\ ** For applications added to the win32Forth system, IDs (together with any message
\ ** that could be handled) must be registered in the file w32fMsgList.f. For user
\ ** applications, it is a good idea to consult this file to choose unused IDs for
\ ** application and messages. Then :

\ *B Use line (*1*) to give your application a new unique ID (9999 in the example
\ ** above). This will activate shared memory for it, and thus inter-process interaction.

\ *B Notice that you MUST NOT use (*1*) in the \t[else]\d part following the
\ ** \tturnkey?\d test. This means that when you run your application under Forth,
\ ** its ID remains Forth's one (that allows for use of remote debugger, help, etc).
\ ** If you need to test your application under its new ID, simply \tSAVE\d it under
\ ** a new name. You will no longer have remote debugging capabilities but all the
\ ** interpreter facilities will still be there for debugging. This allows to test 2
\ ** applications of yours that need communicating. When everything is ok you can
\ ** \tTURNKEY\d your applications.

\ *B If you want your application to run as a single instance, add the line (*2*).

\ *B Once shared memory is enabled for each application, you can enable communication
\ ** between them by providing the handles of windows that will receive messages. Do
\ ** this with the line (*3*) command. Now the applications are ready to exchange messages.
\ ** \n\bNotice that it may be better to put this line in the On_Init method of your
\ ** main window in order to set it sooner\d.


\ ------------------------------------------------------------------------------
\  Shared memory for inter-win32forth applications identification
\ ------------------------------------------------------------------------------

Require w32fMsgList.f

Require mapfile.f

\ 0 value MyAppID
\ *G My unique current win32forth application identifier \n
\ ** A value of 0 means I don't share memory \n
\ ** READ-ONLY : DON'T change this value directly, set \tNewAppID\d instead.

\ 0 value NewAppID
\ *G Set this value to change the ID of your application \n
\ ** Change will be effective after either \tSAVE\d or \tTURNKEY\d .
\ ** A value of 0 (which is the default) means I don't share memory \n
\ ** Used to configurate your application

\ 0 value RunUnique
\ *G Set this value to true if you want your application to run as a unique instance \n
\ ** Change will be effective after either \tSAVE\d or \tTURNKEY\d . \n
\ ** Used to configurate your application

\ 0 value MyRunUnique    \ true if I am running as a unique instance
 create w32fshareName  \ a complex enough win32forth application shared-memory name
        z," *.Win32ForthSharedMemory.*"
0 value w32fshareh     \ win32forth application shared-memory handle
0 value w32fsharep     \ win32forth application shared-memory pointer


\ Shared memory data structure
\ ----------------------------
\ The shared memory contains one record for each currently running process.
\ Each record contains :
\ - the win32forth application unique ID
\ - the hwnd of the window that must handle messages

\ IMPORTANT NOTE :
\ ****************
\ HWnd is a unique identifier across all w32fapps but w32fappID is not (if
\ multiple instances of the same process are running). This package uses only
\ the w32fappID parameter to communicate, so, in case of multiple instances,
\ you wouldn't know which one would receive any message sent.
\ No attempt was made to uniquely identify an instance by the couple appID/hwnd,
\ mainly because handling multiple instances would remain very complex from the
\ developper point of view.
\ Instead we ASSUME THAT ONLY ONE INSTANCE of each communicating process is present.
\ To "guarantee" that only one instance can communicate, the following features
\ are provided :
\ - you can force an application to run as a unique instance
\ - in case of multiple instances allowed, only one shares memory, the rules are :
\   - the first instance shares memory
\   - next ones won't share memory
\   - if the first instance is closed, the NEXT launched one will share memory.

: IsRunning?    ( AppID -- flag )
\ *G true if an instance of AppID is already running
                w32fsharep 0=
                abort" Need to share memory to use this word"
                w32fsharep
                begin  2dup @ = if 2drop -1 exit then
                       dup @ while
                       2 cells +
                repeat 2drop 0 ;

: EnableW32FMsg ( hwnd -- )
\ *G Set the window handle of your application for inter-process communication \n
\ ** Used to configurate your application
                w32fsharep 0= if drop exit then
                dup IsWindow 0=
                abort" in EnableW32FMsg : Not a valid window handle"  \ just in case...
                w32fsharep
                begin  dup @ MyAppID =             \ if this is my appID
\ don't be tempted to do that ! :  over cell+ @ 0= and   \ and hwnd is still empty
                       if cell+ ! exit then        \ it's me, save my hwnd
                       dup @ while
                       2 cells +
                repeat 2drop
                -1 abort" in EnableW32FMsg : Enable shared memory before messaging" ;

: (?EnableConsoleMessages) ( -- )
                MyAppID w32fForth =             \ if win32for.exe itself
                if conhndl EnableW32FMsg then ; \ enable messaging thru Console

: Set?EnableConsoleMessages ( -- )
                ['] (?EnableConsoleMessages) is ?EnableConsoleMessages ;

initialization-chain  chain-add         Set?EnableConsoleMessages

: SetShared    ( AppID -- ) \ append AppID record in shared memory
                w32fsharep                      \ get next available record
                begin  dup @ while
                       2 cells +
                repeat
                swap over !                     \ store AppID
                0 swap cell + ! ;               \ store dummy hwnd for now

: ResetShared   { AppID \ addrme addrend -- } \ remove AppId from shared memory
                w32fsharep
                begin  dup @ ?dup while       \ get addr of end of records
                       AppId =
                       if dup to addrme then  \ and addr of my instance
                       2 cells+
                repeat to addrend
                addrme 2 cells+               \ addrfrom
                addrme                        \ addrto
                addrend addrme - 2 cells+     \ count that move trailing nulls
                cmove ;                       \ remove me
                \ Note: if 2 same apps were running, the one that will be
                \ removed would always be the first one

: SharedAppID   ( hwnd -- w32fappID ) \ Get application ID in shared memory,
                \ given its window handle, 0 = not found
                w32fsharep 0= if drop 0 exit then
                w32fsharep
                begin  2dup cell+ @ = if nip @ exit then
                       dup @ while
                       2 cells+
                repeat 2drop 0 ;

: SharedHwnd    ( w32fAppID -- hwnd ) \ Get window handle in shared memory,
                \ given an application ID, 0 = not found \n
                \ (if multiple instance, the first one will be found)
                w32fsharep 0= if drop 0 exit then
                w32fsharep
                begin  2dup @ = if nip cell+ @ exit then
                       dup @ while
                       2 cells +
                repeat 2drop 0 ;

: .Shared       ( -- )
\ *G Show current contents of win32forth applications shared memory
                cr
                cr ." Win32Forth applications shared memory"
                w32fsharep 0=
                if   cr ."       -- no shared memory --"
                else cr ." w32fappID  hwnd  "
                     cr ." -----------------"
                     w32fsharep
                     begin  dup @ while
                            cr dup @ . cell+ dup @ . cell+
                     repeat drop
                then ;


\ Shared memory init/uninit
\ -------------------------

\ Note: the very last (inter-process) call to close-share will destroy the
\       "file" mapping object
: CloseSharedMemory ( -- ) \ close win32forth application shared memory
		w32fsharep w32fshareh close-share
                0 to w32fsharep
                0 to w32fshareh ;

\ Note: If a process crashes, Windows will free its handle to shared memory
\       BUT the AppID & hwnd will remain in shared memory. This is why we check,
\       when testing if an app is already present, if its hwnd is still valid.
\       If not, the first thing we do is remove the "ghost" instance.
: ?RemoveGhost	{ aAppId -- } \ remove any "ghost" instance
                aAppId IsRunning?
                if   aAppId SharedHwnd IsWindow not
                     if aAppId ResetShared then
                then ;


\ Note: the very first (inter-process) call to open-share will erase the mapped
\       "file" contents.
\ Note: StopLaunching is used in boot in imageman.f to stop a process launch
\       when needed.
\ Note: If launching is stopped, UninitSharedMemory will be executed thru BYE
: InitSharedMemory ( -- ) \ Init win32forth application shared memory
                0 to w32fsharep                       \ initialize to not present
                0 to w32fshareh
                MyAppID 0= ?exit                      \ I don't share memory
                w32fshareName 1024 open-share ?dup
                if   to w32fshareh
                     to w32fsharep

                     MyAppID ?RemoveGhost             \ first remove any "ghost" instance

                     MyAppID IsRunning?               \ if I am really running
                     if   MyRunUnique                 \ and must be unique
                          if   true to StopLaunching  \ stop me
                          else false to StopLaunching \ if running & new instance
                               CloseSharedMemory      \ launch but don't register
                          then
                     else false to StopLaunching      \ if I am not running
                          MyAppID SetShared           \ launch & register
                     then                             \ notice that my hwnd is not yet set
                else drop
                then ;

: UninitSharedMemory ( -- ) \ Uninit win32forth application shared memory
                w32fsharep 0<>                      \ only if I shared memory
                if   StopLaunching not              \ if I did register..
                     if MyAppID ResetShared then    \ ..then unregister
                     CloseSharedMemory              \ in all cases, close
                then ;

initialization-chain  chain-add         InitSharedMemory
unload-chain          chain-add-before  UninitSharedMemory

: RunAsNewAppID ( -- ) \ Set the application's inter-process communication
                \ capabilities using current NewAppID and RunUnique flags
                \ Remember: hwnd must be set again after use of this word
                UninitSharedMemory            \ remove my previous ID
		RunUnique to MyRunUnique      \ set new app flags
                NewAppID to MyAppID
                InitSharedMemory              \ add my new ID
                0 to RunUnique                \ restore defaults
                0 to NewAppID ;


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------- PART TWO : WIN32FORTH MESSAGES ---------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

\ *S Exchanging messages between win32forth applications

\ *P Once two win32Forth applications are running with inter-process communication
\ ** enabled, they can implement win32forth-specific message handling.

\ *P Technical note: internally, Win32Forth use the Windows' special message
\ ** WM_COPYDATA, that can send any block of data to another window.

\ *P Each application can create a set of win32forth-specific messages, identified
\ ** by custom messages numbers. These message identifiers must be loaded in both
\ ** applications so that they understand each other.

\ *P The contents of a win32forth
\ ** message is a data area represented by its address and size. This data must be
\ ** considered as \bread-only\d and remains \bvalid only in the receiver's message
\ ** handler\d. You should make a local copy if you want to override this rule.


\ *A How to send a win32forth message :

\ *P This is simple : use \tSendw32fMsg\d if you want to send a message to a
\ ** particular application, or \tBroadCastw32fMsg\d if you want to broadcast a message
\ ** to all running applications.

4 PROC SendMessage

create COPYDATASTRUCT
       0 ,            \ dwdata     used to carry the w32f sub-message id
       0 ,            \ cbdata     size of data to communicate
       0 ,            \ lpdata     pointer to data to communicate

: Sendw32fMsg	( addr siz w32fmsg w32fappIDto -- result )
\ *G Send an inter-process win32forth-specific message \n
\ ** w32fAppIDTo is the destination application ID \n
\ ** w32fmsg is the win32forth-specific message number \n
\ ** addr siz is the data area passed with the message \n
\ ** result: <>0 (the message has been processed) or false\n
\ ** Note: it is supposed to be harmless to use this word
\ ** without the shared memory nor hwnd set.
                w32fsharep 0= if 4drop 0 exit then
                SharedHwnd ?dup
                if   >r COPYDATASTRUCT !          \ win32forth message number
                     COPYDATASTRUCT cell+ !       \ count
                     COPYDATASTRUCT 2 cells + !   \ address
                     COPYDATASTRUCT           \ the structure to send
                     MyAppID SharedHwnd       \ sending window : me
                     WM_COPYDATA              \ the Windows message id
                     r>                       \ the destination window
                     call SendMessage
                else 3drop 0
                then ;

: BroadCastw32fMsg { addr siz w32fmsg \ -- }
\ *G Send an inter-process win32forth-specific message to all running processes
\ ** in a pool of win32forth applications, including myself. See Sendw32fMsg
                w32fsharep 0= ?exit
		w32fsharep
                begin  dup @ while
                       >r
                       addr siz w32fmsg r@ @ Sendw32fMsg drop
                       r> 2 cells +
                repeat drop ;


\ ------------------------------------------------------------------------------
\ The win32forth message handler for an application own window
\ ------------------------------------------------------------------------------

\ *A How to receive a message :

\ *P You just have to add a method in your window class to handle
\ ** the WM_COPYDATA message. The word \tDecodew32fMsg\d converts the window's message
\ ** parameters into win32forth-specific message data :

\ *E :M WM_COPYDATA  ( hwnd msg wparam lparam -- result )
\ **                 \ Result must be -1 if the message has been processed, 0 if not
\ **                 Decodew32fMsg ( hwnd msg wparam lparam -- addr siz w32fmsg w32fAppIDSender )
\ **                 CASE
\ **                   app1 OF CASE
\ **                             msg1 OF ... handle message 1 ... set result ... ENDOF
\ **                             msg2 OF ... handle message 2 ... set result ... ENDOF
\ **                             2DROP 0 SWAP
\ **                           ENDCASE
\ **                        ENDOF
\ **                   app2 OF CASE
\ **                             msg5 OF ... handle message 5 ... set result ... ENDOF
\ **                             msg6 OF ... handle message 6 ... set result ... ENDOF
\ **                             2DROP 0 SWAP
\ **                           ENDCASE
\ **                        ENDOF
\ **                   3DROP 0 SWAP   \ here, you can handle other WM_COPYDATA messages
\ **                 ENDCASE ;M

: Decodew32fMsg ( hwnd msg wparam lparam -- addr siz w32fmsg w32fAppIDsender )
\ *G decode a WM_COPYDATA message received from a win32forth application
\ ** in a form ready for a CASE statement in a window message handler. \n
\ ** w32fAppIDSender will be 0 if any problem with shared memory
                w32fsharep 0= if 4drop 0 0 0 0 exit then
                2swap 2drop swap SharedAppID >r
                dup 2 cells + @
                swap dup cell+ @
                swap @
                r> ;

\ Note : win32forth-specific messages are handled, on the sender and receiver
\        sides, by many parameters on the stack, basically  :
\               ( addr siz w32fmsg w32fappIDto/from -- result )
\        This can lead to a bit bulky code.
\        Despite this, I think it is preferable that the sender specify the
\        destination app, that the receiver knows the sender and that a result
\        is given. This allow for the most general use.
\ Note : The result follows the WM_COPYDATA rule : -1 = has been processed
\        (Actually Windows allows to set any return value <>0)


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ -------------- PART THREE : LAUNCH WIN32FORTH APPLICATIONS -------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

\ *S Launching Win32Forth processes

\ *P Launching a win32forth application from another one can be done \bonly when both
\ ** applications share memory\d. About win32for.exe itself, only one instance is
\ ** currently sharing memory. Thus it is possible, for example, that you want to
\ ** launch Help from an instance of Forth not currently sharing memory : this will
\ ** not work.

\ *P You can however consider a win32forth application which doesn't share memory
\ ** as a "foreign" application and use different tools to launch it.


\ ------------------------------------------------------------------------------
\  Primitive for launching any process
\ ------------------------------------------------------------------------------

Require CreateProcess.f

\ ------------------------------------------------------------------------------
\  Launch a win32forth application (ready for communication if needed and enabled)
\ ------------------------------------------------------------------------------

\ Added to increase delays for older (i.e. slower) machines GAH Wednesday, June 16 2010

60 value time-taken

: Set-time-taken ms@ 5000000 0 do loop ms@ - negate [ 24 60 * 60 * 1000 * ] literal mod to time-taken ;

initialization-chain chain-add Set-time-taken

\ *P To launch a win32forth application from another one use :

: ExecW32FApp	( addr len w32fappID -- flag )
\ *G Execute a win32forth application, whose communication features are enabled,
\ ** with a command line whose first token is the filename. If no path is given the
\ ** file will be searched in the current directory. You may specify a path. \n
\ ** Example: (cf setup.f) \n
\ ** s" WIN32FOR.EXE CHDIR HELP FLOAD HELPMAIN.F BYE" w32fHelp ExecW32FApp
\ ** Return -1 if failed, 0 if success
                dup ?RemoveGhost                     \ first remove any "ghost" instance
                dup IsRunning?
                if   SharedHwnd                      \ if w32fapp is running, get hwnd
                     dup IsIconic if dup SW_RESTORE over ShowWindow drop then
                     SetForegroundWindow drop        \ and activate it
                     2drop 0
                else >r ((createprocess))            \ launch the w32fapp
                     if   r>drop -1
                     else 3000  40 time-taken * + ( ms) ProcInfo @      \ give the launched process a..
                          call WaitForInputIdle drop \ ..chance to set its hwnd..
                          CloseThread                \ ..in shared memory
                          CloseProcess
                          r>
                drop
\               begin dup SharedHwnd 0= while repeat drop ( *)
                     500 ms
                          0
                     then
                then ;
\ ( *): This line would make sure that the launched app is ready but there is
\       a risk of locking...
\ Note: First WM_KEY messages to a just-launched Forth are lost even if :
\       - we have no time-out in WaitForInputIdle so that it is sure that the
\         process has finished its initialization.
\         (on my computer - pentium M - , help needs 1500 ms, IDE around 200 ms)
\       - we add a loop waiting for the hwnd of w32fappID being set (<>0)
\       !!!
\       I suspect PUSHKEY to be asynchronous, specially in Paste-Load
\
\       The only way to solve the problem seems to be waiting a long time
\       (50 ms seems to be enough on my machine, I put more for slower ones)
\       This is a very bad solution ...


\ *P Specialized words to launch an application of the win32forth pool :

: (w32fAppCmdLine) ( addr len w32fappID -- addr len )
                { \ <CmdLine> -- }
                max-path 1+ LocalAlloc: <CmdLine>
                w32fAppID>Filename
                PrePend<Home>\ <CmdLine> place
                         s"  " <CmdLine> +place
                               <CmdLine> +place
                <CmdLine> count ;

: ExecForth	( addr len -- flag )
\ *G Launch win32Forth or use an existing instance who shares memory \n
\ ** Automatically builds filename and prepends home \n
\ ** addr len (len may be 0) is a commandline that will be appended
\ ** to the filename if the application is actually launched
\ ** Return -1 if failed, 0 if success
                w32fForth (w32fAppCmdLine)
                w32fForth ExecW32FApp ;

: ExecIDE	( addr len -- flag )
\ *G Launch IDE if not already running \n
\ ** Automatically builds filename and prepends home \n
\ ** addr len (len may be 0) is a commandline that will be appended
\ ** to the filename if the application is actually launched
\ ** Return -1 if failed, 0 if success
                w32fIDE (w32fAppCmdLine)
                w32fIDE ExecW32FApp ;

: ExecHelp	( addr len -- flag )
\ *G Launch Help if not already running \n
\ ** Automatically builds filename and prepends home \n
\ ** addr len (len may be 0) is a commandline that will be appended
\ ** to the filename if the application is actually launched
\ ** Return -1 if failed, 0 if success
                w32fHelp (w32fAppCmdLine)
                w32fHelp ExecW32FApp ;

: ExecWinEd	( addr len -- flag )
\ *G Launch IDE if not already running \n
\ ** Automatically builds filename and prepends home \n
\ ** addr len (len may be 0) is a commandline that will be appended
\ ** to the filename if the application is actually launched
\ ** Return -1 if failed, 0 if success
                w32fWinEd (w32fAppCmdLine)
                w32fWinEd ExecW32FApp ;

: ExecEditor    ( addr len -- flag )
\ *G Launch or put in front if already present, the current editor,
\ ** either IDE or WinEd
                w32fEditor
                case
                  w32fIDE   of ExecIDE   endof
                  w32fWinEd of ExecWinEd endof
                endcase ;


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------ PART FOUR : LAUNCH FOREIGN APPLICATIONS -------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

\ * S Launching foreign processes
\ * P To launch a foreign (not win32forth) application from win32Forth, use :
\ * P todo
\ * P To launch a foreign application by a filename with an extension, provided
\ * * that this extension is registered by Windows' shell, use :
\ * P todo
\ ...

\ This is in fact in shell.f, we could simplify a bit shell.f
\ ??? to be done

\ exec any app
\ exec any app and wait for finished
\ exec a file given its extension via ShellExecute
\ exec DOS command
\ drag and drop file ?


\ *W <hr>Document : Dexh-w32fMsg.htm -- 2008/05/23 -- Camille Doiteau
\ *Z


