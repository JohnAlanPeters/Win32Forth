\ $Id: HelpSystem.f,v 1.13 2008/09/02 07:01:23 camilleforth Exp $
\
\    File: HelpSystem.f
\  Author: Dirk Busch
\ Created: Mittwoch, November 10 2004 - dbu
\ Updated: Sonntag, Dezember 26 2004 - dbu
\ Updated: 2008/06/14 - cdo - adapted for new Help
\
\ Win32Forth Help system

anew -HelpSystem.f

internal

\ ------------------------------------------------------------------------
\ Create a table with error definitions
\ ------------------------------------------------------------------------

: CREATE-HTML-LINK-TABLE ( -- )
	create ;

: CLOSE-HTML-LINK-TABLE	 ( -- )
	0 , ;

: ERROR-TABLE-ENTRY	( word filename label -- addr len )
	BL WORD NUMBER d>s ,
	BL WORD COUNT ",
	BL WORD COUNT ", ;

: skip-string	( adr -- adr1 )
		count + ;

CREATE-HTML-LINK-TABLE ERROR-TABLE

\                 Nr	FILENAME	REFERENCE
\                 -----	-----------     ---------

\ ANS Error Messages
ERROR-TABLE-ENTRY -1	w32f-errors.htm   Error(-1)
ERROR-TABLE-ENTRY -2	w32f-errors.htm   Error(-2)
ERROR-TABLE-ENTRY -4	w32f-errors.htm   Error(-4)
ERROR-TABLE-ENTRY -13	w32f-errors.htm	  Error(-13)
ERROR-TABLE-ENTRY -14	w32f-errors.htm   Error(-14)
ERROR-TABLE-ENTRY -16	w32f-errors.htm   Error(-16)
ERROR-TABLE-ENTRY -22	w32f-errors.htm   Error(-22)
ERROR-TABLE-ENTRY -38	w32f-errors.htm   Error(-38)
ERROR-TABLE-ENTRY -45	w32f-errors.htm   Error(-45) \ floating-point stack underflow
ERROR-TABLE-ENTRY -58	w32f-errors.htm   Error(-58) \ Unmatched Interpreted conditionals

\ Extended System Error Messages
ERROR-TABLE-ENTRY -260	w32f-errors.htm   Error(-260)
ERROR-TABLE-ENTRY -262	w32f-errors.htm   Error(-262)
ERROR-TABLE-ENTRY -270	w32f-errors.htm   Error(-270)
ERROR-TABLE-ENTRY -271	w32f-errors.htm   Error(-271)
ERROR-TABLE-ENTRY -272	w32f-errors.htm   Error(-272)
ERROR-TABLE-ENTRY -280	w32f-errors.htm   Error(-280)
ERROR-TABLE-ENTRY -281	w32f-errors.htm   Error(-281)
ERROR-TABLE-ENTRY -282	w32f-errors.htm   Error(-282)
ERROR-TABLE-ENTRY -290	w32f-errors.htm   Error(-290)
ERROR-TABLE-ENTRY -300	w32f-errors.htm   Error(-300)
ERROR-TABLE-ENTRY -301	w32f-errors.htm   Error(-301)
ERROR-TABLE-ENTRY -302	w32f-errors.htm   Error(-302)
ERROR-TABLE-ENTRY -310	w32f-errors.htm   Error(-310)
ERROR-TABLE-ENTRY -311	w32f-errors.htm   Error(-311)
ERROR-TABLE-ENTRY -320	w32f-errors.htm   Error(-320)
ERROR-TABLE-ENTRY -330	w32f-errors.htm   Error(-330)
ERROR-TABLE-ENTRY -331	w32f-errors.htm   Error(-331)
ERROR-TABLE-ENTRY -332	w32f-errors.htm   Error(-332)

\ Warning Messages
ERROR-TABLE-ENTRY -4100	w32f-errors.htm   Warning(-4100)
ERROR-TABLE-ENTRY -4101	w32f-errors.htm   Warning(-4101)
ERROR-TABLE-ENTRY -4102	w32f-errors.htm   Warning(-4102)
ERROR-TABLE-ENTRY -4103	w32f-errors.htm   Warning(-4103)
ERROR-TABLE-ENTRY -4104	w32f-errors.htm   Warning(-4104)
ERROR-TABLE-ENTRY -4105	w32f-errors.htm   Warning(-4105)
ERROR-TABLE-ENTRY -4106	w32f-errors.htm   Warning(-4106)

\ Application and Runtime Error Messages
ERROR-TABLE-ENTRY 9998	w32f-errors.htm   Error(9998)

CLOSE-HTML-LINK-TABLE

: GetErrorTable	{ err-code -- adr } \ get address of error definition in table
		ERROR-TABLE >r
		begin  r@ @ dup
		while  err-code =
		       if r> exit then
		       r> cell+ skip-string skip-string >r
		repeat drop r>drop NULL ;

: GetErrorLink	( err-code -- adr1 len1 )
		GetErrorTable ?dup
		if   s" help\html\" pad place
		     cell+ dup count pad +place
		     s" #" pad +place
		     skip-string count pad +place
		     pad count Prepend<home>\
		else 0 0
		then ;

: (err-help)	( err-code -- ) \ show help for the win32forth error message err-code
		dup GetErrorLink
                2dup msgpad place           \ right now because GetErrorLink use pad
                nip
		if   0 0 ExecHelp drop      \ launch help or put it in front
                     msgpad dup c@ 1+ WM_HTML w32fHelp Sendw32fMsg drop
                     drop
		else ." No help for error code " . ." available."
		then ;

: (w32f-help)	{ addr len \ cfa -- } \ show help for a word
                addr 1-
\in-system-ok   anyfind swap to cfa
                if   0 0 ExecHelp drop           \ launch help or put it in front
                     addr len msgpad place       \ try to show word from help
                     msgpad dup c@ 1+ WM_WORDHELP w32fHelp Sendw32fMsg
                     0=                          \ if not in help database, show source
\in-system-ok        if   cfa get-viewfile drop count
                          rot msgpad !
                          dup 1+ >r msgpad cell+ place
                          msgpad r> cell+ WM_LINEFILE w32fHelp Sendw32fMsg drop
                     then

                else addr len type ."  is undefined"
                then ;
external

WARNING OFF
: help		( -<word>- -- ) \ show help for a word
		( -- )          \ show last win32forth error message
		bl word count ?dup
		if   (w32f-help)
		else drop
		     LAST-ERROR ?dup
		     if   (err-help)
		          0 to LAST-ERROR         \ clear error code
		     else ." No error happened."
		     then
		then ;
WARNING ON

:noname		( -- )
		cr cr ." Win32Forth Help system loaded"
		cr cr ." Usage:"
		cr ." HELP <word>         => get help for a word"
		cr ." HELP                => get help for the last error message"
		cr ; is help-system

module

help-system



