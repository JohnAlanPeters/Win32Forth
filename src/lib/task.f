\ $Id: task.f,v 1.25 2015/12/03 09:12:26 jos_ven Exp $

\ task.f beta 5.01.0 14/03/2003 20:33:36 arm Callback changes to use assembler

cr .( Loading Task Support...)

\ *D doc
\ *! p-task W32F Task
\ *T Using the Task Wordset

\ *P The multi-tasker is not loaded in the system by default so the file TASK.F in the lib
\ ** folder should be included in any program that multi-tasks, unless using the file
\ ** MultiTaskingClass.f (also in the lib folder) which includes it automatically.
\ *P Multi-tasking in Win32Forth is accomplished by using the Windows\_® \d multi-tasker.
\ ** This is a pre-emptive multi-tasker.

\ *S The Task Control Block

\ *P The task control block (also known as task-block or TCB) is a small structure either
\ ** alloted in the dictionary or allocated on the heap containing information about a task.
\ *B The xt and parameter variables are set when the task-block is created.
\ *B The stop flag can be set by other tasks and is used to signal the task that it has
\ ** been asked to finish.
\ *B The ID is set when the task is created and is valid only until the task terminates.
\ *B The handle is set when the task is created and is valid until it is closed by the
\ ** API CloseHandle function, even after the task has terminated. The operating system
\ ** does not free the OS resources allocated to a task until all handles (except for
\ ** the pseudohandle returned by the API GetCurrentThread) are closed and
\ ** the task has terminated. Programs should close the handle as soon as it's no longer
\ ** needed (if it's never used close it at the start of the task word).

\ *S The User Area

\ *P When a task is created the operating system allocates a stack for the task.
\ ** Win32Forth splits this stack into three regions, a return stack, a User area
\ ** and a data stack. The address of this User area is stored in thread local
\ ** storage so that callbacks have access to the correct User area for the task
\ ** (Versions prior to V6.05 always used the main task's User area for callbacks).
\ ** When a task starts the contents of the User area are undefined except
\ *B Base is set to decimal.
\ *B The exception handler is set so the task exits if an exception is thrown, returning
\ ** the error code to the operating system.
\ *B TCB is set to the task control block of the task.
\ *B RP0 is set to the base of the return stack.
\ *B SP0 is set to the base of the data stack.
\ *P All other User variables used by a task should be explicitly set before use.
\ ** If the task uses floating-point words then FINIT should be called first.

\ *S Glossary

\ -------------------- Task Control Block Offsets --------------------

cell checkstack
cell field+ task>parm     ( task-block -- addr )             \ W32F    Task
\ *G Convert the task-block address into the address of the thread parameter
cell field+ task>id       ( task-block -- addr )             \ W32F    Task
\ *G Convert the task-block address into the address of the thread id
cell field+ task>handle   ( task-block -- addr )             \ W32F    Task
\ *G Convert the task-block address into the address of the thread handle
cell field+ task>stop     ( task-block -- addr )             \ W32F    Task
\ *G Convert the task-block address into the address of the the stop flag
drop

: task>parm@    ( task-block -- parm )                       \ W32F    Task
\ *G Fetch the parameter from the task-block.
                task>parm @ ;

\ -------------------- Task Start Initialisation --------------------

internal

: DisposeUserObjects ( addr -- )
                cell+ @ ?dispose ;

external

1 proc ExitThread

: exit-task     ( n -- )                  \ W32F    Task
\ *G Exit the current task returning the value n to the operating system, which can be retrieved
\ ** by calling GetExitCodeThread. The stacks and user area for the thread are freed and
\ ** DLLs are detatched. If the thread is the last active thread of the process then the
\ ** process is terminated.
                ['] DisposeUserObjects UserObjectList do-link Release-Except-Buffer call ExitThread ;

: (task)        ( parm cfa -- )                 \ helper routine
                Init-Except-Users
                Allocate-Except-Buffer
 \+ dialog-link dialog-link off
                catch                           \ execute cfa and catch errors gah 27nov03
                exit-task                       \ and exit the thread, never returns
                ;

cfa-code BEGIN-TASK ( -- )                      \ thread management. init a new thread/task
                push    ebp                     \ save regs
                push    ebx
                push    edi
                push    esi
                mov     ebp, esp
                call    TASK-ENTRY              \ setup stacks, error-handler etc (in kernel)
                mov     eax, 5 cells [ebp]      \ get task block
                mov     TCB [UP] , eax          \ save in TCB
                mov     ebx, 4 [eax]            \ parameter
                push    ebx                     \ save it
                mov     ebx, 0 [eax]            \ cfa = tos
                mov     eax, # ' (task)         \ get helper entry point
                exec    c;                      \ go do it

\ -------------------- Task Management  --------------------

: (create-task) ( thread state -- flag )        \ create a task
                swap                            \ state addr
                dup task>stop off               \ turn off stop flag
                dup>r                           \ put address of task on rstack
                task>id                         \ threadid pointer
                swap ( CREATE_SUSPENDED | 0  )  \ run it later? from state on stack
                r@                              \ parameter (ptr to cfa/parm pair)
                begin-task                      \ task entry code
                0 0                             \ stack, thread attributes
                call CreateThread dup
                r> task>handle !                \ save in threadid
                0<> ;                           \ and set the flag, true=ok

: create-task   ( task-block -- flag )                       \ W32F    Task
\ *G Create a new task which is suspended. Flag is true if successful.
                CREATE_SUSPENDED (create-task) ;

: run-task      ( task-block -- flag )                       \ W32F    Task
\ *G Create a new task and run it. Flag is true if successful.
                0 (create-task) ;

: suspend-task  ( task-block -- flag )                       \ W32F    Task
\ *G Suspend a task. Flag is true if successful.
                task>handle @                   \ point at thread handle
                call SuspendThread -1 <> ;      \ true=0K

: resume-task   ( task-block -- flag )                       \ W32F    Task
\ *G Resume a task. Flag is true if successful.
                task>handle @                   \ point at thread handle
                call ResumeThread -1 <> ;       \ true=0K

: stop-task     ( task-block -- )                            \ W32F    Task
\ *G Set the stop flag of the task block to true.
                task>stop on ;                  \ stop flag

: (task-block)  ( parm cfa-task addr -- len )                \ W32F    Task
\ *G Build a task block at the supplied address, initialise the parameter and xt and
\ ** return the size of the task block.
                dup>r !                         \ cfa
                r@ cell+ !                      \ parameter for the task
                r> 2 cells+ 0 over !            \ 0 threadid
                cell+ 0 over !                  \ thread handle
                cell+ 0 swap !                  \ flag
                5 cells
                ;

: task-block    ( parm cfa-task -- addr )                    \ W32F    Task
\ *G Build a task block in the dictionary, initialise the parameter and xt and return
\ ** the address of the block.
                here >r                         \ return this block's address
                ,                               \ cfa to execute as task
                ,                               \ parameter for task (extracted later)
                0 ,                             \ threadid
                0 ,                             \ thread handle
                0 ,                             \ stop flag
                r> ;                            \ return structure

: task-stop?    ( task-block -- flag )                       \ W32F    Task
\ *G Flag is true if stop-task has been set by another task. In this case the task should
\ ** do any necessary clean-up and exit.
                task>stop @ ;                   \ check, exit if stop set

\ -------------------- Task Lock Definitions --------------------

internal

variable lock-list lock-list off               \ list of locks gah

6 cells constant lock-size

external

\ *S Locking Resources

\ *P Since the multi-tasker is pre-emptive it is sometimes necessary to restrict access
\ ** to resources to a single task to prevent inteference between different tasks.
\ ** Win32Forth provides a set of words for efficiently locking sections of code.
\ ** The system also contains some locks used internally that are transparent to the user.

\ *S Glossary

: lock          ( lock -- )                                  \ W32F     Lock
\ *G If another thread owns the lock wait until it's free,
\ ** then if the lock is free claim it for this thread,
\ ** then increment the lock count.
                call EnterCriticalSection drop ;

: unlock        ( lock -- )                                  \ W32F     Lock
\ *G Decrement the lock count and free the lock if the resultant count is zero.
                call LeaveCriticalSection drop ;

version# ((version)) 0. 2swap >number 3drop 7 < dup [if] winver winnt4 < and [then]
 [if]  \ For V6.xx.xx older OSs
\ sorry, TryEnterCriticalSection() is only avaible for NT4 and later !!!

: trylock       ( lock -- fl )
                lock true ;

internal

: init-lock     ( lock -- )
                call InitializeCriticalSection drop ;

[else] \ For future V7.xx.xx and above and newer OSs made conditional for now.

: trylock       ( lock -- fl )                                \ W32F    Lock
\ *G \b For NT4, w2k and XP; \d
\ ** If the lock is owned by another thread return false. \n
\ ** If the lock is free claim it for this thread,
\ ** then increment the lock count and return true. \n
\ ** \b For Win9x, and NT<4; \d
\ ** Perform the action of LOCK and return true.
                call TryEnterCriticalSection 0<> ;

internal

: init-lock     ( lock -- )     \ Initialise a lock
                0 swap call InitializeCriticalSectionAndSpinCount drop ;

[then]

external

: (make-lock)   ( -- lock )                                   \ W32F    Lock
\ *G Make a new lock, and return it's identifier.
                here dup
                lock-size ( 6 cells ) allot
                lock-list link, \ add to list of locks
                init-lock \ Initialise the critical section
                ;

in-system

: make-lock     ( compiling: "name"  --  runtime: -- lock ) \ W32F    Lock
\ *G Create a new lock. When executed the lock returns it's identifier.
                create  (make-lock) drop ;

in-previous

internal

: init-lock-from-list ( addr -- )  \ Initialise a lock given address of link
                lock-size - init-lock ;

: init-locks          ( -- )       \ Initialise all the locks
                ['] init-lock-from-list lock-list do-link ;

initialization-chain chain-add init-locks

\ -------------------- Task Specific Overrides --------------------
\ Memory locks, see kernel & primutil memory words. See also controls and generic for locking
\ of dialog linking and control subclasssing

make-lock mem-lock                      \ to make memory allocation thread safe
make-lock control-lock                  \ to make control subclassing thread safe
make-lock dialog-lock                   \ to make linking dialogs thread safe
make-lock classname-lock                \ to make unique window class naming thread safe
make-lock pointer-lock                  \ to make allocating pointers thread safe
make-lock dyn-lock                      \ to make new$ thread safe
make-lock gdi-lock                      \ to make linking gdi objects thread safe

: _memlock         ( -- )  mem-lock       lock   ;   \ for overriding defered lock memory word
: _memunlock       ( -- )  mem-lock       unlock ;   \ for overriding defered unlock memory word
: _controllock     ( -- )  control-lock   lock   ;   \ for overriding deferred lock subclassing word
: _controlunlock   ( -- )  control-lock   unlock ;   \ for overriding deferred unlock subclassing word
: _dialoglock      ( -- )  dialog-lock    lock   ;   \ for overriding deferred lock dialog linking word
: _dialogunlock    ( -- )  dialog-lock    unlock ;   \ for overriding deferred unlock dialog linking word
: _classnamelock   ( -- )  classname-lock lock   ;   \
: _classnameunlock ( -- )  classname-lock unlock ;
: _pointerlock     ( -- )  pointer-lock   lock   ;
: _pointerunlock   ( -- )  pointer-lock   unlock ;
: _dynlock         ( -- )  dyn-lock       lock   ;
: _dynunlock       ( -- )  dyn-lock       unlock ;
: _gdilock         ( -- )  gdi-lock       lock   ;
: _gdiunlock       ( -- )  gdi-lock       unlock ;

dpr-warning-off

: init-system-locks  ( -- )                   \ initialize system locks for multitasking
               ['] _memlock         is (memlock)
               ['] _memunlock       is (memunlock)
               ['] _controllock     is (controllock)
               ['] _controlunlock   is (controlunlock)
               ['] _dialoglock      is (dialoglock)        \ No longer needed.
               ['] _dialogunlock    is (dialogunlock)      \ No longer needed.
               ['] _classnamelock   is (classnamelock)
               ['] _classnameunlock is (classnameunlock)
               ['] _pointerlock     is (pointerlock)
               ['] _pointerunlock   is (pointerunlock)
               ['] _dynlock         is (dynlock)
               ['] _dynunlock       is (dynunlock)
               ['] _gdilock         is (gdilock)
               ['] _gdiunlock       is (gdiunlock) ;

dpr-warning-on

init-system-locks

initialization-chain chain-add init-system-locks

\ -------------------- Forgetting Locks -----------------------------

\ *S WARNING
\ *P Before using FORGET or executing MARKER words unlock any locks which are
\ ** about to be forgotten to avoid memory leaks AND exit any threads which will be
\ ** forgotten to avoid \b CRASHING !! YOU HAVE BEEN WARNED \d

in-system

: delete-locks ( nfa link -- nfa )     \ delete lock if created after nfa
              2dup trim? if lock-size - call DeleteCriticalSection then drop ;

: trim-locks ( nfa -- nfa )
             ['] delete-locks lock-list do-link dup lock-list full-trim ;

forget-chain chain-add trim-locks

in-previous

module

\ *Z
