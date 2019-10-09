\    File: ScintillaHyperEdit.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Freitag, Juli 02 2004 - 17:48 - dbu
\ Updated: Samstag, Juli 03 2004 - 10:08 - dbu

needs linklist.f
needs ScintillaEdit.f     \ Source code Editor
needs HyperLink.f

anew -ScintillaHyperEdit.f

INTERNAL
EXTERNAL

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
\  Class ScintillaHyperEdit
\ -----------------------------------------------------------------------------

:Class ScintillaHyperEdit        <Super ScintillaEdit

int HyperList
int Browse?

:M ?BrowseMode: ( -- f )
                Browse? ;M

:M SetBrowseMode: ( f --  )
                dup to Browse?
                dup SetReadOnly: self
        0= UsePopUp: self
        ;M

:M SetTextz:    ( addr len -- )
                over + 0 swap c! \ 0-terminate
                false SetReadOnly: self
                SetText: self
                Browse? SetReadOnly: self ;M

: AddHyperLink  ( #line addr len -- )
                HyperList 0=
                if   new> HyperObjectList to HyperList
                then addnew: HyperList ;

:M LoadHyperFile:  ( #line addr len -- )
                false SetReadOnly: self
                OpenNamedFile: self
                if   1- 0 max dup GotoLine: self

                     dup PositionFromLine: self swap
                     LineLength: self
                     over SetSelectionStart: self
                     + SetSelectionEnd: self
                then
                Browse? SetReadOnly: self ;M

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
                0 GetSelText: self LocalAlloc: SelBuf$
                SelBuf$ GetSelText: self
                if   SelBuf$ HyperWord
                then ;M

:M DisposeHyperLinks: ( -- )
                HyperList if HyperList DisposeList 0 to HyperList then ;M

:m ~:           ( -- )
                DisposeHyperLinks: self ;m

:M Start:       ( parent -- )
                start: super
                0 to HyperList
                true to Browse?
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

;Class

MODULE

