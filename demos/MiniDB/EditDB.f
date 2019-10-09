\ $Id: EditDB.f,v 1.2 2011/08/10 15:58:18 georgeahubert Exp $

\ Dialog for editing and adding to simple database. G. Hubert Friday, December 07 2007

Require TextBox.f  \ Use TextBoxes rather than EditControls for the extra methods.

defer Add-ModifyDB \ must be referenced outside of the dialog object
defer RejectDB     \ must be referenced outside of the dialog object

COLOR_BTNFACE call GetSysColor New-Color DialogColor

: InitDialogColor ( -- )
             COLOR_BTNFACE call GetSysColor InitColor: DialogColor ;

initialization-chain chain-add InitDialogColor

:Object DBDialog <super DialogWindow

int record# \ holds ID of entry or 0 for new entry.

StaticControl FirstLabel
StaticControl NameLabel
StaticControl AbodeLabel

TextBox First
TextBox Name
TextBox Abode

ButtonControl Accept
ButtonControl Reject

:M WindowStyle: ( -- style )
           WS_CAPTION WS_POPUPWINDOW or WS_CLIPCHILDREN or ;M

:M StartSize:   ( -- w h )
          250 160 ;m

:m Start: ( record# -- )
          to record#
          Start: Super ;m

:m On_Init: ( -- )
          record# if s" Editing Database" else s" Adding Record to Database" then
          SetTitle: self
          self Start: FirstLabel
          self Start: NameLabel
          self Start: AbodeLabel
          self Start: First
          self Start: Name
          self Start: Abode

          10  20  80  20 move: FirstLabel
          10  60  80  20 move: NameLabel
          10  100 80  20 move: AbodeLabel
          90  20  120 20 move: First
          90  60  120 20 move: Name
          90  100 120 20 move: Abode

          s" First Name:" SetText: FirstLabel
          s" Surname:"    SetText: NameLabel
          s" Abode:"      SetText: AbodeLabel

          record# if
          s" SELECT * FROM Customers WHERE id = "
          new$ dup>r place
          record# (.) r@ +place r@ +null r> count
          execute: MiniDB

          1 getstr: MiniDB SetText: First
          2 getstr: MiniDB SetText: Name
          3 getstr: MiniDB SetText: Abode

          false SetModify: First
          false SetModify: Name
          false SetModify: Abode

          then

          SetFocus: First

          IDOK               SetID: Accept
          self               Start: Accept
          10  130 100 25      Move: Accept
          s" Accept"       SetText: Accept
                          GetStyle: Accept
          BS_DEFPUSHBUTTON OR
                          SetStyle: Accept
          ['] Add-modifyDB SetFunc: Accept
          self               Start: Reject
          140  130 100 25     Move: Reject
          s" Reject"       SetText: Reject
          ['] RejectDB     SetFunc: Reject
          ;m

:M On_Paint:    ( -- )          \ screen redraw procedure
          0 0 width height ( LTGRAY ) DialogColor FillArea: dc
                ;M

:m record#:  ( -- record# )
          record# ;m

: BufferText ( addr len -- addr len )
          new$ dup>r place r@ +null r> count ;

:m BindText: ( -- )
          GetText: First BufferText 1 bindstr: MiniDB
          GetText: Name  BufferText 2 bindstr: MiniDB
          GetText: Abode BufferText 3 bindstr: MiniDB ;m

:m Dirty: ( -- f )
          IsModified?: First
          IsModified?: Name or
          IsModified?: Abode or ;m

;object


