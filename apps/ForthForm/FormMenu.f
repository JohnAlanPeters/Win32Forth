\ FormMenu.f        Menu Definitions for ForthForm

MenuBar MainMenuBar

Popup "&Form"
         MenuItem "&New\tCtrl+N"         doNew   ;
         MenuItem "&Open\tCtrl+O"       doOpen   ;
         :MenuItem mnu_doform "&Edit properties"       doForm   ;

         :MenuItem mnu_close "Close Active &Form" ActiveForm if ActiveForm doCloseForm then ;

         :MenuItem mnu_closeall "&Close All"          doCloseAllForms ;
         MenuSeparator
         :MenuItem mnu_merge "&Merge open forms"  domerge ;
         MenuSeparator
         :MenuItem mnu_save "&Save"       doSave   ;
         :MenuItem mnu_saveas "Save &As"    doSaveAs ;
         :MenuItem mnu_saveall "Save a&ll modified"  doSaveAll ;
         MenuSeparator
         :MenuItem mnu_compile "Com&pile"  doWrite ;
         :MenuItem mnu_copy "Cop&y to Clipboard" doCopy ;
         :MenuItem mnu_test "&Test"     doTest ;
         MenuSeparator
         MenuItem "E&xit ForthForm\tAlt-F4"        doexit  ;

Popup "&Control"
         :MenuItem mnu_edit "&Edit"       doedit    ;
         :MenuItem mnu_delete "&Delete"     dodelete  ;
         SubMenu "Align"
                :MenuItem mnu_gp "to grid point"  AlignGridXY ;
                :MenuItem mnu_gpv "to grid's vertical plane" AlignGridY ;
                :MenuItem mnu_gph "to grid's horizontal plane" AlignGridX ;
         EndSubmenu
         MenuSeparator
         :MenuItem mnu_size "Size sequential controls" AutoSize  ;
         :MenuItem mnu_arrangev "Arrange sequential controls vertically" ArrangeVertical ;
         :MenuItem mnu_arrangeh "Arrange sequential controls horizontally" ArrangeHorizontal ;
         MenuSeparator
         :MenuItem mnu_changetab "Change Tab Order"  doTabOrder ;
         :Menuitem mnu_changetype "Change type"         ChangeControl ;
         MenuSeparator
         :MenuItem mnu_bringfront "Bring to Front"       doMoveToFront ;
         :MenuItem mnu_moveback "Move to Back"        doMoveToBack ;

Popup "&Tools
         MenuItem "&Create ToolBar"  doCreateToolBar ;
         MenuItem "Splitter &Window Templates" doSplitter ;
         MenuItem "&Define Menu"     doCreateMenu ;
         :MenuItem mnu_psheet "&Property Form Template" doPropertyForm ;
\         MenuSeparator
\         MenuItem "Win32Forth IDE" Start-Win32ForthIDE ;
\         MENUITEM    "Compile &Project\tF12"             FFLoadProject ;

\         MenuItem "Project Manager " Start-ProjectManager ;
         MenuSeparator
         MenuItem "&Save Session" doSaveSession ;
         MenuItem "&Load Session" doLoadSession ;
         MenuSeparator
         MenuItem "&Toggle Console Display" doForth ;

Popup "&Options
         MenuItem "&Set Preferences" doPref ;
         MenuSeparator
         MenuItem "&Customize toolbar" Customize: TheControlToolbar ;

PopUp "&Help"
        :MenuItem mnu_hlp "Form &Help"       doFormHelp ;
        :MenuItem mnu_nohlp "&Close Help Window" CloseHelpWindow ;
        MenuSeparator
        MenuItem "&About ForthForm" doabout   ;

EndBar

comment:
Since we have a customizable toolbar we have to check if a button is on the bar before we attempt
to change it. Windows complains if we try to change a button that is not in the bar.
comment;

: ?ChangeButton { flag id -- }  \ if button with id is on bar perform flag operation
                id CommandToIndex: TheControlToolbar 0< not      \ -1 if not on bar
                if      flag id EnableButton: TheControlToolbar
                then    ;

: ?ChangeMainButton { flag id -- }  \ if button with id is on bar perform flag operation
                id CommandToIndex: TheMainToolbar 0< not      \ -1 if not on bar
                if      flag id EnableButton: TheMainToolbar
                then    ;


: ?EnableToolbarItems  { flag -- }
            flag IDC_SAVE           ?ChangeMainButton
            flag IDC_COPY           ?ChangeMainButton
            flag IDC_COMPILE        ?ChangeMainButton
            flag IDC_TEST           ?ChangeMainButton
            flag IDC_EDITOR         ?ChangeMainButton
            flag IDC_SAVEALL        ?ChangeMainButton
            flag IDC_SELECT         ?ChangeButton
            flag IDC_BITMAP         ?ChangeButton
            flag IDC_LABEL          ?ChangeButton
            flag IDC_TEXTBOX        ?ChangeButton
            flag IDC_GROUPBOX       ?ChangeButton
            flag IDC_PUSHBUTTON     ?ChangeButton
            flag IDC_CHECKBOX       ?ChangeButton
            flag IDC_RADIOBUTTON    ?ChangeButton
            flag IDC_COMBOBOX       ?ChangeButton
            flag IDC_LISTBOX        ?ChangeButton
            flag IDC_HORIZSCROLL    ?ChangeButton
            flag IDC_VERTSCROLL     ?ChangeButton
            flag IDC_GENERIC        ?ChangeButton
            flag IDC_FILEWINDOW     ?ChangeButton
            flag IDC_TABCONTROL     ?ChangeButton
            ;

: EnableMenuItems   ( -- )
            #Forms 0<>
            dup Enable: mnu_doform
            dup Enable: mnu_close
            dup Enable: mnu_closeall
            dup Enable: mnu_save
            dup Enable: mnu_saveas
            dup Enable: mnu_saveall
            dup Enable: mnu_compile
            dup Enable: mnu_copy
            dup Enable: mnu_test
               ?EnableToolBarItems
            #Forms 2 < not dup
                 Enable: mnu_psheet
                 Enable: mnu_merge
            ActiveForm                          \ if no active form or it doesn't have controls
            if      #Controls: ActiveForm 0<>   \ disable controls menu
            else    0
            then    \
            dup Enable: mnu_edit
            dup Enable: mnu_delete
            dup Enable: mnu_gp
            dup Enable: mnu_gpv
            dup Enable: mnu_gph
            dup Enable: mnu_size
            dup Enable: mnu_arrangev
            dup Enable: mnu_arrangeh
            dup Enable: mnu_changetab
            dup Enable: mnu_changetype
            dup Enable: mnu_bringfront
            dup Enable: mnu_moveback
            dup IDC_BACK   ?ChangeMainButton
            dup IDC_FRONT  ?ChangeMainButton
            dup IDC_DELETE ?ChangeMainButton
                IDC_TAB    ?ChangeMainButton
            GetHandle: FFHelpwindow 0=
            dup Enable: mnu_hlp
            dup IDC_HELP   ?ChangeMainButton
            not Enable: mnu_nohlp ;
' EnableMenuItems is UpdateSystem

\s
