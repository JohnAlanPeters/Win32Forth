

\ Server Side

needs sock.f

create tbuf 256 allot

: sdump ( sock -- )
  begin
    dup sock-read? if dup tbuf 256 rot sock-read tbuf swap type then
    dup sock-closed? key? or until
  sock-close drop ;

s" www.google.com" 80 sock-open value sock
s" GET / HTTP/1.0" sock sock-write .
crlf$ count sock sock-write .
crlf$ count sock sock-write .

cr sock sdump

\s

0 value sock


: server-init ( -- )
  8003 sock-create dup to sock
  dup -1 = if abort" Unable to make socket!" then
  5 sock sock-listen ;


: serve ( -- )
  begin
    sock sock-accept?
      if sock sock-accept drop
         dup s" Server Hello! " rot sock-write drop
         dup get-local-time time-buf >time" rot sock-write drop
         10 ms sock-close drop
      then
  10 ms key? until ;


: server ( -- ) server-init serve ;


\ client side

: client ( hostname -- )
  8003 sock-open to sock
  begin 10 ms
    sock sock-read? dup
      if pad swap sock sock-read pad swap type else drop then
    sock sock-closed?
  until
  sock sock-close drop ;


.( Type 'server' or 's" hostname" client' to test the server or client)
