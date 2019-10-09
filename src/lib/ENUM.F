\ $Id: ENUM.F,v 1.3 2006/10/13 03:50:29 ezraboyce Exp $

anew -Enum.f

dp checkstack

in-system

internal

1 value increment

: not-a-comment?	( addr cnt -- f )
                2dup s" \" compare 0<> -rot              \ not a \ comment ?
                     s" //" compare 0<>  and          \ not a // comment
		;

external

100 value enum-value

: enum: ( -- )  \ create a list of constants until terminating ;
        begin   begin   >in @ bl word swap >in ! c@ 0=
                while   refill 0=                           \ get more stuff
                        abort" Enum: - missing terminating ;"
                repeat  >in @ bl word
                count s" ;" compare     \ done enumerating if ; found
        while   dup >in ! bl word count
                2dup not-a-comment?
                if      number? 			\ if a number
			if	drop Constant		\ allow setting specific value
				drop	( >in )
			else	2drop 	( from number? )
				>in ! enum-value Constant       \ create a constant value
				increment +to enum-value
                        then
                else    2drop >in ! interpret                 \ is a comment
                then
        repeat  drop 1 to increment ;    \ restore default

module

to dp

\s

: enum: { cnt -- }
         cnt 0
         ?do    >in @ bl word swap >in ! c@ 0=
                if      refill 0= abort" end of file in enums:"
                then    enum-value Constant
                increment +to enum-value
         loop   1 to increment ;        \ reset
\s

