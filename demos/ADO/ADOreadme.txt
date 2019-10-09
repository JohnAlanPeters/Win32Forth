These files are examples on how to use the ADO classes.
In order to run them, you must setup a database and make 
sure that the connection string in EX_Connstr.F points 
to it.  An access database is the easiest to make.  All
the examples use EX_Connstr.f to connect.

EX_Create.f - creates a table in the database
EX_InsSQL.F - inserts records into the table (through SQL)
EX_Ins.F - inserts records programmatically
EX_Dump.F - dumps a column of the table


If you run the examples in the order listed, there should
be no errors.  Drop the table from the database to run 
them again.