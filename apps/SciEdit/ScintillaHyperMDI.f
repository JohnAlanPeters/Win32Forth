\ $Id: ScintillaHyperMDI.f,v 1.4 2006/01/08 09:25:36 dbu_de Exp $

\    File: ScintillaHyperMDI.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Freitag, Juli 02 2004 - 17:48 - dbu
\ Updated: Samstag, Juli 03 2004 - 10:08 - dbu

needs linklist.f
needs HyperLink.f

\ -----------------------------------------------------------------------------
\  Class HyerObject
\ -----------------------------------------------------------------------------

:class HyperObject <Super Object

int            #Line
max-path bytes filename

:M setname:     ( addr cnt -- )
                filename place ;m

:m getname:     ( -- addr )
                filename ;m

:M setline:     ( #line -- )
                to #Line ;m

:m getline:     ( -- #line )
                #Line ;m

:M classinit:   ( #line addr cnt -- )
                classinit: super
                setname: self
                setline: self ;M

;class


\ -----------------------------------------------------------------------------
\  Class HyerObjectList
\ -----------------------------------------------------------------------------

:class HyperObjectList <Super linked-list

:M AddNew:      ( #line addr cnt -- )
                AddLink: self
                New> HyperObject Data!: self
                ;m

:m GetLast:     { \ current -- #line addr cnt }
                #links: self
                if   Data@: self to current
                     current
                     if   getline: current getname: current count
                     else 0 0 0
                     then
                else 0 0 0
                then ;m

:M DeleteLast:  ( -- )
                DeleteLink: self
                ;M

;class


\ -----------------------------------------------------------------------------
\  Class EditorChild
\ -----------------------------------------------------------------------------

: file-exist?   ( adr len -- true-if-file-exist )
                file-status nip 0= ;

:Class HyperEditorChild        <Super EditorChild

int HyperList
int Browse?

:M ?BrowseMode: ( -- f )
                Browse? ;M

:M SetBrowseMode: ( f --  )
                dup to Browse?
                dup SetReadOnly: ChildWindow
                0= UsePopUp: ChildWindow
                ;M

:M SetTextz:    ( addr len -- )
                over + 0 swap c! \ 0-terminate
                false SetReadOnly: ChildWindow
                SetText: self
                Browse? SetReadOnly: ChildWindow ;M

: AddHyperLink  ( #line addr len -- )
                HyperList 0=
                if   new> HyperObjectList to HyperList
                then addnew: HyperList ;

\ Samstag, August 20 2005 dbu
\ Changed to open the file only if it exist
:M LoadHyperFile:  ( #line addr len -- )
                false SetReadOnly: ChildWindow

                2dup file-exist?
                if   OpenNamedFile: self
                     if   1- 0 max dup GotoLine: ChildWindow

                          dup PositionFromLine: ChildWindow swap
                          LineLength: ChildWindow
                          over SetSelectionStart: ChildWindow
                          + SetSelectionEnd: ChildWindow
                     else drop beep
                     then
                else 3drop beep
                then
                Browse? SetReadOnly: ChildWindow ;M

: HyperWord     ( addr -- )
                zcount bl skip -trailing 10 -TRAILCHARS 13 -TRAILCHARS
                s" HYPER.NDX" Prepend<home>\ "hyper
                if   \ save the current file in our list
                     GetCurrentLine: self 1+ GetFileName: self count
                     AddHyperLink
                     \ and open new file
                     LoadHyperFile: self
                else beep
                then ;

:M <Hyper:      ( -- )
                HyperList
                if   Getlast: HyperList \ get the previous one
                     DeleteLast: HyperList \ delete it
                     ?dup if LoadHyperFile: self else 2drop beep then
                else beep
                then ;M

:M Hyper>:      { \ SelBuf$ -- } \ Hyperlink to selected word
                0 GetSelText: ChildWindow LocalAlloc: SelBuf$
                SelBuf$ GetSelText: ChildWindow
                if   SelBuf$ HyperWord
                then ;M

:M DisposeHyperLinks: ( -- )
                HyperList if HyperList DisposeList 0 to HyperList then ;M

:m ~:           ( -- )
                DisposeHyperLinks: self ;m

:M Update:      ( -- ) \ update the control state from global variables
                CreateBackup?    EnableBackup: super
                EOL              SetEOL: super
                ViewEOL?         ViewEOL: super
                ViewWhiteSpace?  ViewWhiteSpace: super
                Colorize?        Colorize: super
                ViewLineNumbers? ViewLineNumbers: super
                TabSize	         SetTabWidth: super
                UseTabs?         SetUseTabs: super
                FinalNewLine?    EnableEnsureFinalNewLine: super
                StripTrailingWhitespace? EnableStripTrailingSpaces: super
                ;M

:M Start:       ( parent -- )
                start: super
                0 to HyperList
                false SetBrowseMode: self
                Update: self
                ;M

:M OpenFile:    ( -- )          \ open a file
                false SetBrowseMode: self
                OpenFile: super
                ;M

:M NewFile:     ( -- )          \ open a new empty file
                false SetBrowseMode: self
                NewFile: super
                ;M

:M Self:        ( -- self )
                self ;M

:M On_Close:    ( -- )
                On_Close: super
                self ActiveBrowser = if 0 to ActiveBrowser then
                self ActiveRemote  = if 0 to ActiveRemote  then
                self ActiveChild   = if 0 to ActiveChild   then
                UpdateStatusBar
                EnableToolbar
                ;M

:M GoBack:      ( -- )
                <Hyper: self ;M

:M GoForward:   ( -- )
                Hyper>: self ;M

;Class

