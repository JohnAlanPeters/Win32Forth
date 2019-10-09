\ $Id: W32fdexh.f,v 1.8 2008/12/23 21:12:06 camilleforth Exp $

\ *D doc
\ *! p-W32fdexh
\ *T Extensions to DexH for producing Win32Forth Documents

\ *P DexH is a versatile system for producing documentation and these extensions are designed
\ ** to customise it for producing the Win32Forth documentation itself (including this
\ ** file).

needs tools/dexh

anew -w32fdexh.f
internal

create W32Fheader
   ,| <?xml version="1.0"?>                                                        |
   ,| <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"                     |
   ,|     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">                     |
   ,| <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">          |
   ,| <head>                                                                       |
   ,| <meta name="GENERATOR" content="dexh v03">                                   |
   ,| <meta name="ProgId" content="FrontPage.Editor.Document">                     |
   ,| <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">   |
   ,| <title>                                                                      |
   0 c,

create W32FHeaderA
   ,| </title><style><!--                                                          |
   ,| h1           { font-family: Tahoma; font-size: 24pt; font-weight: bold }     |
   ,| h2           { font-family: Tahoma; font-size: 18pt; font-weight: bold } --> |
   ,| </style>                                                                     |
   ,| </head>                                                                      |
   ,| <body><h1 align="center">                                                    |
   ,| <a href="mailto:win32forth@yahoogroups.com?subject=DOC:Doc error in $Id: W32fdexh.f,v 1.8 2008/12/23 21:12:06 camilleforth Exp $"> |
   ,| <img border="0" src="TELLUS.gif" align="left" width="32" height="32"></a>    |
   ,| <img border="0" src="FORTHPRO.gif"                                           |
   ,| width="32" height="32">&nbsp;&nbsp;Win32Forth</h1>                           |
   0 c,

create W32FClassheaderA
   ,| </title><style><!--                                                          |
   ,| h1           { font-family: Tahoma; font-size: 24pt; font-weight: bold }     |
   ,| h2           { font-family: Tahoma; font-size: 18pt; font-weight: bold } --> |
   ,| </style>                                                                     |
   ,| </head>                                                                      |
   ,| <body><h1 align="center">                                                    |
   ,| <a href="mailto:win32forth@yahoogroups.com?subject=DOC:Doc error in $Id: W32fdexh.f,v 1.8 2008/12/23 21:12:06 camilleforth Exp $"> |
   ,| <img border="0" src="../TELLUS.gif" align="left" width="32" height="32"></a> |
   ,| <img border="0" src="../FORTHPRO.gif"                                        |
   ,| width="32" height="32">&nbsp;&nbsp;Win32Forth</h1>                           |
   0 c,

create W32FTrailer
   ,| <hr><p>Document $Id: W32fdexh.f,v 1.8 2008/12/23 21:12:06 camilleforth Exp $</p>                                                   |
   ,| </body></html>                                                               |
   0 c,

create W32FNoTrailer
   0 c,

external

\ *S Glossary

: W32FDocs    ( -- )
\ *G Set output for Win32Forth documents in the doc folder.
     W32Fheader     to HtmlHeader
     W32FheaderA    to HtmlheaderA
     W32FTrailer    to HtmlTrailer ;

: W32FClassDocs    ( -- )
\ *G Set output for Win32Forth documents in the doc\classes folder.
     W32Fheader        to HtmlHeader
     W32FClassheaderA  to HtmlheaderA
     W32FTrailer       to HtmlTrailer ;

: DexDocs     ( -- )
\ *G Set normal DexH output style.
     DexHTMLheader  to HTMLheader
     DexHTMLheaderA to HTMLheaderA
     DexHTMLtrailer to HTMLtrailer ;

internal

0 value OLDtrailer

external

: -tr   ( -- )
\ *G Stop output of the HTML trailer.
        OLDtrailer 0=
        if   HTMLtrailer to OLDtrailer
             W32FNoTrailer to HTMLtrailer
        then ;

: +tr   ( -- )
\ *G Restart output of the HTML trailer.
        OLDtrailer ?DUP
        if   to HTMLtrailer
             0 to OLDtrailer
        then ;

: create-doc    ( addr len -- )
\ *G Create the document for a file. To find the file the forth
\ ** search path is used.
        Prepend<home>\ (dex) ;

internal
in-application

FileOpenDialog DexFile  "Dex Forth File"   "Forth Files (*.f)|*.f|All Files (*.*)|*.*|"

in-system
external

: DEXF  ( -- )
\ *G Choose a file and convert it to HTML. Output filenames are included in the
\ ** source file.
        conhndl start: DexFile count ?dup
        if   (dex)
        else drop
        then ;

[defined] dexh [if]
\in-system-ok ' DEXF is dexh \ link into w32f console menu
[then]

module

cr .( DexH -- Document Extractor loaded )
cr
cr .( Usage: " DEX <filename> " to convert the file <filenname> )
cr .( or     " DEXF " to choose a file and convert it. )
cr
cr .( Use W32FDocs or W32FClassDocs to set the style for Win32Forth docs, )
cr .( in the docs folder or Class docs, in the docs\class folder. )
cr .( Use DexDocs for the standard DexH style. The DexH style is the default. )

\ *Z

