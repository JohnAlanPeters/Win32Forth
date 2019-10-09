\ Example of inserting data into a database VIA SQL
\ Tom Dixon

\ This example shows how to execut SQL queries to insert
\ data into a table

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


create qstr LMAXSTRING allot


s" INSERT INTO globals (global_name, global_text, global_integer, global_datetime)" qstr lplace
s" VALUES('StartDate','The Date the database was started',1,now())" qstr +lplace

qstr lcount execute: cursor

close: cursor
close: conn
