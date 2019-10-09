\ $Id: FONTS.F,v 1.9 2008/04/27 11:21:19 dbu_de Exp $

\ FONTS.F       Font Class and Methods
\ Font creation Class and control methods

cr .( Loading Font class...)

in-application

needs gdi/gdiFont.f

\ ----------------------------------------------------------------------
\ Font class
\ ----------------------------------------------------------------------
:Class Font     <Super GdiFont

:M Height:         ( n1 -- )  SetHeight: super         ;M
:M Width:          ( n1 -- )  SetWidth: super          ;M
:M Escapement:     ( n1 -- )  SetEscapement: super     ;M
:M Orientation:    ( n1 -- )  SetOrientation: super    ;M
:M Weight:         ( n1 -- )  SetWeight: super         ;M
:M Italic:         ( f1 -- )  SetItalic: super         ;M
:M Underline:      ( f1 -- )  SetUnderline: super      ;M
:M StrikeOut:      ( f1 -- )  SetStrikeOut: super      ;M
:M CharSet:        ( n1 -- )  SetCharSet: super        ;M
:M OutPrecision:   ( n1 -- )  SetOutPrecision: super   ;M
:M ClipPrecision:  ( n1 -- )  SetClipPrecision: super  ;M
:M Quality:        ( n1 -- )  SetQuality: super        ;M
:M PitchAndFamily: ( n1 -- )  SetPitchAndFamily: super ;M

:M Create:      ( -- )
                Create: super drop ;M

:M Delete:      ( -- )
                Destroy: super ;M

:M Handle:      ( -- hFont )
                GetHandle: super ;M

\ found this in an old w32f application...
:M zHandle:     ( -- )
                Destroy: super ;M

;class
