Anew -joystick.f

INTERNAL WinLibrary WINMM.DLL EXTERNAL

Needs ExtStruct.f

:struct joycapsa
     WORD    wMid                               \ manufacturer ID
     WORD    wPid                               \ product ID
     MAXPNAMELEN               Field:  szPname  \ product name (NULL terminated string)
     UINT    wXmin                              \ minimum x position value
     UINT    wXmax                              \ maximum x position value
     UINT    wYmin                              \ minimum y position value
     UINT    wYmax                              \ maximum y position value
     UINT    wZmin                              \ minimum z position value
     UINT    wZmax                              \ maximum z position value
     UINT    wNumButtons                        \ number of buttons
     UINT    wPeriodMin                         \ minimum message period when captured
     UINT    wPeriodMax                         \ maximum message period when captured
     UINT    wRmin                              \ minimum r position value
     UINT    wRmax                              \ maximum r position value
     UINT    wUmin                              \ minimum u (5th axis) position value
     UINT    wUmax                              \ maximum u (5th axis) position value
     UINT    wVmin                              \ minimum v (6th axis) position value
     UINT    wVmax                              \ maximum v (6th axis) position value
     UINT    wCaps                              \ joystick capabilites
     UINT    wMaxAxes                           \ maximum number of axes supported
     UINT    wNumAxes                           \ number of axes in use
     UINT    wMaxButtons                        \ maximum number of buttons supported
     maxpnamelen                Field: szRegKey \ registry key
     max_joystickoemvxdname     Field: szOEMVxD \ OEM VxD in use
;struct

sizeof joycapsa         mkstruct: *lpjoycapsa


\ Not needed joyinfo is on the stack
\ :struct joyinfo
\      UINT wXpos                 \ x position
\      UINT wYpos                 \ y position
\      UINT wZpos                 \ z position
\      UINT wButtons              \ button states
\ ;struct
\ sizeof joyinfo         mkstruct: *lpjoyinfo


:struct joyinfoex
     DWORD dwSize           \ size of structure
     DWORD dwFlags          \ flags to indicate what to return
     DWORD dwXpos           \ x position
     DWORD dwYpos           \ y position
     DWORD dwZpos           \ z position
     DWORD dwRpos           \ rudder/4th axis position
     DWORD dwUpos           \ 5th axis position
     DWORD dwVpos           \ 6th axis position
     DWORD dwButtons        \ button states
     DWORD dwButtonNumber   \ current button number pressed
     DWORD dwPOV            \ point of view state
     DWORD dwReserved1      \ reserved for communication between winmm & driver
     DWORD dwReserved2      \ reserved for future expansion
;struct

sizeof joyinfoex         mkstruct: *lpjoyinfoex

: joyGetPosEx   (  dwFlags id -- result )
    >r [ sizeof joyinfoex ] literal
    struct, *lpjoyinfoex  joyinfoex dwSize  !
    struct, *lpjoyinfoex  joyinfoex dwFlags !
    *lpjoyinfoex r> call joyGetPosEx
 ;


\ About joyGetPosEx:
\ The information returned from joyGetPosEx depends on the flags you specify in dwFlags.
\
\ Result JOYERR_NOERROR if successful or one of the following error values.
\
\ Value Description
\ MMSYSERR_NODRIVER The joystick driver is not present.
\ MMSYSERR_INVALPARAM An invalid parameter was passed.
\ Windows 95/98/Me: The specified joystick identifier is invalid.
\
\ MMSYSERR_BADDEVICEID Windows 95/98/Me: The specified joystick identifier is invalid.
\ JOYERR_UNPLUGGED The specified joystick is not connected to the system.
\ JOYERR_PARMS Windows NT/2000/XP: The specified joystick identifier is invalid.
\
\ Remarks
\  This function provides access to extended devices such as rudder pedals,
\  point-of-view hats, devices with a large number of buttons, and coordinate
\  systems using up to six axes. For joystick devices that use three axes or
\  fewer and have fewer than four buttons, use the joyGetPos function.

: GetJoystickInfo       ( id -- x y z buttons )
   >r   0 0 0 0 sp@ r>  Call joyGetPos drop  4reverse
 ;

: MaxJoysticks          ( - #MaxJoysticks )     call joyGetNumDevs ;

: FindFirstJoyStick     ( -  *lpjoycapsa ID  )  \ ID should be <= MaxJoysticks
  *lpjoycapsa [ sizeof JOYCAPSA ] literal 2dup erase swap MaxJoysticks 0
        ?do     2dup  i Call joyGetDevCaps 0=
                  if   nip  I leave
                  then
        loop
 ;

: JoystickSetup         ( - )
   z" control joy.cpl" zEXEC-CMD abort" Can't use the setup in the control panel"
 ;

\s Tests and demo:

: JoystickTest          ( - )   \ Move the joystick and press some buttons
    FindFirstJoyStick nip dup MaxJoysticks <
        if      begin   cr dup GetJoystickInfo  dup>r .s 4drop 20 ms
                        r> JOY_BUTTON1 =
                until   \  the fire button has been pressed
        drop ." The fire button has been pressed."
        else    cr ." No joystick found."
        then
 ;

JoystickTest

\ joy_returnall FindFirstJoyStick joyGetPosEx . *lpjoyinfoex sizeof joyinfoex dump

\s
