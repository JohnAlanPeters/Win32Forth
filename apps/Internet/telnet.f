\ TelNet Client
\ Thomas Dixon

needs sock.f            \ Socket Library

0 value tsock     \ socket handle
0 value tparam1
0 value tparam2
2variable oldcursor

\ special keys for telnet session
131081  value bkchar   \ break key
131078  value upchar
131079  value downchar
131076  value leftchar
131077  value rightchar
        

: telsend ( ch -- ) \ send a byte to the connection
  pad ! pad 1 tsock sock-write drop ;
  
: teltype ( str len -- ) \ write a string to the connection 
  tsock sock-write drop ;
  
: telget ( -- ch ) \ get a byte from the connection
  pad 1 tsock sock-read drop pad c@ ;

: teliac ( cmd -- ) \ interactive command dispatcher
  case
    253 of telget 252 255 telsend telsend telsend endof
    254 of telget 252 255 telsend telsend telsend endof
  endcase ;
  
: telparam ( -- )
  telget dup [char] 0 [char] 9 1+ within
  if [char] 0 - tparam1 10 * + to tparam1 recurse exit then    
  case
    [char] ; of tparam1 to tparam2 0 to tparam1 recurse endof
    [char] J of page endof
    [char] H of tparam1 tparam2 at-xy endof
    [char] s of getxy oldcursor 2! endof
    [char] u of oldcursor 2@ at-xy endof
    [char] A of getxy tparam1 1 max - at-xy endof
    [char] B of getxy tparam1 1 max + at-xy endof
    [char] C of getxy swap tparam1 1 max + swap at-xy endof
    [char] D of getxy swap tparam1 1 max - swap at-xy endof
    [char] f of tparam1 tparam2 at-xy endof
  endcase ;

: telesc ( -- ) \ escape code dispatcher
  telget case
    [char] [ of telparam endof
    [char] H of tab endof
    [char] 7 of getxy oldcursor 2! endof
    [char] 8 of oldcursor 2@ at-xy endof
  endcase ;

: telchar ( ch -- ) \ handle an incoming byte
  dup 32 127 within if emit exit then 
  case
    8   of 8  emit endof
    9   of tab endof
    10  of 10 emit endof
    12  of page endof
    13  of 13 emit endof
    27  of 0 0 to tparam1 to tparam2 telesc endof
    255 of telget teliac endof
  endcase ;

: telnetloop ( -- ) \ main loop of telnet program
  begin tsock sock-closed? 0= while
    tsock sock-read? 0> if 
      telget telchar
    else 1 ms then  
    key? if 
      key dup  case
        13        of telsend 10 telsend endof
        bkchar    of drop exit endof
        upchar    of drop 27 telsend s" [1A" teltype endof
        downchar  of drop 27 telsend s" [1B" teltype endof
        leftchar  of drop 27 telsend s" [1C" teltype endof
        rightchar of drop 27 telsend s" [1D" teltype endof
        telsend
      endcase
    then
  repeat ;

: telnet ( addr len port -- ) \ open a telnet session
  sock-open to tsock
  telnetloop
  tsock sock-close drop ;


\ This works very similar to the command line utility
\ Examples:
\ s" myserver" 23 telnet

\ On the Internet ASCII Art:
\ s" towel.blinkenlights.nl" 23 telnet


