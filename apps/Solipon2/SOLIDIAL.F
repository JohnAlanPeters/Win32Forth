\ solidial.f

        0 value rank-in-dial
        0 value dial-busy?


:OBJECT SoliPion-Dial <Super DialogWindow

        EditControl Edit_1            \ an edit window
        StaticControl Title
        StaticControl HeadRank
        StaticControl HeadText
        StaticControl HeadScore
        StaticControl Text_1
        StaticControl Text_2
        StaticControl Text_3
        StaticControl Text_4
        StaticControl Text_5
        StaticControl Text_6
        StaticControl Text_7
        StaticControl Text_8
        StaticControl Text_9
        StaticControl Text_10
        StaticControl Rank1
        StaticControl Rank2
        StaticControl Rank3
        StaticControl Rank4
        StaticControl Rank5
        StaticControl Rank6
        StaticControl Rank7
        StaticControl Rank8
        StaticControl Rank9
        StaticControl Rank10
        StaticControl Score1
        StaticControl Score2
        StaticControl Score3
        StaticControl Score4
        StaticControl Score5
        StaticControl Score6
        StaticControl Score7
        StaticControl Score8
        StaticControl Score9
        StaticControl Score10
        ButtonControl Button_1   \ a button


: CloseSample   ( -- )
        Close: [ self ]
        ;

:M ExWindowStyle: ( -- style )
        ExWindowStyle: SUPER

        ;M

:M WindowStyle: ( -- style )
        WindowStyle: SUPER
        WS_OVERLAPPED OR
        ;M

:M WindowTitle: ( -- title )
        z" Solipion"


        ;M

:M StartSize:   ( -- width height )
        350 305 ;M

:M StartPos:    ( -- x y )
        CW_USEDEFAULT CW_USEDEFAULT ;M


:M On_Init:     (   -- )
        On_Init: super

        time-reset

        self                               Start: title
                                        GetStyle: title
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR

                                        SetStyle: title
                        4  4 290 25         Move: title
               s" Table of Bests Scores" SetText: title

                        self               Start: HeadRank
                                        GetStyle: HeadRank
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                        SetStyle: HeadRank
                        4 30  60 25         Move: HeadRank

                                s" Rank" SetText: HeadRank

                        self               Start: HeadText
                                        GetStyle: HeadText
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                        SetStyle: HeadText
                       72 30 150 25         Move: HeadText
                               S" Name"  SetText: HeadText

                        self               Start: HeadScore
                                        GetStyle: HeadScore
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                        SetStyle: HeadScore
                       230 30 64 25         Move: HeadScore
                              S" Score"  SetText: HeadScore


       11 1 DO

         Rank-in-dial i =

               if


                       self                 Start: Edit_1

                                         GetStyle: Edit_1
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                         SetStyle: Edit_1

                      72 30 25 i * + 150 25  Move: Edit_1


                       self              SetFocus: Edit_1


               else
               i case
                 1 of
                                                self   Start: Text_1
                                                    GetStyle: Text_1
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                    SetStyle: Text_1

                               72 30 25 i * + 150 25    Move: Text_1
                          bests-table i 1- 22 * + 20 SetText: Text_1
                   endof
                 2 of
                                                self   Start: Text_2
                                                    GetStyle: Text_2
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                    SetStyle: Text_2

                               72 30 25 i * + 150 25    Move: Text_2
                        bests-table i 1- 22 * + 20 SetText: Text_2
                   endof

                 3 of                           self   Start: Text_3
                                                    GetStyle: Text_3
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                    SetStyle: Text_3

                               72 30 25 i * + 150 25    Move: Text_3
                        bests-table i 1- 22 * + 20 SetText: Text_3
                   endof
                 4 of                           self   Start: Text_4
                                                    GetStyle: Text_4
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                    SetStyle: Text_4

                               72 30 25 i * + 150 25    Move: Text_4
                        bests-table i 1- 22 * + 20 SetText: Text_4
                   endof

                 5 of                           self   Start: Text_5
                                                    GetStyle: Text_5
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                    SetStyle: Text_5

                               72 30 25 i * + 150 25    Move: Text_5
                        bests-table i 1- 22 * + 20 SetText: Text_5
                   endof
                 6 of                           self   Start: Text_6
                                                    GetStyle: Text_6
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                    SetStyle: Text_6

                               72 30 25 i * + 150 25    Move: Text_6
                        bests-table i 1- 22 * + 20 SetText: Text_6
                   endof

                 7 of                           self   Start: Text_7
                                                    GetStyle: Text_7
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                    SetStyle: Text_7

                               72 30 25 i * + 150 25    Move: Text_7
                        bests-table i 1- 22 * + 20 SetText: Text_7
                   endof
                 8 of                           self   Start: Text_8
                                                    GetStyle: Text_8
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                    SetStyle: Text_8

                               72 30 25 i * + 150 25    Move: Text_8
                        bests-table i 1- 22 * + 20 SetText: Text_8
                   endof


                 9 of                           self   Start: Text_9
                                                    GetStyle: Text_9
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                    SetStyle: Text_9

                               72 30 25 i * + 150 25    Move: Text_9
                        bests-table i 1- 22 * + 20 SetText: Text_9
                   endof
                10 of                           self   Start: Text_10
                                                    GetStyle: Text_10
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                    SetStyle: Text_10

                               72 30 25 i * + 150 25    Move: Text_10
                        bests-table i 1- 22 * + 20 SetText: Text_10
                   endof
                endcase

              then

              i
              case
              1 of                              self Start: Rank1
                                                  GetStyle: Rank1
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                  SetStyle: Rank1

                               4 30 25 i * + 60 25    Move: Rank1
                                  s" 1"  SetText: Rank1
                endof
              2 of                              self Start: Rank2
                                                  GetStyle: Rank2
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                  SetStyle: Rank2

                               4 30 25 i * + 60 25    Move: Rank2
                                            s" 2"  SetText: Rank2
                endof
              3 of                              self Start: Rank3
                                                  GetStyle: Rank3
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                  SetStyle: Rank3

                               4 30 25 i * + 60 25    Move: Rank3
                                            s" 3"  SetText: Rank3
                endof
              4 of                              self Start: Rank4
                                                  GetStyle: Rank4
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                  SetStyle: Rank4

                               4 30 25 i * + 60 25    Move: Rank4
                                            s" 4"  SetText: Rank4
                endof
              5 of                              self Start: Rank5
                                                  GetStyle: Rank5
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                  SetStyle: Rank5

                               4 30 25 i * + 60 25    Move: Rank5
                                            s" 5"  SetText: Rank5
                endof
              6 of                              self Start: Rank6
                                                  GetStyle: Rank6
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                  SetStyle: Rank6

                               4 30 25 i * + 60 25    Move: Rank6
                                            s" 6"  SetText: Rank6
                endof

              7 of                              self Start: Rank7
                                                  GetStyle: Rank7
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                  SetStyle: Rank7

                               4 30 25 i * + 60 25    Move: Rank7
                                            s" 7"  SetText: Rank7
                endof
              8 of                              self Start: Rank8
                                                  GetStyle: Rank8
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                  SetStyle: Rank8

                               4 30 25 i * + 60 25    Move: Rank8
                                            s" 8"  SetText: Rank8
                endof
              9 of                              self Start: Rank9
                                                  GetStyle: Rank9
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                  SetStyle: Rank9

                               4 30 25 i * + 60 25    Move: Rank9
                                            s" 9"  SetText: Rank9
                endof
             10  of                             self Start: Rank10
                                                  GetStyle: Rank10
                        WS_GROUP     OR
                        SS_CENTER    OR
                        WS_BORDER    OR
                                                  SetStyle: Rank10

                               4 30 25 i * + 60 25    Move: Rank10
                                           s" 10"  SetText: Rank10
                endof

              endcase

 i
 case
        1 of                                               self Start: Score1
                                                             GetStyle: Score1
                       WS_GROUP OR SS_CENTER OR WS_BORDER OR SetStyle: Score1
                                        230 30 25 i * + 64 25    Move: Score1
                bests-table i 1- 22 * + 20 + w@ 0 <# # # # #> SetText: Score1
        endof
        2 of                                               self Start: Score2
                                                             GetStyle: Score2
                       WS_GROUP OR SS_CENTER OR WS_BORDER OR SetStyle: Score2
                                        230 30 25 i * + 64 25    Move: Score2
                bests-table i 1- 22 * + 20 + w@ 0 <# # # # #> SetText: Score2
        endof
        3 of                                               self Start: Score3
                                                             GetStyle: Score3
                       WS_GROUP OR SS_CENTER OR WS_BORDER OR SetStyle: Score3

                                        230 30 25 i * + 64 25    Move: Score3
                bests-table i 1- 22 * + 20 + w@ 0 <# # # # #> SetText: Score3
        endof
        4 of                                               self Start: Score4
                                                             GetStyle: Score4
                       WS_GROUP OR SS_CENTER OR WS_BORDER OR SetStyle: Score4
                                        230 30 25 i * + 64 25    Move: Score4
                bests-table i 1- 22 * + 20 + w@ 0 <# # # # #> SetText: Score4
        endof
        5 of                                               self Start: Score5
                                                             GetStyle: Score5
                       WS_GROUP OR SS_CENTER OR WS_BORDER OR SetStyle: Score5
                                        230 30 25 i * + 64 25    Move: Score5
                bests-table i 1- 22 * + 20 + w@ 0 <# # # # #> SetText: Score5
        endof
        6 of                                               self Start: Score6
                                                             GetStyle: Score6
                       WS_GROUP OR SS_CENTER OR WS_BORDER OR SetStyle: Score6
                                        230 30 25 i * + 64 25    Move: Score6
                bests-table i 1- 22 * + 20 + w@ 0 <# # # # #> SetText: Score6
        endof
        7 of                                               self Start: Score7
                                                             GetStyle: Score7
                       WS_GROUP OR SS_CENTER OR WS_BORDER OR SetStyle: Score7
                                        230 30 25 i * + 64 25    Move: Score7
                bests-table i 1- 22 * + 20 + w@ 0 <# # # # #> SetText: Score7
        endof
        8 of                                               self Start: Score8
                                                             GetStyle: Score8
                       WS_GROUP OR SS_CENTER OR WS_BORDER OR SetStyle: Score8
                                        230 30 25 i * + 64 25    Move: Score8
                bests-table i 1- 22 * + 20 + w@ 0 <# # # # #> SetText: Score8
        endof                                              self Start: Score9
        9 of
                                                             GetStyle: Score9
                       WS_GROUP OR SS_CENTER OR WS_BORDER OR SetStyle: Score9
                                        230 30 25 i * + 64 25    Move: Score9
                bests-table i 1- 22 * + 20 + w@ 0 <# # # # #> SetText: Score9
        endof
        10 of                                             self Start: Score10
                                                            GetStyle: Score10
                      WS_GROUP OR SS_CENTER OR WS_BORDER OR SetStyle: Score10
                                      230 30 25 i * + 64 25     Move: Score10
               bests-table i 1- 22 * + 20 + w@ 0 <# # # # #> SetText: Score10
        endof

        endcase


            LOOP


                IDOK               SetID: Button_1
                self               Start: Button_1
                                GetStyle: Button_1
                BS_DEFPUSHBUTTON OR
                WS_GROUP         OR
                                SetStyle: Button_1

                300 30 36 275       Move: Button_1
                s" OK"           SetText: Button_1




           ;M

:M On_Paint:    ( -- )          \ screen redraw procedure
        \ 0 0 screen-size LTGRAY  FillArea: dc
        0 0 screen-size LTBLUE  FillArea: dc


                ;M

:M Close:       ( -- )
        Rank-in-dial true =
        if      FALSE to dial-busy?
        else
                bests-table Rank-in-dial 1- 22 * + 20 blank

                GetText: Edit_1 drop bests-table Rank-in-dial 1- 22 * + 20 cmove

                FALSE to dial-busy?
        then
        Close: SUPER
;M

:M WM_COMMAND  ( hwnd msg wparam lparam -- res )
        over LOWORD ( ID )

        case
                IDOK    of Close: self  endof
        endcase
0 ;M

;OBJECT





