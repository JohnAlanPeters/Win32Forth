\  loader for fcp3D.

synonym random-wf32 random

s" src\lib\OpenGl" "fpath+ \ For OpenGL support

needs fcp_inputwin.f

0 to ScreenDelay

: file-exist? (  ( adr len -- true-if-file-exist )
   find-first-file not dup>r
      if    find-close 2drop
      else  drop
      then
   r> ;

\ Needed-file aborts when the file is not found.
: needed-file  ( count adr - )
   2dup file-exist? not
       if    temp$ place  s"  is needed." temp$ +place
             s" Missing file" temp$ count infobox true abort" aborted."
       else  2drop
       then
 ;

s" t1600017.bmp" needed-file

true to static-scene

start-opengl-chess

 ' .board_ogl  is painting

\s
\ Still a challenge for Fcp:

setup  8/3K4/7N/2k8/8/8/2B3 b

