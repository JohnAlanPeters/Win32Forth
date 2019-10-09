\ OldConsoleMessaging.f


\ This file contains the old console messaging system (via the w32fmsg-chain)


\ ------------------------------------------------------------------------------
\ Moved here from primutil.f
\ ------------------------------------------------------------------------------

(( [cdo] removed after new console
new-chain        w32fmsg-chain  \ chain of forth console win32forth messages
))


\ ------------------------------------------------------------------------------
\ Moved here from editor_io.f
\ ------------------------------------------------------------------------------

(( [cdo] removed after new console
IN-SYSTEM
INTERNAL
: (Conw32fMsgHandler) ( addr len w32fmsg AppIDsender result -- addr len w32fmsg AppIDsender result )
                2 pick
                CASE
                  \ Debugger support from forth side
                  WM_SETBP     OF drop 3 pick do-set-breakpoint      ENDOF
                  WM_STEPBP    OF 0x0D           db-pushkey  drop -1 ENDOF
                  WM_NESTBP    OF 'N'            db-pushkey  drop -1 ENDOF
                  WM_UNESTBP   OF 'U'            db-pushkey  drop -1 ENDOF
                  WM_CONTBP    OF 'C'            db-pushkey  drop -1 ENDOF
                  WM_JUMPBP    OF 'J'            db-pushkey  drop -1 ENDOF
                  WM_BEGNBP    OF 'P'            db-pushkey  drop -1 ENDOF
                  WM_HEREBP    OF 'P' +k_control db-pushkey  drop -1 ENDOF
                  WM_RSTKBP    OF 'R'            db-pushkey  drop -1 ENDOF
                  WM_DONEBP    OF 'D'            db-pushkey  drop -1 ENDOF
                  WM_INQUIRE   OF 4 pick do-inquire          drop -1 ENDOF
                  \ put the received key in the input stream
                  WM_KEY       OF 4 pick c@ pushkey          drop -1 ENDOF
                  \ request to copy text from clipboard and compile it
                  WM_PASTELOAD OF paste-load                 drop -1 ENDOF
                ENDCASE ;

IN-APPLICATION

: Conw32fMsgHandler ( addr len w32fmsg AppIDsender result -- addr len w32fmsg AppIDsender result )
\ *G Console win32forth-specific messages handler
                TURNKEYED? ?EXIT        \ exit if no heads are present
\IN-SYSTEM-OK   (Conw32fMsgHandler) ;

w32fmsg-chain chain-add Conw32fMsgHandler
))


\ ------------------------------------------------------------------------------
\ Moved here from w32fmsg.f
\ ------------------------------------------------------------------------------

(( [cdo] removed after new console

\ ------------------------------------------------------------------------------
\ The win32forth message handler for the Console
\ ------------------------------------------------------------------------------

\ *P \nIn the second case, you do not have direct access to the Console message
\ ** handler. Instead a chain is provided that emulates a CASE statement by
\ ** containing every win32forth message handler you create. As each handler in
\ ** the chain is executed in turn, input and output parameters of each message
\ ** handler must be the same, ie :

\ *E MyMsgHandler  ( addr siz w32fmsg w32fAppIDSender result -- add siz w32fmsg w32fAppIDSender result )

\ *P Only the result's contents may be changed.

: HandleW32FMsgs { hwnd msg wParam lParam -- flag }
\ This is the callback which handles the win32forth specific messages.
\ It is called in the windows procedure of the console window of win32forth.
        msg WM_COPYDATA =
        if   hwnd msg wParam lParam
             Decodew32fMsg 0          \ default result
             w32fmsg-chain do-chain   \ perform the handlers
             >r 4drop r>              \ leave result
        else hwnd msg wParam lParam
             DefaultWindowProc        \ use default handler
        then ;

1 PROC TranslateMessage
1 PROC DispatchMessage

: HandleMessages { pMsg -- 0 }
\ This is the word which handles the messages sent by windows to the Console.
\ The chain MSG-CHAIN receives all messages. This word is called by WINPAUSE, and
\ is also used as a callback by the console.
        pMsg TRUE msg-chain do-chain nip
        if   pMsg Call TranslateMessage drop
             pMsg Call DispatchMessage  drop
        then 0 ;

1 callback &HandleMessages HandleMessages \ callback to handle Windows messages
4 callback &HandleW32FMsgs HandleW32FMsgs \ callback to handle Win32Forth messages
0 callback &bye            bye            \ callback to terminate forth

: HandleConMsgInit ( -- ) \ initialize Console system callbacks
		&HandleMessages  &CB-MSG    !
                &HandleW32FMsgs  &CB-WINMSG !
                &bye             &CB-BYE    ! ;

initialization-chain chain-add HandleConMsgInit
HandleConMsgInit


: do-chain      ( chain_address -- )

))

(( [cdo] removed after new console
\ ------------------------------------------------------------------------------
\ An example : the win32forth message WM_BEEPME
\ ------------------------------------------------------------------------------

\ *A Here is a full example of win32forth-specific message in the case of Console :
\ *+
\ 123456 constant WM_BEEPME    \ a win32forth-specific message number

: w32fmsg-beep  ( addr siz w32fmsg w32fAppIDsender result -- addr siz w32fmsg w32fAppIDsender result )
                \ w32fAppIDSender is the sender's ID, we don't care here
                \ w32fmsg is the win32forth message number
                \ addr siz is the data area passed with the message, 0 0 here
	        \ For the message chain to work as a CASE statement, the
                \ input and output parameters must remain exactly the same,
                \ except the "result" item whose content may be changed.
                2 pick WM_BEEPME =
                if   beep drop -1
                then ;

\ then you add your message handler to the chain
w32fmsg-chain chain-add w32fmsg-beep

\ Now any application can send the message "WM_BEEPME" to all running instances of
\ Win32Forth applications sharing memory

: BeepAll       ( -- )
                0 0 WM_BEEPME BroadCastw32fMsg ;
\ *-
))









