\ $Id: AddPVResourcesToWin32for.f,v 1.2 2013/12/09 21:34:02 georgeahubert Exp $

\ PVResources.f     Script for adding the resources into PictureViewer.exe
\                   February 2006  Rod Oakford
\                   Make a copy of Win32for.exe, rename it PVWin32for.exe while running this script
\                   Use PVWin32for.exe to fload PictureViewer.f which will now contain all the resources

Needs Resources.f

version# ((version)) 0. 2swap >number 3drop 7 < dup [if] winver winnt4 < and [then] 0=
[if]  \ Not for V6.xx.xx older OSs

s" PVWin32for.exe" "path-file drop AddToFile

149 s" Res\HandOpen.cur" "path-file drop AddCursor
\ 150 s" Res\HandClosed.cur" "path-file drop AddCursor
151 s" Res\Blank.cur" "path-file drop AddCursor
100 s" Res\Ico100.ico" "path-file drop AddIcon
101 s" Res\Picture.ico" "path-file drop AddIcon
102 s" res\Toolbar.bmp"  "path-file drop AddBitmap
139 s" Res\icon-tif.ico" "path-file drop AddIcon
140 s" Res\icon-iff.ico" "path-file drop AddIcon
141 s" Res\icon-jpg.ico" "path-file drop AddIcon
142 s" Res\icon-pcd.ico" "path-file drop AddIcon
143 s" Res\icon-pcx.ico" "path-file drop AddIcon
144 s" Res\icon-png.ico" "path-file drop AddIcon
145 s" Res\icon-psd.ico" "path-file drop AddIcon
146 s" Res\icon-tga.ico" "path-file drop AddIcon
147 s" Res\icon-bmp.ico" "path-file drop AddIcon
148 s" Res\icon-gif.ico" "path-file drop AddIcon
100 RT_DIALOG s" res\IDD_ABOUTBOX.dlg"    "path-file drop  AddResource
131 RT_DIALOG s" res\IDD_OPTIONS_DIALOG.dlg"     "path-file drop  AddResource
148 RT_DIALOG s" res\IDD_KEY_HELP.dlg"  "path-file drop  AddResource

\ false EndUpdate

UpdateFile

[THEN]
