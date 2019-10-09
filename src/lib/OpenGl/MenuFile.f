Anew -MenuFile

  popup "&File"   menuitem   "&Load a bitmap"  load-bitmap ;
                  menuitem   "&Play captured frames"  show-#bitmaps ;
                  menuitem   "Save as &bitmap" hdc-pixmap save-as ;
                  menuitem   "&Capture frames" save#frames ;
                  menuitem   "E&xit"  bye ;
\s
