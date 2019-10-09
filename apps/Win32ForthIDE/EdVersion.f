\ $Id: EdVersion.f,v 1.19 2013/12/09 21:34:03 georgeahubert Exp $

10214 value sciedit_version#

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
GAH George Hubert
CD  Camille Doiteau
JDV Jos v.d. Ven

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

\ ---------------------------------------------------------------------------
\ SciEdit changes
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

\ ---------------------------------------------------------------------------
\ Win32Forth IDE changes
\ ---------------------------------------------------------------------------

\ changes for Version 1.02.02

GAH     Friday,  June 9 2006
        - Made initialisation of Class and Vocabulary browsers a seperate task performed at start up
        rather than on first use.
GAH     Thursday,  June 29 2006
        - Modified to use seperate tasks for each of the browsers.
GAH     Saturday,  July 8 2006
        - Set priority of background tasks to idle to make main task respond to windows messages.
GAH     Monday,  July 17 2006
        - Adjusted task priority to below normal.
        - Made tabs multi-line.
dbu     Samstag, Juli 22 2006
        - Made the "Project" tab be the first in the tab window.
        - Removed CCS_ADJUSTABLE flag from the toolbar.

dbu     Sonntag, Juli 23 2006
        - Added a "Reset" command to the "Win32Forth" menu. This command
          will reset the remote I/O. After executuing this command it
          should always be possible to compile.

\ changes for Version 1.02.03
EAB	- added the ability to set colors for text and background. Set from the Preferences
	  dialog.
	- Removed the textboxes in the rebarcontrol.
	- Separated the editor toolbar and the project toolbar in the rebar.
	- Added a combobox for quick viewing of source for a word.
	- Ability to open HTML source for editing. Control and double-click in directory window.
	- Quick editing and previewing of HTML source docs. Press F10 in HTML source to preview in
	  in browser.

GAH     Saturday,  October 21 2006
        - Fixed search previous.

GAH     Monday,  October 23 2006
        - Find text in files highlights only the found string not the whole line.

EAB     Friday, January 05 2007
	- Added the ability to autoindent lines in the IDE editor. Enable in the IDE
	  Preferences dialog.
	- Added display of the current column to the status bar.

EAB	Saturday, April 14 2007
	- Added "Search and Replace" ability to the IDE editor. In the process corrected a few bugs in
	  ScintillaControl.f .

\ changes for Version 1.02.04
dbu Samstag, Mai 26 2007
    - Changed the shortkey for the "Winodw" menu to ALT-W.
    - Made the "Data Iquire" button in the "Debug" dialog work.
    - "Set breakpoint" CTRL+B command added

\ changes for Version 1.02.05
EAB	Sunday, October 21 2007
	- Added icon in toolbar for Search & Replace
	- Added "Compile selected text" to Tool menu
	Tuesday, November 27 2007
	- Implemented tabs in the editor for quick switching between files. Enabled
	  from the Preferences dialog.
	Saturday, December 01 2007
	- Added the Project Navigator to the IDE.

\ changes for version 1.02.06
EAB	Friday, April 18 2008
	- Integrated ForthForm into the IDE.
	Tuesday, April 22 2008
	- Made the Form Designer Window floatable. Selectable from Preferences dialog.

\ changes for version 1.02.07
CD	Monday, June 16 2008
        -Changes to messaging system
	-Reset before compile no longer necessary.

\ changes for version 1.02.08
EAB	Saturday, June 21 2008
	- Modified SaveSession & LoadSession to save and load current project and any
	  files open in the IDE in addition to forms.
	- Project Navigator now finds vector table constants i.e from SetCommand
	Saturday, July 05 2008
	- Enhance the Navigator. Separated data into private and global.
	  Added the parent class or object next to methods.

\ changes for version 1.02.09
EAB	Sunday, August 17 2008
	- Code can now be added to forms at design time. Right click
	  on a form or control to bring up the Form Code Editor.
	- Beginnings of documentation for the IDE written.
	Saturday, August 30 2008
	- Added splitter windows to the editor. Available from the Windows menu.

\ changes for version 1.02.10
EAB	Thursday, October 30 2008
	- Modified Forms Code Editor to use the IDE editor for editing form code. Full power of IDE
	  available to edit code. Also allows "on the fly" previewing of form code.
	January 27, 2009
	- Properties++ window have been tied to the main window for editing forms. More screen estate
	  available for editing code.
	Friday, March 20 2009
	- Enhanced the Project Navigator to track number of times entries are used in code.
	  Can be useful when navigating not only projects but the application source code
	  of others.
	Sunday, April 26 2009
	- Added application template loader for templates in \templates folder
	Saturday, May 02 2009
	- Added popup menu with some useful functions to right click of tabs in IDE editor

\ changes for version 1.02.11
EAB	Wednesday, July 08 2009
	- Added the ability to compile dialog forms directly to executable file. Available from right click menu.
	  Actually a good idea now that we can add code to a form at design time. Idea from Dirk Bruehl.
	Sunday, August 02 2009
	- Opened files can now be added to project
	Tuesday, August 11 2009
	- Added the ability to change the editor font.

\ changes for version 1.02.12
EAB     Tuesday, May 11 2010
        - Enhanced search & replace dialog to allow searching and replacing in opened files or
          entire folders.
        Friday, May 28 2010
        - Added feature to monitor file system and prompt a reload if a file has been
          modified. Enabled from options dialog
        - Auto saving of a session also enabled from options dialog. Last active files
          and project now available automatically on startup.
	- Added MessageBox builder dialog. Really just a port aka copy from BCX. Another example of adding
	  code to a form in Form Designer.
        Tuesday, June 22 2010
        - Which tabs are shown is now user configurable, and added a debug dialog ( not shown by default) tab.
        Sunday, July 11 2010
        -Enhancement to search & replace, auto detect disk file changes,debug tab.

\ changes for version 1.02.13
EAB     Tuesday, September 08 2010
        - Added quick search textbox to Project Navigator. After tracking a project highlight the list to be
          searched, type text in box and press enter. The entry that begins with the search text will be
          displayed.
        - Bug fix (if no form open and any button from Action dialog clicked would cause a crash).
        Saturday, November 06 2010
        - Filter specs in the directory tab can now be edited by pressing the control key and clicking the specs tab.
        - Bugfix for displaying .html files
        Monday, December 06 2010
        - Search&Replace dialog now uses combo boxes for text search and replace.
          This allows multiple specs to be specified and reused.
        Monday, December 27 2010
        - Depending on the editor font text can be incrementally zoomed by
          pressing Ctrl-+ (zoom in) and Ctrl-- (zoom out).
        - Option added to edit menu to choose text selection type; normal, column
          or by lines. Option applies to all source files.
        - Updated Scintilla dll to latest version, ScintillaControl.f to
        - include additional constants and allow further enhancements
        - Option added to allow editor caret to be positioned anywhere in the document
        Tuesday, January 04 2011
        - Pressing the control key when opening an HTML file, either from
          Project Manager or from a folder, will open the file for editing
          instead of browsing.
          Small addition to file tab (an asterisk) to indicate file has been modified
        Sunday, January 23 2011
        - Enhance the property form template dialog
        - IDE preferences are now from a property sheet. Less cumbersome
          to add further options. Bug fixes along the way!
        Thursday, January 27 2011
        - Add a quick find combo box to the toolbar. Searches from current position and always case insensitive.

GAH     Thursday,  April 28 2011
        - Opening from the command line (or with file association) captures the running instance rather than
        just giving an error message box.
        Wednesday,  May 25 2011
        - Using browse on .prj files or opening them with association now loads the project rather than opening
        the file for editing.

\ changes for version 1.02.14
GAH     Tuesday, September 19 2011
        -No longer close W32F when it's running IDE for debugging.
EAB     Wednesday, September 07 2011
        -Added handling of shift-key without console.
GAH     Friday, September 09 2011
        -Modified IDE to only update selection modes when not normal
        Tuesday, January 17 2012
        -Added checksums
GAH     Friday, November 15 2013
        -Added tray window class and ability to add minimise button to form designer.
        -Improved command line handling plus minor optimisations.
GAH     Wednesday, November 20 2013
        -Added extra task to speed up initialisation.

