\ $Id: FlashControlDemo.f,v 1.1 2005/09/18 11:10:31 dbu_de Exp $

\ Demo for Shockwave Flash control
\ Tom Dixon

cr .( Loading Flash Control Demo...)

anew -FlashControlDemo.f

needs FlashControl.f

:class Flashwin <super window
  Flashcontrol fcntrl

  :M On_Init: ( -- )
     On_Init: super
     self Start: fcntrl ;M

  :M On_Size: ( h m w -- ) 2drop drop autosize: fcntrl ;M

  \ ShockWave Methods
  :M PutMovie: ( str len -- f ) PutMovie: fcntrl ;M
  :M GetMovie: ( -- str len ) GetMovie: fcntrl ;M
  :M Play: ( -- ) Play: fcntrl ;M
  :M Stop: ( -- ) Stop: fcntrl ;M
  :M Back: ( -- ) Back: fcntrl ;M
  :M Forward: ( -- ) Forward: fcntrl ;M
  :M Rewind: ( -- ) Rewind: fcntrl ;M
  :M StopPlay: ( -- ) StopPlay: fcntrl ;M
  :M GotoFrame: ( n -- ) GotoFrame: fcntrl ;M
  :M CurrentFrame: ( -- n ) CurrentFrame: fcntrl ;M
  :M TotalFrames: ( -- n ) TotalFrames: fcntrl ;M
  :M Playing?: ( -- flag ) Playing?: fcntrl ;M
  :M Loaded%: ( -- percent ) Loaded%: fcntrl ;M
  :M Loop: ( flag -- ) Loop: fcntrl ;M
  :M Loop?: ( -- flag ) Loop?: fcntrl ;M
  :M Pan: ( n n n -- ) Pan: fcntrl ;M
  :M Zoom: ( n -- ) Zoom: fcntrl ;M
  :M SetZoomRect: ( n n n n -- ) SetZoomRect: fcntrl ;M
  :M BGColor: ( -- color ) BGColor: fcntrl ;M
  :M SetBGColor: ( color -- ) SetBGColor: fcntrl ;M

;class

Flashwin fwin
start: fwin
0x808080 setbgcolor: fwin
s" demos\clock.swf" Prepend<home>\ putmovie: fwin drop
true loop: fwin
