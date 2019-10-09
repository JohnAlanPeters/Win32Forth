\ $Id: tools.f,v 1.11 2008/12/27 10:07:46 dbu_de Exp $

\ Tools.f
\ Moved here from ConsoleMenu.f
\ Sonntag, August 28 2005 dbu

anew -tools.f

INTERNAL
EXTERNAL        \ externally available definitions start here

defer .ide
:noname         ( -- ) \ load the class and vocabulary browser
                turnkeyed? 0=
\in-system-ok   IF  s" src\Tools\StartIde.f" Prepend<home>\ INCLUDED
                then ; is .ide

defer .ForthForm
:noname         ( -- ) \ load the class and vocabulary browser
                turnkeyed? 0=
\in-system-ok   IF  s" src\Tools\StartForthForm.f" Prepend<home>\ INCLUDED
                then ; is .ForthForm


defer class-browser
:noname         ( -- ) \ load the class and vocabulary browser
                turnkeyed? 0=
\in-system-ok   IF  s" src\Tools\ClassBrowser.f" Prepend<home>\ INCLUDED
                then ; is class-browser

defer help-system
:noname         ( -- ) \ load the help-system
                turnkeyed? 0=
\in-system-ok   IF   s" src\Tools\HelpSystem.f" Prepend<home>\ INCLUDED
                THEN ; is help-system

defer xref
:noname         ( -- ) \ load the xref tool
                turnkeyed? 0=
\in-system-ok   IF  >system s" src\Tools\xref.f" Prepend<home>\ INCLUDED system>
                THEN ; is xref

defer dexh
:noname         ( -- ) \ load the DexH tool
                turnkeyed? 0=
\in-system-ok   IF  >system s" src\Tools\w32fdexh.f" Prepend<home>\ INCLUDED system>
                THEN ; is dexh

defer .dfc
:noname         ( -- ) \ load the DFC tool
                turnkeyed? 0=
\in-system-ok   IF  >system s" src\Tools\dfc.f" Prepend<home>\ INCLUDED system>
                THEN ; is .dfc

defer .Windows
:noname         ( -- ) \ load the DumpWindow tool
                turnkeyed? 0=
\in-system-ok   IF   s" src\Tools\DumpWindows.f" Prepend<home>\ INCLUDED
                THEN ; is .Windows

defer .lde
:noname         ( -- ) \ load the ListDLLSymbols tool
                turnkeyed? 0=
\in-system-ok   IF   s" src\Tools\ListDLLSymbols.f" Prepend<home>\ INCLUDED
                THEN ; is .lde

MODULE
