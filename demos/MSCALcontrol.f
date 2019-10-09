\ MSCAL.Calendar ActiveX control example
\ Thomas Dixon
\ 7/11/2006


anew -MSCALControl.f

needs AXControl

:CLASS MSCALControl           <SUPER AXControl
  CELL bytes MSCAL        \ pointer to Dispatch Interface

  :M Start: ( Parent -- )
        Start: super
        s" MSCAL.Calendar" AXCreate: self
        MSCAL IDispatch QueryInterface: self
          abort" Unable to get the Dispatch Interface!"
        ;M

  :M On_Done: ( -- )
        MSCAL @ if
          MSCAL COM IDispatch IReleaseref drop 0 MSCAL ! then ;M

  :M Today: ( -- ) \ selects the current date
	MSCAL displate" Today" drop ;M

  :M GetDay: ( -- day ) \ get the selected day
	MSCAL displate" GetDay" drop retvt@ drop ;M

  :M GetMonth: ( -- month ) \ get the selected month
	MSCAL displate" GetMonth" drop retvt@ drop ;M

  :M GetYear: ( -- year ) \ get the selected year
	MSCAL displate" GetYear" drop retvt@ drop ;M

  :M SetDay: ( day -- )
	VT_I2 >vt
	MSCAL displate" PutDay" drop ;M

  :M SetMonth: ( month -- )
	VT_I2 >vt
	MSCAL displate" PutMonth" drop ;M

  :M SetYear: ( year -- )
	VT_I2 >vt
	MSCAL displate" PutYear" drop ;M

  :M Refresh: ( -- )
	MSCAL displate" Refresh" drop ;M

  :M Aboutbox: ( -- )
        MSCAL displate" AboutBox" drop ;M

;CLASS



\ Example:
window win
start: win
mscalcontrol cal
win start: cal
autosize: cal
