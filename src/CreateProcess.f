\ $Id: CreateProcess.f,v 1.1 2013/03/07 15:29:02 georgeahubert Exp $

\ Made into separate file since it's used by both w32fMsg.f and Shell.f

10 proc CreateProcess
 1 proc CloseHandle
 1 proc IsIconic
 2 proc ShowWindow
 1 proc SetForegroundWindow
 2 proc WaitForInputIdle

create StartupInfo
NoStack         here 0 ,                \ cb
                0 ,                     \ lpReserved
                0 ,                     \ lpDesktop
                0 ,                     \ lpTitle
                0 ,                     \ dwX
                0 ,                     \ dwY
                0 ,                     \ dwXSize
                0 ,                     \ dwYSize
                0 ,                     \ dwXCountChars
                0 ,                     \ dwYCountChars
                0 ,                     \ dwFillAttribute
                STARTF_USESHOWWINDOW ,  \ dwFlags
                SW_SHOWNORMAL W,        \ wShowWindow
                0 W,                    \ cbReserved2
                0 ,                     \ lpReserved2
                0 ,                     \ hStdInput
                0 ,                     \ hStdOutput
                0 ,                     \ hStdError
                here over - swap !

create ProcInfo
                0 ,                     \ hProcess
                0 ,                     \ hThread
                0 ,                     \ dwPriocessId
                0 ,                     \ dwThreadId

create processcmd max-path 1+ allot \ counted null-terminated command line

: ((CreateProcess)) ( addr len -- flag )
                \ create the process given as the first token in the "command line" addr/len . Flag true if failed
                ProcInfo 4 cells erase  \ clear procinfo
                processcmd place
                processcmd +null        \ null terminated command line string
                ProcInfo                \ lppiProcInfo
                StartupInfo             \ lpsiStartInfo
                0                       \ lpszCurDir
                0                       \ lpvEnvironment
                0                       \ fdwCreate
                0                       \ fInheritHandles
                0                       \ lpsaThread
                0                       \ lpsaProcess
                processcmd 1+           \ lpszCommandLine
                0                       \ lpszImageName
                call CreateProcess 0= ;

: CloseProcess  ( -- ) \ close process handle of opened process
                ProcInfo @ call CloseHandle drop ;   \ process

: CloseThread   ( -- ) \ close thread handle of opened process
                ProcInfo cell+ @ call CloseHandle drop ;   \ thread
