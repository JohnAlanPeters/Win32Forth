\ GroupAction.f     Positioning of controls in form

:Object frmAction               <Super frmGroupAction

ImageButton imgLeft
ImageButton imgRight
ImageButton imgUp
ImageButton imgDown
UpDownControl updnValue

load-bitmap bmpleft "scrlleft.bmp"
load-bitmap bmpright "scrlright.bmp"
load-bitmap bmpup "scrlup.bmp"      \ for some reason it is not recognizing scrlup from TabOrder.f - yes I did make it global
load-bitmap bmpdown "scrldown.bmp"

\ For size adjustments clicking up/right arrows increases, conversely down/left decreases
: do-up             ( -- )
                    IsButtonChecked?: radPosition
                    if      GroupMoveUp: ActiveForm exit
                    then    IsButtonChecked?: radHeight
                    if      GroupHeightUp: ActiveForm exit
                    then    IsButtonChecked?: radWidth
                    if      GroupWidthUp: ActiveForm
                    then    ;

: do-down           ( -- )
                    IsButtonChecked?: radPosition
                    if      GroupMoveDown: ActiveForm exit
                    then    IsButtonChecked?: radHeight
                    if      GroupHeightDown: ActiveForm exit
                    then    IsButtonChecked?: radWidth
                    if      GroupWidthDown: ActiveForm
                    then    ;

: do-left           ( -- )
                    IsButtonChecked?: radPosition
                    if      GroupMoveLeft: ActiveForm exit
                    then    IsButtonChecked?: radHeight
                    if      GroupHeightDown: ActiveForm exit
                    then    IsButtonChecked?: radWidth
                    if      GroupWidthDown: ActiveForm
                    then    ;

: do-right          ( -- )
                    IsButtonChecked?: radPosition
                    if      GroupMoveRight: ActiveForm exit
                    then    IsButtonChecked?: radHeight
                    if      GroupHeightUp: ActiveForm exit
                    then    IsButtonChecked?: radWidth
                    if      GroupWidthUp: ActiveForm
                    then    ;

: group-action  { id obj -- }
                id
                case
                        GetId: btnLeft              of  GroupAlignLeft: ActiveForm          endof
                        GetId: btnRight             of  GroupAlignRight: ActiveForm         endof
                        GetId: btnTop               of  GroupAlignTop: ActiveForm           endof
                        GetId: btnBottom            of  GroupAlignBottom: ActiveForm        endof
                        GetId: btnTallest           of  GroupSizeTallest: ActiveForm        endof
                        GetId: btnShortest          of  GroupSizeShortest: ActiveForm       endof
                        GetId: btnWidest            of  GroupSizeWidest: ActiveForm         endof
                        GetId: btnNarrowest         of  GroupSizeNarrowest: ActiveForm      endof
                        GetId: btnToBox             of  GroupSizeToBox: ActiveForm          endof
                        GetId: btnVertical          of  GroupArrangeVertical: ActiveForm    endof
                        GetId: btnHorizontal        of  GroupArrangeHorizontal: ActiveForm  endof
                        GetId: imgLeft              of  do-left                             endof
                        GetId: imgRight             of  do-right                            endof
                        GetId: imgUp                of  do-up                               endof
                        GetId: imgDown              of  do-down                             endof
\                        GetId: btnClose             of  Close: self                         endof
                endcase ;

:M On_Init:     ( -- )
                On_Init: Super

                ['] group-action SetCommand: self

                CheckButton: radPosition        \ always default

                self Start: imgUp
                imgbtnUpX imgbtnUpY imgbtnUpW imgbtnUpH Move: imgUp
                bmpup usebitmap map-3DColors
                bmpup SetImage: imgUp

                self Start: imgRight
                imgbtnRightX imgbtnRightY imgbtnRightW imgbtnRightH Move: imgRight
                bmpright usebitmap map-3DColors
                bmpright SetImage: imgRight

                self Start: imgDown
                imgbtnDownX imgbtnDownY imgbtnDownW imgbtnDownH Move: imgDown
                bmpdown usebitmap map-3DColors
                bmpdown SetImage: imgDown

                self Start: imgLeft
                imgbtnLeftX imgbtnLeftY imgbtnLeftW imgbtnLeftH Move: imgLeft
                bmpleft usebitmap map-3DColors
                bmpleft SetImage: imgLeft

                self Start: updnValue
                GetHandle: txtValue SetBuddy: updnValue
                0 screen-size nip SetRange: updnValue
                0 SetValue: updnValue

                ;M

:M GetValue:    ( -- n )
                GetValue: updnValue ;M

;Object
\s
