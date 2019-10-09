\ $Id: \044X.F,v 1.1 2006/09/16 10:52:04 georgeahubert Exp $

\ G.Hubert Friday, September 15 2006 for Win32Forth V6.11.11 or above
\ Based on the class by Doug Hoffman

\ *P Class $x is a dictionary-based simple string class whose length may vary,
\ ** up to a maximum of 255, but the maximum length is defined at instantiation.
\ ** We cheat a bit here and the INDEXED class definition abilities and
\ ** indexed ivar data area in a way that was not really intended.

\ *P $x's are nice for use as string ivars, or if you want a persistent string
\ ** object in the dictionary (no handles here so we don't need to do a new:
\ ** and restore the data at each runtime).

anew -$x.f

needs array11

:class $x ( chars -- ) <super IndexedObj  1 <indexed  \ Each character is one byte.
 \ At instantiation we simply declare the maximum number of characters
 \ desired as if for a byte array.

:m limit:  ( -- lim )
 limit 1- ;m

:m get$: \ ( -- c-addr ) \ counted string format
 idxbase ;m

:m size:  \ ( -- len)
 get$: self c@ ;m


:m setsize:  \ ( len --)
 dup  limit: self > abort" No more room in $x."
 get$: self c!
 ;m

:m clear: ( -- )
 0 setsize: self ;m

:m classinit: ( -- )
 clear: self ;m

:m Addr:  ( -- addr)  \ redefine to give us the indexed data area+1
   \ which will be the address of the first character of text
 idxbase 1+ ;m

:m put: { addr len -- }
 len setsize: self
 addr Addr: self len cmove ;m

:m get: ( -- addr len )
 Addr: self  size: self ;m

:m print:
 get: self type ;m

:m put$:  ( c-addr -- )
 count put: self ;m

:m add: { addr len | $len  -- }
 size: self to $len
 len $len + setsize: self
 addr Addr: self $len + len cmove ;m

:m add$: ( c-addr -- )
 count add: self ;m


: makeUpper ( addr len -- )
 over + swap
 ?DO i c@ dup [char] a >=
     swap [char] z <= and
     IF i c@ 32 xor i c! THEN
 LOOP ;

:m uc: \  ( -- )  converts to upper case
 get: self makeUpper ;m

:m +:  ( c -- ) \ appends a char to the end of the string
 pad c! pad 1 add: self ;m

:m clip:  ( n -- )  \ remove n characters from end of string
     \ if n is too large, string is just cleared with no error
 size: self over - 0 max setsize: self ;m

;class

