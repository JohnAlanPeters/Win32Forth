\ $Id: w32fMsgList.f,v 1.6 2013/11/15 19:35:03 georgeahubert Exp $

\ w32fMsgList.f

\ By Camille Doiteau [cdo] - 2008/05/20

\ ------------------------------------------------------------------------------
\ This file contains data that is not part of the messaging engine itself but is
\ needed allthesame for win32forth applications pools wanting to communicate : it
\ enumerates :
\ - all currently existing win32forth "appID"
\ - and all the messages ID they can handle
\ ------------------------------------------------------------------------------

cr .( Loading w32fMsgList.f : applications & messages IDs...)

\ only forth also definitions
\ anew -w32fMsgList.f


\ ------------------------------------------------------------------------------
\ Currently existing w32fApp unique identifiers
\ ------------------------------------------------------------------------------

\ The win32forth applications pool IDs are organized by Major release. These comments
\ are indeed remainders of all the IDs already used.
\ Notice that there is no reason for two different releases to communicate. So
\ only the current release IDs are actually activated.

\ applications whose version live besides a release
\    3333 = WinEd30202

\ release 6.12.00 (actually these IDs were not set in release 6.12.00)
\    6120 = Win32Forth61200
\    6121 = Win32ForthIDE61200

\ pseudo-release 6.13.00
\    6130 = Win32Forth61300
\    6131 = Win32ForthIDE61300
\    6132 = Win32ForthHelp61300


\ ------------------------------------------------------------------------------
\ Current-release IDs and filenames
\ ------------------------------------------------------------------------------

\ the following values are updated automatically when the major release changes.
\ If needed, filenames are the only things to be
\ changed for a new release

3333 value w32fWinEd
version# 100 / 10 * value w32fForth
w32fForth 1 +       value w32fIDE
w32fForth 2 +       value w32fHelp

w32fIDE value w32fEditor   \ current editor, defaults to IDE, can be WINED

: w32fAppID>Filename ( w32fappID -- addr len )
		\ Give the filename associated to an app ID
                case
                  w32fForth  of s" Win32For.exe" endof
                  w32fIDE    of s" Win32ForthIDE.exe" endof
                  w32fHelp   of s" Help.exe" endof
                  w32fWinEd  of s" WinEd.exe" endof
                endcase ;


\ ------------------------------------------------------------------------------
\ In and out win32forth message numbers available for each w32fapp
\ ------------------------------------------------------------------------------

\ These message numbers must be defined in all applications of the win32forth
\ pool of applications so that they can communicate. The comments give, for
\ each message, if it is an incoming or outgoing message and its use.
\ Althought a sender and a receiver are specified while messaging, it is better
\ to define different messages numbers accross all applications communicating.
\ Also, these messages are likely to be used by every release.

\ The basic parameters for a message are "addr" "size" of a data area
\ All messages return -1 if the message was processed, 0 if not


\ Sender : any     Receiver : any
\ -------------------------------
123456 constant WM_BEEPME      \ ask the receiving app to beep (addr=len=0)

\ Sender : all     Receiver : Help
\ --------------------------------
123401 constant WM_WORDHELP    \ ask help to display quickinfo for a word
                               \ addr size = word (return 0 if not in database)
123402 constant WM_LINEFILE    \ ask Help to display file for a word
                               \ addr size : cell = line ; string = filename
123403 constant WM_HTML        \ ask help to display an html sheet
                               \ addr size : string = url

\ Sender : Help     Receiver : Forth
\ ----------------------------------
123407 constant WM_SHOWDEFER   \ send DEFER name and expect that receiver will
                               \ display its current contents
                               \ addr size = word

\ Sender : all    Receiver : Forth
\ --------------------------------
123701 constant WM_KEY         \ give Forth a key (addr size contains: byte = key)
123702 constant WM_PASTELOAD   \ tell Forth to get text from the clipboard and
                               \ compile it - the sender is supposed to have
                               \ filled the clipboard with code (addr=len=0)

\ Sender : IDE (debugger)    Receiver : Forth
\ -------------------------------------------
123502 constant WM_SETBP       \ tell the forth console to set a breakpoint on a word
                               \ ie: tell it to start debugging the word
                               \ addr size : word name   result =0 failed -1 success
123503 constant WM_STEPBP      \ single step (addr=len=0)
123504 constant WM_NESTBP      \ nest into this definition (addr=len=0)
123505 constant WM_UNESTBP     \ unnest to definition above (addr=len=0)
123506 constant WM_CONTBP      \ continuous step till key (addr=len=0)
123507 constant WM_JUMPBP      \ Jump over next Word (addr=len=0)
123508 constant WM_BEGNBP      \ proceed to def again (addr=len=0)
123509 constant WM_HEREBP      \ proceed to this point again (addr=len=0)
123510 constant WM_RSTKBP      \ show Return stack (addr=len=0)
123511 constant WM_DONEBP      \ done, run the program (addr=len=0)
123513 constant WM_INQUIRE     \ send a string to forth so that forth evaluate it
                               \ addr siz = string (result via WM_RESPONSE)

\ Sender : Forth   Receiver : IDE
\ -------------------------------
123501 constant ED_RESPONSE    \ answer a WM_INQUIRE msg with result of evaluate
                               \ addr siz = string

123602 constant ED_WORD        \ Forth tells the IDE to highlight the word (token)
                               \ currently pointed to by the debugger. Addr siz
                               \ contains: cell1 = line ; cell2 = column
123603 constant ED_STACK       \ send  stacks (addr siz contains:
                               \ 64 cells  = data stack
                               \ maxstring = return stack
123604 constant ED_DEBUG       \ receive debug (addr siz = ed-dbgline)

123605 constant ED_OPEN_EDIT   \ remote open file for edit
123606 constant ED_OPEN_BROWSE \ "           file for browse only
123607 constant ED_WATCH       \ "           file for display source for debugger
                               \ in these 3 msgs, addr siz contains:
                               \ cell1 = line number ; maxpath+1 = filename
123608 constant ED_NAME        \ send currently debugged name
                               \ addr siz = string = word name


