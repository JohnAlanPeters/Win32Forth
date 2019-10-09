\ $Id: HelpScope.f,v 1.15 2015/12/03 09:24:57 jos_ven Exp $

\ By Camille Doiteau - Feb 2008


\ ------------------------------------------------------------------------------
\ The file HelpScope.f is used to define the scope of the words-part of the help
\ database (ie what words to include in the help).

\ (This is NOT for the html-part of help. For this later one, you have to edit
\ the file HelpSummary.tv and to provide adequate html files)

\ Defining the scope is not straightforward and may need several trials. This
\ is the reason why this source can be run as a standalone source while tuning
\ the scope. When everything is ok, just run the HelpBuidhdb.f and HelpScope.f
\ will be used as is.

\ Now you should browse this file to find the places where you can configurate
\ the words-help scope (there are 2 scope setting parts : select sources and
\ select vocabularies whose words will be included in help)
\
\ You must load this file from a clean (just launched) forth.
\ ------------------------------------------------------------------------------


anew -HelpScope.f

needs linklist.f

[DEFINED] -HelpBuildHDB.f
[IF]   false Value RunStandAlone
[ELSE] true  Value RunStandAlone
[THEN]


\ ------------------------------------------------------------------------------
\ Transient sourcefiles and voc lists          (this is not a scope tuning part)
\ ------------------------------------------------------------------------------

:Class tListItem   <super Object
max-path 2 + bytes sourcefilename
:M classinit:   ( -- )
                classinit: super
                sourcefilename max-path 2 + erase ;m
:M setname:     ( addr cnt -- )
                dup sourcefilename c!
                max-path min 0max sourcefilename 1+ swap move ;m
:m getname:     ( -- addr count )
                sourcefilename count ;m
;class



:class tList  <super linked-list
:m classinit:   ( n addr cnt --)
                classinit: super ;m
:m AddItem:     ( addr count -- )
                addlink: self
                new> tListItem Data!: self
                setname: [ Data@: self ] ;m
:m ShowList:    ( -- )
                >FirstLink: self
                #links: self 0 do
                  Data@: self 0<>
                  if
                       cr Data@: self .    getname: [ Data@: self ] type
                  then
                  >NextLink: self
                loop ;m
create srcbuf 250 allot
:m TestList:    ( -- )
                >FirstLink: self
                #links: self 0 do
                  Data@: self 0<>
                  if   &forthdir count srcbuf place
                       getname: [ Data@: self ] srcbuf +place
                       srcbuf +null
                       cr srcbuf count type
                       srcbuf count r/w open-file abort" can't open source"
                       close-file drop
                  then
                  >NextLink: self
                loop ;m
;class

tList tSrcList


Variable MaxSrcName       0 MaxSrcName !
Variable #Src             0 #Src !

: SrcScope:     ( <subdir\source.f> -- )
                \ load the source if not already here
                \ set some statistics
                >in @
     CheckStack needs
                >in !
                bl parse
                dup MaxSrcName @ max MaxSrcName !
                1 #Src +!
                RunStandAlone if cr 2dup ." ********** " type then
                additem: tSrcList
     CheckStack ;


\ -----------------------------------------------------------------------------
\                  - FIRST SCOPE SETTING PART -
\                     - SOURCES SELECTION -
\ -----------------------------------------------------------------------------
\ Syntax:  SrcScope: subdir\file.f
\ Loads the file (if needed) and, later, will include its words in the help.
\ Paths must be relative to the Win32Forth directory
\ Check for Win32Forth version changes - (this is based on 6.12.00)
\
\ Not so simple :
\ - fkernel.f is added manually
\ - check for imbricated NEEDS (some files could be omitted you want help for)
\ - some exception problems according to order of loading ( see NEEDS ??? )


\ 1) Low level files :
\
\ All files that are part of Win32Forth Console. This list is inspired from the
\ file src\extend.f , thought it is not a simple copy.
\ First comment is "what is in this file" second comment is "why we don't include it"

s" src\kernel\fkernel.f" addItem: tSrcList  \ insert manually this one
1 #Src +!
SrcScope: src\comment.f          \ (sys) comments
SrcScope: src\numconv.f          \ general number conversions
SrcScope: src\console\console1.f \ Console I/O part 1
SrcScope: src\primutil.f         \ primitive utilities
SrcScope: src\nforget.f
SrcScope: src\order.f            \ (sys) vocabulary support
SrcScope: src\module.f           \ (sys) scoping support for modules
SrcScope: src\interpif.f         \ (sys) interpretive conditionals
SrcScope: src\paths.f            \ multi path support words

SrcScope: src\486asm.f           \ (sys) Jim's 486 assembler
SrcScope: src\asmmac.f           \ (sys) Jim's 486 macros
SrcScope: src\asmwin32.f         \ (sys) NEXT for Win32forth

SrcScope: src\pointer.f
SrcScope: src\callback.f         \ windows callback support
SrcScope: src\primhash.f         \ primitive hash functions for OOP later

SrcScope: src\float.f            \ floating point support

SrcScope: src\see.f              \ (sys) see
SrcScope: src\dis486.f           \ (sys) disassembler
SrcScope: src\dthread.f          \ (sys) display threads
SrcScope: src\winlib.f           \ (sys) windows proc and memory debug words
SrcScope: src\words.f            \ (sys) words
SrcScope: src\tools\dump.f       \ HEX dump

SrcScope: src\console\console2.f \ Console I/O part 2
SrcScope: src\debug.f            \ (sys) debug

SrcScope: src\class-errs.f       \ Errors for Class.f
SrcScope: src\class.f            \ Object Oriented Programming

\ SrcScope: src\scrnctrl.f         \ screen control words
SrcScope: src\registry.f         \ Win32 Registry support
SrcScope: src\ansfile.f          \ ansi file words
SrcScope: src\keyboard.f         \ function and special key constants
SrcScope: src\mapfile.f          \ Windows32 file memory mapping
SrcScope: src\environ.f          \ (sys) environment? support

SrcScope: src\struct200X.f       \ 200X structure words


SrcScope: src\utils.f            \ load other misc utility words
SrcScope: src\exceptio.f         \ windows exception handling

SrcScope: src\CreateProcess.f    \ common code REQUIREd by w32fmsg.f and Shell.f

SrcScope: src\w32fMsgList.f      \ load win32forth-specific messages list
SrcScope: src\w32fMsg.f          \ load win32forth-specific messages
SrcScope: src\Shell.f            \ load SHELL utility words
SrcScope: src\editor_io.f        \ editor/console Communication
SrcScope: src\imageman.f         \ (sys) fsave, application & turnkey words
SrcScope: src\Pre-save.f

SrcScope: src\dbgsrc1.f          \ (sys) source level debugging #1
SrcScope: src\dbgsrc2.f          \ (sys) source level debugging #2
SrcScope: src\classdbg.f         \ (sys) Object Debugging

SrcScope: src\colors.f
SrcScope: src\fonts.f            \ font class
SrcScope: src\xfiledlg.f         \ xcall replacements for open dialogs
SrcScope: src\PrintSupport.f     \ replacement for w32fPrint.dll
SrcScope: src\dc.f               \ device context class
SrcScope: src\generic.f          \ generic window class
SrcScope: src\window.f
SrcScope: src\childwnd.f         \ child windows
SrcScope: src\winmsg.f
SrcScope: src\control.f
SrcScope: src\controls.f
SrcScope: src\button.f
SrcScope: src\dialog.f
SrcScope: src\menu.f
SrcScope: src\lib\BROWSEFLD.F    \ SHBrowseForFolder() support
SrcScope: src\lib\MultiTaskingClass.f  \ For parallel processing

SrcScope: src\console\forthdlg.f       \ console dialogs
SrcScope: src\keysave.f                \ keyboard macro recording
SrcScope: src\tools\tools.f            \ various tool's
\ SrcScope: src\console\ConsoleMenu.f    \ console menu bar         \ useless
\ SrcScope: src\console\ConsoleStatBar.f \ console status bar       \ useless
\ SrcScope: src\console\NewConsole.f     \ console window           \ useless

SrcScope: src\compat\compatibility.f   \ compatibility with prev release (deprecated)
SrcScope: src\boot.f                   \ hello - boot

SrcScope: src\gdi\gdistruct.f          \ gdi                          \ ???
SrcScope: src\gdi\gdiBase.f            \ gdi
SrcScope: src\gdi\gdiPen.f
SrcScope: src\gdi\gdiBrush.f
SrcScope: src\gdi\gdiFont.f
SrcScope: src\gdi\gdiBitmap.f
SrcScope: src\gdi\gdiMetafile.f
SrcScope: src\gdi\gdiDc.f
SrcScope: src\gdi\gdiWindowDc.f
SrcScope: src\gdi\gdiMetafileDC.f

\ SrcScope: src\console\noconsole.f   \ ??? no longer needed ???

\ 2) Library files :
\
\ All files that are part of Win32Forth Library.
\ - Check for Win32Forth versions changes - (this is based on 6.12.00)
\
\ Be aware of NEEDS imbrications.
\ Order of files-load seems to be important (see NEEDS ???)
\ Comment is "why we don't include"

\ SrcScope: src\lib\excontrols.f         \ not to be loaded (is itself a loader)
SrcScope: src\lib\StatusBar.f
SrcScope: src\lib\TextBox.f
SrcScope: src\lib\ListBox.f
SrcScope: src\lib\UpDownControl.f
SrcScope: src\lib\Buttons.f
SrcScope: src\lib\Label.f
SrcScope: src\lib\ProgressBar.f
SrcScope: src\lib\TrackBar.f
SrcScope: src\lib\ScrollBar.f
SrcScope: src\lib\Calendar.f
SrcScope: src\lib\TabControl.f
SrcScope: src\lib\ButtonBar.f            \ ok ? see comment in excontrols.f

SrcScope: src\lib\ToolBar.f
SrcScope: src\lib\RebarControl.f
SrcScope: src\lib\TrayWindow.f

SrcScope: src\lib\AXControl.f
SrcScope: src\lib\bitmap.f
SrcScope: src\lib\AcceleratorTables.f
SrcScope: src\lib\ADO.f
SrcScope: src\lib\MDI.f
SrcScope: src\lib\MdiDialog.f
SrcScope: src\lib\browsefld.f
\ SrcScope: src\lib\Dialogrc.f           \ redefines many words ??? where were defined ?
SrcScope: src\lib\ListView.f
SrcScope: src\lib\TreeView.f

SrcScope: src\lib\binsearch.f
SrcScope: src\lib\block.f

SrcScope: src\lib\array.f
SrcScope: src\lib\enum.f
SrcScope: src\lib\LinkList.f
SrcScope: src\lib\Ctype.f
SrcScope: src\lib\Struct.f
SrcScope: src\lib\estruct.f
SrcScope: src\lib\extstruct.f
SrcScope: src\lib\exUtils.f

SrcScope: src\lib\fcases.f
SrcScope: src\lib\fCOM.f
SrcScope: src\lib\file.f
SrcScope: src\lib\FileAssociations.f
SrcScope: src\lib\FileLister.f
SrcScope: src\lib\FlashControl.f
SrcScope: src\lib\GetWindowPlacment.f

SrcScope: src\lib\HTMLControl.f
\ SrcScope: src\lib\HTMLDisplayControl.f      \ deprecated, replaced by HTMLControl
SrcScope: src\lib\HTMLDisplayWindow.f
SrcScope: src\lib\HyperLink.f
SrcScope: src\lib\PDFControl.f

SrcScope: src\lib\ImageWindow.f
\ SrcScope: src\lib\MessageLoop.f             \ this file is deprecated and empty
\ SrcScope: src\lib\SendMessage.f             \ this file is deprecated and empty
SrcScope: src\lib\MultiOpen.f
SrcScope: src\lib\RecentFiles.f
SrcScope: src\lib\RegistrySupport.f
SrcScope: src\lib\RegistryWindowPos.f
SrcScope: src\lib\resources.f
\ SrcScope: src\lib\ScintillaControl.f
\ SrcScope: src\lib\ScintillaEdit.f           \ uses lexer, bug on loading
\ SrcScope: src\lib\ScintillaHyperEdit.f      \ uses lexer,    "
\ SrcScope: src\lib\ScintillaLexer.f          \ uses lexer,    "
SrcScope: src\lib\Security.f
SrcScope: src\lib\Sock.f
SrcScope: src\lib\SoundVolume.f
\ SrcScope: src\lib\Joystick.f                \ bug on loading
SrcScope: src\lib\SQLite.f
SrcScope: src\lib\Sub_Dirs.f
SrcScope: src\lib\Switch.f
SrcScope: src\lib\Task.f
SrcScope: src\lib\Unicode.f
SrcScope: src\lib\VolInfo.f
SrcScope: src\lib\w_search.f
SrcScope: src\lib\win32Help.f

\ new files to handle
SrcScope: src\lib\TimerWindow.f
SrcScope: src\lib\ExtDC.f
SrcScope: src\lib\BitmapDC.f


\ 3) Other files :

\ Example :
\ SrcScope: src\tools\xref.f          \ cross reference tool
\ (but for me, tools are better documented by dexh and added in the tools part of html
\ help treeview)

\ -----------------------------------------------------------------------------


NoStack RunStandAlone                        ( this is not a scope tuning part)
[IF]
testlist: tSrcList     \ open and close each file in tsrclist to check if names are ok
showlist: tSrcList
cr .( Max FileName Length = ) MaxSrcName @ .
cr .( # Source Files      = ) #Src @ .
cr .( # Source List       = ) #Links: tSrcList .
tSrcList disposelist
[THEN]


\ ------------------------------------------------------------------------------
\ Vocabularies transient list                  (this is not a scope tuning part)
\ ------------------------------------------------------------------------------

RunStandAlone
[IF]
\ List all vocabularies (classes excepted) as an help for actual vocabulary
\ selection (see next scope setting part). This must be run here in order to scan
\ all vocabularies that might have been created while loading source files.

: xGetName       ( xt -- addr count ) \ get xt's stringname
                dup >name dup name> ['] [UNKNOWN] =     \ if not found
                if   ( nfa) drop base @ >r hex
                     ( xt) 0 <# 8 0 DO # LOOP [CHAR] x HOLD [CHAR] 0 HOLD #>
                     r> base !
                else ( xt nfa -- ) nip ( nfa) count
                then ;

0 value Total#words

: #WordsInVoc   { voc \ w#threads #syswords #appwords -- #syswords #appwords }
                \ count sys and app words in this voc
                0 to #syswords 0 to #appwords
                voc dup voc#threads to w#threads
                dup voc>vcfa
                ?IsClass not                     \ don't look through classes
                if   here 500 + w#threads cells move     \ copy vocabulary up
                     begin   here 500 + w#threads largest dup
                     while   dup l>name name> sys-addr?
                             if 1 +to #syswords else 1 +to #appwords then
                             @ swap !
                     repeat  2drop
                else drop
                then #syswords #appwords 2dup + +to Total#words ;

: xScanVocabularies ( -- )
                0 to Total#words
                voc-link @
                begin   dup vlink>voc
                        dup voc>vcfa
                        ?IsClass not  \ don't look through classes
                        if   dup voc>vcfa xgetname cr type ."     "
                             #WordsInVoc ."  #words: " . ." in app " . ." in sys "
                        else drop
                        then
                        @ dup 0=
                until   drop
                cr ." Total = " Total#Words . ;

xScanVocabularies

[THEN]

tList tVocList

Variable MaxVocName       0 MaxVocName !
Variable #Voc             0 #Voc !

: VocScope:     ( <App|Sys\vocabulary> -- )
                bl parse
                dup MaxVocName @ max MaxVocName !
                1 #Voc +!
                RunStandAlone if cr 2dup ." ********** " type then
                additem: tVocList ;



\ -----------------------------------------------------------------------------
\                  - SECOND SCOPE SETTING PART -
\                       - VOCABULARIES -
\ -----------------------------------------------------------------------------
\ Syntax:  VocScope: app|sys\vocabulary
\ Select a vocabulary whoose names we want in the "words" part of help.
\ (this doesn't concern classes and methods which are handled separately)
\ - Check for Win32Forth versions changes - (this is based on 6.12.00)


\ Application space vocabularies    \ reason why excluded or kept

\ VocScope: APP\STRUCT-VOC          \ internal use ?
\ VocScope: APP\STRUCTS             \ empty, internal use ?
VocScope: APP\ENVIRONMENT
\ VocScope: APP\BUG                 \ empty
\ VocScope: APP\DISASSEMBLER        \ empty
\ VocScope: APP\HASHED              \ methods (will be handled with classes)
VocScope: APP\CLASSES
\ VocScope: APP\ASM-HIDDEN          \ empty
\ VocScope: APP\VIMAGE              \ empty
VocScope: APP\ASSEMBLER
\ VocScope: APP\EDITOR              \ no interest (and empty)
VocScope: APP\HIDDEN
\ VocScope: APP\FILES               \ empty
\ VocScope: APP\LOCALS              \ transient use
VocScope: APP\FORTH
VocScope: APP\ROOT                  \ empty but base of vocs tree

\ System space vocabularies

\ VocScope: SYS\STRUCT-VOC          \ empty
\ VocScope: SYS\STRUCTS             \ internal use ?
VocScope: SYS\ENVIRONMENT
VocScope: SYS\BUG
VocScope: SYS\DISASSEMBLER
VocScope: SYS\HASHED                \ ok, contain only SELF and SUPER
VocScope: SYS\CLASSES
VocScope: SYS\ASM-HIDDEN
VocScope: SYS\VIMAGE
VocScope: SYS\ASSEMBLER
\ VocScope: SYS\EDITOR              \ no interest (and empty)
VocScope: SYS\HIDDEN
\ VocScope: SYS\FILES               \ not words
\ VocScope: SYS\LOCALS              \ internal use
VocScope: SYS\FORTH
VocScope: SYS\ROOT

\ -----------------------------------------------------------------------------


NoStack RunStandAlone                        ( this is not a scope tuning part)
[IF]
showlist: tVocList
cr .( Max Voc Name Length = ) MaxVocName @ .
cr .( # Vocs              = ) #Voc @ .
cr .( # Vocs in list      = ) #Links: tVocList .
tVocList disposelist
[THEN]

\s

