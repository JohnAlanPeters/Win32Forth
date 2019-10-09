anew MultiTaskingClass.f   \ For XP or better. See the demos at the end for its use.

\ *D doc\classes\
\ *! MultiTaskingClass
\ *T MultiTaskingClass -- For clustered tasks in objects.

\ *S Abstract

\ *P CPU's with multiple cores can execute a program faster than cpu's with a single core. \n
\ ** This is done by breaking up a program in smaller pieces and than execute all pieces simultaneously. \n
\ ** In multiTaskingClass.f this idea is supported as follows: \n
\ ** Breaking up is possible at the definition level or at the program level by the 2 classes \biTask\d and \bwTask\d. \n
\ ** Then the pieces are submitted and simultaneously executed in a number of tasks. \n
\ ** Tasks are coverted to jobs and clustered in an object for easy access.

\ *P Objects defined with \biTask\d can be used as soon as ONE definition should be executed in a parallel way
\ ** and the definition uses a do...loop. \n
\ ** The method \iParallel:\d  divides, distributes and submits for execution the specified cfa over a number of jobs. \n
\ ** A started job can pickup its range for the do...loop part by using the method \iGetRange:\d. \n
\ ** It is possible to change the number of simultaneous jobs before they run.

\ *P Objects defined with \bwTask\d can be used to execute concurrently one or more different definitions. \n
\ ** Use the method \iSubmit:\d for executing a definition in a job. \n
\ ** When a new job is submitted and the maximum number of jobs has been reached the following will happen at the next job: \n
\ ** 1) The system will wait till all the jobs in one que of one thread are complete. \n
\ ** 2) Then it will allow the submitting more jobs. \n

\ *P Tasks of both classes will get their parameters at the start on the stack
\ ** as soon as the method \iToStack:\d is used just before the job is submitted. \n
\ ** MultiTaskingClass.f uses the \bpreemptive\d multitasking system of windows. No need to use pause. \n

\ *P \bTypical passing of parameters to a Job:\d \n
\ ** LockJobEntry[: myTasks 10 20 30 \b3\d ToStack: myTasks  ['] TestTask ]Submit: myTasks \n
\ ** \bExplanation:\d\n
\ **  LockJobEntry[: Locks the entrypoint to protect it against overwriting.\n
\ **  ToStack: Passes the \b3\d stack items to the stack of the job.\n
\ **  ]Submit: Submits the task and unlocks the entrypoint just before it returns.

\ History:
\ To handle tasks in an object.
\ 16-07-2011 Released the first version. In the old version each task started a new thread
\   When a task was complete the thread was terminated
\   For waiting was a complex WaitForMultipleObjects used.
\   The number of threads was limited to 63.

\ 1-5-2014 Most important changes:
\ Now each thread gets a que in which jobs are placed to execute a definition.
\ Submitting a job is now about 1000 times faster than the initial version.
\ The total number of jobs depends on #jobs in each used object.
\ Semaphores are used to simplify waiting instead of critical sections.
\ The number of threads is no longer limited to 63.
\ 1500 threads seems to be the limit under W7.
\ All objects need now to be started with the method start: which takes NO parameters from the stack.
\ Exceptions with #IncompleteJobs1Thread: etc happens when an object has not been started.
\ All task-classes have now high resolution timers to determine elapsed times in cycles or seconds.
\ Use .JobAnalysis: to see them.

\ Important renamed methods:
\ old                  ->  new:
\ To&Task:             ->  ToStack:
\ SubmitTask:          ->  Submit:
\ GetTaskRange:        ->  GetRange:
\ GetTaskParam         ->  GetThreadIndex
\ Objectname.taskwaits ->  #IncompleteJobs:
\ SuspendTasks:        ->  SuspendThreads:
\ ResumeTasks:         ->  ResumeThreads:
\ REMOVED &StkParams Waitobject

\ 22-10-2015 Most important change:
\ Now SubmitRanges: gives a better distribution.
\ That may often result in a faster program.
\ Thanks to Herbert.


  (( Disable or delete this line for generating a glossary

cr cr .( Generating Glossary )

needs help\HelpDexh.f  DEX MultiTaskingClass.f

cr cr .( Glossary MultiTaskingClass.f generated )  cr 2 pause-seconds bye  ))


winver winxp < [if] cr cr .( MultiTaskingClass.f needs at least Windows XP.) cr abort [then]

needs task.f
needs src\lib\fmacro\PROFILER.F
' time-in-cycles is time_unit


\ *S Glossary

code cells+@  ( a1 n1 -- n ) \
\ *G Multiply n1 by the cell size and add the result to address a1
\ ** then fetch the value from that address.
                pop     eax
                lea     ebx, 0 [ebx*4] [eax]
                mov     ebx, 0 [ebx]
                next    c;

code cells+!  ( n a1 n1 -- )
\ *G Multiply n1 by the cell size and add the result to address a1
\ ** then store the value n to that address.
                pop     eax
                lea     ebx, 0 [ebx*4] [eax]
                pop     [ebx]
                pop     ebx
                next    c;

256 value stacksize

cell NewUser JobEntryID \ Index pointer to the job entry that is executing in a thread


internal

0 value ValuespMainThread  \ Only to be used to see if a word is running in the mainthread

: GetValueSpMainThread ( - UpMainThread )
\ *G Get sp0 of the main thread. Even when a secondary thread is running.
   ValuespMainThread ;

: SetValueSpMainThread ( - )
\ *G Sets the sp0 value of the main thread. This is done at the start of Forth or at the start
\ ** of a turnkey
  sp0 to ValuespMainThread ;

initialization-chain chain-add SetValueSpMainThread
SetValueSpMainThread

external


\ MultiTaskingClass.f uses a thread control block to pass parameters to a thread
\ it looks a bit like the task control block of task.f.
synonym  tcb>parm   task>parm
synonym  tcb>handle task>handle
synonym  tcb>stop   task>stop

\ The difference is that it is extended with 4 new parameteres as follows:
7 cells dup offset tcb>#JobsSubmitted cell+ \ *G Returns the address of the number of jobs submitted to the thread.
 cell field+ tcb>#JobsDone                  \ *G Returns the address of the number of complete jobs in the thread.
 cell field+ tcb>op                         \ *G Returns the address of the object pointer in the thread.
 cell field+ tcb>UserArea                   \ *G Returns the address of the user area of the thread.

 constant MinimumSizeThreadBlock            \ *G  Minimum size of a thread block


: MainThread? ( - flag )
\ *G Detects if a definition is running in the main thread.\n
\ ** MainThread? returns true when a definition runs in the main thread.
    GetValueSpMainThread sp0 = ;

previous

: GetThreadIndex ( - IDindex )
\ *G Each thread gets an index. GetThreadIndex returns that index.
\ ** GetThreadIndex in a job can be used to target a value in an array
\ ** for one thread.
    MainThread?   if    0    else  tcb @ tcb>parm  @   then ;

: #Hardware-threads ( - #Hardware-threads )
\ *G  Returns the number of hardware threads found in the CPU.
    ( sizeof system_info)  36 LOCALALLOC dup
    ( relative dwNumberOfProcessors) 20  + swap
    call GetSystemInfo drop @
  ;

: SetPriority ( Prio - )
\ *G Changes the priority of the thread.
    call GetCurrentThread call SetThreadPriority drop ;

: below       ( -- )
\ *G Lowers the priority of the thread in order to keep the main thread responsive to the mouse etc.
    THREAD_PRIORITY_BELOW_NORMAL SetPriority ;

winerrmsg on

: #do  \ Compiletime: ( <name> -- )  Runtime: ( limit start - )
\ *G To construct:     do  i  cfa   loop \n
\ ** EG: \n
\ ** : test  10 0   #do . ; \n
\ ** Will be compiled as: \n
\ ** : TEST  10 0    DO  I . LOOP    ; \n
    s" do  i " evaluate
           ' compile,  \   Runtime expects of the compiled cfa: ( index -  )
    s" loop " evaluate
  ; immediate

\ : test 10 0 #do . ; cr  see test cr test abort

8 constant /StkParams                    \ The maximum number of parameters to pass to a job

\ ** \bParameters for 1 job entry in a jobblock:\d
\ *L
\ *| Name:        | Use: |
\ *|  --| -- \bNote:\d Parameters starting wih a '>' use the &JobEntry address to get to their adress. |
\ *| &JobEntry    | -- The start adress of one job entry.|
\ *| >JobCFA      | -- Contains the CFA to be executed by a job.|
\ *| >JobStkDepth | -- The number of stack items for a job.|
\ *| >JobStkLast  | -- A stack for a job to be executed.|
\ *| >StartTic    | -- A double containing the StartTic when a job was started.|
\ *| >EndTic      | -- A double containing the >EndTic when a job became complete.|
\ *| >CfaDone     | -- Contains the previous Cfa of a job entry.|
\ *| >StartTime   | -- A structrure containing the StartTime when a job was started.|
\ *| >EndTime     | -- A structrure containing the EndTime when a job became complete.|
\ *| >Schedule    | -- Reserved to hold a Schedule.|
\ *| >range       | -- 2 cells to hold the start- end-index for a do...loop. used by the class iTasks.|
\ *| /StkParams   | -- The maximum number of parameters to pass to a job. Default is 8.|
\ *| /JobEntry    | -- The size of 1 Job entry.|
\ *| MinimumSizeJobBlock | -- Minimum size of one job entry.|
\ *| #JobParms    | -- Number of parameters in one job entry.|
\ *| /TimeParams  | -- Partial size of job entry to be used to erase statistics.|


                  : >JobCFA       ; immediate   ( -- )               \ Same as the first cell in a job entry
            synonym >JobStkDepth  cell+ ( &JobEntry - >JobStkDepth ) \ The number of stack items for a job
 2 cells dup offset >JobStkLast                                      \ After which the stack follows
dup /StkParams cells
     + swap  field+ >StartTic  ( &JobEntry - >StartTic )
     2 cells field+ >EndTic    ( &JobEntry - >EndTic )
        cell field+ >CfaDone   ( &JobEntry - >CfaDone )
    time-len field+ >StartTime ( &JobEntry - >StartTime )
    time-len field+ >EndTime   ( &JobEntry - >EndTime )
    time-len field+ >Schedule  ( &JobEntry - >Schedule )
     2 cells field+ >range     ( &JobEntry - >range )                     \ For iTasks
             value /JobEntry   \ The size of 1 Job entry

/JobEntry cell /        value    #JobParms
/JobEntry 0 >StartTic - constant /TimeParams
/JobEntry               constant MinimumSizeJobBlock  \ Minimum size of one entry in the &JobBlock

: .Timestamp ( &entry - )
\ *G Displays the time when a job was started.
     >StartTime dup   8 + w@ 10 <
         if   space
         then
     dup >time" type 14 + w@ ." ." 3 .#"  type
 ;

: ms@TB         ( time-buf -- ms )
\ *G Returns the content of a timebuffer into milli-seconds on the stack.
                dup   8 + w@     60 *           \ hours
                over 10 + w@ +   60 *           \ minutes
                over 12 + w@ + 1000 *           \ seconds
                swap 14 + w@ + ;                \ milli-seconds

: .ElapsedJob   ( start-time-buf end-time-buf -- )
\ *G Displays the time that has been elapsed betweeen 2 time buffers
                ms@TB swap ms@TB -
                [ 24 60 * 60 * 1000 * ] literal mod
                1000 /mod
                  60 /mod
                  60 /mod 2 .#" type ." :"
                          2 .#" type ." :"
                          2 .#" type ." ."
                          3 .#" type ;




0x7FFFFFFF constant MaxCountSemaphore
\ *G The maximum count of a Semaphore
\ *S Semaphore class
:Class Semaphore    <Super Object
\ *G A semaphore act as a lock that allows multiple threads to wait in line for the resource to be free.
\ ** The state of a semaphore is set to \bsignaled\d when its count is greater than zero,
\ ** and nonsignaled when its count is zero.
\ ** If the current state of the semaphore is signaled,
\ ** the wait function DECREASES the count by one and waits till the semphomere gets \bsignaled\d.

int HndlSemaphore

:M Gethandle: ( -- hndl ) HndlSemaphore ;M

:M CreateSemaphore: ( lpName lMaximumCount lInitialCount lpSemaphoreAttributes --  )
\ *G Creates a semaphore.\n Parameters:\n
\ ** lpSemaphoreAttributes: Pointer to security attributes can be NULL.\n
\ ** lInitialCount: Specifies an initial count for the semaphore object.
\ ** This value must be greater than or equal to zero and less than.\n
\ ** lMaximumCount: Maximum count \n
\ ** lpName: Pointer to a null-terminated string specifying the name of the semaphore object.
\ ** Can be NULL.
    call CreateSemaphore to HndlSemaphore
;M


:M ReleaseSemaphore: ( lpPreviousCount lReleaseCount -- PreviousCount )
\ *G Increases the count of the specified semaphore.
\ ** Parameters:\n
\ ** lReleaseCount: Specifies the amount by which the semaphore object's current count is to be INCREASED.
\ ** The value must be greater than zero. If the specified amount would cause the semaphore's
\ ** count to exceed the maximum count that was specified when the semaphore was created,
\ ** the count is not changed and the function returns FALSE.\n
\ ** lpPreviousCount: Pointer to receive the previous count for the semaphore.
\ ** Can be NULL if the previous count is not required
   over >r HndlSemaphore call ReleaseSemaphore drop r> @
 ;M


:M Increase:  { \ lpPreviousCount -- } ( -- PreviousCount )
\ *G Releases the semaphore by one.
    &of lpPreviousCount 1 ReleaseSemaphore: Self
 ;M

:M DecreaseWait: ( ms -- )
\ *G DECREASES the count of the semaphore by one.
    HndlSemaphore call WaitForSingleObject drop
 ;M


: SignalObjectAndWait ( bAlertable  dwMilliseconds hObjectToWaitOn hObjectToSignal -- res )
\ *G Allows the caller to atomically signal an object and wait on another object.
   call SignalObjectAndWait
 ;

: OpenSemaphore ( dwDesiredAccess bInheritHandle lpName -- hdnl )
\ *G Returns a handle of an existing named semaphore object.
   call OpenSemaphore
 ;

:M CloseSemaphore:
\ *G Closes the semaphore.
    HndlSemaphore call CloseHandle drop
 ;M

;Class


\ *S ExclExecute class
:Class ExclExecute    <Super Object
\ *G To be used to execute a definition in a serial way by using LockExecute:

int Executing?
\ *G Is true when executing

Semaphore SemaphoreEntryPoint
\ *G A Semaphore used to lock or unlock an entry point.
\ ** That will protect definitions that are not able to be executed simultanously
\ ** It will also protect data against overwriting by another thread while a previous thread still needs that data.

: Serialize ( -- )
    INFINITE DecreaseWait: SemaphoreEntryPoint      \ One at a time !
 ;

:M LockExecute: ( cfa - )
\ *G Locks, executes and unlocks the specified cfa.
\ ** When more than 1 job try to use LockExecute: at nearly the same time of the same object
\ ** the second job will be executed after the previous job is ready.
     Serialize true to Executing? execute
     false  Increase: SemaphoreEntryPoint
     to Executing? drop
 ;M

:M Ready?: ( -- Flag )
\ *G Returns true when LockExecute: is ready.
    Executing? 0= ;M


:M ClassInit:  ( -- )
    ClassInit: super
    false to Executing?
 ;M

;Class


\ *S TaskPrimitives class
:Class TaskPrimitives    <Super ExclExecute
\ *G Contains the \bgeneral\d definitions for a task object.
\ ** In task.f a task in Forth is passed to a thread and when it is complete the task will be destroyed.
\ ** That takes more than 1.000.000 cycles for each time a task starts.
\ ** Now a task in Forth will be passed to a job. The Job will be placed in a que of a thread and then be executed.
\ ** Threads will not be destroyed anymore, they simply wait till an ohter job has been submitted.
\ ** All Job entries are located in an array starting at &JobBlock.
\ ** When all job entries are in use and not complete and the next job is submitted,
\ ** then the system waits till one thread is ready.
\ ** All parameters for the used threads are located in an array starting at &ThreadBlocks

\ ** \bInternal parameters defined in the class TaskPrimitives:\d
\ *L
\ *| Name:           | Use: |
\ *| #threads          | -- The maximum number of threads in use in the object.|
\ *| /Threadblock      | -- The size of one Thread-block.|
\ *| &ThreadBlocks     | -- The starting address of a threadblock array when it has been allocated.|
\ *| OnlyOneThread     | -- A flag used to force to use 1 thread only for testing|
\ *| LastUsedThreadId  | -- Used to a next free thread.|
\ *| FoundJobId        | -- Keeps the last found free jobID.|
\ *| LastUsedJobId     | -- Used to find a next free jobID.|
\ *| &JobBlock         | -- Start address of the JobBlock when it has been allocated.|
\ *| #Jobs             | -- Number of entries in the JobBlock.|
\ *| 'CallBack         | -- callback function for QueueUserAPC (PAPCFUNC).|
\ *| FastJobs          | -- If true the elapsed times are diplayed in cycles.|
\ *| QueFull | -- Increments when the que is full. Then the system waits at the next job till one thread is ready unless one job gets complete.|



	int #threads          \ The maximum number of threads in use in the object.
	int /Threadblock      \ The size of one Thread-block.
	int &ThreadBlocks     \ The taskblock array.
	int OnlyOneThread     \ A flag used to force to use 1 thread only for testing
	int LastUsedThreadId  \ Used to a next free thread.
	int FoundJobId        \ Keeps the last found free jobID
	int LastUsedJobId     \ Used to find a next free jobID.
	int &JobBlock         \ Start of the JobBlock when it has been allocated
	int #Jobs             \ Number of entries in the JobBlock
	int 'CallBack         \ callback function for QueueUserAPC (PAPCFUNC)
	int FastJobs          \ If true the elapsed times are diplayed in cycles
        int QueFull           \ Increments when the que is full.

Semaphore SemaphoreAllJobsReady \ To detect that all jobs of ONE thread are ready.

: ResetJob-ThreadID ( - )
\ *G Set LastUsedJobId and LastUsedThreadId to -1 to reset various ID's
    -1 to LastUsedJobId -1 to LastUsedThreadId ;

:M GetQueFull:   ( -- n )
\ *G Returns the number of times that all job entries are used.
   QueFull ;M

:M ResetQueFull: ( -- )
\ *G Set the count of QueFull to 0.
   0 to QueFull ;M

:M .QueFull:     ( -- )
\ *G Displays the count of QueFull.
     GetQueFull: Self ."  #Que full events: " .
  ;M

: JobEntryID>  ( JobEntryAdr - Index )
\ *G Returns the index of a JobEntry given its address.
   s" &JobBlock - /JobEntry  / "  evaluate ; immediate

1 CALLBACK: ExecuteJob    { \ #bytes } ( JobEntry -- res ) \ Also defines &ExecuteJob
\ *G Callback fuction for all jobs that are submitted and need no analyzing.
   dup>r JobEntryID> JobEntryID !
   r@ >JobStkDepth @ dup 0>     \ Copy the stack to the thread when needed
      if    sp@  swap cells dup to #bytes - sp!
            r@ >JobStkLast  sp@ cell+  #bytes  cmove
      else  drop
      then
   r@ perform                   \ Execute the CFA specified in the jobblock here.
   1 tcb @ tcb>#JobsDone incr
   0 dup r> 2!                  \ Reset the the stack and CFA for GetFreeJobEntry
 ;


1 CALLBACK: ExecuteAnalizeJob    { \ #bytes }  ( JobEntry -- res ) \ Also defines &ExecuteAnalizeJob
\ *G Callback fuction for all jobs that are submitted and need to be analyzed.
   dup>r JobEntryID> JobEntryID !
   r@ >JobStkDepth @ dup 0> \ Copy the stack to the thread when needed
      if    sp@  swap cells dup to #bytes - sp!
            r@ >JobStkLast  sp@ cell+  #bytes  cmove
      else  drop
      then
   r@
   r@ >CfaDone off                       \ Put off to indicate that the job is running
   r@ >EndTime   call GetLocalTime drop  \ Store the timers at the start
   r@ >StartTime call GetLocalTime drop
   tsc 2dup r@  >StartTic 2!
            r@  >EndTic   2!
   perform                               \ Execute the CFA specified in the jobblock here.
   tsc r@  >EndTic   2!                  \ Store timers at the end.
   r@ >EndTime call GetLocalTime drop
   r@ @ r@ >CfaDone !                    \ Save the old CFA for reporting
   1 tcb @ tcb>#JobsDone incr
   0 dup r> 2!                           \ Reset the the stack and CFA for GetFreeJobEntry

 ;


:M Set#Jobs: ( n -- )
\ *G Specify the maximum number of jobs. Set it before starting the object when needed.
    to #Jobs
 ;M

:M Get#Jobs: ( -- n )
\ *G Get the maximum number of jobs.
    #Jobs
 ;M

:M GetLockedJobID: ( -- n )
\ *G Retuns the JobID that is locked
    FoundJobId
 ;M


:M >JobEntry: ( index - adr )
\ *G Returns the address of a jobentry given its index.
    /JobEntry * &JobBlock +
 ;M

:M .Jobblock: ( -- )
\ *G Produces a primitive dump of a jobblock.
   #Jobs 0
       do  cr i >JobEntry: Self dup h.8 ." :" #JobParms 0
              do  dup i cells+ @ space h.8
              loop
           drop
       loop
 ;M

: GetThreadBlock     ( IDindex - ThreadBlock )
\ *G Returns the address of the threadblock array for its index.
    s" /Threadblock  * &ThreadBlocks + " EVALUATE ; IMMEDIATE

: tcb>cfa         ( tcb - tcb>cfa )
\ *G Returns the address of the CFA to be executed from the threadblock.
    5 cells+ ;

: ThreadIndex          ( - #threads 0 )
\ *G Returns 0 and the maximum number of simultaneously threads in use by the object.
    #threads 1 max 0 ;


:M GetThreadcount:  ( -- #threads )
\ *G Returns the maximum number of simultaneously threads in use.
    #threads ;M

:M SetThreadcount:  ( #threads -- )
\ *G Sets the maximum number of simultaneously threads in use.
    to #threads ;M

:M Max#threads:     ( -- #threads )
\ *G Returns the number of hardware threads. \n
\ ** It returns 2 for older cpu's.
    #Hardware-threads 2 max
  ;M

: CreateRunThread    ( IDindex -- )
\ *G Creates and runs the thread for windows given the ID and use the parameters of a filled entry in the threadblock.
    GetThreadBlock 0 (create-task)  0= Abort" Thread not created." ;

:M SuspendThread:      ( IDindex -- )
\ *G Suspend a thread with the specified ID.
    GetThreadBlock  suspend-task drop ;M

:M ResumeThread:       ( IDindex -- )
\ *G Resumes the thread with the specified ID.
    GetThreadBlock  resume-task  drop ;M

:M SuspendThreads:     ( -- )
\ *G Suspend all threads in use by the object.
    ThreadIndex  do  i SuspendThread: Self loop ;M

:M ResumeThreads:      ( -- )
\ *G Resume all threads in use in the object by the object.
    ThreadIndex  do  i ResumeThread: Self  loop ;M

:M TerminateThread:          ( IDindex -- )
\ *G To terminate a thread with the specified ID. \n
\ ** This will also terminate all running jobs of the thread.
   GetThreadblock tcb>handle @ 9 swap call TerminateThread drop
;M

:M TerminateThreads:          ( IDindex -- )
\ *G Terminates all threads in use in the object by the object.
\ ** This will also terminate all running jobs in the object.
     ThreadIndex  do i TerminateThread: Self loop
;M

:M ReleaseArrays:    ( -- )
\ *G Release the allocated arrays.
    &ThreadBlocks release  0 to &ThreadBlocks
    &JobBlock     release  0 to &JobBlock
  ;M

: MallocJobBlock ( -- )
\ *G Allocate the needed arrays.
    #Jobs #threads max 1 max dup to #Jobs     \ Each thread gets at least one entry
    /JobEntry * malloc to &JobBlock
    &JobBlock #Jobs 1 max  /JobEntry * erase  \ More jobs than threads is possible
  ;

:M CloseSemaphores: ( -- )
\ *G Close the semaphores on use by the object.
    CloseSemaphore: SemaphoreEntryPoint
    CloseSemaphore: SemaphoreAllJobsReady
;M

: *Canceled* ( ?? - )
\ *G Resets the stack. *Canceled* is used for reporting.
  _reset-stacks ;

: CancelwaitingJob ( index - )
\ *G Cancel the entry of a job. When a job is running it will continue.
   >JobEntry: Self  ['] *Canceled* swap !
 ;

:M CancelWaitingJobs: ( -- )
\ *G Cancel waiting and pending jobs of the object.
\ ** Running Jobs will continue
\ ** This might give confusing results a job analysis.
   SuspendThreads: Self
   #Jobs 0 #do CancelwaitingJob
   ResumeThreads: Self
;M

:M TerminateAllJobs: ( -- )
\ *G Closes all semaphores and terminate all jobs and threads of one object.
\ ** All waiting jobs will be gone.
\ ** Use Start: to restart mulitasking again.
    SuspendThreads: Self
    TerminateThreads: Self
    ReleaseArrays: Self
    CloseSemaphores: Self
;M

:M UseOneThreadOnly: ( -- )
\ *G Overwrite the number of simultaneously threads in use by the object.
\ ** Use it before submitting a job.
    true to OnlyOneThread  ;M

:M UseALLThreads:    ( -- )
\ *G To overwrite UseOneThreadOnly:. This is default.
    false to OnlyOneThread ;M

:M GetThreadBlockSize: ( - Size )
\ *G Returns the threadblock size.
    /Threadblock  ;M


:M #ActiveThreads:  { \ lpExitCode } ( - #ActiveThreads )
\ *G Returns the number active threads in the object.
    0 &ThreadBlocks 0<>
        if ThreadIndex
             do  i GetThreadBlock tcb>handle @ dup 0<>
                 if 0 swap call WaitForSingleObject WAIT_TIMEOUT =
                    if   1+
                    then
                 else drop
                 then
             loop
        then
  ;M

:M SetThreadBlockSize:  ( NewSize - )
\ *G Sets a new size for the thread block.
    #ActiveThreads: Self abort" Active threads detected. Can't resize threadblock."
    MinimumSizeThreadBlock over > abort" The minimal size of a thread block is 7 CELLS."
    to /Threadblock
  ;M

:M #IncompleteJobs1Thread:  ( index -- #jobs )
\ *G Returns the number of incomplete jobs of one 1 thread given its ID.
     GetThreadBlock dup tcb>#JobsSubmitted @ swap tcb>#JobsDone @ -
    ;M

:M #JobsSubmitted:  ( -- #TotalSubmittedjobs )
\ *G Returns the total number of submitted jobs in the object.
    0 #threads 0
        do  i GetThreadBlock tcb>#JobsSubmitted @ +
        loop
    ;M

:M #IncompleteJobs:  ( -- #Totaljobs )
\ *G Returns the total number of incomplete jobs in the object.
    0 #threads 0
        do  i #IncompleteJobs1Thread: Self +
        loop
    ;M

:M Ready?:  ( -- flag )
\ *G Returns true when all jobs are ready.
  &JobBlock 0<>
     if    #IncompleteJobs: Self 0=
     else  true
     then
   Executing? 0= and
 ;M

:M GetFreeJobId: ( -- Index|-1 )
\ *G Return an index for a free JobEntry or -1 when it fails.
\ ** The result is also stored in FoundJobId.
   -1 #Jobs 0
       do   1 +to LastUsedJobId
            LastUsedJobId dup #Jobs >=
                if  winpause drop 0 dup to LastUsedJobId
                then
             dup >JobEntry: Self @ 0=
                if    nip leave
                else  drop
                then
       loop
    dup to FoundJobId
 ;M


: AlertableState  ( - )
\ *G Puts a thread in a alertable state. So it can receive and handle submitted jobs (APC's).
   tcb @  tcb>op @ op !  \ Copy the current opbject pointer in the user area of the running thread
   tcb @  dup cell+ swap tcb>UserArea !
   finit TRUE INFINITE
    begin  2dup call GetCurrentThread call WaitForSingleObjectEx WAIT_IO_COMPLETION <>  \ 1 thread ready?
              if    winpause     \ Case WAIT_IO_COMPLETION <>
              else  Increase: SemaphoreAllJobsReady 1 > \ One Thread ready. Prevent a count bigger than 1 when
                     if  INFINITE DecreaseWait: SemaphoreAllJobsReady \ two jobs are nearly simultaneously ready
                     then
              then
    again                 \ For the next APC
  ;

:M FindThread: { \ cand least } ( -- i )
\ *G Finds a thread to be used for a job.   \n
\ ** This is done by looking for a waiting thread.  \n
\ ** When there is no thread waiting the thread with the least jobs is returned.
\ ** Some threads are not as often used as others, since it is faster to find a waiting thread.
    0 dup to cand   #IncompleteJobs1Thread: Self to least
    -1  #threads  0
        do   1 +to LastUsedThreadId
             LastUsedThreadId #threads >=
                if  0 to LastUsedThreadId
                then
             LastUsedThreadId #IncompleteJobs1Thread: Self 0=
                if   drop LastUsedThreadId exitm \ Exit as soon as an idle thread is found
                else    i #IncompleteJobs1Thread: Self dup least  <  \ or else find the thread with the least jobs in the que
                     if   to least i to cand
                     else drop
                     then
                then
        loop
     dup 0<
       if drop cand
       then
    ;M

: 5.r ( n - )
\ *G Display n right justified using 5 positions followed by a space.
   5 .r space ;

\ *S Analyzer tool
\ *P \b----- Display definitions to be used when the analyzer is ON. -----\d\n
\ ** (See Analyze:)
: .JobStatus ( &JobEntry - )
\ *G Displays the jobstatus of a job given its &JobEntry address.
      dup >CfaDone @ dup 0<>
         if    #IncompleteJobs: Self
              if   ."  Waiting " \ Waiting to excecute a new job. Previous times are still shown
              else ." Complete " \ Ready and also passed the semaphore.
              then nip   \in-system-ok .name
         else  drop  dup @  0=
                 if   drop ." Not used."
                 else dup >StartTic @ 0=
                       if    ."  Pending" \ Waiting to be executed
                       else  ." *Running" \ Still executing
                       then space @ \in-system-ok .name
                 then
         then
 ;

: .DifCycles ( startL startH endL endH - )
\ *G Calculates and displays the difference between a start time and end time in cycles.
    2swap d- ud. ."  cycles."
 ;

0e fvalue fAverage
0 value JobsCounted

: AverageElapsed \ : ( -- F:AverageInCycles )
\ *G Calculates the average time In cycles of all jobs in an object.
   0 0e #Jobs 0
       do  i >JobEntry: Self dup
           >EndTic 2@ d>f >StartTic  2@ d>f f- fdup f0>
               if   1+ f+
               else fdrop
               then
       loop
   s>f f/
 ;

: .AverageTime ( F: AverageTime ActTime - )
\ *G Calculates and displays the relative difference between the average time and actual time of a job.
   fover 0.000001e f>
     if     fover  f/ 100e f*
     else  fdrop 0e
     then
  precision 4 set-precision  f.  set-precision

;

:M .JobAnalysis: ( -- )
\ *G Displays a Job analysis of an object that include elapsed times status and the name of the executed CFA.
\ ** Note: Job entries can be recycled!
  cr cr ." Job analysis " .date space .time ." ."time-buf 14 + w@ . space
  &JobBlock 0=  abort" *** No JobBlock active ***"
  FastJobs
    if cr ." One noop took " tsc noop tsc   2swap d-   tsc tsc 2swap d-   2swap .DifCycles
          ."  One millisecond took "  tsc 1 ms tsc .DifCycles
    then
 cr ." Sumbitted Jobs:" #JobsSubmitted: Self s>d ud. ." ." space
  #IncompleteJobs: Self dup
    if   ." Incomplete jobs:" s>d ud. ." ." space
    else drop
    then
  AverageElapsed  ." Average cycletime:" fdup fe.
  cr  FastJobs
    if   ." Entry Time stamp counter  Used cycles % diff Rng Status   Last"
    else ." Entry Start time   Elapsed time % diff Rng Status   Last"
    then
   #Jobs 0
       do  cr i dup 5.r >JobEntry: Self
           dup >EndTic   2@ d>f
           dup >StartTic 2@ d>f
           FastJobs
             if    FastJobs  if  fdup f>d 18 ud,.r then
                   ."  -- "  f- fdup  fabs  fe.
             else  dup .Timestamp space
                   dup >StartTime over >EndTime .ElapsedJob space
                   f-
             then
            .AverageTime
            dup >range @ 4 .r space .JobStatus
       loop
  fdrop
 ;M



:M .ThreadBlock: ( - )
\ *G Displays the number of submitted jobs and the number of completed jobs for each thread of an object.
  cr cr ." Thread usage:"
  &ThreadBlocks  0= abort" *** No &ThreadBlock active ***"
  cr ." Thread Submitted    Complete    Pending"
    #threads 0
       do   cr I 4 .r space
            i GetThreadBlock tcb>#JobsSubmitted @ dup 11 U,.R space
            i GetThreadBlock tcb>#JobsDone @ dup 11 U,.R
            - dup 0<>
               if    11 U,.R
               else  drop
               then
       loop
    ;M


:M TimeSeconds: ( -- )
\ *G Displays the time in seconds in .JobAnalysis:.
     false to FastJobs
 ;M

:M TimeCycles: ( -- )
\ *G Displays the time in cycles in .JobAnalysis:.
    true to FastJobs
 ;M

:M AnalyzerOff: ( -- )
\ *G Puts the analyzer for .JobAnalysis: off. This is default. This will be a bit faster.
    &ExecuteJob to 'Callback
  ;M

:M EraseStats: ( -- )
\ *G Erase statistics fome the thread block and Job block of an object.
     #threads 0
        do    i GetThreadBlock dup tcb>#JobsSubmitted off
                                   tcb>#JobsDone off
        loop
     #Jobs 0
         do   i >JobEntry: Self >StartTic /TimeParams erase
         loop
    0 to QueFull
    ;M


\ *P \b----- End of display definitions for the analyzer -----\d

: ExecuteInThread  ( -- )
\ *G Will run first in any thread.
    tcb @  tcb>cfa perform    \ execute the cfa from the thread block
  ;


:M PrepairThread:   ( cfa IDindex -- )
\ *G Prepairs a threadblock with various parameters.
    ['] ExecuteInThread over GetThreadBlock dup>r !
    r@ tcb>parm !
    r@ tcb>cfa !
    op @ r> tcb>op !
  ;M


:M StartQueue: ( cfa IDindex -- )
\ *G Submits the specified cfa in a new thread and returns.
    tuck PrepairThread: Self
         CreateRunThread
 ;M


:M StartQueues:
\ *G Start all queues and threads in an object.
\ ** All started threads will get in an alertable state and will
\ ** be ready to receive APC's that use an entry a JobBlock of an object.
  #threads 0
    do     ['] AlertableState  i  StartQueue: Self
    loop
  10 ms    \ Needed to be sure all threads are in a wait state.
 ;M


:M MallocThreadArrays: ( -- )
\ *G Allocates and initializes the ThreadBlock and JobBlock.
            #threads 1 max  /Threadblock * dup malloc to &ThreadBlocks \ Each thread gets a threadblock
             &ThreadBlocks swap erase         \ Erase the threadblock
             MallocJobBlock
             0 GetThreadBlock tcb>#JobsSubmitted off
             0 GetThreadBlock tcb>#JobsDone off
           ;M

:M Start: ( -- )
\ *G Used to initialize the object. Must be used before jobs can be submitted
    0 1 1 0  CreateSemaphore: SemaphoreEntryPoint    \ Starting Semaphores
    0 MaxCountSemaphore 0 0  CreateSemaphore: SemaphoreAllJobsReady
    ResetJob-ThreadID
    false to OnlyOneThread \ #threads is the maximum number of threads that may run simultaneously.
    MallocThreadArrays: Self             \ Allocates the the needed arrays
    StartQueues: Self
  ;M

:M WaitForFreeJobEntry: ( - addr )
\ *G Waits for a free job entry. When found it will return the addres of the found entry.
      begin   GetFreeJobId: Self dup 0< \  Retry till a job entry has been found
      while   1 +to QueFull drop INFINITE DecreaseWait: SemaphoreAllJobsReady  \ Wait till one thread is ready
      repeat              \ Mostly skipped by fast jobs
     >JobEntry: Self
 ;M

:M LockJobEntry[: ( - )
\ *G Locks a job entry so it can receive parameters.
    Serialize
    WaitForFreeJobEntry: Self >JobStkDepth off
 ;M

:M ToStack:  ( ni...n0  n --  )
\ *G To pass n (maximal 8) parameters to the stack of a job.
    dup /StkParams > abort" Too many parameters for the job. "
    FoundJobId  >JobEntry: Self >r
    dup  r@ >JobStkDepth !
    r> >JobStkLast over cells+ swap  0
       do     1 cells- dup>r ! r>
       loop
     drop
  ;M

:M WaitForAll: ( - )
\ *G Wait till LockExecute and all Jobs in the object are complete.
\ ** The definition AlertableState will increase the semaphore when ready.
         begin  #IncompleteJobs: Self \ Executing? 0=  and
         while  INFINITE DecreaseWait: SemaphoreAllJobsReady
         repeat
    ResetJob-ThreadID
 ;M

: CheckTasbObject ( - )
\ *G To check if a TasbObject has been started.
    &ThreadBlocks &JobBlock and 0= abort" *** TaskObject not started ***"
 ;

:M Analyze:
\ *G Starts the analyzer for .JobAnalysis:
    CheckTasbObject
    EraseStats: Self
    &ExecuteAnalizeJob to 'Callback
  ;M

:M StopAnalyzing:
\ *G Stops the analyzer.
    CheckTasbObject
    EraseStats: Self
    &ExecuteJob to 'Callback
  ;M

:M ClassInit:  ( -- )
\ *G Initializes the object. Happens automaticly when Forth or a turnkey starts.
    Max#threads: Self to #threads
    ClassInit: super
    0 to &ThreadBlocks
    0 to &JobBlock
    MinimumSizeThreadBlock SetThreadBlockSize: Self
    Max#threads: Self dup to #threads  4 * Set#Jobs: Self
    false to OnlyOneThread
    &ExecuteJob to 'Callback
    true to FastJobs
    0 to QueFull
  ;M

;Class


\ *S wTasks class
:Class wTasks    <Super TaskPrimitives
\ *G To run a number of tasks concurrently that can not be indexed. \n
\ ** Each task is converted to a job.
\ ** A job can already be complete while the submit action has not yet returned.

:M ]Submit: ( cfa -- )
\ *G Submits the specified cfa to a locked JobEntry and return after that job is submitted.
   FindThread: Self GetThreadBlock >r
   r@ tcb>#JobsSubmitted incr
   FoundJobId  >JobEntry: Self dup>r !  \ Store the cfa in the found job entry
   r>                           \ Get the jobEntry
   r> tcb>handle @
   'Callback                    \ callback function for QueueUserAPC
   call QueueUserAPC drop       \ Submit the callback as a job in a thread
   Increase: SemaphoreEntryPoint drop
  ;M

:M Submit: ( cfa -- )
\ *G Locks and Submits the specified cfa to a new job and return after that job is submitted.
\ ** To be used when a job needs no parameters.
        LockJobEntry[: Self ]Submit: Self
  ;M

:M ]Single: ( cfa -- )
\ *G Executes the definition of the specified cfa in the main task.
\ ** Made for debugging while running in the MainThread.
     FoundJobId  >JobEntry: Self >JobStkDepth dup>r @  MainThread?
       if  swap >r
              if  sp@   FoundJobId  >JobEntry: Self >JobStkDepth dup>r cell+ r> @ 2>r
                  r@  cells - sp!
                  2r> cells sp@ 2 cells+ swap cmove>
              then
             r>  true to Executing? execute
       else  2drop s" Single: Must start from the main-task" ErrorBox
       then
     r> off  \ puts >JobStkDepth off
     Increase: SemaphoreEntryPoint drop
     false to Executing?
  ;M



:M Single: ( cfa -- )
\ *G Locks and execute the specified cfa and return after that job is submitted.
\ ** To be used when a CFA needs no parameters.
        LockJobEntry[: Self ]Single: Self
  ;M


:M ClassInit:  ( -- )
    ClassInit: super
  ;M

;Class


\ *S sTask class
:Class sTask    <Super wTasks
\ *G To run a number of tasks sequentional. \n
\ ** Each task is converted to a job. All jobs are placed in ONE que for ONE thread.

:M Start: ( -- )     \ Used to initialize the object.
    1 to #threads
    Start: Super
  ;M

:M ClassInit:  ( -- )
    ClassInit: super
    1 to #threads
  ;M

;Class


\ *S iTasks class
:Class iTasks    <Super TaskPrimitives
\ *G To run ONE definition parallel that contains a do...loop. \n
\ ** The task is distributed over several jobs and then handeld in one go.  \n
\ ** Each job can get the index for the do...loop by using GetRange:. \n
\ ** GetThreadIndex can be used to target a value in an array.

    2 cells bytes TotalRange
\ *G 2 cells containing the total of all ranges in the object. |

    /StkParams 1+ cells bytes &TmpStk \ A tmp stack to pass parameters to a range
                                      \ Each range will get the same stack

:M GetRange:  ( -- High Low )
\ *G Returns the range to be used before a do...loop of the running job.
    MainThread?
       if   TotalRange 2@
       else JobEntryID @  /JobEntry * &JobBlock + >range 2@
       then
   ;M

:M Putrange:      ( High Low IDindex -- )
\ *G Saves the range of a job.
    >range 2! ;M

: .range         ( IDindex - )
\ *G Show the assigned range of a job using the entry index of the job.
     cr  dup 5.r >JobEntry: Self
     >range 2@ 2dup - 5.r  space 5.r 5.r
  ;

:M .Ranges:
\ *G Show the ranges of the jobs used by the object.
\ ** Note: Job entries can be overwritten when they are complete.
   cr cr ." Ranges:"
   cr ." Entry     #    low  high"
   #Jobs 0 #do .range
 ;M

:M ToStack:  ( ni...n0  n --  )
    dup /StkParams > abort" Too many parameters for the job. "
    WaitForFreeJobEntry: Self drop
    dup &TmpStk !
        &TmpStk cell+ over cells+ swap  0
       do     1 cells- dup>r ! r>
       loop
     drop
  ;M

:M SubmitRange:  { High low cfa  -- }
\ *G Submits the specified cfa in a new job and return after that job is submitted.
\ ** Range and parameters from ToStack: are also passed to the job.
   FindThread: Self GetThreadBlock dup>r tcb>#JobsSubmitted  incr
   &TmpStk @  \ stack in use?
       if    cfa WaitForFreeJobEntry: Self dup>r !
             &TmpStk lcount cells r@ >JobStkDepth  lplace    \ Move the tmp stack to the job
       else    0 cfa WaitForFreeJobEntry: Self dup>r 2!      \ Store the CFA and 0 to the stack depth of the Job
       then
   High low r@ >range 2!
   r>                           \ Get the jobEntry
   r> tcb>handle @
   'Callback                    \ callback function for QueueUserAPC
   call QueueUserAPC drop       \ Submit the callback as a job in a thread
  ;M

:M SubmitRanges:  { cfa High low _#threads -- } \ 3
\ *G Distributes and submits all the ranges to various jobs.
    High low - _#threads 2/ + _#threads / dup 0>
       if _#threads 1- 1 max 0
          do    High dup>r over - dup  to High r> swap cfa SubmitRange: Self
          loop
       then
    drop
    high low  2dup >
       if     cfa  SubmitRange: Self
       else   2drop
       then
   &TmpStk off
   Increase: SemaphoreEntryPoint drop
  ;M

:M SetParallelItems: ( cfa limit IndexLow #threads - ) \ 2
\ *G Initilizes the ranges and submits them.
   >r 2dup TotalRange 2! r>
    OnlyOneThread
       if     drop 1 \  Force 1 thread when OnlyOneThread is true
       then
    SubmitRanges: Self
  ;M

:M ]Parallel: \ { limit IndexLow cfa -- }   \ 1
\ *G Submits the specified cfa in a number of jobs. \n
\ ** Use LockJobEntry[: to lock the entrypoint.
\ ** The number of jobs depend on the number of hardware threads and
\ ** the specified range in limit and IndexLow. \n
\ ** Parallel: returns when all the jobs in the object are complete. \n
\ ** Each job can get its range by using GetRange:.\n
\ ** Each range can be passed to a do..loop or #do \n
\ ** The debugger can not be used in a job. \n
\ ** See Single: for debugging.
   ResetJob-ThreadID
   -rot 2dup <= abort" Invallid range"
   #threads
   SetParallelItems: Self
   WaitForAll: Self
  ;M


:M Parallel: ( limit IndexLow cfa -- )   \ 1
\ *G Nearly the same as ]Parallel:. Parallel: also uses a lock to prevent nesting while still busy.
\ ** To be used when no other parameters are passed other than limit IndexLow cfa
      Serialize ]Parallel: Self
  ;M

:M Single: ( limit IndexLow cfa -- )
\ *G Executes the definition of the specified cfa in the main thread.
\ ** The executed definition can get its range by using GetRange:.
\ ** Made for debugging while running in the MainThread.
    MainThread?
       if     -rot TotalRange 2! >r
              &TmpStk  @  \ stack in use?
                if  sp@  &TmpStk lcount 2>r
                    r@  cells - sp!
                    2r> cells sp@ 2 cells+ swap cmove>
                then
             r>  true to Executing? execute false to Executing?
       else  s" Single: Must start from the main-thread" ErrorBox
       then
  ;M

:M ClassInit:  ( -- )
    ClassInit: super
  ;M

;Class



\ --- Demo and test section ---


  (( Disable or delete this line for a rapport-test
    wTasks myTasks     \ Make the object myTasks.

: TimeOut                ( Maxloop - ) random 0  ?do i drop 20 ms loop ;
: Random-Time-Task       ( - )         30 TimeOut ;
: Small-Random-Time-Task ( - )          5 TimeOut  ;
: *Last-Task*            ( - )      beep   1444 ms ;

: TestReport
   Start: myTasks      \ Initialize the object myTasks and specify the maximum number of threads
   cls  Analyze: myTasks                             \ Start a new analysis
   cr ." Test report:"
   35 0  cr TIME-RESET
      do   ['] Random-Time-Task Submit: myTasks      \ Submit a number of tasks
      loop

   15 0
      do   ['] Small-Random-Time-Task Submit: myTasks \ Submit a number of tasks
      loop
   .ELAPSED
   cr ." After all jobs were submitted:"              \ They might not yet complete
   SuspendThreads: myTasks   \ To prevent a change in the running jobs while printing the analysis
   TimeCycles:     myTasks   \ For printing the analysis using cycles.
   .JobAnalysis:   myTasks .ThreadBlock: myTasks        \ Print the analysis here
   ResumeThreads:  myTasks   \ Continue with the jobs
   cr cr cr ." After waiting till all jobs are complete:"
   WaitForAll: myTasks
   .JobAnalysis: myTasks .ThreadBlock: myTasks  \ Print the analysis so far
   cr cr ." Submitting and waiting for the *Last-Task*"
   ['] *Last-Task* Submit: myTasks
   WaitForAll: myTasks
   TimeSeconds: myTasks  .JobAnalysis: myTasks .ThreadBlock: myTasks  \ Print the final analysis
   cr ." All done"
   StopAnalyzing: myTasks \  Stop and erase results
 ;

 TestReport abort

 \s ))


  (( \ Disable or delete this line for the Submit-Test.
\     Made to test and to proove that the use of more tasks can be faster.

 500000 value #loops
 1000  value #Restarts

    wTasks myTasks                 \ Make the object myTasks.
50 Set#Jobs: myTasks   \ Set the maximum number of jobs to be used at one time

 Start: myTasks  \ Initialize the object myTasks.
 Max#threads: myTasks value #counters

\   5 dup PutTaskcount: myTasks to #counters \ An optional test.

#counters floats malloc value counters


: TestTask ( n1 n2 n3 - )
    3drop          \ Just to prove that passing parameters from an other task works
    below 0 pad ! #loops 0
      do   1 pad +!
      loop
    pad @ s>f counters  GetThreadIndex floats +  f+!
 ;

: clr-counters ( - )
    #counters 0
        do   0e0 counters i floats + f!
        loop ;

: Total-counters  ( - f: Total )
    0e0 #counters  0
        do   counters i floats + f@ f+
        loop
  ;

: PromptTime ( - ) cr ." -- " .time time-buf 14 + w@ ." ."  3 .#" type ."  -- " ;

: .ActiveTasks ( - )
    PromptTime #IncompleteJobs:  myTasks
    ." The number of incomplete jobs in the jobbblock is: " . cr
 ;

: SubmitTest ( - )
    cr PromptTime ." SubmitTest started for " #loops s>f fe. ." in #loops in TestTask..."
\   UseOneThreadOnly: myTasks            \ Optional choise
\   15 cells SetThreadBlockSize: myTasks \ Optional choise

    clr-counters
   TIMER-RESET
    #Restarts dup>r 0
       do  LockJobEntry[: myTasks 10 20 30 3 ToStack: myTasks  \ Pass 3 parameters to the job to be submitted
           ['] TestTask ]Submit: myTasks
       loop
    .ActiveTasks
    WaitForAll: myTasks \  Needed to make sure that all tasks are ready
    MS@ START-TIME - .ELAPSED  space
    PromptTime ." All Jobs are ready."
    \ ['] beep Submit: myTasks
    WaitForAll: myTasks \  Needed to make sure that all tasks are ready
    cr r@ . ." jobs were submitted."

    cr ." Total counted: "
    Total-counters  fdup FE.      s>f 1000e  f/ f/ cr ." counts / second: " FE.
    cr ." The maximum number of simultaneous running jobs was: " myTasks.#threads r> min .
    .ActiveTasks
 ;

: ExecuteTest ( - )
    cr ." ExecuteTest started for " #loops s>f fe. ." in #loops in TestTask..."
    clr-counters cr  TIMER-RESET
    #Restarts  dup 0
       do    10 20 30 ['] TestTask LockExecute:  myTasks
       loop
    MS@ START-TIME - .ELAPSED  swap space
    cr . ." restarts used." cr ." Total counted: "
    Total-counters  fdup FE. s>f 1000e  f/ f/ cr ." counts / second: " FE.
    cr ." Using Execute: ( No threads at all )"
  ;

ExecuteTest SubmitTest abort


\ (( 27-4-2014 New results

ExecuteTest started for 500.000E3 in #loops in TestTask...
Elapsed time: 00:00:02.494
1000 restarts used.
Total counted: 500.000E6
counts / second: 200.481E6
Using Execute: ( No threads at all )

-- 15:43:09.925 -- SubmitTest started for 500.000E3 in #loops in TestTask...
-- 15:43:10.519 -- The number of incomplete jobs in the jobbblock is: 5
Elapsed time: 00:00:00.598
-- 15:43:10.529 -- All Jobs are ready.
1000 jobs were submitted.
Total counted: 500.000E6
counts / second: 836.120E6
The maximum number of simultaneous running jobs was: 8
-- 15:43:10.538 -- The number of incomplete jobs in the jobbblock is: 0    ))


  (( \ Disable or delete this line for the Range-test.

     iTasks myTasks

create results #Hardware-threads 2 max cells allot

: my-range-task  ( index n3 n2 n1 - ) { \ index }
    3drop                                  \ Delete n1 n2 n3 passed by To&Task: myTasks
    GetThreadIndex dup to index 1+ 10 * ms \ Each task will get an other wait-time.
    Below   index results index cells+!    \ Will be overwritten
    GetRange: myTasks                  \ Get the range for the do -- loop  for the running task
       do    i results index   cells+!
       loop
  ;

\ Just ONE line is needed to distribute data and execute a word in a parallel way
\ using all the hardware threads.

: range-test ( -- ) \ Setting the number of tasks automatically by using the word Parallel:
  0 Set#Jobs: myTasks  \ To use the ONE job for each thread
  Start: myTasks
  Analyze: myTasks
\ 80 SetSubRange%: myTasks  \ Optional for executing 80% of the total range in an other jobsession

    cr ." Range test:"
\   UseOneThreadOnly: myTasks  \ Optional for testing. Note: You can not use the debugger outside the main-task
    LockJobEntry[: myTasks  30 20 10 3  ToStack: myTasks    \ To test that parameters can be passed
\   170 0  ['] my-Range-task  single: myTasks   \ single: instead of Parallel: for debugging

    170 0  ['] my-Range-task  ]Parallel: myTasks \ Start a number of tasks using all hardware threads when possible.

    cr  ." Number of used tasks: "          myTasks.#threads .
    cr  ." Indexes in the array results: "  myTasks.#threads 1 max 0
       do    results i cells+ ?
       loop

  .JobAnalysis: myTasks .ThreadBlock: myTasks
  .Ranges: myTasks
 ;

range-test  abort \ ))

 (( \  Disable or delete this line for a speed-test.

0e fvalue ft0

: value-ft0 ( f: - #counts )
    ms@ 0e fto ft0
       begin  200e ft0 f+ fto ft0
              ms@ over 400 + >
       until drop  ft0 ;

TIMER-RESET
value-ft0 cr f.s fvalue  #counts   \ To get a runtime for about 8 - 20 seconds

wTasks myTasks

: my-task ( - )              \ Increments a floating point value at PAD
   Below 0e0 pad f!
      begin  pad f@ #counts f<
      while  1e pad f+!
      repeat
 ;

0e fvalue first-result

: .Analyse#Counts  ( - )
    cr ." All tasks ended."
    MS@ START-TIME - space .ELAPSED space
    cr ." Total counts: " #counts GetThreadcount: myTasks s>f f* fdup e.
    s>f  1000e  f/
    cr ." counts / second: " f/  fdup FE. first-result f0=
     if    fto first-result
     else  4 spaces first-result f/ fe. ." Times faster"
     then
 ;

: find-elapsed-time   ( #threads -- )
    >r cr cr ." Main task is waiting for " r@  . ." task" r@ 1 >
        if     ." s"
        then
    r@  SetThreadcount: myTasks   \ Set the number of tasks to be used
    Start: myTasks                \ Starting the tasks after the number of threads have been changed
    r> 0
        do  ['] my-task TIMER-RESET submit: myTasks  \ start the tasks
       loop
    WaitForAll: myTasks
   .Analyse#Counts
\   .JobAnalysis: myTasks .ThreadBlock: myTasks \ Optional
    TerminateAllJobs: myTasks     \ So the number of used threads can be changed the next time
 ;

 #Hardware-threads 2/ 1- value incr-loop

: find-elapsed-times  ( -- )
    1 find-elapsed-time
    Max#threads: myTasks dup>r 2/ 2 max find-elapsed-time
    #Hardware-threads 2 >
      if   r@  1- find-elapsed-time
           r@     find-elapsed-time
      then
    r> dup 2/ 1 max + find-elapsed-time
 ;

: .elapsed-results
   0e fto first-result cls  \ Analyze: myTasks
    ." ImpactThreads: Finding the overall speed for" cr  ." parallel running counters using "
    #Hardware-threads . ." hardware threads."
    cr ." Wait till the end of the demo..."
    find-elapsed-times
    cr ." End of demo."
 ;

  .elapsed-results  abort \s ))

(( May 12th, 2014, On my iCore7:

ImpactThreads: Finding the overall speed for
parallel running counters using 8 hardware threads.
Wait till the end of the demo...

Main task is waiting for 1 task
All tasks ended. Elapsed time: 00:00:07.872
Total counts: 5.01246E8
counts / second: 63.6745E6

Main task is waiting for 4 tasks
All tasks ended. Elapsed time: 00:00:10.282
Total counts: 2.00498E9
counts / second: 194.999E6     3.06244E0 Times faster

Main task is waiting for 7 tasks
All tasks ended. Elapsed time: 00:00:13.665
Total counts: 3.50872E9
counts / second: 256.786E6     4.03279E0 Times faster

Main task is waiting for 8 tasks
All tasks ended. Elapsed time: 00:00:15.501
Total counts: 4.00997E9
counts / second: 258.708E6     4.06297E0 Times faster

Main task is waiting for 12 tasks
All tasks ended. Elapsed time: 00:00:23.590
Total counts: 6.01495E9
counts / second: 254.990E6     4.00458E0 Times faster
End of demo.  ))

 (( \ Disable or delete this line for the Lock-test.

0e fvalue ft0

: value-ft0
    ms@ 0e fto ft0
       begin  100e ft0 f+ fto ft0
              ms@ over 400 + >
       until drop  ;

TIMER-RESET
value-ft0 ft0 f>s  value #counts    \ To get a runtime for about 1 second


 sTask SeqTask
iTasks ParallelTasks

: SequentialWord ( - )             \ Increments a value at PAD. Started by all parallel tasks.
    Below  0 pad !   #counts  0
      do   1 pad +!
      loop   beep                  \ Runs sequential so you hear several beeps.
  ;

: Parallel-tasks ( - )             \ Increments a value at PAD parallel in a number of jobs.
    Below 0 pad !   20 0
        do    1 pad +!             \ The submitted jobs will be ready at nearly the same time
        loop  beep                 \ so you might hear 1 beep or several beeps very fast.
    ['] SequentialWord LockExecute: SeqTask    \ LockExecute: takes care for sequentionally
 ;                                  \ executing the ProtectedWord and not all simultaneously.
\ Note: When Submit: SeqTask is used in stead of LockExecute: SeqTask
\ the execution will be in a job task using only ONE thread at the time.

: TestLock
  4 SetThreadcount: ParallelTasks \ Can be more or less than the number of available hardware threads
  0 Set#Jobs: ParallelTasks \ 0 will set the #Jobs to the required minimum at the start depending on the number of threads

  Start: ParallelTasks \ Starting the 2 objects
  Start: SeqTask
  Analyze: ParallelTasks

\  Range       To run parallel    On the targeted object
   20 0     ['] Parallel-tasks    Parallel: ParallelTasks \ Start Parallel-tasks which starts SequentialWord
  cr .JobAnalysis:   ParallelTasks
 ;

 TestLock
abort \s ))


\s
\ ** \s
\ *Z
