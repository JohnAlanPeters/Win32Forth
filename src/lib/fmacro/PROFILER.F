anew profiler.f \ April 28th, 2003 for Win32Forth

(( Reasons for this update:
On my P400 the smallest time that can be measured
with QueryPerformanceCounter is only 838.095E-9 sec
1 cycle on a P400 takes 2.50000E-9
I saw the same resolution for QueryPerformanceCounter on a P 1.7G
So I decided that it would be better to measure the time in the cycles
which the CPU generates
That will be nicer on faster machines.
The disadvantage is that the accuracy of the shown time is less since
the catched clock frequency of the cpu is not stable.
I noticed a difference of 1.06905E-3 sec for the same instruction.
The result is still unstable when you choose to show the time in cycles
instead of seconds.

Other changes:
Now you can choose to show the time in cycles or in seconds.
Added some statistical numbers and an * to indicate a serious delay.

Known bug: A trace might appear 2 times in the debugger when you enter a command. ))


code tsc  ( - tsc_low tsc_high )  \ tsc = Time Stamp Counter
  push ebx      \ save tos
  push edx
  rdtsc         \ uses edx and eax
  mov ebx, edx  \ edx to tos
  pop edx       \ restore edx
  push eax      \ eax to nos
 next c;

\ 1 inline noop takes 15 cycles that is about 37.3617E-9 second


: cycle-time ( f: - f )   1e 10 ms tsc 100 ms   tsc  d- dabs  d>f 10e f* f/   ;

0e fvalue cycle_time

cr cr cycle-time fdup fto cycle_time .( The smallest measurable time is: ) fe. cr

also bug

0e fvalue fmin_time
0e fvalue fmax_time
0e fvalue ftot_time
0e fvalue fprev_av
0e fvalue #traces
0e fvalue #start
0e fvalue #end
0e fvalue debug_cor
0e fvalue delta_t

: rps   ( - ) \ Reset statistics
        0e fto fmax_time
        1.0e30 fto fmin_time
        0e fto ftot_time
        0e fto #traces
        0e fto fprev_av
  ;

: mu_Average ( f: - av )  ."  average: "  ftot_time #traces f/   ;

: .ps
        cr ." Longest trace___: "    fmax_time       fe.
        cr ." Shortest trace__: "    fmin_time       fe.
        cr ." Total used time_: "    ftot_time       fe.
        cr ." Number of traces: "    #traces         f>s .
        cr  9 spaces mu_Average fe.
 ;

defer time_unit

: time-in-cycles ( - f )    #end #start  f-   ;
: cycles>time    ( - f )    time-in-cycles cycle_time f* ;

' time-in-cycles is time_unit
' cycles>time    is time_unit \ disable this line to see the time in cycles

: elapsed  ( - )
        tsc d>f fto #end
        1e #traces f+ fto  #traces
        time_unit fdup fto delta_t debug_cor f-
        #traces 2e f>
        if      fdup fmin_time fmin fto fmin_time
                fdup fmax_time fmax fto fmax_time
                ftot_time f+ fto ftot_time
        else    #traces  rps fto #traces
                fdup fto fprev_av fto ftot_time
        then
 ;

10e fvalue mu_threshold

: .tsc_time   ( f: - )
    #traces 1e f>
      if precision
         delta_t debug_cor f-
         fdup fprev_av   f/  mu_threshold  f>
                if   ." *"
                else ."  "
                then
         #traces 1e f- f>d (d.) type ." ." space
         4 set-precision  fe. ['] time_unit cell+ @  ['] cycles>time =
                if   ." sec "
                else ." cycles"
                then
         space mu_Average fdup fto fprev_av fe.
         space ." total: " ftot_time  fe.
         set-precision
      then
 ;

: tsc_init   ( f: - )    tsc d>f fto #start  ;

: profiler   ( -- )
\IN-SYSTEM-OK [']  elapsed  is debug-entry
\IN-SYSTEM-OK ['] .tsc_time is debug-.s
\IN-SYSTEM-OK [']  tsc_init is debug-exit
        rps
 ;

: profile    ( -<name>- )    \ Shows the elapsed time while profiling.
\IN-SYSTEM-OK	profiler  ' adebug ;

previous

: init-debug-corr ( - )
        tsc_init 1 0
                do     noop  \ debug correction for Win32Forth
                loop
        elapsed delta_t  fto debug_cor
  ;

init-debug-corr  forget init-debug-corr

\s Disable this line to see its use:

\ : test   30 0 do noop drop loop ;
 : test   2 0 do i . 100 ms   loop ;


profile test   \ Aim the debugger at test and change the output of the debugger

cr .( Hit the C to start or the Q to stop ) cr test  \ Run the test


\s Results on my P400:

The smallest measurable time is: 2.49088E-9

Hit the C to start or the Q to stop


code  lit "0x5"      -->  1. 6.069E-6 sec   average: 3.034E-6  total: 6.069E-6
const 0              -->  2. 1.589E-6 sec   average: 2.553E-6  total: 7.658E-6
code  DO             -->  3. 807.2E-9 sec   average: 2.116E-6  total: 8.465E-6


code  I              -->  4. 941.7E-9 sec   average: 1.881E-6  total: 9.407E-6
   :  .              --> 0
                         *5. 241.6E-6 sec   average: 41.83E-6  total: 251.0E-6
code  lit "0x64"     -->  6. 901.8E-9 sec   average: 35.99E-6  total: 251.9E-6
defer MS             --> *7. 96.12E-3 sec   average: 12.05E-3  total: 96.37E-3
code  LOOP           -->  8. 1.106E-6 sec   average: 10.71E-3  total: 96.37E-3
code  I              -->  9. 1.071E-6 sec   average: 9.637E-3  total: 96.37E-3
   :  .              --> 1
                          10. 245.4E-6 sec   average: 8.783E-3  total: 96.62E-3
code  lit "0x64"     -->  11. 976.6E-9 sec   average: 8.052E-3  total: 96.62E-3
defer MS             --> *12. 93.85E-3 sec   average: 14.65E-3  total: 190.5E-3
code  LOOP           -->  13. 1.236E-6 sec   average: 13.61E-3  total: 190.5E-3
code  I              -->  14. 1.126E-6 sec   average: 12.70E-3  total: 190.5E-3
   :  .              --> 2
                          15. 242.9E-6 sec   average: 11.92E-3  total: 190.7E-3
code  lit "0x64"     -->  16. 1.131E-6 sec   average: 11.22E-3  total: 190.7E-3
defer MS             -->  17. 97.58E-3 sec   average: 16.02E-3  total: 288.3E-3
code  LOOP           -->  18. 1.410E-6 sec   average: 15.17E-3  total: 288.3E-3
code  I              -->  19. 866.9E-9 sec   average: 14.41E-3  total: 288.3E-3
   :  .              --> 3
                          20. 243.7E-6 sec   average: 13.74E-3  total: 288.5E-3
code  lit "0x64"     -->  21. 857.0E-9 sec   average: 13.12E-3  total: 288.5E-3
defer MS             -->  22. 92.34E-3 sec   average: 16.56E-3  total: 380.9E-3
code  LOOP           -->  23. 1.261E-6 sec   average: 15.87E-3  total: 380.9E-3
code  I              -->  24. 1.071E-6 sec   average: 15.24E-3  total: 380.9E-3
   :  .              --> 4
                          25. 214.0E-6 sec   average: 14.66E-3  total: 381.1E-3
code  lit "0x64"     -->  26. 986.5E-9 sec   average: 14.11E-3  total: 381.1E-3
defer MS             -->  27. 91.25E-3 sec   average: 16.87E-3  total: 472.3E-3
code  LOOP           -->  28. 797.2E-9 sec   average: 16.29E-3  total: 472.3E-3


code  ;              -->  ok
