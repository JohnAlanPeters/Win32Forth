\ Example of Selecting and displaying Data
\ Tom Dixon

\ This example shows how to access data from a cursor

needs ADO
needs EX_Connstr.f \ load in the connection string


\ declare the objects that we are going to work with
ADOConnection conn
ADOCursor cursor

start: conn			  \ start the connection
connstr count setconnstring: conn \ set the connection string
connect: conn			  \ connect to the database

start: cursor			        \ start the cursor
conn SetConnection: cursor	        \ tell cursor to use the 'conn' connection object

\ retrieve the table
s" SELECT * FROM globals" execute: cursor


: testdump ( -- )
  cr movefirst: cursor
  0 fieldname: cursor dup >r type cr
  r> 0 ?do [char] - emit loop cr
  begin 0 getstr: cursor type cr
    movenext: cursor
    eof: cursor until ;

testdump


\ clean up
close: cursor
close: conn
