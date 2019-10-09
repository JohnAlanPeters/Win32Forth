\ EdPreferences.f

needs EdPreferences.frm

:Class ColorWindow        <Super Child-Window
colorobject thecolor

:M WindowStyle:           ( -- style )
                          WindowStyle: super
                          WS_BORDER or WS_VISIBLE or ;M

:M paint:                 ( colorref -- )
                          newcolor: thecolor
                          paint: super ;M

:M on_paint:              ( -- )
                          0 0 width height thecolor fillarea: dc ;M

;class

colorwindow fore-window
colorwindow back-window
colorwindow current-window
colorwindow selfore-window
colorwindow selback-window
colorwindow browse-forewindow
colorwindow browse-backwindow
colorobject fore
colorobject back
colorobject curr
colorobject selfore
colorobject selback
colorobject browsefore
colorobject browseback
Font Pfont	\ font to actually modify, if not cancelled will copy to editorfont
0 value fore-color-save
0 value back-color-save
0 value caret-backcolor-save
0 value select-forecolor-save
0 value select-backcolor-save
0 value browse-forecolor-save
0 value browse-backcolor-save

: backup-colors		( -- )
			fore-color to fore-color-save
			back-color to back-color-save
			caret-backcolor to caret-backcolor-save
			select-forecolor to select-forecolor-save
			select-backcolor to select-backcolor-save
			browse-forecolor to browse-forecolor-save
			browse-backcolor to browse-backcolor-save ;

: restore-colors	( -- )
			fore-color-save to fore-color
			back-color-save to back-color
			caret-backcolor-save to caret-backcolor
			select-forecolor-save to select-forecolor
			select-backcolor-save to select-backcolor
			browse-forecolor-save to browse-forecolor
			browse-backcolor-save to browse-backcolor ;

: set-colors		( -- )
                        color: fore to fore-color
                        color: back to back-color
                        color: curr to caret-backcolor
                        color: selfore to select-forecolor
                        color: selback to select-backcolor
                        color: browsefore to browse-forecolor
                        color: browseback to browse-backcolor ;

: savecolors            ( -- )
			set-colors
			GetLogFont: PFont GetLogFont: DefaultEditorFont [ LF_FACESIZE 28 + ] LITERAL  cmove
			DefaultEditorFont to EditorFont

			detached? >r		\ save it for a moment
			IsButtonChecked?: chkAutoIndent to autoindent?
			IsButtonChecked?: chkShowTabs to with-tabs?
			IsButtonChecked?: chkIncludeLibs to include-libs?
			IsButtonChecked?: chkAutoProperty to AutoProperty?
			IsButtonChecked?: chkSingleControl to SingleControl?
			IsButtonChecked?: chkDetached to detached?
			IsButtonChecked?: chkAutoDetect to autodetect?
			IsButtonChecked?: chkAutoSession to autosavesession?
			IsButtonChecked?: chkVirtual to virtualspace?
			IsButtonChecked?: chkMultiSelect to multiselections?
			IsButtonChecked?: chkProject to show-projtab?
			IsButtonChecked?: chkFile to show-filetab?
			IsButtonChecked?: chkDirectory to show-dirtab?
			IsButtonChecked?: chkClass to show-classtab?
			IsButtonChecked?: chkVocabulary to show-voctab?
			IsButtonChecked?: chkForm to show-formtab?
			IsButtonChecked?: chkDebug to show-debugtab?

			detached? r> <>	\ if this status changed
			if	IDM_SHOW_FORMTAB DoCommand
			then	Refresh: cTabWindow     \ any tab changes
			Update Resize: MainWindow ;

: DisplayFontName	( -- )
			s" Text Font: " pad place GetFaceName: PFont pad +place
			pad count SetText: btnFont ;

: SetPFont		( -- )
			GetLogFont: DefaultEditorFont GetLogFont: PFont [ LF_FACESIZE 28 + ] LITERAL  cmove
			DisplayFontName
			pFont to EditorFont ;


: frmEditor-func            ( id obj -- )
                          drop
                          case
                              getid: btnforeground    of choose: fore    if color: fore    paint: fore-window    then endof
                              getid: btnbackground    of choose: back    if color: back    paint: back-window    then endof
                              getid: btncurrentline   of choose: curr    if color: curr    paint: current-window then endof
                              getid: btnSelectFore    of choose: selfore if color: selfore paint: selfore-window then endof
                              getid: btnSelectBack    of choose: selback if color: selback paint: selback-window then endof
                              getid: btnBrowseBack    of choose: browseback if color: browseback paint: browse-backwindow then endof
                              getid: btnBrowseFore    of choose: browsefore if color: browsefore paint: browse-forewindow then endof
                              getid: btnPreview       of set-colors Update endof
                              getid: btnFont	      of choose: pfont   if DisplayFontName  Update then endof
                          endcase ;

:Object IDEPreferencesForm            <Super frmPreferenceSheet

:M on_init:               ( -- )
                          On_Init: super

                          SW_HIDE Show: btnApply

			  autoindent? 	        Check: chkAutoIndent
			  with-tabs?  	        Check: chkShowTabs
			  include-libs?         Check: chkIncludeLibs
			  AutoProperty?         Check: chkAutoProperty
			  SingleControl?        Check: chkSingleControl
			  detached?             Check: chkDetached
			  autodetect?           Check: chkAutoDetect
			  autosavesession?      Check: chkAutoSession
			  virtualspace?         Check: chkVirtual
			  multiselections?      Check: chkMultiSelect

			  show-projtab?         Check: chkProject
			  show-filetab?         Check: chkFile
			  show-dirtab?          Check: chkDirectory
			  show-classtab?        Check: chkClass
			  show-voctab?          Check: chkVocabulary
			  show-formtab?         Check: chkForm
			  show-debugtab?        Check: chkDebug

			  SetPFont
			  backup-colors

                          ['] frmEditor-func setcommand: frmEditor

                          fore-color newcolor: fore
                          back-color newcolor: back
                          caret-backcolor newcolor: curr
                          select-forecolor newcolor: selfore
                          select-backcolor newcolor: selback
                          browse-forecolor newcolor: browsefore
                          browse-backcolor newcolor: browseback

                          100 setid: fore-window
                          frmEditor start: fore-window
                          forechildx forechildy forechildw forechildh move: fore-window
                          fore-color paint: fore-window

                          101 setid: back-window
                          frmEditor start: back-window
                          forechildx backchildy backchildw backchildh move: back-window
                          back-color paint: back-window

                          102 setid: current-window
                          frmEditor start: current-window
                          currentchildx currentchildy currentchildw currentchildh move: current-window
                          caret-backcolor paint: current-window

                          103 setid: selfore-window
                          frmEditor start: selfore-window
                          selforechildx selforechildy selforechildw selforechildh move: selfore-window
                          select-forecolor paint: selfore-window

                          104 setid: selback-window
                          frmEditor start: selback-window
                          selbackchildx selbackchildy selbackchildw selbackchildh move: selback-window
                          select-backcolor paint: selback-window

                          105 setid: browse-forewindow
                          frmEditor start: browse-forewindow
                          browseforechildx browseforechildy browseforechildw browseforechildh move: browse-forewindow
                          browse-forecolor paint: browse-forewindow

                          106 setid: browse-backwindow
                          frmEditor start: browse-backwindow
                          browsebackchildx browsebackchildy browsebackchildw browsebackchildh move: browse-backwindow
                          browse-backcolor paint: browse-backwindow

                          ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID )
                case
                        GetID: btnOk            of      savecolors Close: self
                                                endof
                        GetId: btnCancel        of      DefaultEditorFont to EditorFont
                                                        restore-colors Update
                                                        Close: self
                                                endof
                endcase
                0 ;M

:M On_Done:    ( -- )
                On_Done: super
                ;M

;Object

: IDEOptions  ( -- )
              GetHandle: MainWindow SetParentWindow: IDEPreferencesForm
              start: IDEPreferencesForm ;   IDM_PREFERENCES SetCommand

\s

