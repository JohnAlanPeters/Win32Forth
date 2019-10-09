\ $Id: HtmlControlDemo.f,v 1.3 2006/01/14 12:28:21 dbu_de Exp $

\ Demo for the HTML Control
\ Thomas Dixon

cr .( Loading Html Control Demo...)

anew -HtmlControlDemo.f

\ *D doc\classes\
\ *> HTMLcontrol
\ *S Example (demos\HtmlControlDemo.f)
\ *+

needs HtmlControl.f

\ Create a simple browser window
:class Browserwin <super window

HTMLcontrol html

:M On_Init: ( -- )
        On_Init: super
        self Start: html ;M

:M On_Size: ( h m w -- )
        2drop drop autosize: html ;M

:M GoURL:             ( str len -- ) GoURL: html ;M
:M GetLocationURL:    ( -- str len ) GetLocationURL: html ;M
:M GetLocationName:   ( -- str len ) GetLocationName: html ;M
:M Busy?:             ( -- flag )    Busy?: html ;M
:M Offline?:          ( -- flag )    Offline?: html ;M
:M GetType:           ( -- str len ) GetType: html ;M

:M Wait:        ( -- )
\ Wait until the browser has finished all
\ downloading operation or other activity.
        begin winpause
              Busy?: self 0=
        until ;M

;class

BrowserWin bwin

: test
        \ start the window
        start: bwin

        \ let the browser load a document
        Offline?: bwin
        if   s" doc\p-index.htm" Prepend<home>\
        else s" www.win32forth.org\doc\p-index.htm"
        then GoURL: bwin

        \ wait until browser is ready
        Wait: bwin

        \ display some information about the document
        cr GetLocationURL: bwin type
        cr GetLocationName: bwin type
        cr GetType: bwin type
; test

\ *-
\ *Z
