\ $Id: SudokuResources.f,v 1.5 2013/12/09 21:34:03 georgeahubert Exp $
\ SudokuResources.f     Script for adding the resources into Sudoku.exe
\                       September 2005  Rod Oakford

Needs Resources.f


version# ((version)) 0. 2swap >number 3drop 7 < dup [if] winver winnt4 < and [then] 0=
[if]  \ Not for V6.xx.xx older OSs

&forthdir count pad place
s" Sudoku.exe" pad +place
pad count "path-file drop AddToFile

CREATEPROCESS_MANIFEST_RESOURCE_ID RT_MANIFEST s" Sudoku.exe.manifest" "path-file drop  AddResource
101 s" res\Sudoku.ico"   "path-file drop  AddIcon
142 s" res\arrow_m0.cur" "path-file drop  AddCursor
143 s" res\arrow_m1.cur" "path-file drop  AddCursor
144 s" res\arrow_m2.cur" "path-file drop  AddCursor
145 s" res\arrow_m3.cur" "path-file drop  AddCursor
146 s" res\arrow_m4.cur" "path-file drop  AddCursor
147 s" res\arrow_m5.cur" "path-file drop  AddCursor
148 s" res\arrow_m6.cur" "path-file drop  AddCursor
149 s" res\arrow_m7.cur" "path-file drop  AddCursor
150 s" res\arrow_m8.cur" "path-file drop  AddCursor
151 s" res\arrow_m9.cur" "path-file drop  AddCursor
153 s" WAVE" asciiz  s" Applause7.wav" "path-file drop  AddResource


false EndUpdate

\ UpdateFile

[THEN]
