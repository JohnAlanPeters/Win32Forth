\ $Id: RecentFiles.f,v 1.2 2007/07/01 17:16:27 rodoakford Exp $

\ RecentFiles.f         RecentFiles class by Rod Oakford
\                       July 2003
\
\                       Use when defining menuitems before a MenuSeparator, usually on the File menu e.g.
\           POPUP "&File"
\               MENUITEM     "Page Set&up..."   ( word to do Page Setup )            ;
\               9 RECENTFILES   RecentFiles  ( -- FileName$ )  ( word to open file ) ;
\               MENUSEPARATOR
\               MENUITEM     "E&xit  \tAlt-F4"  bye                                  ;
\
\               9 RECENTFILES RecentFiles creates an object of the class RECENTFILES with space for 9 menuitems
\               You can use the following methods:
\               FileName$  Insert: RecentFiles  to add FileName to the top of the list and push the others down
\               Number  SetNumber: RecentFiles  to set the max number of Files shown in the list (max 9 in this case)
\               nth GetRecentFile: RecentFiles  to get the nth FileName$ in the list


cr  .( Loading RecentFiles class...)

INTERNAL

:Class  RECENTFILES  <Super MENUITEMS
int mfunc               \ the menu function
int AllocatedFiles      \ Maximum number of recent files allocated for
int MaxFiles            \ Largest number of recent files saved on file menu
int NumberOfFiles       \ Menu separator is removed if no recent files
int FirstPos            \ Pos of first recent file on file menu

: WithoutFileNumber ( text$ -- text$ )  dup c@ 3 - 0 max >r  3 +  r> over c! ;

:M DoMenu:   { ID \ Text$ -- }
        ID mid mid MaxFiles + within
        IF
            MAXSTRING LocalAlloc: Text$
            MF_BYCOMMAND MAXSTRING Text$ 1+
            ID popid Call GetMenuString Text$ c!
            Text$ WithoutFileNumber  mfunc execute-menufunc
        THEN
        ;M

:M ClassInit: ( n -- )   \ allot n menu IDs to recent files
        dup to AllocatedFiles to MaxFiles
        ClassInit: Super
\In-system-OK   :noname  to mfunc  !csp
        AllocatedFiles 1- +to IDcounter
        ;M

:M LoadMenu: ( pid parent -- )   \ don't add anything to menu
        to parent to popid
        popid Call GetMenuItemCount 1+ to FirstPos
        0 to NumberOfFiles
        ;M

int ID
int Pos
:M Reset: { \ Text$ -- }    \ Numbers recent files and deletes any more than allowed
    NumberOfFiles           \ There must be a menu separator before any further menu items
    IF
        MAXSTRING LocalAlloc: Text$
        FirstPos to Pos
        BEGIN
            MF_BYPOSITION MAXSTRING Text$ 1+
            Pos popid Call GetMenuString dup Text$ c!
        WHILE
            Pos FirstPos MaxFiles + <
            IF
                Pos FirstPos - 49 + Text$ 2 + c!  Text$ 1+ mid Pos + FirstPos -
                MF_BYPOSITION Pos popid Call ModifyMenu drop 1 +to Pos
            ELSE
                MF_BYPOSITION Pos popid Call DeleteMenu drop  -1 +to NumberOfFiles
            THEN
        REPEAT
        MF_BYPOSITION MAXSTRING Text$ 1+ FirstPos popid Call GetMenuString 0=
        IF                  \ Remove second separator if no recent files
            MF_BYPOSITION FirstPos 1- popid Call DeleteMenu drop
        THEN
    THEN
        ;M

:M Insert:   { FileName$  \ MenuText$ Text$ -- }   FileName$ c@
    IF
        MAXSTRING LocalAlloc: MenuText$
        s" &1 " MenuText$ place FileName$ count MenuText$ +place MenuText$ +NULL
        MAXSTRING LocalAlloc: Text$
        NumberOfFiles 0=
        IF                  \ Insert second separator if no recent files
            0 0 MF_BYPOSITION MF_SEPARATOR or FirstPos 1- popid Call InsertMenu drop
        THEN
        mid to ID
        BEGIN
            MF_BYCOMMAND MAXSTRING Text$ 1+
            ID popid Call GetMenuString  Text$ c!
            Text$ WithoutFileNumber count  FileName$ count  CAPS-COMPARE
            IF
                -1
            ELSE
                MF_BYCOMMAND ID popid Call DeleteMenu drop  -1 +to NumberOfFiles  0
            THEN
            ID mid MaxFiles 1- + < and   \ Text$ contains menutext of last recent file
        WHILE                            \ or menutext of matched file
            1 +to ID                     \ or 0 if last Pos is empty and no match
        REPEAT                           \ insert filename with ID of match or last recent file
        MenuText$ 1+  ID MF_BYPOSITION FirstPos popid Call InsertMenu drop
        1 +to NumberOfFiles
        Reset: self
    THEN
        ;M

:M SetNumber: ( n -- )
        AllocatedFiles min to MaxFiles
        Reset: self
        ;M

:M GetRecentFile: { Index -- FileName$ }
        Index 1 NumberOfFiles between
        IF
            MF_BYPOSITION MAXSTRING temp$ 1+
            Index FirstPos + 1- popid Call GetMenuString
        ELSE
            0
        THEN
        temp$ c! temp$ WithoutFileNumber
        ;M

;Class

MODULE
