\ $Id: sendmessage.f,v 1.4 2008/07/18 23:09:28 camilleforth Exp $

cr .( Loading sendmessage.f : )
cr .( ******** This file is deprecated and does nothing ********* )
cr .( *** Please remove any reference to it from your sources *** )



\ This file is now deprecated and does nothing when loaded.
\ SendMessage:Self is defined in the class Generic-Window in Generic.f.
\
\ : SendMessage:Self ( lParam wParam message -- result )   hWnd call SendMessage ;
\ : SendMessage:SelfDrop ( lParam wParam message -- )   SendMessage:Self drop ;
\
\ Applications that use controls which send messages to themselves are now 512 bytes smaller.
\ Tuesday, June 06 2006  18:09:33 Rod


\ This file was created for compatibility and to allow file sharing. Initially I
\ had put this definition in class Generic-Window
\ ":M SendMessage:     ( -- ) hwnd Call SendMessage ;M".
\ It allow controls and windows to send messages to themselves but
\ when I upgraded I had to rebuild each time. In addition it makes it easier to
\ share my apps because others probably wouldn't have this method in the generic
\ class and they would have to rebuild.


\s

Macro SendMessage:Self " hwnd Call SendMessage"
