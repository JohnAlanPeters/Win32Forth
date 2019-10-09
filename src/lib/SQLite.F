\ $Id: SQLite.F,v 1.5 2013/12/17 19:25:23 georgeahubert Exp $

\ SQLite -- Database Class for SQLite
\ Thomas Dixon

\ *D doc\
\ *! SQLite
\ *T SQLite -- Database Class for SQLite
\ *Q Tom Dixon
\ ** This class provides an interface to SQLite databases.

\ *S SQLite Behavior

\ ** SQLite operates on database files.  Files are opened as read-only, if
\ ** no update occurs, and can be shared through several applications.
\ ** Writes cause a block until the file can be opened as read/write.  This
\ ** makes the locking scheme very efficient and easy to work with.\n\n
\ ** SQLite is very fast, flexible, and simple.  One very nice feature is
\ ** that SQLite will convert types as best as it can for you if you want
\ ** a type different from the native database type.\n\n
\ ** For more information about SQLite, please see
\ *W <A href="http://www.sqlite.org/">www.sqlite.org</A>

anew -SQLite.f

INTERNAL
EXTERNAL

winlibrary sqlite3.dll

\ Code to handle returned floats

CODE retF
        FPU>
float;

CFA-CODE DOCALL64 ( [ n ] -- r ) \ like DOCALL, but with a double returned
        push    ebx
        mov     ebx, edx                \ save UP
        call    4 [eax]                 \ call address is absolute!!!
        push    edx
        mov     edx, ebx                \ restore UP
        mov     ebx, eax
        next    c;

: make-proc64 ' docall64 swap ! ;


\ convert standard calls to 64-bit return calls
0 proc sqlite3_column_int64

make-proc64 sqlite3_column_int64


\ DataTypes
1  constant SQLITE_INTEGER
2  constant SQLITE_FLOAT
3  constant SQLITE_TEXT
4  constant SQLITE_BLOB
5  constant SQLITE_NULL

0  constant SQLITE_STATIC
-1 constant SQLITE_TRANSIENT


:class SQLiteDB               <SUPER Object
\ *G SQLiteDB is an interface to SQLite.
        CELL bytes dbhndl
        CELL bytes stmt
             int   lasterr
             int   #args
        256  bytes tstr

:M ClassInit: ( -- )
        0 stmt ! ;M \ Make sure this is cleared

:M SQLOK: ( n -- ) \ checks return argument for errors
        dup 1 99 within if
          to lasterr
        else drop then ;M

:M ERR: ( -- ) \ thows an error on any problem
\ *G Displays any error that might have occured.
        lasterr if
          dbhndl @ call sqlite3_errmsg nip
          zcount tstr place  0 to lasterr
          tstr $DB nabort!
        then ;M

:M Open: ( str len -- )
\ *G Opens a database file so we can execute operations on it.\n
\ ** If the string is ":memory:" the database is actually created
\ ** in memory instead of on disk, and should be faster.
        dup 1+ tstr + 0 swap c! tstr swap cmove
        dbhndl tstr call sqlite3_open
        SQLOK: self drop drop ERR: self ;M

: Finalize ( -- )
        stmt @ if
          stmt @ call sqlite3_finalize nip
          SQLOK: self ERR: self
          0 stmt !
        then ;

:M Close: ( -- flag )
\ *G Closes the database.  You can still open another database with
\ ** the same object after closing, if desired.
        Finalize
        dbhndl @ if
          dbhndl @ call sqlite3_close SQLOK: self drop
          0 dbhndl ! ERR: self
        then false ;M

:M ~: (  --  ) Close: self ;M


:M Version: ( -- str len )
\ *G Returns the version of SQLite being used
        call sqlite3_libversion zcount ;M

:M (Step): ( -- n )
        stmt @ call sqlite3_step nip ;M

:M (Execute): ( str len -- )
        Finalize
        0 stmt 2swap swap dbhndl @
        call sqlite3_prepare_v2
        SQLOK: self ERR: self
        2drop 2drop drop ;M


:M Execute: ( str len -- )
\ *G Execute a SQL query on the cursor.  Any returned data will be in the cursor.
        (Execute): self
        stmt @ call sqlite3_bind_parameter_count nip
        dup to #args if exitm then
        begin (Step): self dup 5 = while
        drop 1 ms repeat SQLOK: self ERR: self ;M

:M Requery: ( -- )
\ *G Rerun the last query.
        stmt @ call sqlite3_reset 2drop ;M

:M FieldCnt: ( -- n )
\ *G Returns the number of columns in the current record.
        stmt @ call sqlite3_column_count nip ;M

:M FieldType: ( field -- DataTypeEnum )
\ *G Returns the data type constant of the given column. Possible data types are:
\ *L
\ *| SQLITE_INTEGER |
\ *| SQLITE_FLOAT |
\ *| SQLITE_TEXT |
\ *| SQLITE_BLOB |
\ *| SQLITE_NULL |
        stmt @ call sqlite3_column_type nip nip ;M

:M FieldName: ( field -- str len )
\ *G Returns the column name of the given column number.
        stmt @ call sqlite3_column_name nip nip
        dup if zcount else drop s" " then ;M

:M GetInt: ( field -- int )
\ *G Returns an integer value of the given column on the current row.
        stmt @ call sqlite3_column_int nip nip ;M

:M GetDouble: ( field -- d )
\ *G Returns the double of the given column on the current row.
        stmt @ sqlite3_column_int64 2swap 2drop swap ;M

:M GetFloat: ( field -- float )
\ *G Returns the floating point value of the given column on the current row.
        stmt @ call sqlite3_column_double retF 2drop drop ;M

:M GetStr: ( field -- str len )
\ *G Returns the string of the given column on the current row.  May be much longer than 255
        stmt @ call sqlite3_column_text nip nip
        dup if zcount else drop s" " then ;M

:M GetBLOB: ( field -- addr len )
\ *G Returns the Binary Buffer of the given column on the current row.
\ ** This binary data may be anything.
        stmt @ call sqlite3_column_bytes >r
        call sqlite3_column_blob nip nip r> ;M

:M isNull?: ( field -- flag )
\ *G Returns true if the given field for the given flag is null
        FieldType: self SQLITE_NULL = ;M

:M NextRow: ( -- flag )
\ *G Goes to the next row of the query result.  If there are no more rows,
\ ** it will return true
        (Step): self 100 <> ;M

:M (Bind): ( -- )
        #args 0= if
          begin (Step): self dup 5 = while
          drop 1 ms repeat SQLOK: self ERR: self
        then ;M

:M BindInt: ( n i -- )
\ *G Binds a '?' in the query string to a integer.  If there are no more question
\ ** marks in the query string, the query will execute.
        1+ stmt @ call sqlite3_bind_int
        SQLOK: self ERR: self
        3drop -1 +to #args
        (bind): self ;M

:M BindDouble: ( d i -- )
\ *G Binds a '?' in the query string to a double int.  If there are no more question
\ ** marks in the query string, the query will execute.
        1+ stmt @ call sqlite3_bind_int64
        SQLOK: self ERR: self
        4drop -1 +to #args
        (bind): self ;M

:M BindFloat: ( f i -- )
\ *G Binds a '?' in the query string to a floating point number.
\ ** If there are no more question
\ ** marks in the query string, the query will execute.
        1+ >r FS>DS r> stmt @ call sqlite3_bind_double
        SQLOK: self ERR: self
        4drop -1 +to #args
        (bind): self ;M

:M BindStr: ( str len i -- )
\ *G Binds a '?' in the query string to a string.  If there are no more question
\ ** marks in the query string, the query will execute.
        1+ >r swap SQLITE_TRANSIENT -rot r>
        stmt @ call sqlite3_bind_text
        SQLOK: self ERR: self
        4drop drop -1 +to #args
        (bind): self ;M

:M BindBlob: ( str len i -- )
\ *G Binds a '?' in the query string to a blob (binary buffer object, or in simpler
\ ** terms, a bunch of bytes).  If there are no more question
\ ** marks in the query string, the query will execute.
        1+ >r swap SQLITE_TRANSIENT -rot r>
        stmt @ call sqlite3_bind_text
        SQLOK: self ERR: self
        4drop drop -1 +to #args
        (bind): self ;M

;class

MODULE

\ *S Examples of Usage:

\ *W <br><U>Creating/Opening a Database:</U><br><br>

\ *E SQLiteDB sqlite
\ ** s" c:\\test.db" open: sqlite

\ *W <br><U>Creating a Database in RAM:</U><br><br>

\ *E SQLiteDB sqlite
\ ** s" :memory:" open: sqlite


\ *W <br><U>Closing a Database:</U><br><br>

\ *E close: sqlite


\ *W <br><U>Creating a table:</U><br><br>

\ *E s" CREATE TABLE idtoname (id int, name varchar)"
\ ** execute: sqlite



\ *W <br><U>Inserting into a table:</U><br><br>

\ *E s" INSERT INTO idtoname(id, name) VALUES(?,?)"
\ ** execute: sqlite
\ ** 1                  0 bindint: sqlite
\ ** s" Jim Hawkins"    1 bindstr: sqlite
\ **
\ ** s" INSERT INTO idtoname(id, name) VALUES(?,?)"
\ ** execute: sqlite
\ ** 2                  0 bindint: sqlite
\ ** s" Billy Bones"    1 bindstr: sqlite
\ **
\ ** s" INSERT INTO idtoname(id, name) VALUES(?,?)"
\ ** execute: sqlite
\ ** 3                  0 bindint: sqlite
\ ** s" Long John Silver" 1 bindstr: sqlite


\ *W <br><U>Executing SQL:</U><br><br>

\ *E : qdump ( -- )
\ **  fieldcnt: sqlite
\ **  0 ?do
\ **    i fieldname: sqlite type tab
\ **  loop cr cr
\ **  begin
\ **    fieldcnt: sqlite
\ **    0 ?do
\ **        i getstr: sqlite type tab
\ **    loop cr
\ **    nextrow: sqlite
\ **  until ;
\ **
\ ** s" SELECT * FROM idtoname WHERE id < 1000 ORDER BY name DESC"
\ ** execute: sqlite
\ ** cr qdump
\ **


\ *W <br><U>Deleting a table:</U><br><br>

\ *E s" DROP TABLE idtoname"
\ ** execute: sqlite


