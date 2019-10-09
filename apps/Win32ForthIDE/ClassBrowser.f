\ $Id: ClassBrowser.f,v 1.11 2010/06/26 16:27:41 jos_ven Exp $

\    File: ClassBrowser.f
\  Author: Dirk Busch
\ Created: Samstag, Mai 22 2004 - dbu
\ Updated: Sonntag, Juli 11 2004 - 9:19 - dbu
\
\ Win32Forth class and vocabulary browser

ANEW -ClassBrowser.f

needs TreeView.f \ TreeView class by Michael Hillerström

INTERNAL
EXTERNAL

cr .( Loading class and vocabulary browser...)

false value Browser?

\ ------------------------------------------------------------------------------
\ the treeview control for browsing the classes and vocabularies
\ ------------------------------------------------------------------------------

:Class ClassBrowserWindow <super TreeViewControl

int VocabulariesAdded?
int ClassesAdded?

:M ClassInit:   ( -- )
                ClassInit: super
                0 to VocabulariesAdded?
                0 to ClassesAdded?
                ;M

:M WindowStyle: ( -- style )
                WindowStyle: super
                WS_BORDER invert and \ remove WS_BORDER style
                [ TVS_HASBUTTONS TVS_HASLINES or TVS_DISABLEDRAGDROP or TVS_SHOWSELALWAYS or TVS_LINESATROOT or ] literal
                or ;M

:M WndClassStyle: ( -- style )
                \ CS_DBLCLKS only to prevent flicker in window on sizing.
                CS_DBLCLKS ;M

int hRoot
int hSon
int hPrev

: AddItem       ( xt sztext hAfter hParent nChildren fChildren -- ) \ add an entry to the treeview
                >r
                ( nChildren)      to cChildren
                ( hParent)        to hParent
                ( hAfter)         to hInsertAfter
                ( sztext)         to pszText
                ( xt)             to lParam
                [ TVIF_TEXT TVIF_PARAM or ] literal
                r> if TVIF_CHILDREN or then
                to mask
                tvins 0 TVM_INSERTITEMA hWnd Call SendMessage
                to hPrev ;

MAXSTRING 1+ bytes NameBuf$

\ The following definitions enable us to find the name of an object defined with :OBJECT
\ from the xt of it's nameless class; gah

int SearchClass

: (objname)     ( nfa -- )
                dup name> dup @ doobj =
                if      >body @ SearchClass =
                        if      s" :OBJECT " NameBuf$ place
                                nfa-count NameBuf$ +place NameBuf$ +null
                                0 to SearchClass
                        else    drop
                        then
                else    2drop
                then    ;


: objname       ( xt -- )
                >body to SearchClass NameBuf$ off
\in-system-ok   ['] (objname) on-allwords ;

: AddName       ( xt hPrev hRoot fChildren -- ) \ show name, if can't find name, [UNKNOWN]
                >r rot DUP >NAME DUP NAME> ['] [UNKNOWN] =     \ if not found
                IF   DROP dup ?IsClass
                     IF   dup objname Namebuf$ count 0=
                          IF drop z" [UNKNOWN]"
                          THEN
                     ELSE z" [UNKNOWN]"
                     THEN
                ELSE COUNT NameBuf$ ascii-z \ make a z-String
                THEN 2swap 1 r> AddItem ;

\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

: ?IsVoc        ( xt -- f )       \ check if cfa point's to a vocabulary
                ?IsClass not ;

: ?IsEmptyVoc   { voc xtSpace \ w#threads -- f } \ check for empty vocabulary
                voc dup voc#threads to w#threads
                dup voc>vcfa
                ?IsVoc \ don't look through classes
                if   here 500 + w#threads cells move     \ copy vocabulary up
                     begin   here 500 + w#threads largest dup
                     while   dup l>name name>
                             xtSpace execute \ in system/app space?
                             if 2drop false exit then
                             @ swap !
                     repeat  2drop
                else drop
                then true ;

: ?IsFilesVoc   ( voc -- f )      \ check if it's the FILES voc
                voc>vcfa >name count s" FILES" compare 0= ;

: ?SkipVoc      { voc xtSpace -- f } \ check if should skip this vocabulary
                voc xtSpace ?IsEmptyVoc not \ skip empty vocabularies
                voc ?IsFilesVoc not and ;  \ skip FILES vocabulary

: AddWords      { voc xtSpace \ w#threads -- } \ add the words in a vocabulary to the treeview
                voc dup voc#threads to w#threads
                dup voc>vcfa
                ?IsVoc \ don't look through classes
                if   here 500 + w#threads cells move     \ copy vocabulary up
                     begin   here 500 + w#threads largest dup
                     while   dup l>name name>
                             dup xtSpace execute \ in system/app space?
                             if hPrev hSon false AddName else drop then
                             @ swap !
                     repeat  2drop
                else drop
                then hSon SortChildren: [ self ] ;

: AddVoc        { xtSpace -- }    \ add vocabularies to the treeview
                voc-link @
                begin   dup vlink>voc
                        dup voc>vcfa
                        ?IsVoc \ don't look through classes
                        if   dup xtSpace ?SkipVoc \ skip vocabulary ?
                             if   dup voc>vcfa hPrev hRoot true AddName
                                  hPrev to hSon xtSpace AddWords
                             else drop
                             then
                        else drop
                        then @ dup 0=
                until   drop
                hRoot SortChildren: [ self ] ;

: app-addr?     ( xt -- f )       \ check if xt is in application space
                sys-addr? not ;

: AddVocabularies ( -- )          \ add the vocabularies to the treeview
                false SetRedraw: self
                tvins  /tvins  erase
                -1 z" Vocabularies" TVI_LAST TVI_ROOT 1 true AddItem

                hPrev to hRoot
                -1 z" Application space" hPrev hRoot 1 true AddItem hPrev
                -1 z" System space"      hPrev hRoot 1 true AddItem hPrev

                to hRoot ['] sys-addr? AddVoc
                to hRoot ['] app-addr? AddVoc

                true SetRedraw: self
                ;


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

: HASH>         ( hash-val -- cfa flag ) \ get cfa from hash-value
                hash-wid dup voc#threads cells+ hash-wid  ( hash-wid end to hash-wid )
                do   i
                     begin @ ?dup
                     while ( hash-val link-field )
                           2dup link> >body @ =
                           if   nip ( discard hash value )
                                l>name name> ( cfa )
                                true unloop exit
                           then
                     repeat
                cell +loop
                drop -1 false ;

: AddMethods    ( class-pfa -- )  \ add methods of a class to the treeview
                { \ superlist -- }
                dup MFA swap
                SFA @ MFA
                #mlists 0 do
                2dup i tuck cells+ @ to superlist cells+
                begin  @ dup  superlist <>
                while  dup cell+ @ HASH> ( cfa )
                       if hPrev hSon false AddName else drop then
                repeat drop
                loop   2drop ;

: (AddClass)    ( class-pfa -- )  \ add class to the treeview
                dup BODY> hPrev hRoot true AddName \ add name
                hPrev dup to hRoot to hSon AddMethods ; \ add methods

: AddClass      ( class-cfa -- )  \ add class and super-classes to the treeview
                >body \ class-pfa
                dup (AddClass) \ add this class
                begin  SFA @ dup ['] classes >body <> \ get next super-class-pfa
                while  dup (AddClass) \ add super-class
                repeat 2drop ;

: AddClasses    (  -- )           \ add the classes to the treeview
                false SetRedraw: self
                tvins  /tvins  erase
                -1 z" Classes" TVI_LAST TVI_ROOT 1 true AddItem
                hPrev >R

                voc-link @
                begin dup vlink>voc
                      dup voc>vcfa
                      ?isclass
                      if   dup voc>vcfa r@ to hRoot AddClass
                      else drop
                      then @ dup 0=
                until drop r>drop

                true SetRedraw: self
                ;


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

:M AddVocabularies:     ( -- )
                VocabulariesAdded? 0=
                if   AddVocabularies
                     true to VocabulariesAdded?
                then ;M

:M AddClasses:  ( -- )
                ClassesAdded? 0=
                if   AddClasses
                     true to ClassesAdded?
                then ;M

: $browse	( line_number file_name len -- )
 		      NewBrowseChild LoadHyperFile: ActiveBrowser
 		      SetBrowseMode: ActiveBrowser Update  ;

: Browse        ( xt -- )         \ browse for the given xt
\in-system-ok   get-viewfile
                if   \ if it's defind in FKERNEL.F than we must
		     \ add the path to the file
		     count 2dup KERNFILE count ISTR=
		     if Prepend<home>\ then

		     $browse
                else 2drop
                then ;

:M On_SelChanged: ( -- f )        \ Browse for the selected word if CTRL-Key is down
                [ also FORTH ] ?control [ previous ]
                if   TVIF_PARAM       to mask
                     hItemNew         to hItem
                     tvitem 0 TVM_GETITEMA  hWnd Call SendMessage drop

                     lParam ( xt) browse
                then false
                ;M

;Class

MODULE


