\    File: ClassBrowser.f
\  Author: Dirk Busch
\ Created: Samstag, Mai 22 2004 - dbu
\ Updated: Samstag, Mai 29 2004 - 10:58 - dbu
\ Updated: Friday, June 09 2006 - gah
\ Updated: Friday, July 18 2008 - to use Statusbar class and not Console_MultiStatusbar - rod

\ Win32Forth class and vocabulary browser

ANEW -ClassBrowser.f

Needs Statusbar.f
needs TreeView.f \ TreeView class by Michael Hillerström
needs RegistryWindowPos.f

INTERNAL

false value Browser?

\ ------------------------------------------------------------------------------
\ the treeview control for browsing the classes and vocabularies
\ ------------------------------------------------------------------------------

:Class ClassBrowserWindow <super TreeViewControl

:M WindowStyle: ( -- style )      \ set the windowstyle for the treeview
                WindowStyle: super
                [ TVS_HASBUTTONS TVS_HASLINES or TVS_DISABLEDRAGDROP or TVS_SHOWSELALWAYS or TVS_LINESATROOT or ] literal
                or ;M

int hRoot
int hSon
int hPrev

: AddItem       ( xt sztext hAfter hParent nChildren fChildren -- ) \ add an entry to the treeview
                tvins  /tvins  erase
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

create NameBuf$ MAXSTRING 1+ allot

\ The following definitions enable us to find the name of an object defined with :OBJECT
\ from the xt of it's nameless class; gah

0 value SearchClass

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
                -1 z" Vocabularies" TVI_LAST TVI_ROOT 1 true AddItem

                hPrev to hRoot
                -1 z" Application space" hPrev hRoot 1 true AddItem hPrev
                -1 z" System space"      hPrev hRoot 1 true AddItem hPrev

                to hRoot ['] sys-addr? AddVoc
                to hRoot ['] app-addr? AddVoc ;


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

: AddMethods    ( class-pfa -- )  \ add methods of a class
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

: (AddClass)    ( class-pfa -- )  \ add class to the treview
                dup BODY> hPrev hRoot true AddName \ add name
                hPrev dup to hRoot to hSon AddMethods ; \ add methods

: AddClass      ( class-cfa -- )  \ add class and super-classes to the treview
                >body \ class-pfa
                dup (AddClass) \ add this class
                begin  SFA @ dup ['] classes >body <> \ get next super-class-pfa
                while  dup (AddClass) \ add super-class
                repeat 2drop ;

: AddClasses    (  -- )           \ add the classes to the treeview
                -1 z" Classes" TVI_LAST TVI_ROOT 1 true AddItem
                hPrev >R

                voc-link @
                begin dup vlink>voc
                      dup voc>vcfa
                      ?isclass
                      if   dup voc>vcfa r@ to hRoot AddClass
                      else drop
                      then @ dup 0=
                until drop r>drop ;


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

:M Start:       ( Parent -- )     \ create the treeview
                Start: super
                ;M

: Browse        ( xt -- )         \ browse for the given xt
\in-system-ok   get-viewfile
                if $browse
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

:M Update:	( -- )
                AddVocabularies
                AddClasses
		;M
;Class


\ ------------------------------------------------------------------------------
\ the status bar
\ ------------------------------------------------------------------------------
((
:Object ClassBrowserStatusbar  <Super Console_MultiStatusbar

create SingleWidth -1 , \ width of statusbar parts

:M SetSingle:   ( -- )
                SingleWidth 1 SetParts: self
                ;M

:M SetText:	( -- )
                z" Use CTRL+Click to open the source for a definition in the Editor." 0 SetText: super
		;M

:M Create:      ( hParent -- )
                Create: super
                SetSingle: self
		SetText: self
                Show: self
                ;M

:M Height:      ( -- n )
                GetWindowRect: self drop nip - ;M

;Object
))

Statusbar ClassBrowserStatusbar


\ ------------------------------------------------------------------------------
\ the main window
\ ------------------------------------------------------------------------------

:Object ClassBrowser  <super Window

int TreeView
create RegPath$ ," ClassBrowser\"

:M On_Init:     ( -- )
                On_Init: super

                New> ClassBrowserWindow to TreeView
                1001 SetId: TreeView
                self Start: TreeView
                self start: ClassBrowserStatusbar
                z" Use CTRL+Click to open the source for a definition in the Editor." SetText: ClassBrowserStatusbar
                true to Browser?
                ;M

:M On_Done:     ( -- )
                hWnd RegPath$ SaveWindowPos
                On_Done: super
		false to Browser?
                ;M

:M WindowTitle: ( -- sztitle )
                z" Win32Forth - Class and vocabulary browser" ;M

:M StartSize:   ( -- w h )
                RegPath$ LoadWindowPos 2nip
                ;M

:M StartPos:    ( -- x y )
                RegPath$ LoadWindowPos 2drop
                ;M

: AdjustWindowSize      { width height win -- }
                SWP_SHOWWINDOW SWP_NOZORDER or SWP_NOMOVE or
                height width
                0 0     \ ignore position
                0       \ ignore z-order
                win Call SetWindowPos drop ;

:M On_Size:     ( -- )

		\ adjust the TreeView
                winRect GetClientRect: self
                Left: winRect Top: winRect Right: winRect
                Bottom: winRect Height: ClassBrowserStatusbar -
                Move: TreeView

		\ and the the Statusbar
                Redraw: ClassBrowserStatusbar ;M

:M WM_NOTIFY    ( h m w l -- f )
                dup  @ GetHandle: TreeView  =
                if   Handle_Notify: TreeView
                else false
                then ;M

:M Update:      ( -- )
                IDC_WAIT NULL call LoadCursor call SetCursor \ set wait cursor
                Update: TreeView      \ fill treeview
                call SetCursor drop   \ restore cursor
                ;M
;Object

EXTERNAL

:noname  	( -- )
                Browser?
                if   SetForegroundWindow: ClassBrowser
                     SW_SHOW Show: ClassBrowser
                else Start: ClassBrowser
                     Update: ClassBrowser
                then ; is class-browser

MODULE

cr .( 'Class and vocabulary browser' loaded )

class-browser

