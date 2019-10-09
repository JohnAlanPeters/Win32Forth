\ $Id: OldPaths.f,v 1.2 2006/08/17 12:08:04 georgeahubert Exp $

\ G.Hubert Thursday, August 10 2006

\ This file should be included in legacy programs which make use of the earlier (and more
\ limited) functionality provided prior to V6.11.10

warning @ warning off checkstack

create &fpath MAX-PATH 1+ allot     \ a static forth path buffer

&fpath off

&fpath value path-ptr

internal

path: temp-path-ptr

: set-temp-path-ptr ( -- addr )
              path-ptr temp-path-ptr tuck max-path 1+ move ;

: ("path-file) ( addr1 len1 -- addr2 len2 f ) \ might not be needed?
              set-temp-path-ptr full-path ;
external

: Path-source ( -- addr )
              temp-path-ptr path-source ;

: First-path" ( -- addr len )
              set-temp-path-ptr first-path" ;

: Next-path"  ( -- addr len )
              set-temp-path-ptr next-path" ;

module

warning !

