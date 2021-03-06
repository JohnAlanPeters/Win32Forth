\ ----------------------------------------------------------------------
\ LANGUAGE    : ANS Forth
\ PROJECT     : CHForth, a Dutch public domain ANS Forth for PC's
\ DESCRIPTION : The Famous Sieve of Eratosthanes
\ CATEGORY    : Benchmarks
\ AUTHOR      : Marcel Hendrix October 5th, 1991
\ CHANGES by J.v.d.Ven (on a P400):
\ March 31th, 2003  Changed to demonstrate fmacro.f
\                   The elapsed time now is becomes 16.91
\ May 10th, 2003    Improved the elapsed time to 11.87
\                   by using register ECX and EDX as local variables
\ May 26th, 2003    Used  [ I dup_a! flags ass-lit+ ] in DO-PRIME2 in stead of
\                         [ addr flags I dup_a! + ]
\                   This reduces unneeded pushing of a parameter on the stack.
\                   fmacro.f is now able to remove unneeded pops and pushes.
\                   The new elapsed time is: 11.18
\ November 15th, 2004 Changed the code according to 
\ 	            http://www.mpeltd.demon.co.uk/pfwvfx.htm#bnchmrk
\		    #times to 1000 and size to 8190
\ November 30th, 2004 Added Primes3. For maximum use of fmacro.f rate: 236.124
\ December  1st, 2004 	Changed Primes3. New rate: 234.229
\ December  9th, 2004	Changed Primes2 and Primes3 New rates: 206.846 and 206.635
\	 		There seems no need for Primes3.
\ ----------------------------------------------------------------------



        MARKER -sieve

needs fmacro.f

 1000 constant #times          
 8190 variable size  size !    \ 8190

CREATE flags    size @ ALLOT

: PRIMES1        CR size @ . ." size. " #times . ." iterations."  TIMER-RESET
                0 #times 0 DO   DROP flags size @ 1 FILL
                                0  size @ 0 DO flags I +
                                             C@ IF I DUP +  3 +
                                                   DUP  I +
                                                       BEGIN  DUP size @ <
                                                       WHILE  0 OVER flags + C!
                                                              OVER +
                                                       REPEAT
                                                    2DROP 1+
                                                THEN
                                             LOOP
                           LOOP
                CR .  ." primes found using primes-org."
                CR .ELAPSED CR CR ;

code DO-PRIME2 ( n1 - n2 )        
      b>r drop 0 ass-lit b!  0 ass-lit  size addr@ 0 ass-lit 
              DO   I dup_a! flags ass-lit+ C@
                       IF    a@  a@+  3 ass-lit+ 
                             dup>r a@+
                                 BEGIN  dup_a! size addr@<
                                 WHILE  addr flags a@+ b_nos_c!  r@ a@+ 
                                 REPEAT
                             1+ r>drop				
                        THEN 
              LOOP
       r>b 
   next,
   end-code

: PRIMES2        CR size @ . ." size. " #times . ." iterations."  TIMER-RESET
                 0 #times 0 DO   flags size @ 1 FILL
                                DO-PRIME2
                            LOOP
                CR .  ." primes found using primes2."
                CR .ELAPSED CR CR ;
                
code   DO-PRIME3    ( - n2 )         
   b>r 0 ass-lit b! 0 ass-lit  #times ass-lit 0 ass-lit 
   DO  flags ass-lit  size addr@ 1 ass-lit fcall FILL 
        DROP  0 ass-lit  size addr@ 0 ass-lit
              DO   I dup_a! flags ass-lit+ C@
                       IF    a@  a@+ 3 ass-lit+
                             dup>r  a@+  
                                 BEGIN  dup_a! size addr@<
                                 WHILE  addr flags a@+ b_nos_c!  r@ a@+ 
                                 REPEAT
                             1+  r>drop				
                        THEN 

              LOOP 
   LOOP 
   r>b
  next, 
  end-code


: PRIMES3       CR size @ . ." size. " #times . ." iterations."  TIMER-RESET
		DO-PRIME3
                CR .  ." primes found using primes3."
                CR .ELAPSED CR CR ;

cr cr
 .( High level Win32Forth:) PRIMES1
 .( Using fmacro.f:)  PRIMES2
 .( Maximum use of fmacro.f:)  PRIMES3

\s


The numbers from http://www.mpeltd.demon.co.uk/pfwvfx.htm#bnchmrk
Test including overheads (all times are in milliseconds,
Athlon 900Mhz, 256Mb RAM, Windows 2000)
Added a rate. When the rate is smaller the coding is better!

Erastothenes Sieve 1899 primes
System			MS	Rate = MHZ_clk * ms  / #primes 
SwiftForth 2.00.3    	441	209.005
iForth 1.12.1121   	326	154.502
VFX Forth 3.40.0686 	380	180.095

Note: The rate only compensates the clock frequentie and 
      does not compensate the improvements of technology.

Results on a P400:

High level Win32Forth version 6.09.13, build 1:
8190 size. 1000 iterations.
1899 primes found using primes-org.
Elapsed time: 00:00:06.419	1352.08

Using fmacro.f:
8190 size. 1000 iterations.
1899 primes found using primes2.
Elapsed time: 00:00:00.982	206.846

Maximum use of fmacro.f:
8190 size. 1000 iterations.
1899 primes found using primes3.
Elapsed time: 00:00:00.981	206.635

Jos
 