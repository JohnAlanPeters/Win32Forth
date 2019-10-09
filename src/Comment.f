\ $Id: Comment.f,v 1.6 2008/08/03 11:08:47 camilleforth Exp $

cr .( Loading Comment.f : words removed from previous release...)

\  Author: Dirk Busch
\ Created: November 9th, 2003 - dbu
\ Updated: June    26th, 2008 - cdo - removed some synonyms


DECIMAL                                 \ start everything in decimal

in-system

: _commeof      \ ( flag -- ) \ end of file abort if true
                abort" EOF encountered in comment" ;

-1 value multi-line?    \ we can have multiple line '(' comments

: _comment      \ char --
                multi-line?
                loading? and
                if      begin   source >in @ /string
                                2 pick scan nip 0=
                        while   refill 0= _commeof
                        repeat
                then    parse 2drop ;

: comment       \ -<char>-
                char _comment ; immediate

: (             \ comment till )
                [char] ) _comment ; immediate

: \S            \ comment to end of file
                FALSE TO INCLUDING?  [COMPILE] \ ; IMMEDIATE

: "comment      ( a1 n1 -- )   \ everything is a comment up to the string a1,n1
                2dup upper
                begin
                  2dup bl nextword
                while
                  uppercase count str=
                  if 2drop exit then
                repeat _commeof ;

: ((            \ comment till ))
                s" ))"       "comment ; immediate

: comment:      \ comment till COMMENT;
                s" COMMENT;" "comment ; immediate



: //            \ comment till end of line - synonym of \
                postpone \ ; IMMEDIATE

: //{{NO_DEPENDENCIES}} ;   \ so we can load .H file

in-application


