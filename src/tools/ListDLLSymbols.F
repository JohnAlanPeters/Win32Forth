\ $Id: ListDLLSymbols.F,v 1.4 2010/02/14 17:46:28 georgeahubert Exp $

\ By Yves Surrel - 2008 Aug 26

\ I have been looking for some time for a utility to list all functions
\ exported by a DLL. I recently found a solution with DbgHelp.dll. Here is
\ the code (v 4, but works on v. 6 too).

\ The useful words are ListSymbols and ListsymbolsU, where U stands for
\ "undecorated". As an example, Freeimage.dll document functions like
\ FreeImage_GetImageType, but really exports the function with the "decorated"
\ name _FreeImage_GetImageType@4.

\ Modified to add it to the Win32Forth console menu
\ Samstag, Dezember 27 2008 by Dirk Busch

anew -ListDLLSymbols.f

INTERNAL

winlibrary DbgHelp.dll

defer EnumSymbolsProc

3 callback: EnumSymbolsCallback { pSymInfo SymbolSize UserContext -- true }
		pSymInfo 84 + pSymInfo 76 + @ ( add len )
		EnumSymbolsProc true ;

: _EnumSymbolsProc ( add len -- )
		cr type ;

' _EnumSymbolsProc is EnumSymbolsProc

: (ListSymbols) { add len option \ process SymbolAdd -- }

                cls
                ." The exported functions of the DLL-File: " cr
                add len type cr ." are:"

		option call SymSetOptions drop
		call GetCurrentProcess to process
		0 0 process call SymInitialize drop
		0 0. 0 0 0 add len asciiz 0 process
		call SymLoadModuleEx to SymbolAdd
		0 &EnumSymbolsCallback 0 0 SymbolAdd process
		call SymEnumSymbols drop
		0 SymbolAdd process
		call SymUnloadModule64 drop
		;

EXTERNAL

0 constant LSM_NORMAL
2 constant LSM_UNDECORATED

LSM_NORMAL value ListSymbolsMode

INTERNAL

: ListSymbols   ( add len -- )
		ListSymbolsMode (ListSymbols) ;

EXTERNAL

internal
in-application

FileOpenDialog LdeFile  "DLL File"   "DLL Files (*.dll)|*.dll|All Files (*.*)|*.*|"

in-system
external

: LDE   ( <filename> -- )
\ *G List the exported functions of the dll-file <filenname>
        BL PARSE ListSymbols ;

: LDEF  ( -- )
\ *G Choose a dll-file and list the exported functions.
        conhndl start: LdeFile count ?dup
        if   ListSymbols
        else drop
        then ;

[defined] .lde [if]
\in-system-ok ' LDEF is .lde \ link into w32f console menu
[then]

module

cr .( List DLL Symbols -- loaded )
cr
cr .( Usage: " LDE <filename> " to list the exported functions of the dll-file <filenname> )
cr .( or     " LDEF " to choose a dll-file and list the exported functions. )
cr
cr .( Note:  Normaly the decorated names of the DLL functions are displayed. )
cr .(        If you want to see the undecorated names set the value use: )
cr .(        LSM_UNDECORATED to LISTSYMBOLSMODE )

\ *Z
