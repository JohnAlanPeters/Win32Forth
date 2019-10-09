\ $Id: taskdemo.f,v 1.9 2008/10/29 23:20:55 georgeahubert Exp $

needs task.f \ task demo code

\ -------------------- Demonstrations  --------------------
\ demo1 code, fairly complex example.
\ creates several running tasks and waits for them to complete.
\ each task runs and produces output on a line number passed as a parameter
\ and waits between printing numbers based on the line it's on.
\ wait-eachtask is notable -- it waits on all the tasks. as each task completes
\ it then rewaits on those that are still running until none are left.

make-lock console-lock                     \ a simple console lock, the console is not thread-safe
: c-lock console-lock lock getxy ;         \ lock console, save where the cursor is
: c-unlock gotoxy console-lock unlock ;    \ unlock, restore cursor

4 newuser location

: my-task { y -- }  \ prints a counter from 1 to 99 with a wait
                               \ that depends on which line it is running
          y location !         \ show that user & local variables work
          c-lock
          1 location @ gotoxy
          ." Task " tcb @ task>id @ .  tab
          ."  running at line " location @ 1+ .
          c-unlock
          100 1 do
          location @ 15 * ms  \ sleep depends on line number, bigger=longer
          c-lock
            40 location @  gotoxy
            i  .
          c-unlock
          loop
          c-lock 50 location @ gotoxy ." Exiting..." gotoxy
           1 ;     \  my exit code and leave the console locked

15 value taskcount                      \ number of tasks to start
create taskblocks 15 cells allot        \ cells to hold task blocks ptrs
create taskhndls  15 cells allot        \ cells to hold task handles for wait function

: make-tasks   ( n -- )                  \ create the task blocks
    to taskcount
    taskcount 0 do
        i 1 +                            \ line number for my-task
        ['] my-task task-block           \ create the task block
        taskblocks i cells+ !            \ save in the taskblocks area
    loop
    ;

: run-tasks  ( -- )                      \ run all the tasks
    taskcount 0 do                       \ for each task
       taskblocks i cells+ @             \ get the task-block
       dup run-task drop                  \ run the tasks
       task>handle @ taskhndls i cells+ ! \ save all the task handles created
    loop
    ;

winerrmsg on

: WaitForMultipleObjects { ms wait array count -- res } \ Must deal with messages
        begin QS_ALLINPUT ms wait array count call MsgWaitForMultipleObjects
        dup WAIT_OBJECT_0 count + = while drop winpause repeat ;

0 value taskwaits
: wait-eachtask ( -- )                   \ wait for each task
        taskcount to taskwaits
        begin
          taskwaits
        while
          INFINITE false taskhndls           \ wait for 1 or more tasks to end
          taskwaits WaitForMultipleObjects   \ wait on handles list
          dup WAIT_FAILED = if getlastwinerr then \ note the error
          WAIT_OBJECT_0 +
          dup>r taskblocks +cells @ task>id @   \ get the task id
\         console-lock lock                   \ locking here will lock the whole system
\         begin winpause console-lock trylock until \ can be used provided unlock in task exit is resored
\         but only on NT 4 or greater.
          ." Task " . ." completed"  cr
          console-lock unlock                 \ Unlock here.( was locked at the task exit )
          -1 +to taskwaits                    \ 1 fewer task, clean up the list
          taskhndls taskwaits cells+ @        \ get last handle in list
          taskhndls r@ cells+ !               \ store in signaled event ptr
          taskblocks taskwaits cells+ @       \ get last block in list
          taskblocks r> cells+ !              \ store in signaled block
        repeat
        ." All tasks completed" cr
    ;

: start-tasks ( n -- )
     make-tasks
     console-lock lock   \ Prevents locking by the tasks
     run-tasks           \ They will wait till the console is unlocked
     0 25 gotoxy ." Main task is waiting for " taskcount . ." tasks" cr
     console-lock unlock \ The tasks will continue to run here
     wait-eachtask
     ." All tasks ended" cr
     ;

: demo1
     cls
     ." Demo1: Creating free running tasks "
     taskcount start-tasks ;

cr .( Type Demo1 to start Demo1) cr

\ demo2 creates 2 tasks that read the same file, but at varying speeds, showing
\ that file i/o is thread safe

4 newuser fhndl

: t2-openfile ( addr len -- )
        r/o open-file abort" File open error!" fhndl ! ;

: my-task2 { speed -- }
        console-lock lock
        tcb @  task>id @ ." Task" . ." is running with a delay of"
           speed . cr
        console-lock unlock
        s" src\lib\task.f" Prepend<home>\ t2-openfile
        begin
          pad 256 fhndl @ read-line abort" IO Error!"
        tcb @  task-stop? not and
        while
          console-lock lock
          ." Task" tcb @  task>id @ .
          pad swap type cr
          console-lock unlock
          speed ms
        repeat
         fhndl @ close-file ;

0 value task-slow
0 value task-fast
100 constant  task-slow-speed
30 constant  task-fast-speed

: demo2
  cls ." Multithread file I/O, press any key to stop" cr
  task-slow-speed ['] my-task2 task-block to task-slow
  task-fast-speed ['] my-task2 task-block to task-fast
  task-slow run-task drop
  task-fast run-task drop
  key drop
\  console-lock unlock \ To be sure the console is unlocked; do noy use since locks and unlocks MUST be balanced.
  task-slow stop-task
  task-fast stop-task
  ." Ended"
;

.( Type Demo2 to start Demo2, any key to stop) cr

