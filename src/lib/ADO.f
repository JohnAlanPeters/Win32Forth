\ *D doc\classes\
\ *! ADO
\ *T ADO -- ADO Classes for Database Interfacing
\ *Q Tom Dixon - August 2006
\ ** These classes were developed to make accessing databases easy and convienent
\ ** with win32forth.

needs fcom

2 5 typelib {00000205-0000-0010-8000-00AA006D2EA4} \ inlude ADO type library


create UComma 32 allot  u" ," UComma uniplace           \ Column Delimeter
create Ucrlf  32 allot  crlf$ count >unicode Ucrlf uniplace \ New Record Delimeter
create Unull 32 allot  u" " Unull uniplace     \ Null Character Replacement

\ *S  ADOConnection Class

:class ADOConnection               <SUPER Object
\ *G An ADO connection object controls the access of cursors to the database.
\ ** It is meant to control things such as tranactions, read/write properties
\ ** and error handling.
        CELL bytes Conn
        CELL bytes Errs
        16   bytes xtra
             int   mstr
             int   mstrlen

:M Freemstr: ( -- )
        mstr if mstr free drop 0 to mstr 0 to mstrlen then ;M

:M ~: (  --  )

        Conn @ if Conn COM _Connection Release drop 0 Conn ! then
        Freemstr: self ;M

:M Start: ( -- )
\ *G Initializes the ADO Connection Component.  Most methods will not execute properly
\ ** if this is not called when the object instance is created
        Conn @ 0= if
          Conn _Connection 1 0 Connection CoCreateInstance
          abort" Unable to Create Connection Object!" then ;M

:M Connect: ( -- )
\ *G Connects to the data source specified by the connection string with the given
\ ** connection properties.
        0 0 0 0 Conn COM _Connection Open drop ;M

:M GetConn: ( -- IConn ) Conn @ ;M

:M Close: ( -- flag )
\ *G Closes the database connection.  The COM component still exists and a new
\ ** connection may be made if desired.
        Conn COM _Connection Close drop
        Freemstr: self ;M

:M BSTR>ASC: ( bstr -- str len )
        dup 0= if drop s" " exitm then
        Freemstr: self
        dup dup bstrlen ?dup if uni>asc else drop s" " then
        2dup to mstrlen to mstr
        rot bstrfree ;M

:M GetErrorCnt: ( -- cnt )
\ *G Return the number of errors in the FIFO error queue
        Errs Conn COM _Connection GetErrors
        abort" Unable to Get Errors!"
        xtra Errs COM Errors GetCount drop xtra @
        Errs COM Errors Release drop ;M

:M GetError: ( cnt -- n )
\ *G Return the error number of the 'cnt' error in the error queue
        Errs Conn COM _Connection GetErrors
        abort" Unable to Get Errors!"
        xtra 0 rot 0 VT_I4
        Errs COM Errors GetItem abort" Unable to get Error!"
        0 >r rp@ xtra COM Error GetNumber drop r>
        xtra COM Error Release drop
        Errs COM Errors Release drop ;M

:M Error>str: ( n -- str len )
\ *G Return the error string of the 'cnt' error in the error queue
        Errs Conn COM _Connection GetErrors
        abort" Unable to Get Errors!"
        xtra 0 rot 0 VT_I4
        Errs COM Errors GetItem abort" Unable to get Error!"
        0 >r rp@ xtra COM Error GetDescription drop
        r> bstr>asc: self
        xtra COM Error Release drop
        Errs COM Errors Release drop ;M

:M ClearErrors: ( -- )
\ *G Clears the FIFO error queue
        Errs Conn COM _Connection GetErrors
        abort" Unable to Get Errors!"
        Errs COM Errors Clear drop
        Errs COM Errors Release drop ;M

:M ERR: ( n -- ) \ thows an error on any problem
\ *G Displays and clears all errors in the queue
        GetErrorCnt: self 0 ?do
          i Error>str: self type cr
        loop
        clearerrors: self ;M

:M Transaction: ( -- )
\ *G Starts a transaction session for this connection.  All changes
\ ** performed on the database will not take effect until they are committed.
\ ** Some databases may not support this functionality.
        xtra Conn COM _Connection BeginTrans drop
        xtra @ drop \ nesting level - don't use right now...
        ;M
:M Commit: ( -- )
\ *G Commit all changes in the current transaction to the database.
        Conn COM _Connection CommitTrans drop ;M

:M RollBack: ( -- )
\ *G Drop all changes in the current transaction - no changes are made for the
\ ** transaction session.
        Conn COM _Connection RollbackTrans drop ;M

:M GetTimeOut: ( -- n )
\ *G Returns the timeout time (in seconds) that queries will give up.
        xtra Conn COM _Connection GetCommandTimeout drop
        xtra @ ;M

:M SetTimeOut: ( n -- )
\ *G Sets the timeout time (in seconds) that queries will give up.
        Conn COM _Connection PutCommandTimeout drop ;M

:M GetConnString: ( -- str len )
\ *G Return the connection string for the data source.  This may not necessarily
\ ** be the same string that was given to the object
        xtra Conn COM _Connection GetConnectionString drop
        xtra @ bstr>asc: self ;M

:M SetConnString: ( str len -- )
\ *G Set the connection string for the data source.  The connection string tells
\ ** the object what drivers to use, where the database is, user name, and password.
        Asc>bstr dup >r Conn COM _Connection PutConnectionString
        abort" Unable to set Connection String!" r> bstrfree ;M

:M GetProvider: ( -- str len )
\ *G Returns the provider for the connection.
        xtra Conn COM _Connection GetProvider drop
        xtra @ bstr>asc: self ;M

:M SetProvider: ( str len -- )
\ *G Sets the provider for the connection.  Can be set through the connection string
\ ** as well.
        Asc>bstr drop dup >r Conn COM _Connection PutProvider
        abort" Unable to set Provider!" r> bstrfree ;M

:M GetMode: ( -- n )
\ *G Returns the connection mode.
        xtra Conn COM _Connection GetMode drop
        xtra @ ;M

:M SetMode: ( n -- )
\ *G Sets the connection mode.  The connection mode indicates whether the database
\ ** is read-only, write-only, sharable, etc...\n
\ ** See the ConnectModeEnum constants below the class descriptions.
        Conn COM _Connection PutMode drop ;M

:M GetState: ( -- n )
\ *G Returns the current state of the connection object.
        xtra Conn COM _Connection GetState drop
        xtra @ ;M

;class




\ *S  ADOCursor Class

:class ADOCursor               <SUPER Object
\ *G An ADO cursor object represents a recordset of data, or data in a table-like
\ ** structure.  Data can be loaded, updated, inserted through this object.
        CELL bytes Rec
        CELL bytes flds
        CELL bytes fld
        16   bytes xtra
             int   CONNptr
             int   mstr
             int   mstrlen

:M Freemstr: ( -- )
        mstr if mstr free drop 0 to mstr 0 to mstrlen then ;M

:M ~: (  --  )
        Rec @ if Rec COM _Recordset Release drop 0 Rec ! then
        Freemstr: self ;M

:M Start: ( -- )
\ *G Initializes the ADO Recordset Component.  Most methods will not execute properly
\ ** if this is not called when the object instance is created
        Rec @ 0= if
          Rec _Recordset 1 0 RecordSet CoCreateInstance
          abort" Unable to Create Recordset Object!" then ;M

:M BSTR>ASC: ( bstr -- str len )
        dup 0= if drop s" " exitm then
        Freemstr: self
        dup dup bstrlen ?dup if uni>asc else drop s" " then
        2dup to mstrlen to mstr
        rot bstrfree ;M

:M SetConnection: ( ADOConnection -- )
\ *G Sets the connection object for this cursor.  It is required before any query
\ ** is executed.
        to CONNptr ;M

:M GetCacheSize: ( -- n )
\ *G Returns the cache size of the cursor.  The value is the number of records in the
\ ** cache before updates are required.
        xtra rec COM _Recordset GetCacheSize drop xtra @ ;M

:M SetCacheSize: ( n -- )
\ *G Sets the cache size of the cursor.  The default is 1, or updates occur with every
\ ** new record edited.
        rec COM _Recordset PutCacheSize drop ;M

:M GetCursorType: ( -- ctype )
\ *G Returns the cursor type.
        xtra rec COM _Recordset GetCursorType drop xtra @ ;M

:M SetCursorType: ( ctype -- )
\ *G Sets the cursor type.  The cursor type determines what is allowed on the cursor
\ ** data and how data is seen in a multi-client environment.  The possible values are:
\ *L
\ *| adOpenUnspecified | The cursor type is unspecified.  Usually defaults to adOpenForwardOnly |
\ *| adOpenStatic | All movement methods are available.  Changes from other users are not visible |
\ *| adOpenForwardOnly | The cursor can only move forward.  The record count and other navigation methods are invalid.  This should have the best performance of the cursors. |
\ *| adOpenDynamic  | All additions, deletions and changes from other users are visible |
\ *| adOpenKeyset | Like a dynamic cursor, except added records can't be seen and deleted records are inaccessible |
        rec COM _Recordset PutCursorType drop ;M

:M GetLockType: ( -- n )
\ *G Returns the lock type.
        xtra rec COM _Recordset GetLockType drop xtra @ ;M

:M SetLockType: ( n -- )
\ *G Sets the lock type.  The lock type determines how the database is to handle changes
\ ** to the data on a cursor.  The possible values are:
\ *L
\ *| adLockUnspecified | The lock type is unspecified.  Usually defaults to adLockReadOnly |
\ *| adLockReadOnly | The records are read-only. Data cannot be altered |
\ *| adLockPessimistic | Pessamistic locking.  Record(s) are locked at the data source immediately when the alterations begin. |
\ *| adLockOptimistic | Optimistic locking.  Record(s) are locked only when the update method is called |
\ *| adLockBatchOptimistic | Useful for batch updates. |
        rec COM _Recordset PutLockType drop ;M

:M GetMaxRows: ( -- n )
\ *G Returns the maximum number of records to be returned in a query.
        xtra rec COM _Recordset GetMaxRecords drop xtra @ ;M

:M SetMaxRows: ( n -- )
\ *G Sets the maximum number of records to be returned from a query (0 = unlimited)
        rec COM _Recordset PutMaxRecords drop ;M

:M Close: ( -- )
\ *G Closes the cursor.  Another query can be executed on the cursor once it has been closed.
        Rec COM _Recordset Close drop ;M

:M GetState: ( -- n )
\ *G Returns the state of the cursor.  Useful when executing queries asyncronously.
        xtra Rec COM _Recordset GetState drop xtra @ ;M

:M Executing?: ( -- flag )
\ *G Returns true if the query is still executing.
        GetState: self adStateExecuting and ;M

:M Fetching?: ( -- flag )
\ *G Returns true if the rows are still being retrieved
        GetState: self adStateFetching and ;M

:M (Execute): ( str len option -- )
        -rot asc>bstr >r
        GetLockType: self
        GetCursorType: self
        0 CONNptr dup if GetConn: ADOConnection then 0 VT_DISPATCH
        0 r@ 0 VT_BSTR
        Rec COM _RecordSet Open
        r> bstrfree
        if CONNptr dup if err: ADOConnection then
           true abort" Unable to Execute Query!" then ;M


:M Execute: ( str len -- )
\ *G Execute a SQL query on the cursor.  Any returned data will be in the cursor.
        adOptionUnspecified (Execute): self ;M

:M AsyncExecute: ( str len -- )
\ *G Operates the same as the execute method, but is asyncronous.  The cursor's
\ ** state will indicate if the query has finished executing or not.
        adAsyncExecute (Execute): self ;M

:M Requery: ( n -- )
\ *G Rerun the last query.
        rec COM _Recordset Requery drop ;M

:M RecordCount: ( -- n )
\ *G Return the number of records in cursor.  May not work with the adOpenForwardOnly
\ ** cursor type.
        xtra rec COM _Recordset GetRecordCount drop xtra @ ;M

:M Move: ( n -- )
\ *G Move to the record number 'n' of the cursor's data
        >r 0 DISP_E_PARAMNOTFOUND 0 VT_ERROR r>
        rec COM _Recordset Move drop ;M

:M MoveFirst: ( -- )
\ *G Move to the first record of the cursor's data.
        rec COM _Recordset MoveFirst drop ;M

:M MoveNext: ( -- )
\ *G Move to the next record of the cursor's data
        rec COM _Recordset MoveNext drop ;M

:M MovePrevious: ( -- )
\ *G Move to the previous record of the cursor's data
        rec COM _Recordset MovePrevious drop ;M

:M MoveLast: ( -- )
\ *G Move to the last record of the cursor's data
        rec COM _Recordset MoveLast drop ;M

:M EOF: ( -- flag )
\ *G Flag that indicates if the current record position is after the last record.
        xtra rec COM _Recordset GetEOF drop xtra sw@ ;M

:M BOF: ( -- flag )
\ *G Flag that indicates if the current record position is before the first record.
        xtra rec COM _Recordset GetBOF drop xtra sw@ ;M

:M FieldCnt: ( -- n )
\ *G Returns the number of columns in the current record.
        flds rec COM _Recordset GetFields abort" Fields error!"
        xtra flds COM Fields GetCount drop xtra @
        flds COM Fields Release drop ;M

:M FieldType: ( field -- DataTypeEnum )
\ *G Returns the data type constant of the given column. Possible data types are:
\ *L
\ *| adEmpty |
\ *| adTinyInt |
\ *| adSmallInt |
\ *| adInteger |
\ *| adBigInt|
\ *| adUnsignedTinyInt  |
\ *| adUnsignedSmallInt |
\ *| adUnsignedInt |
\ *| adUnsignedBigInt |
\ *| adSingle |
\ *| adDouble |
\ *| adCurrency  |
\ *| adDecimal |
\ *| adNumeric  |
\ *| adBoolean  |
\ *| adError  |
\ *| adUserDefined  |
\ *| adVariant  |
\ *| adIDispatch  |
\ *| adIUnknown |
\ *| adGUID |
\ *| adDate  |
\ *| adDBDate  |
\ *| adDBTime  |
\ *| adDBTimeStamp |
\ *| adBSTR |
\ *| adChar  |
\ *| adVarChar  |
\ *| adLongVarChar |
\ *| adWChar |
\ *| adVarWChar |
\ *| adLongVarWChar |
\ *| adBinary |
\ *| adVarBinary  |
\ *| adLongVarBinary |
\ *| adChapter |
\ *| adFileTime |
\ *| adPropVariant |
\ *| adVarNumeric  |
\ *| adArray |
        flds rec COM _Recordset GetFields abort" Fields error!"
        fld 0 rot 0 VT_I4 flds COM Fields GetItem abort" Not a Field!"
        xtra fld COM Field GetType drop xtra @
        flds COM Fields Release drop ;M

:M FieldName: ( field -- str len )
\ *G Returns the column name of the given column number.
        flds rec COM _Recordset GetFields abort" Fields error!"
        fld 0 rot 0 VT_I4 flds COM Fields GetItem abort" Not a Field!"
        xtra fld COM Field GetName drop
        xtra @ bstr>asc: self
        fld COM Field Release drop
        flds COM Fields Release drop ;M

:M FieldSize: ( field -- n )
\ *G Returns the data size of the given column number.
        flds rec COM _Recordset GetFields abort" Fields error!"
        fld 0 rot 0 VT_I4 flds COM Fields GetItem abort" Not a Field!"
        xtra fld COM Field GetActualSize drop xtra @
        fld COM Field Release drop
        flds COM Fields Release drop ;M


:M GetValue: ( field -- )
        xtra 16 0 fill
        flds rec COM _Recordset GetFields abort" Fields error!"
        fld 0 rot 0 VT_I4 flds COM Fields GetItem abort" Not a Field!"
        xtra fld COM Field GetValue drop
        fld COM Field Release drop
        flds COM Fields Release drop ;M

:M GetInt: ( field -- int )
\ *G Returns an integer value of the given column on the current row.
        GetValue: self
	xtra @ VT_NULL = if 0 else xtra 2 cells + @ then ;M

:M GetDouble: ( field -- d )
\ *G Returns the double of the given column on the current row.
        GetValue: self
	xtra @ VT_NULL = if 0 0 else xtra 2 cells + 2@ then ;M

:M GetFloat: ( field -- float )
\ *G Returns the floating point value of the given column on the current row.
        GetValue: self
        xtra @ VT_NULL = if 0e0 else xtra 8 + df@ then ;M

:M GetStr: ( field -- str len )
\ *G Returns the string of the given column on the current row.  May be much longer than 255
        GetValue: self
	xtra @ VT_NULL = if s" " else xtra 2 cells + @ bstr>asc: self then ;M

:M GetTimeStamp: ( field -- float )
\ *G Return the timestamp value of the given column on the current row.  The timestamp value is
\ ** a floating point number that indicates the number of days since Dec 31, 1899.
        GetFloat: self ;M

:M GetDateTime: ( field -- sec min hour day month year )
\ *G Returns the datetime values of the given column on the current row.
        GetValue: self
	xtra @ VT_NULL = if 0 0 0 0 0 0 exitm then
        time-buf xtra 8 + 2@ call VariantTimeToSystemTime drop
        time-buf 12 + w@        \ seconds
        time-buf 10 + w@        \ minutes
        time-buf  8 + w@        \ hours
        time-buf  6 + w@        \ day of month
        time-buf  2 + w@        \ month of year
        time-buf      w@ ;M     \ year

:M isNull?: ( field -- flag )
\ *G Returns true if the given field for the given flag is null
	getValue: self
	xtra @ VT_NULL = ;M


:M SetValue: ( variant field -- ) \ puts xtra variant into Field
        flds rec COM _Recordset GetFields abort" Fields error!"
        fld 0 rot 0 VT_I4 flds COM Fields GetItem abort" Not a Field!"
        fld COM Field PutValue abort" Value Not Set!"
        fld COM Field Release drop
        flds COM Fields Release drop ;M

:M SetInt: ( int field -- )
\ *G Sets the integer value of a given column on the current row.
        >r 0 swap 0 VT_I4 r> SetValue: self ;M

:M SetDouble: ( d field -- )
\ *G Sets the double value of a given column on the current row.
        >r 0 VT_I8 r> SetValue: self ;M

:M SetFloat: ( float field -- )
\ *G Sets the floating point number of a given column on the current row.
        >r fs>ds 0 VT_R8 r> SetValue: self ;M

:M SetNull: ( field -- )
\ *G Sets the field value to null of a given column on the current row.
        >r 0 0 0 VT_NULL r> SetValue: self ;M

:M SetStr: ( str len field -- )
\ *G Sets the string value of a given column on the current row.
        -rot asc>bstr dup >r swap >r
        0 swap 0 VT_BSTR r> SetValue: self
        r> bstrfree ;M

:M SetTimeStamp: ( float field -- )
\ *G Sets the timestamp value of the given column on the current row.  The timestamp value is
\ ** a floating point number that indicates the number of days since Dec 31, 1899.
        SetFloat: self ;M

:M SetDateTime: ( sec min hour day month year field -- )
\ *G Sets the datetime values of the given column on the current row.
        time-buf time-len 0 fill
        >r time-buf      w!  \ year
           time-buf 2  + w!  \ month
           time-buf 6  + w!  \ day
           time-buf 8  + w!  \ hours
           time-buf 10 + w!  \ minutes
           time-buf 12 + w!  \ seconds
        xtra time-buf call SystemTimeToVariantTime
        0= abort" Unable to Convert DateTime!"
        xtra 4 + @ xtra @ 0 VT_DATE
        r> SetValue: self ;M

:M AddRow: ( -- )
\ *G Adds a new record to the end of the recordset and sets this as the current row.  The row
\ ** is not actually created until the update method is called.
        0 DISP_E_PARAMNOTFOUND 0 VT_ERROR
        0 DISP_E_PARAMNOTFOUND 0 VT_ERROR
        rec COM _Recordset AddNew abort" Unable to Add Row!" ;M

:M DeleteRow: ( -- )
\ *G Deletes the current record.
        adAffectCurrent rec COM _Recordset Delete
        abort" Unable to Delete Row!" ;M

:M Update: ( -- )
\ *G Updates the alterations to the data.
        0 DISP_E_PARAMNOTFOUND 0 VT_ERROR
        0 DISP_E_PARAMNOTFOUND 0 VT_ERROR
        rec COM _Recordset Update abort" Update Failed!" ;M


:M (Save): ( str len type -- )
        -rot asc>bstr dup >r 0 swap 0 VT_BSTR
        Rec COM _RecordSet Save abort" Unable to Save!"
        r> bstrfree ;M

:M SaveNative: ( str len -- )
\ *G Saves the cursor's data to a file that is in a unspecified format.
        0 (Save): self ;M

:M SaveXML: ( str len -- )
\ *G Saves the cursor's data as a XML file.
        adPersistXML (Save): self ;M

:M SaveADTG: ( str len -- )
\ *G Saves the cursor's data in the Microsoft Advanced Data TableGram (ADTG) format.
\ ** Requires a filename.
        adPersistADTG (Save): self ;M

:M SaveCSV: ( str len -- )
\ *G Saves the cursor's data to a comma separated value file for easy viewing.
\ ** Cannot be loaded later through the loadfile method.
        xtra 16 0 fill
        xtra UNull cell+ Ucrlf cell+ Ucomma cell+
        -1 adClipString Rec COM _Recordset GetString
        abort" Unable to Convert Records!"
        w/o create-file abort" Unable to Create File!" >r
        xtra @ bstr>asc: self
        r@ write-file drop r> close-file drop ;M

:M LoadFile: ( str len -- )
\ *G Loads a cursor data file that was saved previously.\n
\ ** A connection object is not required to load this data.
        adCmdFile (Execute): self ;M

;class



\ Relavant ADO Constants
\ This may seem unnecessary, but once we unload the type library, the
\ constants will not be accessible, so they are redefined as forth
\ constants

\ ConnectModeEnum
adModeUnknown           CONSTANT adModeUnknown
adModeRead              CONSTANT adModeRead
adModeWrite             CONSTANT adModeWrite
adModeReadWrite         CONSTANT adModeReadWrite
adModeShareDenyRead     CONSTANT adModeShareDenyRead
adModeShareDenyWrite    CONSTANT adModeShareDenyWrite
adModeShareExclusive    CONSTANT adModeShareExclusive
adModeShareDenyNone     CONSTANT adModeShareDenyNone
adModeRecursive         CONSTANT adModeRecursive

\ CursorTypeEnum
adOpenUnspecified       CONSTANT adOpenUnspecified
adOpenForwardOnly       CONSTANT adOpenForwardOnly
adOpenKeyset            CONSTANT adOpenKeyset
adOpenDynamic           CONSTANT adOpenDynamic
adOpenStatic            CONSTANT adOpenStatic

\ LockTypeEnum
adLockUnspecified       CONSTANT adLockUnspecified
adLockReadOnly          CONSTANT adLockReadOnly
adLockPessimistic       CONSTANT adLockPessimistic
adLockOptimistic        CONSTANT adLockOptimistic
adLockBatchOptimistic   CONSTANT adLockBatchOptimistic

\ DataTypeEnum
adEmpty                 CONSTANT adEmpty
adTinyInt               CONSTANT adTinyInt
adSmallInt              CONSTANT adSmallInt
adInteger               CONSTANT adInteger
adBigInt                CONSTANT adBigInt
adUnsignedTinyInt       CONSTANT adUnsignedTinyInt
adUnsignedSmallInt      CONSTANT adUnsignedSmallInt
adUnsignedInt           CONSTANT adUnsignedInt
adUnsignedBigInt        CONSTANT adUnsignedBigInt
adSingle                CONSTANT adSingle
adDouble                CONSTANT adDouble
adCurrency              CONSTANT adCurrency
adDecimal               CONSTANT adDecimal
adNumeric               CONSTANT adNumeric
adBoolean               CONSTANT adBoolean
adError                 CONSTANT adError
adUserDefined           CONSTANT adUserDefined
adVariant               CONSTANT adVariant
adIDispatch             CONSTANT adIDispatch
adIUnknown              CONSTANT adIUnknown
adGUID                  CONSTANT adGUID
adDate                  CONSTANT adDate
adDBDate                CONSTANT adDBDate
adDBTime                CONSTANT adDBTime
adDBTimeStamp           CONSTANT adDBTimeStamp
adBSTR                  CONSTANT adBSTR
adChar                  CONSTANT adChar
adVarChar               CONSTANT adVarChar
adLongVarChar           CONSTANT adLongVarChar
adWChar                 CONSTANT adWChar
adVarWChar              CONSTANT adVarWChar
adLongVarWChar          CONSTANT adLongVarWChar
adBinary                CONSTANT adBinary
adVarBinary             CONSTANT adVarBinary
adLongVarBinary         CONSTANT adLongVarBinary
adChapter               CONSTANT adChapter
adFileTime              CONSTANT adFileTime
adPropVariant           CONSTANT adPropVariant
adVarNumeric            CONSTANT adVarNumeric
adArray                 CONSTANT adArray


\ free the type library
free-lasttypelib

\ *Z
