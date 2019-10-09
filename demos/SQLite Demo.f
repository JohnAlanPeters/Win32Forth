\ Benchmark for SQLite stuff
\ Thomas Dixon

anew -SQLiteDemo.f

include SQLite.f

SQLiteDB sqlite

10000 constant #records

: create-table ( -- )
  s" CREATE TABLE test (name varchar, id int, fl1 float, data blob )"
  execute: sqlite ;

: delete-table ( -- )
  s" DROP TABLE test"
  execute: sqlite ;

: row-iter ( xt -- )
  begin dup >r execute r>
  nextrow: sqlite until drop ;

\ Generating a random word
create tbuf 256 allot
create tstr 256 allot

: random-word ( -- str len )
  12 random 1 +
  dup tbuf c!
  0 do
    26 random 97 +
    tbuf i + 1 + c!
  loop tbuf count ;

\ Generating a random string
: random-str ( n -- str len )
  0 tstr c!
  0 do random-word tstr +place
       s"  " tstr +place loop
  tstr count ;


\ Fill tables with junk...

: ins-rows ( n -- )
  0 do
    s" INSERT INTO test(name, id, fl1, data) VALUES(?,?,?,?)"
    execute: sqlite
    4 random 1+ random-str 0         bindstr: sqlite
    i 1                              bindint: sqlite
    i s>f 3.14159265358979e0 f* 2  bindfloat: sqlite
    get-local-time time-buf 16 3    bindblob: sqlite
  loop ;


\ misc operations
: walk-table ( -- )
  0 ['] 1+ row-iter
  ." Ran through " . ."  rows." ;

: order-by-int ( -- )
  s" select * from test order by id desc"
  execute: sqlite ;

: order-by-float ( -- )
  s" select * from test order by fl1 desc"
  execute: sqlite ;

: order-by-string ( -- )
  s" select * from test order by name desc"
  execute: sqlite ;

: order-by-blob ( -- )
  s" select * from test order by data desc"
  execute: sqlite ;

: random-access ( n -- )
  0 do
    s" select * from test where id = ?" execute: sqlite
    #records random 0 bindint: sqlite
  loop ;

\ for debug
: qdump ( -- )
  fieldcnt: sqlite
  0 ?do
    i fieldname: sqlite type tab
  loop cr cr
  begin
    fieldcnt: sqlite
    0 ?do
        i getstr: sqlite type tab
    loop cr
    nextrow: sqlite
  until ;




: memory-db ( -- )
  s" :memory:" open: sqlite ;

: file-db ( -- )
  s" c:\mytest.db" open: sqlite ;

cr cr .( SQLITE Benchmark! )
cr cr .( Creating Database from RAM:  )
elapse memory-db
cr cr .( Creating Tables:   )
elapse create-table
cr cr #records . .( row insert:   )
elapse #records ins-rows
cr cr .( Ordering Data by Integer: )
elapse order-by-int
cr cr .( Walk Through All Records: )
elapse walk-table
cr cr .( Ordering Data by Float: )
elapse order-by-float
cr cr .( Walk Through All Records: )
elapse walk-table
cr cr .( Ordering Data by String: )
elapse order-by-string
cr cr .( Walk Through All Records: )
elapse walk-table
cr cr .( Ordering Data by Blob: )
elapse order-by-blob
cr cr .( Walk Through All Records: )
elapse walk-table
cr cr .( Random Access -100 records- :)
elapse 100 random-access
cr cr .( Deleting Tables: )
elapse delete-table



