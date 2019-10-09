\ SplitterWindow.f      Some Splitter Windows Templates for ForthForm by Ezra Boyce
\ May 27, 2006 - Updated to used splitter-window templates by Rod OakFord

load-bitmap splitwin-type1 "splitwin-type1.bmp"
load-bitmap splitwin-type2 "splitwin-type2.bmp"
load-bitmap splitwin-type3 "splitwin-type3.bmp"
load-bitmap splitwin-type4 "splitwin-type4.bmp"
load-bitmap splitwin-type5 "splitwin-type5.bmp"
load-bitmap splitwin-type6 "splitwin-type6.bmp"


:Object frmCreateSplitterWindow         <Super frmSplitterWindow

ImageButton Split1
ImageButton Split2
ImageButton Split3
ImageButton Split4
ImageButton Split5
ImageButton Split6
\ 0 value ischild-window?
ReadFile SplitterFile
create type-name$ 32 allot

: test          ( -- )
                s" anew -testsplit" evaluate
                GetBuffer: SplitterFile (fload-buffer) s" Start: SplitterWindow" evaluate
                ;

: toclipboard       ( -- )
                    GetBuffer: SplitterFile copy-clipboard ;

: edit              ( -- )
                    s" SplitterWindow-" pad place
                    type-name$ count pad +place
                    GetBuffer: SplitterFile pad count ShowSource ;

: radfunction       ( -- )
                    IsButtonChecked?: radTest
                    if      test exit
                    then    IsButtonChecked?: radEdit
                    if      edit exit
                    then    toclipboard ;

: do-splitfunc      { filename cnt -- }
                    s" apps\forthform\" PREPEND<HOME>\ pad place
                    filename cnt pad +place
                    filename cnt type-name$ place
                    pad count LoadFile: SplitterFile 0=
                    if        abort
                    then      radfunction ;
                    
: splitter-command  ( id obj -- )
                    drop
                    case
                            GetId: Split1   of      s" splitter1.f" do-splitfunc   endof
                            GetID: Split2   of      s" splitter2.f" do-splitfunc   endof
                            GetID: Split3   of      s" splitter3.f" do-splitfunc   endof
                            GetID: Split4   of      s" splitter4.f" do-splitfunc   endof
                            GetID: Split5   of      s" splitter5.f" do-splitfunc   endof
                            GetId: Split6   of      s" splitter6.f" do-splitfunc   endof
                            GetID: btnExit  of      Close: self                    endof
                    endcase ;

:M ParentWindow:    ( -- hwnd )
                    GetHandle: TheMainWindow ;M

false value mapped?

: ?map-colors   ( -- )
                mapped? ?exit
               \ map the system colors at this time
               splitwin-type1 usebitmap map-3DColors
               splitwin-type2 usebitmap map-3DColors
               splitwin-type3 usebitmap map-3DColors
               splitwin-type4 usebitmap map-3DColors
               splitwin-type5 usebitmap map-3DColors
               splitwin-type6 usebitmap map-3DColors
               true to mapped? ;

:M On_Init:         ( -- )
                    On_Init: Super

                    ['] splitter-command SetCommand: self

                    ?map-colors

                    self Start: Split1
                    ImgType1X ImgType1Y ImgType1W ImgType1H Move: Split1
                    splitwin-type1 SetImage: Split1
                    s" left vertical pane, right vertical pane" Binfo: Split1 place

                    self Start: Split2
                    ImgType2X ImgType2Y ImgType2W ImgType2H Move: Split2
                    splitwin-type2 SetImage: Split2
                    s" top horizontal pane, bottom horizontal pane" Binfo: Split2 place

                    self Start: Split3
                    ImgType3X ImgType3Y ImgType3W ImgType3H Move: Split3
                    splitwin-type3 SetImage: Split3
                    s" left vertical pane, two-way split for right vertical pane" Binfo: Split3 place

                    self Start: Split4
                    ImgType4X ImgType4Y ImgType4W ImgType4H Move: Split4
                    splitwin-type4 SetImage: Split4
                    s" two-way split left vertical pane,two-way split right vertical pane" Binfo: Split4 place

                    self Start: Split5
                    ImgType5X ImgType5Y ImgType5W ImgType5H Move: Split5
                    splitwin-type5 SetImage: Split5
                    s" top horizontal pane, two-way split for bottom horizontal pane" Binfo: Split5 place

                    self Start: Split6
                    ImgType6X ImgType6Y ImgType6W ImgType6H Move: Split6
                    splitwin-type6 SetImage: Split6
                    s" two-way split for top horizontal pane, bottom horizontal pane" Binfo: Split6 place

                    CheckButton: radTest        \ always default

                    SW_HIDE Show: radChild-Window

                    ;M

:M Close:   ( -- )
          ReleaseBuffer: SplitterFile
          Close: Super ;M
        
:M ClassInit:   ( -- )
                ClassInit: Super
                self link-formwindow
                ;M

;Object

:NoName      ( -- )
             Start: frmCreateSplitterWindow ; is doSplitter

\s

