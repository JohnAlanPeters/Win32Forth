\ $Id: Pl_Version.f,v 1.21 2006/12/06 19:20:56 jos_ven Exp $

anew -Pl_Version.f

10128 value player_version#

\ Version numbers: v.ww.rr
\
\ v   Major version
\ ww  Minor version
\ rr  Release
\
\ Odd minor version numbers are possibly unstable beta releases.

: (.player_version)    ( -- addr len )
                player_version# 0 <# # # '.' hold # # '.' hold #s #> ;

create player-compile-version time-len allot  \ a place to save the compile time
get-local-time                                \ save as part of compiled image
time-buf player-compile-version time-len move \ move time into buffer

\ ---------------------------------------------------------------------------
\s ---------------------  Initals of developers -----------------------------
\ ---------------------------------------------------------------------------
BRG Bruno Gauthier  bgauthier@free.fr
JOS Jos van de Ven  josv@wxs.nl
DBU Dirk Busch      dirk@win32forth.org

\ ---------------------------------------------------------------------------
\ ----------------------  Known bugs ----------------------------------------
\ ---------------------------------------------------------------------------

- sometimes videos aren't displayed (need to resize the window first to see them)

\ ---------------------------------------------------------------------------
\ ----------------------  Wish list -----------------------------------------
\ ---------------------------------------------------------------------------

 - Create *.m3u files and import them the catalog
 - Columns in the treeview.

\ ---------------------------------------------------------------------------
\ ----------------------  Change Log ----------------------------------------
\ ---------------------------------------------------------------------------

\ changes for Version 1.01.06
dbu     Samstag, April 16 2005
        - Play files from a 'Generic M3U' playlist file (*.m3u)
        - Play files via Drag and Drop
        - File Pl_Version.f added
        - Moved the About dialog int Pl_About.f
jos     - Sorting the catalog (by name and by random)
        - Display the catalog window at startup

\ changes for Version 1.01.07
dbu     Sonntag, April 17 2005
        - Splitted the main window into two parts. The left part
          is used to display the catalog and the right part is used
          to display the video output
        - File Pl_MciWindow.f added

\ changes for Version 1.01.08
jos     - Search in the catalog and handle a collection

\ changes for Version 1.01.09
jos\dbu Samstag, April 23 2005
        - Speedup the refresh of the catalog window

          The elapsed times for Refresh on my (dbu)
          PII-400 with 590 Files to display are:

          30.71 sec with the old code from Version 1.01.08
           4.89 sec with JOS changes
           1.28 sec with my (dbu) changes

dbu     - Checking the file extention's when adding directorys to the catalog
        - New file Pl_Toolset.f added
        - Some minor changes

\ changes for Version 1.01.10
dbu     Sonntag, April 24 2005
        - Player 4th now add's an icon into the windows traybar.
          If the player is minimiszed the main window and the "Control center"
          will be hidden. With a click on the traybar-icon the windows will be
          made visible again. If a Video is played when minimizing the window
          it will be paused.

\ changes for Version 1.01.11
Jos     April 25th, 2005
        - Made Refresh about 2* faster.

\ changes for Version 1.01.12
Jos     May 2nd, 2005
        - Made Refresh again faster
          (The Treeview was loaded 2 times when it was refreshed)
        - Added a freelist, delete and undelete

\ changes for Version 1.01.13
Jos     May 4th, 2005
        - Fixed 2 bugs. Now PathMediaFiles.dat must exist.

\ changes for Version 1.01.14
Jos     May 4th, 2005
        - Fixed 1 bug in add-to-catalog.

\ changes for Version 1.01.15
Jos     May 10th, 2005
        - When the catalog is randomsized the least played file will be
          shown first in its randomsized group.
        - Made it possible to change the maximum randomlevel.

\ changes for Version 1.01.16
dbu     Sonntag, Mai 15 2005
        - Replaced my MciClass with Rod's MCIControl class

\ changes for Version 1.01.17
dbu     Sonntag, August 07 2005
        - Fixed some problems when resizing the Player4 window while playing videos.

\ changes for Version 1.01.18
Jos     September 29th, 2005
        - Made it possible to drag and drop files into de catalog

\ changes for Version 1.01.19
Jos     September 29th, 2005
        - Enabled a fileselector to add files into de catalog

\ changes for Version 1.01.20
Jos     October 19th, 2005
        - Added a form to define a view.

\ changes for Version 1.01.21
Jos     October 26th, 2005
        - Changed the shellsort and added more views

\ changes for Version 1.01.22
        - A lot of undocumented changes...

\ changes for Version 1.01.23
dbu     Sonntag, Mai 21 2006
        - Rewritten the Command handling by using an accelerator-key-table.

\ changes for Version 1.01.24
Jos: Added a the following joystick commands:
button1      next
button2      reserved for joystick browsing
button3      decreasevolume
button4      increasevolume
button5      pause/resume
button6      shutdown the pc

\ changes for Version 1.01.25
Jos: June 28th, 2006.
Added a Joystickbrowser and some more button commands. They are now:
button1   Next OR the current selected record
button2   Change the Font into big or small
button3   DecreaseVolume
button4   IncreaseVolume
button5   PAUSE/RESUME
button6   shutdown the pc
button9   Opens the item that is playing from the catalog

Movements: Forward:  Up in tree
           Backward: Down in tree
           Left:     Close child in tree
           Right:    Open child in tree

Added also an option to disable the joystick to avoid conflicts with games etc.

To keep the movements in the treeview under control you must move the
joystick between the center and a direction outside the center and then back to
the center to prevent continuous scrolling,
Push the joystick to the right when you would like to go in an already open child
in a tree.

\ changes for Version 1.01.26
Jos: July 8th, 2006.
File names will now be relative stored when a search path is filled.

\ changes for Version 1.01.27
Jos: July 19th, 2006.
The catalog now only adds a new record to the catalog when it is not a duplicate.
2 records are considered to be duplicate when the
medialabel, relative filename and filesize are the same.

\ changes for Version 1.01.28
Jos: December 6th, 2006.
Made the catalog of the player ROM bootable.
The idea is to burn a CD or DVD with a configured Player4 and some music.
As soon as that disk is put in the drive player4 will auto-start and
act according its configuration. It might even start playing and go
to the tray bar.
Steps to make a DVD:
Copy player4.exe and autorun.inf to a directory on your HD
Make a directory in it called files.
Copy the music into the directory files
Start Player4
Choose in the menu Options for Setup a search path catalog
Select the music directory
Choose in the menu Catalog for Import directory tree...
Activate you favorite flags such as: Auto play the catalog at the start
Note: The sort flags can also be used.
Leave Player4

Burn the disk in such a way that the files:

autorun.inf
catalog.dat
catalog.idx
PathMediaFiles.dat
Player4.exe

are in the root together with the directory Files.

When the autostart option is still on in your PC then it will start
player4 as soon as the disk is put in the drive.


