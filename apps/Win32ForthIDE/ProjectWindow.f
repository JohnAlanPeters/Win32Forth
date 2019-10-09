\ ProjectWindow.f

\ * *********************** Project Navigator **********************************
\
\ Allows quick navigating between code in a project. When editing files in a large
\ project sometimes remembering where a word was defined can be challenging. You
\ can find yourself opening many files and browsing through them to find the word.
\ Project navigator keeps tracks of various code routines and by double clicking
\ in the navigator tree on the desired word the file is open to the position of
\ the word.
\
\
\ Usage: After starting Navigator click "Track" to build code tree. Note that
\ doing so clears the entire tree. By default library files used by a project are
\ not scanned. This however, can be enabled in the Preferences dialog. Note too
\ that this option is not saved when the IDE is closed.
\
\
\ Sunday, April 27 2008 - 22:25 - Have been noticing some inconsistencies when clicking
\ in the navigator tree to go to a file. Cursor is not always position correctly; you
\ have to click and pause then double-click to open file. This is whether I double-click
\ or right click on an item. Tests indicate it may be timing issues or something.
\ For now I've added a button to goto a position. It seem more consistent than the
\ tree clicking, even though some peculiarities still seem to be lurking around.
\ I will continue to work on it.
\
\ * ****************************************************************************

\ adapted from -scan
CODE -LSCAN      ( addr len long -- addr' len' ) \ Scan for cell "long"  BACKWARDS starting
                \ at addr, the end of the string, back through len cells before addr,
                \ returning addr' and len' of long.
                mov     eax, ebx
                pop     ecx
                jecxz   short @@1
                pop     edi
                std
                repnz   scasd
                cld
                jne     short @@2
                add     ecx, # 1
                add     edi, # 4
@@2:            push    edi
                xor     edi, edi                \ edi is zero
@@1:            mov     ebx, ecx
                next    c;

create abort$ 6 c, 'a' c, 'b' c, 'o' c, 'r' c, 't' c, '"' c,
\ create squote$ 2 c, 's' c, '"' c,
create dotquote$ 2 c, '.' c, '"' c,
create cquote$ 2 c, 'c' c, '"' c,
\ create zquote$ 2 c, 'z' c, '"' c,
create commaquote$ 2 c, ',' c, '"' c,
create zcommaquote$ 3 c, 'z' c, ',' c, '"' c,

Label lblInfo1
Label lblInfo2
TextBox txtFindInTree
\ s" After tracking, select list, type text and press enter for quick find" BInfo: txtFindInTree place
PushButton btnTrack
PushButton btnGoto
s" Press control to toggle single click file open" BInfo: btnGoto place
StatusBar NavigatorBar
String: curfilename
String: currentname
String: lastword$
String: parentclass 	\ parent class or object of method
-1 value markerhandle
0 value TheNavigator
0 value nav-linecount	\ navigator line count

defer OpenSource
defer auto-showfile
false value goto-on-click?

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ the Project Treeview control
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

needs ProjectTree.f
needs joinstr.f

:object ManagerWindow  <Super ProjectTreeViewControl

:M ExWindowStyle: ( -- )
        WS_EX_CLIENTEDGE ;M

:M Handle_Notify: ( h m w l -- f )
\ Handle the notification messages of the treeview control.
\         dup GetNotifyCode NM_DBLCLK =
\         if  IDM_EXECUTEFILE_PRJ DoCommand false
\         else Handle_Notify: super
\         then ;M
        Handle_Notify: super
        ;M

;object

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Tree Item object \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class Codeitem                 <Super Object

record: iteminfo
   max-path bytes itemname
              int parenttree        \ parent treeview control
              int parentitem        \ parent item in treeview control
              int hwnditem          \ handle for item
              int linenumber
              int markerhandle	    \ scintilla control handle
              int itemid            \ item id
              int #grands
   max-path bytes linetext
   max-path bytes filename
;recordsize: sizeof(iteminfo)

:M classinit:   ( -- )
                classinit: Super
                iteminfo sizeof(iteminfo) erase
                -1 to markerhandle ;M

:M setname:     ( addr cnt -- )
                itemname maxstring erase
                maxstring min 0max itemname swap move ;M

:M getname:     ( -- addrz )
                itemname ;M

:M getname$:     ( -- addrz )
                itemname zcount ;M

:M isparentitem: ( n -- )
                to parentitem ;M

:M parentitem:  ( -- n )
                parentitem ;M

:M isparenttree: ( n -- )
                to parenttree ;M

:M parenttree:  ( -- n )
                parenttree ;M

:M handle:      ( -- hwnd )
                hwnditem ;M

:M ishandle:    ( n -- )
                to hwnditem ;M

:M ItemID:      ( -- f )
                itemid ;M

:M isItemID:      ( f --  )
                to itemid ;M

:M linenumber:    ( -- n )
                linenumber ;M

:M islinenumber:      ( n -- )
                to linenumber ;M

:M linetext:    ( -- addr count )
                linetext count ;M

:M islinetext:      ( addr count--  )
                linetext place ;M

:M filename:    ( -- addr count )
                filename count ;M

:M isfilename:      ( addr count--  )
                filename place ;M

:M markerhandle:    ( -- n )
                markerhandle ;M

:M ismarkerhandle:      ( n -- )
                to markerhandle ;M

:M incr:    	( -- )
                1 +to #grands ;M

:M #grands:      (  -- n )
                #grands ;M

;class

:object NavigatorTree  <Super TreeViewControl

\ 1. Colon Definitions/Code
\ 2. Values/Variables/Constants/Creates/Ints
\ 3. Objects/Classes
\ 4. Privates/Publics (Methods, Colon Definitions)

0 value  hwndmain    \ handle of root item in tree

\ pointers to dynamic parent list
0 value  MainList
0 value  CodeList
0 value  GlobalDataList
0 value  PrivateDataList
0 value  ClassesList
0 value  MethodsList
0 value  PrivateCodeList
0 Value ActiveList

false value in-class?
false value in-definition?
false value in-enum?
0 value code-id
0 value ThisItem
0 value ThisGrandChild
0 value CurrentChild
0 value SelectedItem
256 constant _grand-id
0 value hash-table 			\ points to table of hash values
0 value hash-table-mirror		\ points to table of child items
128 1024 * cell+ ( length cell ) constant hash-table-size	\ ( 128k )
hash-table-size cell / 1- constant max-hash-items ( 32k )
hash-table-size Pointer GrandChildList	\ instance items to be disposed
int hwndimage

enum:
	_colon _code _value _variable _constant _method
	_class _object _create _int _bytes _short
	_dint  _byte _2value _fvariable _fconstant _fvalue
	_defer _setcommand _user _string _record
	;

\ enumerate parent ids
-32 to enum-value
enum:
0 _main_
_code_
_pdata_ \ private data list
_gdata_  \ global data list
_classes_
_Methods_
_pcodelist_
;

create treename ," Code Tracker" 33 allot
create default-treename ," Code Tracker"

:M CodeList:    ( -- list )
                CodeList ;M

:M PrivateDataList:   ( -- list )
                PrivateDataList ;M

:M PrivateCodeList:   ( -- list )
                PrivateCodeList ;M

:M GlobalDataList:  ( -- list )
		GlobalDataList ;M

:M ClassesList:     ( -- list )
                ClassesList ;M

:M MethodsList:    ( -- list )
                MethodsList ;M

:M MainList:     ( -- list )
                MainList ;M

: AddChildItem  ( -- )
                tvins  /tvins  erase
                0                           to cChildren
                Handle: ThisList            to hParent
                TVI_LAST                    to hInsertAfter
                2                 	    to iImage
                2                           to iSelectedImage
                GetName: ThisItem  	    to pszText
                ThisItem                    to lparam
                [ TVIF_TEXT TVIF_CHILDREN or TVIF_PARAM or TVIF_IMAGE or TVIF_SELECTEDIMAGE or ] literal to mask
                InsertItem: Self IsHandle: ThisItem ;

: add-to-hash-table	{ item str cnt -- }
		hash-table @ max-hash-items >= abort" Hash buffer full!"
		new$ >r
		str cnt 2dup bl scan nip - \ remove appended parent name if necessary
		r@ place
		r@ count lower		\ case insensitive
		r> count method-hash
		hash-table lcount cells+ !
		hash-table incr		\ bump count
		item hash-table-mirror lcount cells+ !
		hash-table-mirror incr ;

: UpdateList    ( f -- )
                ThisList 		IsParentItem: ThisItem
                Self 			IsParentTree: ThisItem
                currentname count 	     SetName: ThisItem
                code-id 		    isItemID: ThisItem
                source 			  islinetext: ThisItem
                nav-linecount      	islinenumber: ThisItem
                markerhandle 	      ismarkerhandle: ThisItem
                curfilename count 	  isfilename: ThisItem
                AddChildItem
                ThisItem currentname count add-to-hash-table
                ;

:M AddItem:     ( parentlist -- )
                to ThisList
                Data@: ThisList
                if      AddLink: ThisList
                then    New> CodeItem dup Data!: ThisList to ThisItem
                UpdateList ;M

:M AddCode:     ( -- ) \ global definitions
                CodeList AddItem: Self ;M

:M AddPrivateCode:     ( -- )
                PrivateCodeList AddItem: Self ;M

:M AddPrivateData:    ( -- )
                PrivateDataList AddItem: Self ;M

:M AddGlobalData:    ( -- )
                GlobalDataList AddItem: Self ;M

:M AddMethod:   ( -- )
                MethodsList AddItem: Self ;M

:M AddClass:    ( -- )
                ClassesList AddItem: Self ;M

:M WindowStyle: ( -- style )
                WindowStyle: Super
                WS_BORDER invert and \ remove WS_BORDER style
                WS_CLIPCHILDREN or
                [ TVS_HASLINES TVS_HASBUTTONS or TVS_DISABLEDRAGDROP or TVS_SHOWSELALWAYS or TVS_LINESATROOT or ] LITERAL or
                ;M

: AddParentItem ( lparam hAfter hParent nChildren -- hwnd )
                tvins  /tvins  erase
                ( nChildren)      to cChildren
                ( hParent)        to hParent
                ( hAfter)         to hInsertAfter
                ( lparam)         to lparam
                getname: lparam   to pszText
                0                 to iImage
                1                 to iSelectedImage
[ TVIF_TEXT TVIF_CHILDREN or TVIF_PARAM or TVIF_STATE or TVIF_IMAGE or TVIF_SELECTEDIMAGE or ] LITERAL to mask
		TVIS_BOLD dup to state to statemask
                InsertItem: Self ;

: AddParentLists   ( -- )
                MainList    	TVI_LAST  TVI_ROOT   1  AddParentItem dup to hwndmain isHandle: MainList
                ClassesList     TVI_LAST  hwndmain   1  AddParentItem isHandle: ClassesList
                MethodsList    	TVI_LAST  hwndmain   1  AddParentItem isHandle: MethodsList
                PrivateCodeList TVI_LAST  hwndmain   1  AddParentItem isHandle: PrivateCodeList
                PrivateDataList TVI_LAST  hwndmain   1  AddParentItem isHandle: PrivateDataList
                CodeList  	TVI_LAST  hwndmain   1  AddParentItem isHandle: CodeList
                GlobalDataList  TVI_LAST  hwndmain   1  AddParentItem isHandle: GlobalDataList
                ;

: HaveChildren  ( -- )	\ show the "+" next to item
                tvins  /tvins  erase
                1 to cChildren
                Handle: CurrentChild to hitem
                TVIF_CHILDREN  to mask
                SetItem: Self ;

: AddGrandChildItem  ( -- )
                HaveChildren
                tvins  /tvins  erase
                0                           to cChildren
                Handle: CurrentChild        to hParent
                TVI_LAST                    to hInsertAfter
                2                 	    to iImage
                2                           to iSelectedImage
                GetName: ThisGrandChild	    to pszText
                ThisGrandChild              to lparam
 [ TVIF_TEXT TVIF_CHILDREN or TVIF_PARAM or TVIF_IMAGE or TVIF_SELECTEDIMAGE or ] LITERAL to mask
                InsertItem: Self IsHandle: ThisGrandChild
                Incr: CurrentChild 	\ bump child count
                ;

: UpdateGrandInfo    ( -- )
                CurrentChild 		IsParentItem: ThisGrandChild
                Self 			IsParentTree: ThisGrandChild
                currentname count 	     SetName: ThisGrandChild
                code-id 		    isItemID: ThisGrandChild
                source 			  islinetext: ThisGrandChild
                nav-linecount      	islinenumber: ThisGrandChild
                markerhandle 	      ismarkerhandle: ThisGrandChild
                curfilename count 	  isfilename: ThisGrandChild
                AddGrandChildItem ;

: AddNewGrandChild	( -- )
		GrandChildList @ max-hash-items >= abort" Sorry, too many references!"
		New> CodeItem dup to ThisGrandChild
		GrandChildList lcount cells+ !
		GrandChildList incr ;

: DisposeGrandChildren	( -- )	\ this takes a little while if there are a lot of grans
		GrandChildList lcount cells bounds
		?do	i @ Dispose
	   cell +loop	GrandChildList off ;

: add-grandchild ( -- )
		_grand-id to code-id
		in-definition? not
		if	itemid: CurrentChild _class =
			if	bl word count ?dup	\ likely it's an instance if a name follows
				if	currentname place
				else	drop
				then
			then
		then
		AddNewGrandChild
		UpdateGrandInfo	;

: init-hash-tables	( -- )
		hash-table-size malloc to hash-table
		hash-table off
		hash-table-size malloc to hash-table-mirror
		hash-table-mirror off ;

:M UnInit: ( -- )
          hash-table ?dup
          if	release 0 to hash-table
          then	hash-table-mirror ?dup
          if	release 0 to hash-table-mirror
          then	;M

: search-hash-table	{ hash-val -- addr flag }
		hash-table lcount dup>r 1- 0max cells+ r> hash-val -lscan
		;

: searchLists	{ str cnt -- }
		str cnt method-hash search-hash-table
		if	hash-table cell+ - 		\ calculate offset
			hash-table-mirror cell+ + @ to CurrentChild
			add-grandchild
		else	drop
		then	;

:M Find:          { addr cnt \  list-item -- } \ searches children for text beginning with addr cnt, scroll child into view if found
                       ActiveList 0= ?exitm      \ no parent selected
                       #items: ActiveList 1+ 1
                       ?do      i >Link#: ActiveList
                                   Data@: ActiveList to list-item
                                   getname: list-item cnt addr cnt caps-compare 0=        \ item begins with addr cnt?
                                   \ note that because the lists are sorted the first entry may not necessarily be the one found
                                   if   handle: list-item TVGN_FIRSTVISIBLE SelectItem: Self leave
                                   then
                        loop    ;M

:M SortParentLists:   ( -- )
\ Sort the content of the lists
                handle: GlobalDataList 	SortChildren: Self
                handle: PrivateDataList SortChildren: Self
                handle: MethodsList   	SortChildren: Self
                handle: ClassesList    	SortChildren: Self
                handle: Codelist    	SortChildren: Self
                handle: PrivateCodeList SortChildren: Self
                ;M

:M Classinit:   ( -- )
                Classinit: Super
                0 to SelectedItem
                ;M

\ Thursday, November 06 2008 - Lists being disposed but not their pointers. Fixed

: DisposeThisList  ( list -- )
		   dup DisposeList 	\ dispose the list
		   Dispose ;		\ then the object

: DisposeLists ( -- )
          MainList 0= ?exit
          CodeList   		DisposeThisList 0 to CodeList
          PrivateCodeList   	DisposeThisList 0 to PrivateCodeList
          GlobalDataList 	DisposeThisList 0 to GlobalDataList
          PrivateDataList 	DisposeThisList 0 to PrivateDataList
          MethodsList   	DisposeThisList 0 to MethodsList
          ClassesList    	DisposeThisList 0 to ClassesList
          Mainlist    		DisposeThisList 0 to Mainlist
          DisposeGrandChildren
          ;

:M setname:    ( addr cnt -- )
		treename place ;M

: CreateTree ( -- )
              _main_		treename count          new> treelinked-list to MainList
              _code_		s" Global Definitions"	new> treelinked-list to CodeList
              _pcodelist_	s" Private Definitions"	new> treelinked-list to PrivateCodeList
              _gdata_ 		s" Global Data"         new> treelinked-list to GlobalDataList
              _pdata_ 		s" Private Data"        new> treelinked-list to PrivateDataList
              _Methods_		s" Methods"             new> treelinked-list to MethodsList
              _classes_		s" Objects & Classes"   new> treelinked-list to ClassesList
              ;

: CreateImageList ( -- )    \ create image list for treeview control
            8               \ maximum images
            7               \ number of images to use
            ILC_COLOR4      \ color depth
            18 16           \ bitmap size height,width
            Call ImageList_Create to hwndimage ;

: AddImages { \ ptreebmp -- }
            hwndimage 0= ?exit    \ we don't have any
            ImageList usebitmap   \ create bitmap handle
            GetDc: self dup>r CreateDIBitmap to ptreebmp
            r> ReleaseDc: self
            ptreebmp              \ was it successful?
            if      NULL          \ no overlay image list
                    ptreebmp
                    hwndimage
                    Call ImageList_Add -1 = s" Add images failed!" ?messagebox
                    ptreebmp Call DeleteObject drop \ discard, windows has a copy
            then    ;

: RegisterList ( -- )   \ register imagelist with this treeview control
        hwndimage ?dup 0= ?exit
        TVSIL_NORMAL SetImageList: self ;

:M Start:   ( parent -- )
            Start: Super
            CreateImageList
            AddImages
            RegisterList
            CreateTree
            AddParentLists
            ;M

:M Close: ( -- )
        DisposeLists
        hwndimage ?dup
        if      Call ImageList_Destroy drop
                0 to hwndimage
        then
        Close: Super
        ;M

: ID$	( -- addr cnt )
	ItemID: SelectedItem
	case
		_colon		of	s" Colon definition"	endof
		_code		of	s" Code definition"	endof
		_value		of	s" Value"		endof
		_variable	of	s" Variable"		endof
		_constant	of	s" Constant"		endof
		_method		of	s" Method"		endof
		_class		of	s" Class"		endof
		_object		of	s" Object"		endof
		_create		of	s" Create"		endof
		_int		of	s" Int"			endof
		_bytes		of	s" Bytes"		endof
		_short		of	s" Short"		endof
		_dint		of	s" Dint"		endof
		_byte		of	s" Byte"		endof
		_2value		of	s" Double value"	endof
		_fvariable	of	s" Float variable"	endof
		_fvalue		of	s" Float value"		endof
		_fconstant	of	s" Float constant"	endof
		_user		of	s" User variable"	endof
		_defer		of	s" Deferred word"	endof
		_setcommand	of	s" DoCommand vector"	endof
		_string		of	s" String variable"	endof
		_record		of	s" Record structure"	endof
		_grand-id	of	s" References " new$ dup>r place
					GetName$: [ ParentItem: SelectedItem ]
					r@ +place
					r> count
								endof
		s" " rot
	endcase	s" Type: " pad place
	pad +place
	#grands: SelectedItem ?dup
	if	s"  with " pad +place
		dup>r (.) pad +place
		s"  reference" pad +place
		r> 1 >
		if	s" s" pad +place
		then
	then	pad count ;

:M On_SelChanged: ( -- f )
        lparamNew to SelectedItem
        ItemID: SelectedItem 0>		\ filename selected
        if	join$(	s" File: "
			Filename: SelectedItem "to-pathend"
			s" , Line#: "
			LineNumber: SelectedItem (.)
		)join$	count SetText: lblInfo1
		ID$ SetText: lblInFo2
		auto-showfile
        else	ItemID: SelectedItem 0<	\ category selected
		if	SelectedItem to ActiveList
                        #items: SelectedItem (.) pad place
			s"  entries" pad +place
			pad count
		else	0 to ActiveList
                        s" "	\ root item
		then	SetText: lblInfo1 s" " SetText: lblInfo2
        then	false
        ;M

:M SelectedItem: (  -- n )  SelectedItem ;M

:M Clear:       ( -- )
        TVI_ROOT DeleteItem: Self drop
\        GrandChildList off
        DisposeLists
        CreateTree
        AddParentLists
        parentclass off
        default-treename count treename place
        init-hash-tables
        ;M

: not-in-class	( -- )
		false to in-class?
		parentclass off ;

: +parent-class	( -- )
		s"  (" currentname +place
		parentclass count currentname +place
		s" )" currentname +place ;

: data-add	( -- )
		in-class?
		if	+parent-class
			AddPrivateData: Self
		else	AddGlobalData: Self
		then	;

: add-code	{ cid -- }
		in-definition? ?exit \ should not happen!
		bl word dup c@ 0= if drop exit then  \ forget it!
		count currentname place
		cid to code-id
		true to in-definition?
		in-class?
		if	+parent-class
			AddPrivateCode: Self
		else	AddCode: Self
		then	;

: add-data	{ cid -- }
		in-definition? ?exit
		bl word dup c@ 0= if drop exit then  \ forget it!
		count currentname place
		cid to code-id
		data-add ;

: add-class	{ cid -- }
		in-definition? ?exit
		in-class? ?exit
		bl word dup c@ 0= if drop exit then  \ forget it!
		count currentname place
		currentname count parentclass place
		cid to code-id
		true to in-class?
		AddClass: Self ;

: add-method	( -- )
		in-definition? ?exit
		in-class? not ?exit
		bl word dup c@ 0= if drop exit then  \ forget it!
		count currentname place
		+parent-class
		_method to code-id
		true to in-definition?
		AddMethod: Self ;

: add-defer	( -- )
\ is may be found in s" strings, typically found only in definitions.
\ But ['] <name> is <deferred word> wouldn't be found either!
\		in-definition? ?exit
		bl word dup c@ 0= if drop exit then  \ forget it!
		count currentname place
		_defer to code-id
		in-class?
		if	+parent-class
			AddPrivateCode: Self
		else	AddCode: Self
		then	;

: ?add-word ( a -- )
	comment? if drop exit then
        Case
            s" :"       	"of  _colon add-code   		EndOf
            s" code"   		"of  _code add-code  		EndOf
            s" ;"       	"of false to in-definition?
				    false to in-enum?		EndOf
            s" ;code"		"of false to in-definition?	EndOf
            s" c;"		"of false to in-definition?	EndOf
            s" :class"    	"of _class add-class		EndOf
\ these next are for when navigating W32F source files
            s" |class"		"of _class add-class		EndOF
            s" |:"		"of _colon add-code		EndOF
            s" :object"    	"of _object add-class		EndOf
            s" ;class"    	"of not-in-class		EndOf
            s" ;object"    	"of not-in-class		EndOf
            s" :m"      	"of add-method 			EndOf
            s" defer"		"of add-defer			EndOf
            s" ;m"    		"of false to in-definition?  	EndOf
            s" value"   	"of _value add-data  		EndOf
            s" variable"    	"of _variable add-data  	EndOf
            s" constant"    	"of _constant add-data  	EndOf
            s" create"      	"of _create add-data    	EndOf
            s" string:"		"of _string add-data		EndOF
            s" 2value"		"of _2value add-data		EndOf
            s" fvalue"   	"of _fvalue add-data  		EndOf
            s" fvariable"    	"of _fvariable add-data  	EndOf
            s" fconstant"    	"of _fconstant add-data  	EndOf
            s" newuser"		"of _user add-data		EndOf
            s" int"    		"of in-class?
				    if _int add-data    then	EndOf
            s" bytes"  		"of in-class?
                                    if _bytes add-data  then	EndOf
            s" short"   	"of in-class?
                                    if _short add-data	then	EndOf
            s" byte"		"of in-class?
				    if _byte add-data	then	EndOf
            s" dint"		"of in-class?
				    if _dint add-data	then	EndOf
	    s" record:"		"of in-class?
				    if _record add-data then	EndOF
            s" enum:"		"of in-definition? not
				    to in-enum?		        EndOf
            s" setcommand"	"of lastword$ uppercase count
				    currentname place  		\ uppercase any vector tables
				    _setcommand to code-id
				    data-add			EndOF
	    s" :noname"		"of true to in-definition?	EndOf
	    abort$ count	"of skip-"			EndOf
	    squote count	"of skip-"			EndOf
	    dotquote$ count	"of skip-"			EndOf
	    cquote$ count	"of skip-"			EndOF
	    zquote count	"of skip-"			EndOF
	    commaquote$ count	"of skip-"			EndOF
	    zcommaquote$ count	"of skip-"			EndOf
	    s" {"		"of '}' parse 2drop		EndOF	\ ignore locals
            in-enum? if 	count pad place 	\ uppercase enumerated constants
				pad uppercase count currentname place
				_constant to code-id
				data-add
				false
		     then       dup
		     if		count 2dup lastword$ place	\ save word
				searchLists
				false
		     then

        EndCase
        ;

:M AddWord:	( addr -- )	\ for when building a project
		?add-word ;M

\    // --    -1   \S
\    (         1    )
\    ((        2   ))
\    /*        4   */
\    (*        8   *)
\    comment:  16  comment;
\    DOC       32  ENDDOC

\ : +Comment ( n -- )   comment? IF  drop  ELSE  comment? or to comment?  THEN ;
\ : -Comment ( n -- )   invert comment? and to comment? ;
\ : \Comment ( -- )   comment? 0= IF  source nip >in !  THEN ;   \ ignore till end of line

: build-NavigatorTree ( -- )
        bl word dup count lower dup c@
        IF
            Case
                s" \"               "of  \comment           EndOf
                s" //"              "of  \comment           EndOf
                s" --"              "of  \comment           EndOf
                s" .("		    "of  ')' parse 2drop    EndOF
                s" \s"              "of  -1 +Comment        EndOf
                s" ("               "of  1  +Comment        EndOf
                s" )"               "of  1  -Comment        EndOf
                s" (("              "of  2  +Comment        EndOf
                s" ))"              "of  2  -Comment        EndOf
                s" /*"              "of  4  +Comment        EndOf
                s" */"              "of  4  -Comment        EndOf
                s" (*"              "of  8  +Comment        EndOf
                s" *)"              "of  8  -Comment        EndOf
                s" comment:"        "of  16 +Comment        EndOf
                s" comment;"        "of  16 -Comment        EndOf
                s" doc"             "of  32 +Comment	    EndOf
                s" enddoc"          "of  32 -Comment	    EndOf
                ( default ) ?add-word
                false
            EndCase
        ELSE	drop
        THEN ;

: .trackmessage	( fname cnt -- )
		join$(	s" Tracking "
			curfilename count "to-pathend"
			s" ..."
		)join$	count SetText: lblInfo1 ;

:M TrackCode: 	( fname cnt -- )
                curfilename place
                curfilename c@ 0= ?exitm
                .trackmessage
                false to comment?
                0 to nav-linecount
                curfilename count "open
                if   drop exitm
                then source-ID >r to source-ID
                >in @ >r
                source 2>r                     \ save current source
                new$ (source) cell+ !
                refill
                if      1 +to nav-linecount
                then
                begin   more? dup 0=
                        if      drop refill dup
                                if       1 +to nav-linecount     \ bump line count
                                then
                        then
                while	build-NavigatorTree
                repeat  source-id close-file drop
                2r> (source) 2!
                r> >in !
                r> to source-id
                SortParentLists: Self
                0 to selecteditem
                0 to ActiveList
                s" " SetText: lblInfo1
		;M

;object

: FindInTree    ( addr cnt -- )
                        Find: NavigatorTree ;

: FITWmChar      ( h m w l obj -- res )
                2 pick VK_RETURN  =
                if      GetText: [  ]  ?dup  \ get adr,len of edit control text
                        if      FindInTree
                        else    drop
                        then    false           \ we already processed this message
                else    drop            \ discard object
                            true            \ and use default processing
                then    ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Top window pane \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object NavigatorWindow   <Super Child-Window

ColorObject FrmColor      \ the background color

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super
        WS_EX_CLIENTEDGE or ;M

:M On_Paint: ( -- )
        0 0 Width Height FrmColor FillArea: dc
        ;M

:M On_Init:     ( -- )
		\ prevent flicker in window on sizing
		CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor

		self Start: NavigatorTree
		NavigatorTree to TheNavigator

		self Start: btnTrack
		s" Track" SetText: btnTrack
		Handle: TabFont SetFont: btnTrack


		self Start: btnGoto
		s" Goto" SetText: btnGoto
		Handle: TabFont SetFont: btnGoto

		self Start: lblInfo1
		Handle: TabFont SetFont: lblInfo1

		self Start: lblInfo2
		Handle: TabFont SetFont: lblInfo2

		WS_BORDER AddStyle: txtFindInTree
		Self Start: txtFindIntree
		Handle: TabFont SetFont: txtFindInTree
		s" Quick find" SetText: txtFindInTree
		['] FITWmChar SetWmChar: txtFindInTree

                ;M

:m On_Size:	( -- )

		0 25 Width Height 75 - Move: NavigatorTree

		0 0 60 20   Move: btnTrack
		62 0 60 20 Move: btnGoto

		124 0 200 20 Move: txtFindInTree

		0 Height 50 - Width 24 Move: lblInfo1
		0 Height 25 - Width 24 Move: lblInfo2
		;M

: ShowFile	{ \ item -- }
		SelectedItem: NavigatorTree dup to item 0= ?exit \ should not be
		ItemID: item 0 <= ?exit   \ listname
		FileName: item OpenSource
		LineNumber: item 1- GotoLine: CurrentWindow
		SetFocus: CurrentWindow ;

:M ShowFile:	( -- )
		ShowFile ;M

:M WM_NOTIFY	( h m w l -- f )
		dup GetNotifyWnd GetHandle: NavigatorTree <> if false exitm then
		Handle_Notify: NavigatorTree
		goto-on-click? CurrentWindow 0<> and
		if	Setfocus: CurrentWindow
		then	;M

:M Close:        ( -- )
                Close: NavigatorTree
                Close: super
                ;M

;Object

: LibFile? ( a n - f )
	   pad place pad count "path-only"  dup 7 - /string  s" src\lib"  istr= ;


: Track-Project-Files	{ \ ilist item -- }
		ProjectName: TheProject SetName: NavigatorTree
		Clear: NavigatorTree
		ModuleList: TheProject to ilist
		#items: ilist 1+ 1
		?do	i >Link#: ilist Data@: ilist to item
			GetName$: item 2dup LibFile? not include-libs? or
			if	TrackCode: NavigatorTree
			else	2drop
			then
		loop	Handle: [ MainList: NavigatorTree ] ExpandItem: NavigatorTree
		UnInit: NavigatorTree ; \ IDM_BUILD_CODE_TREE SetCommand

: Track-Opened-Files	{ \ ThisFile -- }
                s" Opened Files" SetName: NavigatorTree
		Clear: NavigatorTree
		GetTabCount: OpenFilesTab 1+ 0
                do      i GetFileTabChild dup to ThisFile
                        if	GetFileType: ThisFile FT_SOURCE =
				if	GetFileName: ThisFile count TrackCode: NavigatorTree
				then
			then
		loop	UnInit: NavigatorTree ;

: BuildNavigatorTree { \ open? -- }
		GetTabCount: OpenFilesTab 0> to open?
		Clear: NavigatorTree
		s" " SetText: lblInfo2	\ clear this one
		control-key? open? and	\ force tracking of opened files if control key pressed
		if	Track-Opened-Files exit
		then	GetBuildFile: TheProject nip
		if	Track-Project-Files
		else	open?
			if	Track-Opened-Files
			then
		then	; ' BuildNavigatorTree SetFunc: btnTrack

: ShowFile	( -- )
		control-key?
		if	goto-on-click? 0= dup to goto-on-click?	\ toggle function
			if	s" Auto Goto"
			else	s" Goto"
			then	SetText: btnGoto
		then	ShowFile: NavigatorWindow ;  ' ShowFile SetFunc: btnGoto

: (auto-showfile) ( -- )
		goto-on-click?
		if	ShowFile
		then	; ' (auto-showfile) is auto-showfile

:Object ProjectWindow   <Super Child-Window

TabControl ProjectTab

:M WndClassStyle:       ( -- style )
\ Set the style member of the the WNDCLASS structure.
        CS_DBLCLKS ;M

:M ReSize:	( -- )
\ Resize the controls within the main window.
        AutoSize: ProjectTab

        ClientSize: ProjectTab 2over d- ( x y w h )
        4dup Move: ManagerWindow
	     Move: NavigatorWindow
        ;M

:M On_Size:	( -- )
\ Handle the WM_SIZE message.
        ReSize: self Paint: ProjectTab ;M

: ShowManager     ( -- )
        SW_SHOW Show: ManagerWindow   \ show before hide
        SW_HIDE Show: NavigatorWindow
        ;

: ShowNavigator   ( -- )
        SW_SHOW Show: NavigatorWindow
        SW_HIDE Show: ManagerWindow
        ;

:M SelChange:	( -- )
\ Show the control for the currently selected tab.
	GetSelectedTab: ProjectTab
        case    0 	of ShowManager    endof
                1    	of ShowNavigator     endof
        endcase ;M
\
: selchange-func  { lParam obj \ Parent -- false }
\ This function is executed when the currently selected tab has changed.
\ lParam is the address of the Address of an NMHDR structure.
\ obj is the address of the TabControl object that has sent the
\ notification message.
	GetParent: obj to Parent
	SelChange: Parent
	false ;

:M ShowTab:	( n -- )
\ show tab n
	SetSelectedTab: ProjectTab
	SelChange: self ;M

:M On_Init:     ( -- )
		self Start: ManagerWindow
		self Start: NavigatorWindow

		TCS_FLATBUTTONS AddStyle: ProjectTab
		self Start: ProjectTab
		Handle: TabFont SetFont: ProjectTab

		['] selchange-func IsChangeFunc: ProjectTab

		TCIF_TEXT IsMask: ProjectTab
		z" Manager" IsPszText: ProjectTab
		1 InsertTab: ProjectTab

		TCIF_TEXT IsMask: ProjectTab
		z" Navigator" IsPszText: ProjectTab
		2 InsertTab: ProjectTab

		SelChange: self \ show the control for the currently selected tab

		;M

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super
        WS_EX_CLIENTEDGE or ;M

:M On_Paint: ( -- )
        0 0 Width Height white FillArea: dc
        ;M

:M WM_NOTIFY    ( h m w l -- f )
\ Handle the notification messages of the controls.
        dup GetNotifyWnd GetHandle: ManagerWindow =
        if   Handle_Notify: ManagerWindow
        else	dup GetNotifyWnd GetHandle: ProjectTab =
		if	Handle_Notify: ProjectTab
		else	false
		then
	then	;M

:M Close:	( -- )
		Close: ManagerWindow
		Close: NavigatorWindow
		Close: Super
		;M

;Object

\s
