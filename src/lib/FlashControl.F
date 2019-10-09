\ $Id: FlashControl.F,v 1.2 2005/09/18 11:10:31 dbu_de Exp $

\ Shockwave Flash control written in forth
\ Tom Dixon

anew -FlashControl

needs AXControl

\ Load Shockwave TypeLibrary
1 0 typelib {D27CDB6B-AE6D-11CF-96B8-444553540000}

\ We Build off the Generic ActiveX Control
:CLASS FlashControl           <SUPER AXControl
  CELL bytes Flash      \ pointer to IShockwaveFlash interface
  16 bytes xtra         \ xtra space for api calls

  :M Start: ( Parent -- )
        Start: super
        xtra ShockwaveFlash StringFromCLSID abort" Unable to Get Flash CLSID!"
        xtra @ AXUCreate: self
        Flash IShockwaveFlash QueryInterface: self
          abort" Unable to get the IShockwaveFlash Interface!"
        ;M

  :M On_Done: ( -- )
        Flash @ if
          Flash COM IShockwaveFlash Release drop 0 Flash ! then ;M

  \ ShockWave Methods
  :M PutMovie: ( str len -- f )
        >unicode drop flash COM IShockwaveFlash PutMovie ;M
  :M GetMovie: ( -- str len )
        xtra Flash COM IShockwaveFlash GetMovie drop
        xtra @ dup >r zunicount >ascii r> call SysFreeString drop ;M

  :M Play: ( -- ) Flash COM IShockwaveFlash Play drop ;M
  :M Stop: ( -- ) Flash COM IShockwaveFlash Stop drop ;M
  :M Back: ( -- ) Flash COM IShockwaveFlash Back drop ;M
  :M Forward: ( -- ) Flash COM IShockwaveFlash Forward drop ;M
  :M Rewind: ( -- ) Flash COM IShockwaveFlash Rewind drop ;M
  :M StopPlay: ( -- ) Flash COM IShockwaveFlash StopPlay drop ;M
  :M GotoFrame: ( n -- ) Flash COM IShockwaveFlash GotoFrame drop ;M
  :M CurrentFrame: ( -- n ) xtra Flash COM IShockwaveFlash CurrentFrame drop xtra @ ;M
  :M TotalFrames: ( -- n ) xtra Flash COM IShockwaveFlash GetTotalFrames drop xtra @ ;M
  :M Playing?: ( -- flag ) xtra Flash COM IShockwaveFlash IsPlaying drop xtra @ ;M
  :M Loaded%: ( -- percent ) xtra Flash COM IShockwaveFlash PercentLoaded drop xtra @ ;M
  :M Loop: ( flag -- ) Flash COM IShockwaveFlash PutLoop drop ;M
  :M Loop?: ( -- flag ) xtra Flash COM IShockwaveFlash GetLoop drop xtra @ ;M
  :M Pan: ( n n n -- ) Flash COM IShockwaveFlash Pan drop ;M
  :M Zoom: ( n -- ) Flash COM IShockwaveFlash Zoom drop ;M
  :M SetZoomRect: ( n n n n -- ) Flash COM IShockwaveFlash SetZoomRect drop ;M
  :M BGColor: ( -- color ) xtra Flash COM IShockwaveFlash GetBackgroundColor drop xtra @ ;M
  :M SetBGColor: ( color -- ) Flash COM IShockwaveFlash PutBackgroundColor drop ;M

;CLASS

\ We don't need the typelibrary anymore, so unload it now.
free-lasttypelib

\s
for an example see demos\FlashControlDemo.f
