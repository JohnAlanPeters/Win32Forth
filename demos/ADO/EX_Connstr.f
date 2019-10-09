
\ Database Connection Example
\ Tom Dixon

\ ADO connects to a database through the connection string.
\ This connection string can take several different formats.
\ For our example, we will only use Access

needs ADO

defined connstr nip 0= [if]
create connstr 256 allot
[then]


s" DRIVER={Microsoft Access Driver (*.mdb)};" connstr place

\ this may need to be changed to where ever the test database is.
s" DBQ=" connstr +place
s" demos\ADO\test.mdb" prepend<home>\ connstr +place



\ For a large list of other connection string options, as well as examples
\ of other databases, look at
\ http://www.carlprothman.net/Default.aspx?tabid=81

