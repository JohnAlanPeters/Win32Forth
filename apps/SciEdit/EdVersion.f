\ $Id: EdVersion.f,v 1.10 2006/05/07 06:34:26 dbu_de Exp $

10128 value sciedit_version#

\ Version numbers: v.ww.rr
\
\ v   Major version
\ ww  Minor version
\ rr  Release
\
\ Odd minor version numbers are possibly unstable beta releases.

: (.sciedit_version)    ( -- addr len )
                sciedit_version# 0 <# # # '.' hold # # '.' hold #s #> ;

create sciedit-compile-version time-len allot  \ a place to save the compile time
get-local-time                                 \ save as part of compiled image
time-buf sciedit-compile-version time-len move \ move time into buffer

\s

\ ---------------------------------------------------------------------------
\ ----------------------  Initals of developers -----------------------------
\ ---------------------------------------------------------------------------
DBU Dirk Busch (dirk@win32forth.org)
EAB Ezra Boyce
ROD Rod Oakford

\ ---------------------------------------------------------------------------
\ ----------------------  Known bugs ----------------------------------------
\ ---------------------------------------------------------------------------
- Ctrl+a ctrl+c in the html browser window does not copy to the clipboard (jos)
- In a html browser window, the filename isn't updated in the tiltlebar when a
  file is opened by selecting a link in the html file (dbu)
- When using hyperlinking somtimes SciEdit ends in an endless loop displaying
  error messages in a MessageBox. (dbu) - Fixed: Samstag, August 20 2005 dbu

\ ---------------------------------------------------------------------------
\ ----------------------  Wish list -----------------------------------------
\ ---------------------------------------------------------------------------
- Ability to compile a line or selected text (erza)
- Text search with regular expressions (the sintilla control can do this) (dbu)
- Search and replace text (dbu)
- The hyperlinking to this source code my places the source about
  three lines from the bottom of the screen in a 25 lines screen.
  Ability much nicer to have the source code appear a few lines down
  from the top of the window since source code usually trails on
  down below the word in question (jap)
- Open the last active files on startup (dbu)
- Also searching backwards is useful at times. (george)
- User defined color's for the Background and the Text (dbu)
- Convert Tab's to spaces and spaces to Tab's (RBS)
- If a second copy of a file is opend SciEdit currently activates the first
  copy only. It should better check if the copy on the disk is newer than
  the ony in memory, and ask the user to load the newer one. (dbu)
- Monitor the file-system, and ask the user to reload a file if it was modified.

\ ---------------------------------------------------------------------------
\ ----------------------  Change Log ----------------------------------------
\ ---------------------------------------------------------------------------

\ changes for Version 1.01.02
dbu     Samstag, August 14 2004
        - New "View" and "Options" menu
        - New Menu entry "Save all Files before Compile" in the "Options" menu.
          If this option is active all open source files will be saved before
          the compilation of the active file. If this option is inactive only
          the active file will be saved
        - Enhanced toolbar

\ changes for Version 1.01.03
dbu     Sonntag, August 15 2004
        - New menu Entry "Colorize source" in the "View" menu to turn colorization
          on and off (new w32fScintilla.dll Version 1.6.1.4 is needed).
dbu	Montag, August 16 2004
        - New menu Entry "Display Line numers" in the "View" menu (thank's
          Erza to tell me how it works).

\ changes for Version 1.01.04
dbu	Samstag, August 21 2004
        - New Menu entry "Customize toolbar..." in the "Options" menu
        - made debug support work
        - "Search..." and "Find text in Files..." now grab the highlighted text

\ changes for Version 1.01.05
dbu	Sonntag, August 22 2004
        - New "Close file" and "Close all" buttons in the toolbar
        - enable/disableing of toolbar buttos and menu entries corrected

\ changes for Version 1.01.06
dbu	Samstag, August 28 2004
        - New Menu entries "Line cut...", "Line copy", "Line transpose",
          "Line duplicate", "Lowercase" and "Uppercase" in the "Edit" menu.
        - Little enhancement of the debug support

\ changes for Version 1.01.07
dbu	Sonntag, August 29 2004
        - Added a recent file list to the File menu (Thank's Rod for the code)

\ changes for Version 1.01.08
dbu	Samstag, September 04 2004
        - Fixed some Win98 bug's (I hope) as Rod sugested
        - Deleted some duplicated command id's (thank's Prad)
        - Removed the obsolate Download stuff
        - Changed the "Open Source files" and "The open HTML Files" dialog's
          to allow multiple selection of files
        - Fixed a bug in the recent file list (HTML files were opend for editing
          and not for displaying HTML)
        - Enabled Drag & Drop from windows explorer to open files.
        - Changed to open only one copy of a file. If you try to open a second
          copy the window of first one is activated and it beep's one time.
        - New menu entry "Set Tab options..." in the options menu. It opens
          a dialog were you can set the tab size (between 1 and 8 chars) and
          if you want to insert real tab's or spaces (soft tab's)

\ changes for Version 1.01.09
dbu	Sonntag, September 05 2004
        - Fixed a bug in the Class browser; once it was closed it couldn't be
          opend again
        - New entries in the "Options" menu to hide the Toolbar and/or Statusbar
          of the main window
dbu	Montag, September 06 2004
        - Added a Statusbar to the Class browser window to tell the user how
          to open the source for a definition
        - In Brwose mode the statusbar of the main window now displays a text
          how to use the browse mode.

\ changes for Version 1.01.10
dbu	Dienstag, September 07 2004
        - New menu entry "Open Highlighted File" in "File" menu (it need's some more work)

\ changes for Version 1.01.11
dbu	Donnerstag, September 09 2004
        - Fixed the WM_COMMAND handling problems (I hope)
        - Fixed the NewFile: method of the EditorChild class whitch was complety broken

\ changes for Version 1.01.12
dbu	Samstag, September 11 2004
        - Accelerator table support rewritten

\ changes for Version 1.01.13
dbu	Samstag, September 11 2004
        Sonntag, September 12 2004
        - WM_COMMAND handling reworked (I hope that it's finaly working now)

\ changes for Version 1.01.14
dbu	Dienstag, September 14 2004
        - Fixed the display of the filename in the Titlebar

\ changes for Version 1.01.15
dbu	Donnerstag, September 16 2004
        - Fixed loading of files

\ changes for Version 1.01.16
dbu	Samstag, September 18 2004
        - Fixed some smal bugs in the colorization support

\ changes for Version 1.01.17
dbu	Samstag, Oktober 02 2004
        - SciEditMDI now has it's own Icon's for the Main- and the MDI-windows

\ changes for Version 1.01.18
dbu	Mittwoch, Oktober 06 2004
        - Changed to use Rod's AcceleratorTables.f instead of my Accel.f

\ changes for Version 1.01.19
dbu	Montag, November 08 2004
        - Update w32fScintilla.dll to use the latest Scintilla Version 1.62
        - File>Exit terminated SciEdit without saving changed files; fixed

\ changes for Version 1.01.20
dbu	Samstag, Dezember 04 2004
        - New Button's "Back" and "Forward" added to the toolbar
          used to navigate within HTML documents and for browseing within
          the source files (Hyperlinking)

\ changes for Version 1.01.21
dbu	Sonntag, Dezember 26 2004
        - New command "Help for highlighted Win32-API function" added to
          the help menu. The Win32-SDK help file is needed for this command.
          If you don't have a copy you can download it from:

          http://www.borland.com/devsupport/borlandcpp/patches/BC52HLP1.ZIP

          Don't forget to copy the win32.hlp file into the 'doc\hlp' folder of
          your Win32Forth version

\ changes for Version 1.01.22
dbu     Freitag, August 19 2005
        - SciEdit append a null byte to any file that was saved to disk.
          Thank's Ezra for reporting this bug.

\ changes for Version 1.01.23
dbu     Samstag, August 20 2005
        - Fixed some bugs in the hyper-linking and in the debug-interface.
EAB     August 21, 2005
        - Added a little integration with ForthForm. If SciEdit is open
          ForthForm will use it for editing/viewing sources. Modification
          in EdRemote.f.
dbu     August 21, 2005
        - Made the communication beetween SciEdit and the console window
          work a better (I hope).
        - New menu entry "Handle debug messages?" in the Win32Forth menu
          to turn off the handling of the debug messages from the console
          window.

\ changes for Version 1.01.24
dbu     Mittwoch, August 31 2005
        - New options "Remove trailing white space" and "Ensure final line ending"

\ changes for Version 1.01.25
dbu     Donnerstag, Dezember 08 2005
        - New "Glossary" command (ALT+G), that turns the selected lines into
          a glossary entry (for DexH)

\ changes for Version 1.01.26
dbu     Sonntag, Januar 08 2006
        - New "DexH" menu.
        - Moved "Glossary" command into the DexH menu.
        - New "Bold" command (ALT+B) that turns the selected text into bold style
	  for DexH.
        - New "Italic" command (ALT+I) that turns the selected text into italic
	  style for DexH.
        - Fixed some bugs.

\ changes for Version 1.01.27
dbu     Samstag, Januar 21 2006
        - New "Paragraph" command (ALT+P), that turns the selected lines into
          a paragraph (for DexH)
        - New "Code paragraph" command (CTRL+ALT+C), that turns the selected lines
	  into a paragraph that is a code example (for DexH).
        - New "Typewriter" command (CTRL+ALT+T) that turns the selected text into
	  typwriter style for DexH.

\ changes for Version 1.01.28
Rod     Saturday, May 06 2006
        - Added Print and PageSetup
