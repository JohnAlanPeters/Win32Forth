Anew -RichEdit.f  \  November 23rd, 2014 by J.v.d.Ven
Needs ExControls.f


\ winlibrary Riched32.dll   \ W95 Does not work in W10
\ winlibrary Riched20.dll   \ XP or better
  winlibrary Msftedit.dll   \ XP with SP1 or better

:Class RichEdit <Super RichEditControl

Record: settextex
	Int flags
	Int codepage
;Record


:M Start:       ( Parent -- )
\ *G Create the control.
			TO Parent
	ST_DEFAULT	to flags
	1200 		to codepage
\	z" RichEdit" Create-Control	\ for w95
\	z" RichEdit20A" Create-Control	\ 2.0 for XP or better
	z" RICHEDIT50W" Create-Control	\ 4.1 for XP with SP1 or better ( fastest )
	;M

:M WindowStyle: ( -- style)   \ typical multiline, none-wrapped control style
        WS_CHILD WS_VISIBLE OR ES_LEFT OR ES_MULTILINE OR
        WS_VSCROLL OR ES_AUTOVSCROLL OR
        WS_HSCROLL OR ES_AUTOHSCROLL OR
        ES_NOHIDESEL OR
        ;M

:M AutoUrlDetect: ( f -- )
\ *G Autodetect Html-links. It needs more code to activate them.
	0 swap EM_AUTOURLDETECT	SendMessage:self ?WinError
 ;M

:M ReadOnly:      ( f -- )
\ *G To prevent changing the text
	0 SWAP EM_SETREADONLY	SendMessage:self ?WinError
	;M

:M SetTexTex:     ( buffer -- )
\ *G Display the text
	settextex  EM_SETTEXTEX	SendMessage:self drop
	;M

:M ToLastLine: ( -- )
\ *G Move to the last line in the control
	$7FFFFFFF $7FFFFFFF EM_SETSEL SendMessage:self
	0 0 EM_SCROLLCARET            SendMessage:self
	2drop
	;M


;Class

\s

