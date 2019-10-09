
\ Example of Creating Database Tables
\ Tom Dixon

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


\ Create a generic Globals Table

s" CREATE TABLE globals (              " qstr lplace
s"  global_name varchar(64) not null,  " qstr +lplace
s"  global_char varchar(255) null,     " qstr +lplace
s"  global_text text null,             " qstr +lplace
s"  global_datetime datetime null,     " qstr +lplace
s"  global_integer int null,           " qstr +lplace
s"  global_float float null)           " qstr +lplace

qstr lcount execute: cursor


close: cursor
close: conn

