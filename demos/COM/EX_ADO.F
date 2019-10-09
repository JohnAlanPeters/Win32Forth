\ $Id: EX_ADO.F,v 1.2 2005/09/18 11:10:30 dbu_de Exp $

\ Example of using ADO
\ Thomas Dixon

\ This is a very simple sql utility

needs fcom

2 7 typelib {EF53050B-882E-4776-B643-EDA472E8E3F2} \ inlude ADO type library

_RecordSet ComIFace rec

create DSN 1024 allot                            \ DSN holder
create querybuf 1024 allot                       \ holds the query buffer
create cCol 32 allot     u" ," cCol uniplace     \ Column Delimeter
create NL 32 allot crlf$ count >unicode NL uniplace \ New Record Delimeter
create nullch 32 allot  u" " nullch uniplace     \ Null Character Replacement
create sqlbuf 0 , 0 ,                            \ holds the returned buffer

: DSN! ( str len -- ) 0 CoInitialize drop      \ store the connection string (ODBC)
  rec @ 0= if
    rec _RecordSet 1 0 RecordSet CoCreateInstance
     abort" Unable to Create ADO Recordset!"
  then asc>uni 2dup DSN uniplace drop free drop ;

: SQLEXEC ( options locktype cursortype -- )
  0 DSN unicount drop 0 8 0 querybuf unicount drop 0 8
  rec open abort" Unable to Execute SQL Query!" ;

: records>str ( -- str len ) \ converts recordset to string
  sqlbuf @ ?dup if free drop then 0 sqlbuf !
  sqlbuf nullch unicount drop NL unicount drop ccol unicount drop -1 2
  rec GetString abort" Unable to convert data to String!"
  sqlbuf @ dup zunicount uni>asc 2dup sqlbuf cell+ ! sqlbuf !
  rot CoTaskMemFree drop ;

: SQL ( str len -- str len )     \ executes a query
  asc>uni 2dup querybuf uniplace drop free drop
  adOptionUnspecified adLockUnspecified adOpenDynamic
  SQLEXEC records>str ;


((
\ Here is a simple example I use on my System
\ (Assumes 'DBTest' is a dsn on the machine with a table called 'test')

s" DSN=DBTest" dsn!                                 \ Load the DSN
s" Select * FROM test" SQL cr type                  \ Execute a query
rec close drop                                      \ cleanup

))

