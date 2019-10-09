\ $Id: STARTDB.F,v 1.2 2011/08/10 15:58:18 georgeahubert Exp $

\ Build the database if it doesn't already exist

require sqlite.f

SQLiteDB MiniDB

: Create-Customers-Table ( -- )
           s" CREATE TABLE Customers (id INTEGER PRIMARY KEY, name varchar, surname varchar, abode varchar)"
           execute: MiniDB ;

: Add-Customers ( -- )

 s" INSERT INTO Customers (name, surname, abode) VALUES(?,?,?)"
 execute: MiniDB
 s" Robin            "    0 bindstr: MiniDB
 s" Hood             "    1 bindstr: MiniDB
 s" Sherwood Forest  "    2 bindstr: MiniDB

 s" INSERT INTO Customers (name, surname, abode) VALUES(?,?,?)"
 execute: MiniDB
 s" Isaac            "    0 bindstr: MiniDB
 s" Newton           "    1 bindstr: MiniDB
 s" Cambridge        "    2 bindstr: MiniDB

 s" INSERT INTO Customers (name, surname, abode) VALUES(?,?,?)"
 execute: MiniDB
 s" Maid             "    0 bindstr: MiniDB
 s" Marian           "    1 bindstr: MiniDB
 s" Sherwood Forest  "    2 bindstr: MiniDB

 s" INSERT INTO Customers (name, surname, abode) VALUES(?,?,?)"
 execute: MiniDB
 s" Friar            "    0 bindstr: MiniDB
 s" Tuck             "    1 bindstr: MiniDB
 s" Sherwood Forest  "    2 bindstr: MiniDB

 s" INSERT INTO Customers (name, surname, abode) VALUES(?,?,?)"
 execute: MiniDB
 s" Will             "    0 bindstr: MiniDB
 s" Scarlet          "    1 bindstr: MiniDB
 s" Sherwood Forest  "    2 bindstr: MiniDB

 s" INSERT INTO Customers (name, surname, abode) VALUES(?,?,?)"
 execute: MiniDB
 s" Alan A           "    0 bindstr: MiniDB
 s" Dale             "    1 bindstr: MiniDB
 s" Sherwood Forest  "    2 bindstr: MiniDB

 s" INSERT INTO Customers (name, surname, abode) VALUES(?,?,?)"
 execute: MiniDB
 s" George           "    0 bindstr: MiniDB
 s" Hubert           "    1 bindstr: MiniDB
 s" UK               "    2 bindstr: MiniDB

 s" INSERT INTO Customers (name, surname, abode) VALUES(?,?,?)"
 execute: MiniDB
 s" Queen            "    0 bindstr: MiniDB
 s" Elizabeth        "    1 bindstr: MiniDB
 s" Buckingham Palace"    2 bindstr: MiniDB
;

: Create-database ( -- )
           Create-Customers-Table Add-Customers ;

: Start-database ( -- )
           s" Mini.db" 2dup file-status nip -rot open: MiniDB
           if create-database then ;

: GetAllCustomers ( -- )
  s" SELECT * FROM Customers" execute: MiniDB ;

: qdump ( -- )
 fieldcnt: MiniDB
 0 ?do
   i fieldname: MiniDB type 20 #tab
 loop cr cr
 begin
   fieldcnt: MiniDB
   0 ?do
       i getstr: MiniDB type 20 #tab
   loop cr
   nextrow: MiniDB
 until ;

Start-database

GetAllCustomers

cr .( The database contains the following data.)

cr qdump


