Anew -MenuOgl.f
 popup "&View"
                  menuitem   "Key - Function:" ;
         menuseparator
                  menuitem   "C - Change center-offset of the eye"
                           ['] fref3CenterC is-fref3D ;
                  menuitem   "D - Change the direction of the eye"
                           ['] fref4RotD    is-fref3D ;
                  menuitem   "E - Move the viewpoint of the eye"
                           ['] fref3eyeE    is-fref3D ;
                  menuitem   "F - Change up-offset of the eye"
                           ['] fref3upF     is-fref3D  ;
         menuseparator
                  menuitem   "G - Rotate cylinder using glRotatef"
                           ['] fref4RotG    is-fref3D ;

                  menuitem   "H - Change the size of the outlined cube"
                           ['] fref3SizeH   is-fref3D ;
                  menuitem   "I  - Move cylinder using glTranslatef"
                           ['] fref3TransI  is-fref3D ;

                  menuitem   "P - Change perspective"
                           ['] fref4PersP   is-fref3D ;
                  menuitem   "R - Rotate all objects"
                           ['] fref4RotR    is-fref3D ;
                  menuitem   "S - Change the scale"
                           ['] fref3ScaleS  is-fref3D ;
                  menuitem   "T - Move a scene using glTranslatef"
                           ['] fref3TransT  is-fref3D ;
                  menuitem   "X - Rotate around the center"
                           ['] fref4RotX    is-fref3D ;
         menuseparator
                  menuitem   "= - Increase interval"
                            incr_interval ;
                  menuitem   "-  - Decrease interval"
                            decr_interval ;
         menuseparator
                  menuitem   "Home - Reset active function"
                            reset-active-function ;
                  menuitem   "Del - Reset all functions"
                            clear-all-offsets ;

 popup "&Light"
                  menuitem   "Key - Function:" ;
         menuseparator
                  menuitem   "L - Change the light position"
                           ['] fref3LpositionL is-fref3D ;
                  menuitem   "N - Ambient "
                           ['] fref4LambientN  is-fref3D ;
                  menuitem   "V - Diffuse"
                           ['] fref4DiffuseV   is-fref3D ;

 popup "&Options"
                  menuitem   "Key - Function:" ;
         menuseparator
                  menuitem   "W - Full screen or window"
                          start-FullscreenOpenGLWindow ;
                  menuitem   "Z - Start/stop rotating"
                          start/stop-slow-action  ;
                  menuitem   "F1 - Full screen to window"
                          fullscreen-to-window  ;
         menuseparator
                  menuitem   "Sounds on/off"
                           sounds_on/off not to sounds_on/off ;
                  menuitem   "Maximum frames/second"
                           set-speed-fps ;
                  menuitem   "Maximum rotation speed"
                           set-speed-degrees ;


 popup "&Help "
                  menuitem   "First choose a scene." ;
                  menuitem   "Choose a function in the View or Light menu." ;
                  menuitem   "Then use the Cursor keys"  ;
                  menuitem   "PageUp PageDown , or . " ;
                  menuitem   "to change them." ;
                  menuitem   "Press Esc to get parameters or stop an animation." ;

 popup "&Info V2.2"
  false menumessage  "Date: August 23st, 2001."
  false menumessage  "WARNING: Long time interaction with computers can be hazardous."
  menuitem "Released from: http://home.planet.nl/~josv" s" http://home.planet.nl/~josv" ogl-hwnd "Web-Link ;

\s
