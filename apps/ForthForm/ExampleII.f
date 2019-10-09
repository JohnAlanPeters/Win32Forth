\ TestExample.f   A Demo Form For ForthForm

comment:
Forms created in ForthForm can be used in four ways.
(1) They can be pasted into an application and directly modified.
(2) They can be compiled to a .frm file and modified, then included into an application.
(3) Selected controls can be made global and thus be accessible directly from an
    application.
(4) The compiled form can be used as the super class for an object.

The last two methods has certain advantages over the others. When a form is directly modified
it difficult to add or change controls without "upsetting" the app. However, using (3) or (4)
method, an application is unaware of any changes to the form. Controls can be added,
rearranged or changed as needed. For simplicity and for those new to using forms method (3)
is demonstrated in this example.

comment;

anew -testexample.f
s" apps\forthform" "fpath+      \ path where files are stored
needs exampleii.frm \ load the form

: parse-filters { str cnt \ tempaddr -- addr cnt }
\ example of filter specs - "Forth Files (*.f;*.frm)"
\ specs can be preceded by a description but actual specs must be enclosed by brackets
                str cnt '(' scan dup
                if      1 /string over to tempaddr
                        ')' scan dup
                        if      drop tempaddr - tempaddr swap
                        then
                then    ;

: add-filters   ( -- )
                \ add default filters
                z" All Files (*.*)"                       AddstringTo: cmblstFilters
                z" Forth Files (*.f;*.frm)"               Addstringto: cmblstfilters
                z" Html Files (*.htm;*.html)"             Addstringto: cmblstfilters
                z" Text Files (*.txt;*.bat;*.ini;*.cfg)"  Addstringto: cmblstfilters
                0 SetSelection: cmblstFilters ;           \ select first item in control

0 value frm   \ pointer to form object
0 value cid
: on_selection     { item -- }      \ what to do when file in tree is selected
              \    only files can be deleted
                   itemid: item 0= Enable: btnDelete  \ for a file the itemid is 0
                   ;

: tally-files      { thedirbox -- }  \ what to do when directory tree is updated
\ it is passed the filewindow object
                   #dirs: thedirbox (.) pad place
                   s"  directories, " pad +place
                   #files: thedirbox (.) pad +place
                   s"  total files" pad +place     \ we could also total the file sizes
                   pad count asciiz settext: frmExample.TheStatusBar ;

: ExampleFunc   ( h m w l id frmobj -- ) \ handle the form messages
                to frm    \ save object address
                to cid
                cid
                case    GetID: btnChoose        of     choosefolder: dirbox    endof
                        GetID: btnDelete        of     deletefile: dirbox      endof
                        GetID: btnclose         of     Close: frm              endof
                        GetId: cmblstfilters    of     over HIWORD CBN_SELCHANGE =
                                                        if      GetCurrent: cmblstFilters
                                                                GetStringAt: cmblstFilters
                                                                parse-filters SetSpecs: dirbox
                                                                UpdateFiles: dirbox
                                                        then
                                                                                endof
                endcase ;

: Dotest        ( -- )  \  main word
                ['] ExampleFunc SetCommand: frmExample    \ install
                ['] on_selection IsTree-Click: dirbox     \ the
                ['] tally-files IsOn_Update: dirbox       \ functions
                WS_BORDER AddStyle: dirbox                \ additional style to add
                start: frmExample                         \ start the form
                add-filters                               \ the specs
                false enable: btnDelete                   \ initially disabled
                true readonly: txtpath                    \ don't allow user changes
                Gethandle: txtpath IsLabelHandle: dirbox  \ display the name of selected path
                CURRENT-DIR$ count setpath: dirbox
                UpdateFiles: dirbox
                ;                     \ show everything

\ debug breaker
dotest

comment:

Points to note:
If the form is now modified the demo would still work, assuming of course that
none of the controls used by the demo are deleted.

Controls are referenced by name as oppose to IDs a la dialogs.

comment;
\s
