\ Example of inserting data programmatically
\ Tom Dixon

\ This example shows how to insert data programmatically.

needs ADO
needs EX_Connstr.f \ load in the connection string


\ declare the objects that we are going to work with
ADOConnection conn
ADOCursor cursor

start: conn			  \ start the connection
connstr count setconnstring: conn \ set the connection string
adModeReadWrite setmode: conn	  \ set the mode to read and write
connect: conn			  \ connect to the database

start: cursor			        \ start the cursor
conn SetConnection: cursor	        \ tell cursor to use the 'conn' connection object
adLockOptimistic SetLockType: cursor	\ Lock on updates

\ retrieve the table
s" SELECT * FROM globals" execute: cursor


\ add a float global
addrow: cursor \ add a row to the end
s" PI" 0 setstr: cursor
3.14159265358979e0 5 setfloat: cursor
update: cursor

\ add an integer global
addrow: cursor
s" Major Version" 0 setstr: cursor
3 4 setint: cursor
update: cursor

\ add a date global
addrow: cursor
s" Testdate" 0 setstr: cursor
time&date 3 setdatetime: cursor
update: cursor

\ add a varchar
addrow: cursor
s" Owner" 0 setstr: cursor
s" Billy Bones" 2 setstr: cursor
update: cursor



\ clean up
close: cursor
close: conn
