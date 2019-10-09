\ $Id: Ed_Gotoline.F,v 1.2 2005/04/30 20:52:42 jos_ven Exp $
\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 22    Goto Line Dialog
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

NewEditDialog GotoDlg "Goto Line" "Line Number:" "Goto"  ""  ""


: goto-line     { \ line$ -- }  \ move cursor to line entered in dialog
        bitImage? ?EXIT
        MAXSTRING LocalAlloc: line$
        line$ off
        BEGIN   line$ EditorWindow Start: GotoDlg
                IF      line$ count number? nip
                        IF

                                \ disable highlighting and
                                \ accidental erasure
                                find-buf off
                                
                                0 swap 1- 0max to-find-line
                                refresh-line
                                TRUE
                        ELSE    drop FALSE
                        THEN
                ELSE    TRUE
                THEN
        UNTIL
                ReTitle: EditorWindow ;

