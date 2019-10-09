aNew -RtfGenerator.f   \ November 23rd, 2014 by J.v.d.Ven

\ Ref:  http://msdn.microsoft.com/en-us/library/aa140301(office.10).aspx
\ and   http://www.biblioscape.com/rtf15_spec.htm  ( better )


400 constant /linesScreen
/linesScreen maxstring * constant /buffer
0 value &buffer
: AllocateRtfBuffer ( - )  /buffer 2 cells+ malloc to &buffer ;

initialization-chain chain-add AllocateRtfBuffer
AllocateRtfBuffer

0 value /header				\ Size header incl /buffer
defer Rtf_cr

vocabulary rtf

: +lplaceNoClip       ( addr len dest -- ) \ append string addr,len to a long counted string dest
   2dup 2>r
   lcount chars + swap move
   2r> +! ;

0xa constant eol

: Terminate}0 ( -- )
   0x007D  \ ascii }+00
   &buffer dup @ + cell+ w!
 ;

: FindLine  0 swap  { adr n -- adr cnt } \ Finds lines terminated with a cr and lf (0xd and 0xa)
   &buffer /header +
   &buffer @  /header - 3 -  n 0
     do  2dup to n to adr eol
        scan dup 0=
            if    leave
            else  1 /string
            then
    loop
   n swap - nip adr swap 2 - 0 max
 ;

: DeleteLine ( adr n -- ) \ Deletes the found lines terminated with a linefeed (0xa)
   dup 1 <
    if     2drop &buffer off
    else   &buffer @ over - 2 - dup>r &buffer !
           over + 2 + swap r> move
    then
   Terminate}0
 ;

: +Ctrl_cr	( -- )        crlf$ count type  ; \ Used for removing lines

0 value #lines



(( 0 value &logline

: _Rtf_cr	( -- )		\ Application depended
   ." \line" 1 +to #lines +Ctrl_cr
   #lines /linesScreen >
      if    1 FindLine  dup 2 + negate +to &logline
            DeleteLine
      then
   UpdateLogText: LiveLogWindow
;

' _Rtf_cr is Rtf_cr \ ))

defer PrepareRtfOut$ ( adr count - adr' count' )
' noop is PrepareRtfOut$

: Rtf_clr	( -- )         &buffer off ;

: Rtf_type	( adr n -- )
   PrepareRtfOut$ &buffer @ over + /buffer > s" Overflow Rtf buffer !" ?ErrorBox
   &buffer +lplaceNoClip Terminate}0
 \ UpdateText: LiveLogWindow \ Optinal: Show the text even when the logline is not complete. (SLOW!)
 ;


: Rtf_emit	( c -- )
   case
      $7  of   beep   endof
      sp@ 1 Rtf_type
   endcase
   ;

0 value {pairs}

: Rtf[ ( - )
   0 to {pairs}
   ['] Rtf_type is type
   ['] Rtf_cr   is cr
   ['] Rtf_clr  is cls
   ['] Rtf_emit is emit
   ['] 2drop is \n->crlf
 ;

also hidden

: ]Rtf ( - )
   Rtf_cr  turnkeyed? not
     if ['] c_type is type
        ['] c_cr   is cr
        ['] c_cls  is cls
        ['] c_emit is emit
        ['] _\n->crlf is \n->crlf
     then
   {pairs} 1- 0<> abort" { not paired with } in RTF text."
;


previous

: .".            \ comp: ( -<string">- ) run: ( N -- )
\ *G Compiletime: Parses the input stream until it finds the next " and
\ ** compiles it . into the current definition.
\ ** Runtime: Prints the compiled text followed by N and a space.
                compile (.") ," compile . ; IMMEDIATE

also rtf rtf definitions
vocabulary rtf{} also rtf{} definitions \ To avoid a conflict with locals in { -- }

: }		( {pairs -- )	ascii } emit -1 +to {pairs} +Ctrl_cr	; 	\ Start a new group
: {		( -- {pairs )	ascii { emit  1 +to {pairs}	; 		\ End group

previous rtf definitions

: ;} 		( {pairs -- )	." ;}"	     -1 +to {pairs}	;

\ RTF escapes
: \ansi		( -- )		." \ansi "	; \ ANSI (the default)
: \fonttbl	( -- )		." \fonttbl "	; \ Start a font table group

\ Font family's
: \fnil  	( -- )		." \fnil "	;
: \froman  	( -- )		." \froman "	;
: \fswiss 	( -- )		." \fswiss "	;
: \fmodern  	( -- )		." \fmodern "	;
: \fscript  	( -- )		." \fscript "	;
: \fdecor  	( -- )		." \fdecor "	;
: \ftech  	( -- )		." \ftech "	;
: \fbidi   	( -- )		." \fbidi "	;

: \colortbl  	( -- )		." \colortbl;"	; \ Starts color table group
: \pard	  	( -- )		." \pard"	; \ Starts a new paragraph
: \par	  	( -- )		." \par"	; \ Ends the paragraph.
: \tab  	( -- )		." \tab "	; \ Tab character
: \*	  	( -- )		." \*"		; \ To add unseen comment.
: \bullet	( -- )		." \bullet "	; \ Bullet character.

: \rtf		( n -- )	.". \rtf1"	; \ RTF version
: \ansicpg	( n -- )	.". \ansicpg"	; \ ANSI code page
: \deff		( n -- )	.". \deff"	; \ The default font number
: \deflang	( n -- )	.". \deflang"	; \ The default language used in the document
: \f		( n -- )	.". \f" 	; \ Specifies a function key
: \fprq		( n -- )	.". \fprq" 	; \ the pitch of a font in the font table. Allowed: 0 1 2
: \uc 		( n -- )	.". \uc" 	; \ A single Unicode character
: \fs		( n -- )	.". \fs" 	; \ Font size in half-points (the default is 24).
: \highlight	( n -- )	.". \highlight" ; \ Start highlighting text
: \fcharset	( n -- )	.". \fcharset"	; \ Specifies the character set of a font in the font table
: \deftab	( n -- )	.". \deftab"	; \ Tabs size. 720 twips is default, Uses only the last \deftab in a paragraph
: \li		( n -- )	.". \li"	; \ Left indent (the default is 0).

: \plain 	( -- )		." \plain " 	; \ Reset font (character) formatting properties to a default value

: \ul0		( -- ) 		." \ul0 " 	; \ Stops all underlining.
: \ulnone	( -- )		." \ulnone "	; \ Stops all underlining.

: \ul		( -- )		." \ul "	; \ Continuous underline.
: \uld		( -- )		." \uld "	; \ Dotted underline.
: \uldash	( -- )		." \uldash "	; \ Dash underline.
: \uldashd	( -- )		." \uldashd "	; \ Dot dash underline.
: \uldashdd	( -- )		." \uldashdd "	; \ Dot dot dash underline.
: \uldb		( -- )		." \uldb " 	; \ Double underline.
: \ulth		( -- )		." \ulth " 	; \ Thick underline
: \ulw		( -- )		." \ulw " 	; \ Word underline.
: \ulwave       ( -- )          ." \ulwave "	; \ Wave underline.
: \cf		( n -- )	.". \cf" 	; \ Foreground color (the default is 0).
: \strike	( -- )		." \strike "	; \ Strikethrough.
: \strike0	( -- )		." \strike0 "	; \ Strikethrough. off
: \i		( -- )		." \i " 	; \ Italic.
: \i0		( -- )		." \i0 " 	; \ Italic off.
: \b	  	( -- )		." \b "		; \ bold.
: \b0	  	( -- )		." \b0 "	; \ bold off.
: \viewkind	( n -- )	.". \viewkind"	; \ The view mode of the document. (0-5)

\ Win32Forth extensions

: \rgb ( r g b -- )  \ Macro in WF32 to fill a color table
    rot .". \red" swap .". \green" .". \blue" ." ;" ;

: \rgbID ( ID r g b - ID+1 ) \rgb 1+ dup ;

0 value \black
0 value \gray
0 value \ltgray
0 value \dkgray
0 value \red
0 value \ltred
0 value \green
0 value \ltgreen
0 value \blue
0 value \ltblue
0 value \yellow
0 value \ltyellow
0 value \dkmagenta
0 value \magenta
0 value \ltmagenta
0 value \cyan
0 value \ltcyan
0 value \white
0 value \brown

also forth definitions   also rtf{}   \ NOTE: rtf{} will disable locals defined with "{"

: \StartRtfTxt$
   { \* ." \generator Win32Forth version " version# ((version)) type ;}
   4 \viewkind 1 \uc \pard 0 \f 20 \fs +Ctrl_cr
 ;

: RtfHeader \ As soon as you change the header you need to start a NEW logfile using the new header.
        Rtf_clr
        { 1 \rtf \ansi  1252 \ansicpg  0 \deff  1033 \deflang
		{ \fonttbl
                    { 0 \f \fswiss   0 \fcharset  ." Arial" ;}
                    { 1 \f \fmodern  2 \fprq  0 \fcharset ." Courier New" ;} }
                  0 { \colortbl
				0   0   0  \rgbID to \black
				128 128 128  \rgbID to \gray
				192 192 192  \rgbID to \ltgray
				 64  64  64  \rgbID to \dkgray
				128   0   0  \rgbID to \red
				255   0   0  \rgbID to \ltred
				  0 128   0  \rgbID to \green
				  0 255   0  \rgbID to \ltgreen
				  0   0 128  \rgbID to \blue
				  0   0 255  \rgbID to \ltblue
				128 128   0  \rgbID to \yellow
				255 255   0  \rgbID to \ltyellow
				204   0 204  \rgbID to \dkmagenta
				128   0 128  \rgbID to \magenta
				255   0 255  \rgbID to \ltmagenta
				  0 128 128  \rgbID to \cyan
				  0 255 255  \rgbID to \ltcyan
				255 255 255  \rgbID to \white
                    }
                drop \StartRtfTxt$

        180 \li \ Optional: Left margin at 180 twips
        &buffer @ cell+ to /header
 ;

previous previous
\s
