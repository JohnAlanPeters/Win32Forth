\ FormHelp.f

create help$ ," doc\forthform\ForthForm.htm" 32 allot
HtmlControl FFHelpWindow
2005 SetID: FFHelpWindow
FFHelpWindow link-formwindow

: SizeHelpWindow        ( -- )
                        GetHandle: FFHelpWindow
                        if       Canvas: TheMainWindow Move: FFHelpWindow
                        then     ;
                        
: CloseHelpWindow       ( -- )
                        Close: FFHelpWindow
\+ withbgnd             SW_SHOWNORMAL Show: BkGndImageWindow 
                        UpdateSystem  \ update toolbar help button
                        ;   

: (FormHelp)      ( -- )  \ prepare dinner :-)
                GetHandle: FFHelpwindow ?exit
                help$ count "path-file 0=     \ if help file found
                if      TheMainWindow Start: FFHelpWindow
                        asciiz SetUrl: FFHelpWindow \ show it
                        SizeHelpWindow
\+ withbgnd             SW_HIDE Show: BkGndImageWindow 
                else    2drop true s" Help file not found" ?MessageBox \ sorry!
                then    UpdateSystem  \ update toolbar help button
                ;

: FormHelp      ( -- )
                s" doc\forthform\forthform.htm" help$ place
                (FormHelp) ; ' FormHelp is doFormHelp

\s
