\ $Id: HelpMain.f,v 1.13 2013/03/07 16:19:15 georgeahubert Exp $

\ By Camille Doiteau - Feb 2008


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ---------------------------- help system - main ------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

\ ------------------------------ ASSUMPTIONS & NOTES ----------------------------------
\ - In searching the parent class for a method, it is assumed that the parent class is
\   unique, ie: classes haven't been redefined.
\ - In analyzing source files, it is assumed that no word can overlap on 2 lines
\ - In getting a word's comments, it is assumed that the comments immediately follow the word.
\ - For TV-structure-text-files handling, it is assumed that in texts containing
\   "|" no space can follow |
\ Note: xts are not recorded as they will be different if libraries are subsequently
\       loaded at different places in dictionary.
\ Note: in order to get coherent quickinfo, which itself comes from the source via the
\       VIEW info, the help database should be rebuilt right after rebuilding the whole
\       win32forth system.
\ -------------------------------------------------------------------------------------

\ *! dexh-HelpMain
\ *T HELP
\ *Q Version 1.0
\ ** 2008/04/15 By Camille Doiteau \n
\ ** Todo: see Help\HelpBugFix.txt

\ *Q Abstract
\ ** This is the help system you are currently using. It includes html documentation and
\ ** fast access to thousands of win32forth words, with either displaying a quick info
\ ** about each word or viewing its source file.

\ *S How to use the help ?
\ *P Simply read the "help on Help" ! \n
\ ** (This document describes how to \bmaintain\d the help system and database).

\ *S Notation convention for enhancing help quick info
\ *P The quick info used by this help system is parsed from the sources : for each
\ ** word definition, all the subsequent comments are gathered as the quick info.
\ ** To get the best result, Win32Forth developpers are encouraged to follow this
\ ** convention : on a first line, you put the word definition, its stack effect,
\ ** maybe with locals, and the beginning of comments. Comments can continue on
\ ** any number of following lines (maximum 8K). The only comment words allowed
\ ** are : \t(...) { ... }\d and \t\\\d they may include Dexh commands. Example :
\ *E : AWORD  ( n1 -- n2 )           \ what does this word, in short
\ **          { n1 / local1 -- n2 }  \ a locals stack effect
\ ** \\ *G This is a Dexh auto-documentation glossary entry, explaining what the word does.
\ ** \\ It could be a simple comment too.
\ *P The comments scan will stop as soon as any Forth word is encountered. For the
\ ** case where comments unrelated to the word immediately follow the end of its comments,
\ ** you can insert the Forth word \tNOOP\d to force scanning to stop.

\ *S Compiling the help program
\ *P Compile \bHelp\HelpMain.f\d to create Help.exe.
\ *P Help.exe need not be recompiled when the help database is rebuilt. However,
\ ** the help database must exist before Help.exe can be run. This database comes
\ ** ready with the Win32Forth distribution but you may modify it if needed. The
\ ** following explains how to do it.

\ *S What is the help database ?
\ *P The help database is made of 2 main parts: \n
\ *B the html help pages\n
\ *B the words database (words' index and quickinfo)

\ *S Expanding the html help database
\ *P The html help database is made of 3 parts: \n
\ *B a set of hand-written html pages (names beginning with "\bw32f-\d")\n plus htm
\ ** files in the help\html subdirs forthform, dpans and guides
\ *B a set of dexh-generated help pages (names beginning with "\bdexh-\d" or "\bclass-\d")\n
\ ** (please have a look at the dexh documentation next to this page)
\ *B a help summary, describing, for each html page, its hierarchy and link.

\ *N Maintaining the hand-written help pages :
\ *P Theese are basic-html pages. We suggest you use a simple text editor to edit
\ ** them as some html editors add a lot of useless styling code (eg, never
\ ** use Microsoft Words).
\ *P To create a new help page from scratch :\n
\ *B Use the file \bhelp\html\anew-w32f.htm\d as a template (make a copy and rename
\ ** it). It contains all you need to create a win32Forth help page. Moreover, it
\ ** follows the general win32Forth presentation rules (thanks to the CSS style
\ ** sheet help\html\style.css).
\ *B Insert the newly created page in the help summary (see below)
  noop
\ *N Maintaining the dexh help pages :
\ *P As this documentation is written inside source files, just edit them to update
\ ** their dexh contents.
\ *P If you want to document a new file, then there is a little more to do :
\ *B Check that your dexh code is ok by running \tDEXF\d as standalone and looking at the result.
\ *B Edit the file \bHelp\HelpCreateDexhDocs.f\d to add your file in the list of
\ ** files whose dexh documentation must be generated and run it.
\ *B Insert the newly created page in the help summary (see below)

\ *N Maintaining the html help summary :
\ *P The file \bhelp\hdb\HelpSummary.tv\d contains all the information about html pages
\ ** organization and links, in a treeview-like structure.
\ ** HelpSummary.tv contains comments explaining how to fill it. To modify or add a
\ ** new help page, follow this procedure :
\ *B Make a backup copy of the file help\hdb\HelpSummary.tv
\ *B Open it with the IDE (use: files all *.*) and search the right place to insert
\ ** your page (ie your line in HelpSummary.tv).
\ *B Edit the line to give it a treeview depth, a treeview name and the link to your
\ ** html page. (*** check syntax ! *** especially for character "|" )
\ *B Save HelpSummary.tv
\ *B Relaunch Help.exe, so that it uses this new version
\ *P The tool \bHelp\HelpTestTV.f\d allows you to test HelpSummary.tv before launching the
\ ** help itself.

\ *S Configurating and building the words help database
\ *P The words help database is built in two steps :
\ *B Select all the words to be included to the word database :\n
\ ** Edit the file \bHelp\HelpScope.f\d in order to select sources files and vocabularies
\ ** whoose words must be included in the words'index. (Browse HelpScope.f for details).
\ ** You should run HelpScope.f as a stand alone until everything goes well.
\ *B Once this is ok, run \bHelp\HelpBuildhdb.f\d to actually create the words database.
\ *P As building the words database needs loading and parsing a great number of files, it
\ ** is a somewhat risky process. Always make a backup of HelpScope.f before.

\ *N Caution
\ *P A great deal of files are used by Help.exe to run. Don't modify the directory
\ ** layout of the Help directory. Some files are pre-built and needed, even for the
\ ** databases building, they are :
\ *B help\hdb\HelpFct.txt
\ *B help\hdb\HelpSummary.tv
\ *B help\hdb\HelpAns.txt
\ *B help\hdb\Help.cfg
\ *B help\html\style.css
\ *B all the w32f-???.htm files and help\html subdirs forthform, dpans and guides


anew -HelpMain.f

true value Turnkey?

needs resources.f

needs help\HelpFiles.f       \ for database files
needs help\FileParser.f      \ for load config & load treeview-structure-text-files


\ ------------------------------------------------------------------------------
\ >Num : replace EVALUATE to convert a string to n
\ ------------------------------------------------------------------------------

\ This word is used to convert a string to a number (as when turnkeyed, we have
\ no longer the Forth interpreter and cannot use EVALUATE)

: >Num          ( addr len -- n )
                bl skip -trailing (number?) drop d>s ;


\ ------------------------------------------------------------------------------
\ Help Database files availability check   / Path handling
\ ------------------------------------------------------------------------------

DFILE Help.cfg DummyFilename               \ help configuration

DFILE HelpSrc.hdb DummyFilename            \ sources filenames table
DFILE HelpVoc.hdb DummyFilename            \ vocabularies table
DFILE HelpAns.hdb DummyFilename            \ ANS standard table
DFILE HelpFct.hdb DummyFilename            \ Functionality table
DFILE HelpWrd.hdb DummyFilename            \ words database
DFILE HelpWrd.hdx DummyFilename            \ words index
DFILE HelpWrd.txt DummyFilename            \ words quick info
DFILE HelpWrd.tv DummyFilename             \ words treeview-structure-text-file

DFILE HelpSummary.tv DummyFilename         \ html help treeview-structure-text-file


\ paths handling  : simply use &ForthDir

: TestOpenWrd   ( -- flag ) \ flag=0 if all files could be opened
                New$ &ForthDir count 2 pick place          \ set file name
                s" Help\hdb\Help.cfg" 2 pick +place
                count Help.cfg FileName!
                Help.cfg fopen                             \ try open
                Help.cfg fclose drop

                New$ &ForthDir count 2 pick place
                s" Help\hdb\HelpSrc.hdb" 2 pick +place
                count HelpSrc.hdb FileName!
                helpsrc.hdb fopen
                helpsrc.hdb fclose drop             or

                New$ &ForthDir count 2 pick place
                s" Help\hdb\HelpVoc.hdb" 2 pick +place
                count HelpVoc.hdb FileName!
                helpVoc.hdb fopen                   or
                helpVoc.hdb fclose drop

                New$ &ForthDir count 2 pick place
                s" Help\hdb\HelpAns.hdb" 2 pick +place
                count HelpAns.hdb FileName!
                helpAns.hdb fopen                   or
                helpAns.hdb fclose drop

                New$ &ForthDir count 2 pick place
                s" Help\hdb\HelpFct.hdb" 2 pick +place
                count HelpFct.hdb FileName!
                helpFct.hdb fopen                   or
                helpFct.hdb fclose drop

                New$ &ForthDir count 2 pick place
                s" Help\hdb\HelpWrd.hdb" 2 pick +place
                count HelpWrd.hdb FileName!
                HelpWrd.hdb fopen                   or
                HelpWrd.hdb fclose drop

                New$ &ForthDir count 2 pick place
                s" Help\hdb\HelpWrd.hdx" 2 pick +place
                count HelpWrd.hdx FileName!
                HelpWrd.hdx fopen                   or
                HelpWrd.hdx fclose drop

                New$ &ForthDir count 2 pick place
                s" Help\hdb\HelpWrd.txt" 2 pick +place
                count HelpWrd.txt FileName!
                HelpWrd.txt fopen                   or
                HelpWrd.txt fclose drop

                New$ &ForthDir count 2 pick place
                s" Help\hdb\HelpWrd.tv" 2 pick +place
                count HelpWrd.tv FileName!
                HelpWrd.tv fopen                     or
                HelpWrd.tv fclose drop ;


: TestOpenHlp   ( -- flag ) \ flag=0 if file could be opened
                New$ &ForthDir count 2 pick place
                s" Help\hdb\HelpSummary.tv" 2 pick +place
                count HelpSummary.tv FileName!
                HelpSummary.tv fopen
                HelpSummary.tv fclose drop ;


\ ------------------------------------------------------------------------------
\ Help Database tables files open and read in array of record
\ ------------------------------------------------------------------------------

create filecells 3 cells allot
: filecell1  filecells ;
: filecell2  filecells cell+ ;
: filecell3  filecells 2 cells + ;

\ Sources table
\ -------------

:DataType Src=                                   \ array of records in memory
   1 String= SrcName
;DataType
Unallocated Array[ 1 ]Of Src= HelpSrc[]

Variable #Src                                    \ # sources files

: ReadSrc       ( -- status ) \ status:  =0 ok
                helpsrc.hdb fopen                        \ open file
                if 2 exit then
                filecells 2 cells HelpSrc.hdb ReadSeq    \ get file header
                if HelpSrc.hdb fClose drop 4 exit then
                filecell1 @ #Src !
                filecell2 @ 1+ SrcName diSize !          \ dirty trick to resize
                #Src @ 0 HelpSrc[] diDim !               \ string and array of record
                SrcName diSize @ HelpSrc[] diSize !
                HelpSrc[] diSize @ #Src @ 1+ *
                HelpSrc[] diTotalSize !
                HelpSrc[] valloc
                0 HelpSrc.hdb FSEEK                      \ load whole file
                if HelpSrc.hdb fClose drop 4 exit then
                0 HelpSrc[] vaddr HelpSrc[] SizeOf
                HelpSrc.hdb READSEQ
                if HelpSrc.hdb fClose drop 4 exit then
                HelpSrc.hdb fClose drop
                0 ;
((
ReadSrc .
: ShowHelpSrc[] ( -- )
                #Src @ 1+ 0 do
                  cr i . i HelpSrc[] SrcName v@ count type
                loop ;
ShowHelpSrc[]
))


\ Vocabularies table
\ ------------------

:DataType Voc=                                   \ array of records in memory
      dword= Voc#Words  \ # words in this voc
   1 String= VocName
;DataType
Unallocated Array[ 1 ]Of Voc= HelpVoc[]

Variable #Voc                                    \ # vocabularies files

: ReadVoc       ( -- status ) \ status:  =0 ok
                \ fill array of record with file's contents
                helpVoc.hdb fopen                        \ open file
                if 2 exit then
                filecells 2 cells HelpVoc.hdb ReadSeq    \ get file header
                if HelpVoc.hdb fClose drop 4 exit then
                filecell1 @ #Voc !
                filecell2 @ 1+ VocName diSize !          \ dirty trick to resize
                #Voc @ 0 HelpVoc[] diDim !               \ string and array of record
                VocName diSize @ Voc#Words diSize @ + HelpVoc[] diSize !
                HelpVoc[] diSize @ #Voc @ 1+ *
                HelpVoc[] diTotalSize !
                HelpVoc[] valloc
                0 HelpVoc.hdb FSEEK                      \ load whole file
                if HelpVoc.hdb fClose drop 4 exit then
                0 HelpVoc[] vaddr HelpVoc[] SizeOf
                HelpVoc.hdb READSEQ
                if HelpVoc.hdb fClose drop 4 exit then
                HelpVoc.hdb fClose drop
                0 ;
((
ReadVoc .
: ShowHelpVoc[] ( -- )
                #Voc @ 1+ 0 do
                  cr i . i HelpVoc[] VocName v@ count type
                         i HelpVoc[] Voc#Words v@ space .
                loop ;
ShowHelpVoc[]
))


\ ANS standard table
\ ------------------

:DataType Ans=                                   \ array of records in memory
     1 String= AnsName
     1 String= AnsInfo
;DataType
Unallocated Array[ 1 ]Of Ans= HelpAns[]

Variable #Ans                                    \ # ans words

: ReadAns       ( -- status ) \ status:  =0 ok
                \ fill array of record with file's contents
                helpAns.hdb fopen                        \ open file
                if 2 exit then
                filecells 3 cells HelpAns.hdb ReadSeq    \ get file header
                if HelpAns.hdb fClose drop 4 exit then
                filecell1 @ #Ans !
                filecell2 @ 1+ AnsName diSize !          \ dirty trick to resize
                filecell3 @ 1+ AnsInfo diSize !          \ string and array of record
                AnsName diSize @ AnsInfo diOff !
                #Ans @ 0 HelpAns[] diDim !
                AnsName diSize @ AnsInfo diSize @ +
                HelpAns[] diSize !
                HelpAns[] diSize @ #Ans @ 1+ *
                HelpAns[] diTotalSize !
                HelpAns[] valloc
                0 HelpAns.hdb FSEEK                      \ load whole file
                if HelpAns.hdb fClose drop 4 exit then
                0 HelpAns[] vaddr HelpAns[] SizeOf
                HelpAns.hdb READSEQ
                if HelpAns.hdb fClose drop 4 exit then
                HelpAns.hdb fClose drop
                0 ;
((
ReadAns .
: ShowHelpAns[] ( -- )
                #Ans @ 1+ 0 do
                  cr i . i HelpAns[] AnsName v@ count type
                loop ;
ShowHelpAns[]
))


\ Functionality table
\ -------------------

:DataType Fct=
     1 String= FctName
     1 String= FctInfo
;DataType
Unallocated Array[ 1 ]Of Fct= HelpFct[]

Variable #Fct                                    \ # words by functionality

: ReadFct       ( -- status ) \ status:  =0 ok
                \ fill array of record with file's contents
                helpFct.hdb fopen                        \ open file
                if 2 exit then
                filecells 3 cells HelpFct.hdb ReadSeq    \ get file header
                if HelpFct.hdb fClose drop 4 exit then
                filecell1 @ #Fct !
                filecell2 @ 1+ FctName diSize !          \ dirty trick to resize
                filecell3 @ 1+ FctInfo diSize !          \ string and array of record
                FctName diSize @ FctInfo diOff !
                #Fct @ 0 HelpFct[] diDim !
                FctName diSize @ FctInfo diSize @ +
                HelpFct[] diSize !
                HelpFct[] diSize @ #Fct @ 1+ *
                HelpFct[] diTotalSize !
                HelpFct[] valloc
                0 HelpFct.hdb FSEEK                      \ load whole file
                if HelpFct.hdb fClose drop 4 exit then
                0 HelpFct[] vaddr HelpFct[] SizeOf
                HelpFct.hdb READSEQ
                if HelpFct.hdb fClose drop 4 exit then
                HelpFct.hdb fClose drop
                0 ;
((
ReadFct .
: ShowHelpFct[] ( -- )
                #Fct @ 1+ 0 do
                  cr i . i HelpFct[] FctName v@ count type
                loop ;
ShowHelpFct[]
))

\ Words index
\ -----------

:DataType WordsIndex=
        dword= Wordn0rec   \ n0rec in HelpWrd.hdb for this word
        dword= WordExtra   \ for transient use
     1 String= WordName    \ word name
;DataType
Unallocated Array[ 1 ]Of WordsIndex= HelpWrd[]


Variable #Wrd                                    \ # words in index

: ReadNdx       ( -- status ) \ status:  =0 ok
                \ fill array of record with file's contents
                HelpWrd.hdx fopen                        \ open file
                if 2 exit then
                filecells 2 cells HelpWrd.hdx ReadSeq    \ get file header
                if HelpWrd.hdx fClose drop 4 exit then
                filecell1 @ #Wrd !
                filecell2 @ 1+ WordName diSize !          \ dirty trick to resize
                #Wrd @ 0 HelpWrd[] diDim !                \ string and array of record
                WordName diSize @ WordN0rec diSize @ +
                         WordExtra disize @ + HelpWrd[] diSize !
                HelpWrd[] diSize @ #Wrd @ 1+ *
                HelpWrd[] diTotalSize !

                HelpWrd[] valloc
                0 HelpWrd.hdx FSEEK                      \ load whole file
                if HelpWrd.hdx fClose drop 4 exit then
                0 HelpWrd[] vaddr HelpWrd[] SizeOf
                HelpWrd.hdx READSEQ
                if HelpWrd.hdx fClose drop 4 exit then
                HelpWrd.hdx fClose drop
                0 ;
((
ReadNdx .
: ShowHelpWrd[] ( -- )
                #Wrd @ 1+ 0 do
                  cr i . i HelpWrd[] WordName v@ count type
                         i HelpWrd[] WordN0rec v@ space .
                         i HelpWrd[] WordExtra v@ space .
                loop ;
ShowHelpWrd[]
))



\ Words database
\ --------------

\ HelpWrd.hdb record structure
:DataType HelpWord=
         byte= WordDepr?         \ true if word is deprecated
         byte= WordImm?          \ true if word is immediate
         byte= WordSys?          \ true if word of System dictionary
         byte= WordCls?          \ true if class word (classes & methods)
        dword= WordVoc           \ pointer to HelpVoc.hdb record
        dword= WordSrc           \ pointer to HelpSrc.hdb record
        dword= WordLine          \ source line number
        dword= WordFct           \ pointer to HelpFct.hdb record
        dword= WordAns           \ pointer to HelpAns.hdb record
        dword= WordFrom          \ beginning fileposition in word help texts
        dword= WordTo            \ ending fileposition in word help texts
;DataType

HelpWord= HelpWord               \ room for one record



\ ------------------------------------------------------------------------------
\ Handle config file   (don't like writing in Registry)
\ ------------------------------------------------------------------------------

0 Value WindowX
0 Value WindowY
0 Value WindowW
0 Value WindowH
0 Value SplitterV
0 Value SplitterH

create LineCfg 200 allot
: write-linecfg ( -- ) \ write line which is in LineCfg
                LineCfg count Help.cfg FilChan @ Write-Line
                abort" Write error in Help.cfg" ;

: SaveConfig    ( -- ) \ save config info
                Help.cfg fopen drop
                s" [WindowX] "   LineCfg place WindowX   s>d (d.) LineCfg +place write-linecfg
                s" [WindowY] "   LineCfg place WindowY   s>d (d.) LineCfg +place write-linecfg
                s" [WindowW] "   LineCfg place WindowW   s>d (d.) LineCfg +place write-linecfg
                s" [WindowH] "   LineCfg place WindowH   s>d (d.) LineCfg +place write-linecfg
                s" [SplitterV] " LineCfg place SplitterV s>d (d.) LineCfg +place write-linecfg
                s" [SplitterH] " LineCfg place SplitterH s>d (d.) LineCfg +place write-linecfg
                Help.cfg fclose drop ;

: LoadConfig    ( -- ) \ load config info
                Help.cfg fopen
              \  s" Couldn't open Help.cfg" ?AbortBox
                0<> if -1 abort" Couldn't open Help.cfg" then
                Help.cfg FilChan @ ParseInit
                s" [WindowX]"   SearchWord if GetWord >Num else 0   then to WindowX
                s" [WindowY]"   SearchWord if GetWord >Num else 0   then to WindowY
                s" [WindowW]"   SearchWord if GetWord >Num else 800 then to WindowW
                s" [WindowH]"   SearchWord if GetWord >Num else 400 then to WindowH
                s" [SplitterV]" SearchWord if GetWord >Num else 240 then to SplitterV
                s" [SplitterH]" SearchWord if GetWord >Num else 100 then to SplitterH
                Help.cfg fclose drop ;


\ ------------------------------------------------------------------------------
\ Help launch
\ ------------------------------------------------------------------------------

0 value WithWords? \ false if only html-help ( ??? doesn't work yet, will need separate pg)

: Clearhdb      ( -- ) \ to be run when main window is destroyed
                SaveConfig
                WithWords?
                if   HelpSrc[] vfree
                     HelpVoc[] vfree
                     HelpAns[] vfree
                     HelpFct[] vfree
                     HelpWrd[] vfree
                     HelpWrd.hdb fclose drop
                     HelpWrd.txt fclose drop
                   \ HelpWrd.tv fclose drop   \ will be opened and closed on the fly
                then
              \ HelpSummary.tv fclose drop    \ will be opened and closed on the fly
                ;


needs help\HelpWindow.f


: Runhdb        ( -- )
                TestOpenWrd               \ if 1 word-database file open failed
                0= to WithWords?          \ then html help only
                WithWords?
                if   ReadSrc
                     ReadVoc or
                     ReadAns or
                     ReadFct or
                     ReadNdx or
                     HelpWrd.hdb fopen or
                     HelpWrd.txt fopen or
                   \ HelpWrd.tv fopen  or \ will be opened and closed on the fly
                     abort" Couldn't open words-help database"
                then
                TestOpenHlp
                0<> abort" Couldn't open html-help database"
              \ HelpSummary.tv fopen      \ will be opened and closed on the fly
                LoadConfig

                Start: NewHelp
                turnkey? if GetHandle: NewHelp Enablew32fMsg then
                ;

: Main          ( - )
                ['] Runhdb catch if true s" exception occured" ?messagebox then ;

Nostack turnkey?
[if]   &forthdir count &appdir place \ to make it compile from every directory
       w32fHelp to NewAppID
       true to RunUnique
       ' main turnkey Help.exe
       s" Help\Res\Help.ICO" s" Help.exe" Prepend<home>\ AddAppIcon
        Require Checksum.f
        s" Help.exe" prepend<home>\ (AddCheckSum)
       1 pause-seconds bye
[else]
       Runhdb
[then]

\ *W <hr>Document : Dexh-HelpMain.htm -- 2008/04/15 -- Camille Doiteau
\ *Z

\s






