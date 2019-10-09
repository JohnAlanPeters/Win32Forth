\ $Id: GENERIC.F,v 1.33 2013/12/17 19:25:22 georgeahubert Exp $

\ *D doc\classes\
\ *! Generic
\ *T Generic-Window -- Base class for all window objects.

\ *P Generic-Window is the base class for all window objects.  This class
\ ** contains an ivar, hWnd, that is the (MS Windows) handle for the
\ ** window.  This class encapsulates all the Win32 API calls that specify a
\ ** window handle.  There will be the following subclasses of Generic-Window:

\ *W <ul>
\ *W <li><a href="class-Window.htm">Window</a> Adds a device context and the ablility to display text and graphics output.</li>
\ *W <li><a href="class-Dialog.htm">Dialog</a> Support for dialog boxes</li>
\ *W <li><a href="class-Control.htm">Control</a> Adds support for the standard Win32 controls with subclassing.</li>
\ *W </ul>

\ *P Since Generic-Window is a generic class it should not be used to create
\ ** any instances. \n
\ ** The Global Rectangle objects wRect and WndRect ( originally
\ ** defined in Window.f ) are now synonyms of temprect ( defined in class.f )
\ ** which has been made a User Object so that
\ ** Windows in different threads don't interfere with each other's drawing
\ ** operations. \n



\ *S Glossary


Needs Dc.f

cr .( Loading Generic Window...)

in-system

\ Linked list, to hold all dictionary window objects.
VARIABLE windows-link
         windows-link OFF

in-previous

\ Linked list, to hold all modeless dialog, Frame window and MDI child window objects
\ that respond to dialog messages.
cell NewUser dialog-link
             dialog-link  OFF

\ Normally wRect is called by methods and : definitions inside generic-window, however the
\ original global object is used by Lib\RegistryWindowPos.f so we define it
\ as an alias for backward compatibility.

' TempRect Alias wRect           \ Can't be made a colon def - [cdo-2008May13]
' TempRect Alias WinRect

\ Moved from control.f since it's also used by descendants of the class window.
\ Made thread-safe gah Sunday, May 20 2007
: get-mouse-xy  ( hWnd -- x y)               \ W32F
\ *G Return the co-ordinates of the mouse pointer in window, hWnd.
                { hWnd | CursorPoint -- x y }
                2 cells localalloc: CursorPoint
                CursorPoint      Call GetCursorPos   drop
                CursorPoint hWnd Call ScreenToClient drop
                CursorPoint 2@ swap ;

in-system

:CLASS  Generic-Window    <Super Object
\ *G Base class for all window objects.

in-application

\ -----------------------------------------------------------------
\ *N Instance Variables
\ -----------------------------------------------------------------

\ WARNING: DO NOT ADD ANY INSTANCE VARIABLES TO THIS CLASS BEFORE HWND

\ HWND MUST BE THE FIRST IVAR.  THIS IS ESSENTIAL TO THE
\ WINDOW PROCEDURE OF CLASS WINDOW AND THE SUBCLASSING TECHNIQUE
\ USED BY CLASS CONTROL.

int hWnd
\ *G handle to Win32 window object

cell bytes dialoglink \ must follow hwnd

in-system

int (wStatus)

in-previous

1 bits wStatus0 ' wStatus0 alias AmDialog \ Can be aliased by descendants of CONTROL only
1 bits wStatus1
1 bits wStatus2
1 bits wStatus3
1 bits wStatus4
1 bits wStatus5
1 bits wStatus6
1 bits wStatus7
1 bits wStatus8
1 bits wStatus9
1 bits wStatus10
1 bits wStatus11
1 bits wStatus12
1 bits wStatus13
1 bits wStatus14
1 bits wStatus15
1 bits wStatus16
1 bits wStatus17
1 bits wStatus18
1 bits wStatus19
1 bits wStatus20
1 bits wStatus21
1 bits wStatus22
1 bits wStatus23
1 bits wStatus24
1 bits wStatus25
1 bits wStatus26
1 bits wStatus27
1 bits wStatus28
1 bits wStatus29
1 bits wStatus30
1 bits wStatus31

\ Rectangle WinRect

\ The following is for backward compatibility. Use WinRect for new code since it will
\ be early bound whereas wRect will be latebound.

\ int wRect

\ synonym tempRect wRect

\ -----------------------------------------------------------------
\ -----------------------------------------------------------------


in-system

: static-window? ( -- f1 )      \ is this a static window
                self app-origin sys-here between ;

: link-window   ( -- )
                static-window?          \ only link in static windows
                if >system windows-link link, \ link into list
                     self , system>
                then ;

: trim-windows  ( nfa -- nfa )                \ for forgetting
                dup windows-link full-trim ;

forget-chain chain-add trim-windows

: trim-dialogs  ( nfa -- nfa )
                dup Dialog-link full-trim ;

forget-chain chain-add trim-dialogs

in-application


: SendMessage:Self      ( lParam wParam message -- result )
\ *G Send a windows message to our self.
                hWnd call SendMessage ;

: SendMessage:SelfDrop  ( lParam wParam message -- )
\ *G Send a windows message to our self and discard the result.
                hWnd call SendMessage drop ;

\ -----------------------------------------------------------------
\ *N Methods
\ -----------------------------------------------------------------

:M Classinit:   ( -- )
\ *G Initialise the class.
                ClassInit: super
                0 to hWnd turnkeyed? 0=  \ only dynamic windows can be used in a
\in-system-ok   if link-window then      \ turnkeyed application so skip linking
                dialoglink off           \ added Sonntag, Juni 04 2006 dbu
\                addr: WinRect to wRect
                ;M

:M GetHandle:   ( -- hWnd )
\ *G Get the window handle.
                hWnd ;M

:M PutHandle:   ( hWnd -- )
\ *G Set the window handle. Normally handled by the system.
                to hWnd ;M

:M ZeroWindow:  ( -- )
\ *G Clear the window handle. Normally handled by the system. All window
\ ** handles are zeroed automatically in the image when saving.
                0 to hWnd ;M

:M DestroyWindow: ( -- )
\ *G Destroy the window. The handle is always zero after executing this method. In a
\ ** multi-tasking application this method causes an error if executed by a task that
\ ** didn't create the window.
                hWnd
                if   hWnd Call DestroyWindow ?win-error
                     0 to hWnd
                then ;M

:M Close:       ( -- )
\ *G Close the window.
                DestroyWindow: self ;M

:M Paint:       ( -- )
\ *G Force window repaint. A WM_PAINT message is posted to the message queue.
                hWnd
                if   1 0 hWnd Call InvalidateRect ?win-error
                then ;M

:M IsVisible?:  ( -- f )
\ *G Check if the window is visible or not.
                hWnd call IsWindowVisible ;M

:M SetRedraw:   ( f -- )
\ *G Set the redraw state of the window.
\ *P \i f \d Specifies the redraw state. If this parameter is TRUE, the
\ ** content can be redrawn after a change. If this parameter is FALSE,
\ ** the content cannot be redrawn after a change.
                0 swap WM_SETREDRAW hWnd call SendMessage drop ;M

: OwnedByTask  ( -- f )
                     0 hWnd call GetWindowThreadProcessId
                     call GetCurrentThreadId = ;

:M Show:        ( state -- )
\ *G Set the specified window's show state. \n
\ ** Possible values for state are:
\ *L
\ *| SW_FORCEMINIMIZE   | Windows 2000: Minimizes a window, even if the thread that owns the window is hung. This flag should only be used when minimizing windows from a different thread. |
\ *| SW_HIDE            | Hides the window and activates another window. |
\ *| SW_MAXIMIZE        | Maximizes the specified window. |
\ *| SW_MINIMIZE        | Minimizes the specified window and activates the next top-level window in the Z order. |
\ *| SW_RESTORE         | Activates and displays the window. If the window is minimized or maximized, the system restores it to its original size and position. An application should specify this flag when restoring a minimized window. |
\ *| SW_SHOW            | Activates the window and displays it in its current size and position.  |
\ *| SW_SHOWDEFAULT     | Sets the show state based on the SW_ value specified in the STARTUPINFO structure passed to the CreateProcess function by the program that started the application. |
\ *| SW_SHOWMAXIMIZED   | Activates the window and displays it as a maximized window. |
\ *| SW_SHOWMINIMIZED   | Activates the window and displays it as a minimized window. |
\ *| SW_SHOWMINNOACTIVE | Displays the window as a minimized window. This value is similar to SW_SHOWMINIMIZED, except the window is not activated. |
\ *| SW_SHOWNA          | Displays the window in its current size and position. This value is similar to SW_SHOW, except the window is not activated. |
\ *| SW_SHOWNOACTIVATE  | Displays a window in its most recent size and position. This value is similar to SW_SHOWNORMAL, except the window is not actived. |
\ *| SW_SHOWNORMAL      | Activates and displays a window. If the window is minimized or maximized, the system restores it to its original size and position. An application should specify this flag when displaying the window for the first time. |
\ *P If the window belongs to a different task or application the WM_SHOW is posted to the
\ ** the message queue to prevent the current task hanging. If the window belongs to the
\ ** current task the message is sent.
                hWnd
                if   OwnedByTask
                     if    hWnd Call ShowWindow
                     else  hWnd call ShowWindowAsync
                     then
                then drop ;M

:M GDIFlush:    ( -- )
\ *G Flush the calling thread's current batch.
                Call GdiFlush ?win-error ;M

:M Update:      ( -- )
\ *G Update the client area of the window by sending
\ ** a WM_PAINT message to the window if the window's update region is not empty. The
\ ** function sends a WM_PAINT message directly to the window procedure of the window,
\ ** bypassing the application queue. If the update region is empty, no message is sent.
                hWnd
                if   hWnd Call UpdateWindow ?win-error
                then ;M

:M Scroll:      { x y -- }
\ *G Scroll the contents of the specified window's client area.
                hWnd
                if   0 0 y x hWnd Call ScrollWindow drop
                then ;M

:M Move:        { x y w h -- }
\ *G Change the position and dimensions of window.
\ ** For a top-level window, the position and dimensions are relative to the upper-left corner
\ ** of the screen. For a child window, they are relative to the upper-left corner of the parent
\ ** window's client area.
                hWnd
                if   1 ( repaint flag ) h w y x
                     hWnd Call MoveWindow ?win-error
                then ;M

:M SetWindowPos: { x y -- }
\ *G The SetWindowPos function changes the position of a child, pop-up, or top-level window. \n
\ ** X Specifies the new position of the left side of the window, in client coordinates. \n
\ ** Y Specifies the new position of the top of the window, in client coordinates.
                hWnd
                if      [ SWP_NOSIZE SWP_SHOWWINDOW or SWP_NOZORDER or ] literal
                        0 0             \ no size specified
                        y x
                        0               \ insert parameter not used
                        hWnd Call SetWindowPos ?win-error
\ April 27th, 1998 - 9:14 tjz removed, reported by Bruno Gauthier
\                else    2drop
                then
                ;M

:M GetWindowRect: ( -- left top right bottom )
\ *G The GetWindowRect method retrieves the dimensions of the bounding rectangle of the window.
\ ** The dimensions are given in screen coordinates that are relative to the upper-left corner
\ ** of the screen.
                hWnd
                if   EraseRect: WinRect
                     WinRect hWnd Call GetWindowRect ?win-error
                     Left: WinRect  Top: WinRect
                     Right: WinRect Bottom: WinRect
                else 0 0 0 0
                then ;M

:M SetMenu:     ( MenuHandle -- )
\ *G The SetMenu function assigns a new menu to the window.
\ ** If MenuHandle is NULL, the window's current menu is removed.
                hWnd -if Call SetMenu ?win-error else 2drop then ;M

:M SetText:     { addr len \ text$ -- }
\ *G The SetWindowText function changes the text of the window's title bar (if it has one).
\ ** If the window is a control, the text of the control is changed.
                hWnd
                if   MAXSTRING localAlloc: text$
                     addr len text$ place text$ +NULL
                     text$ 1+ hWnd Call SetWindowText ?win-error
                then ;M

3 import: GetWindowText

:M GetText:     ( -- addr len )
\ *G The GetWindowText function copies the text of the window's title bar (if it has one)
\ ** into a buffer. If the window is a control, the text of the control is copied.
\ ** The text is stored in a dynamic buffer so should be copied if it needs to be
\ ** persistant.
                new$ hWnd
                -if  over MAXCOUNTED GetWindowText
                then ;M

: (SetTextAlign) ( flag hwnd -- )
                dup>r Call GetDC >r
       ( flag ) case    1 of [ TA_RIGHT  TA_UPDATECP or ] literal endof
                        2 of [ TA_CENTER TA_UPDATECP or ] literal endof
                             [ TA_LEFT   TA_UPDATECP or ] literal swap
                endcase
                r@ Call SetTextAlign
                r> r> Call ReleaseDC 2drop  ;

:M SetTextAlign: ( flag -- )
\ *G Set the text-alignment for the window. \n
\ ** The current position is updated after each text output call.
\ ** The current position is used as the reference point.
\ ** Possible values for flag are:
\ *L
\ *| 0  | The reference point will be on the left edge of the bounding rectangle. |
\ *| 1  | The reference point will be on the right edge of the bounding rectangle. |
\ *| 2  | The reference point will be aligned horizontally with the center of the bounding rectangle. |
                hwnd (SetTextAlign) ;M

:M GetDC:       ( -- hdc )
\ *G The GetDC function retrieves a handle to a display device context (DC)
\ ** for the client area of the window. \n
\ ** You have to call ReleaseDC when the DC isn't needed any longer.
                hWnd Call GetDC ;M

:M GetWindowDC: ( -- hdc )
\ *G The GetWindowDC function retrieves the device context (DC) for the entire
\ ** window, including title bar, menus, and scroll bars. A window device context
\ ** permits painting anywhere in a window, because the origin of the device context
\ ** is the upper-left corner of the window instead of the client area. \n
\ ** GetWindowDC assigns default attributes to the window device context each time it
\ ** retrieves the device context. Previous attributes are lost. \n
\ ** You have to call ReleaseDC when the DC isn't needed any longer.
                hWnd Call GetWindowDC ;M

:M ReleaseDC:   ( hdc -- )
\ *G The ReleaseDC function releases the device context (DC) of the window. \n
\ ** Call only after GetDC or GetWindowDC.
                hWnd Call ReleaseDC ?win-error ;M

:M BeginPaint:  ( ps -- hdc )
\ *G The BeginPaint function prepares the window for painting and fills a
\ ** PAINTSTRUCT (ps) structure with information about the painting.
                hWnd Call BeginPaint ;M

:M EndPaint:    ( ps -- )
\ *G The EndPaint function marks the end of painting in the window. This function is
\ ** required for each call to the BeginPaint function, but only after painting is complete.
                hWnd Call EndPaint drop  ;M

:M GetClientRect:  ( rect -- )
\ *G The GetClientRect function retrieves the coordinates of the window's client area. The
\ ** client coordinates specify the upper-left and lower-right corners of the client area.
\ ** Because client coordinates are relative to the upper-left corner of a window's client
\ ** area, the coordinates of the upper-left corner are (0,0).
                hWnd Call GetClientRect ?win-error ;M

:M GetWindowLong:  ( index -- value )
\ *G The GetWindowLong function retrieves information about the window. The function
\ ** also retrieves the 32-bit (long) value at the specified offset into the extra
\ ** window memory. \n
\ ** Index Specifies the zero-based offset to the value to be retrieved. Valid values are
\ ** in the range zero through the number of bytes of extra window memory, minus four; for
\ ** example, if you specified 12 or more bytes of extra memory, a value of 8 would be an
\ ** index to the third 32-bit integer. To retrieve any other value, specify one of the
\ ** following values.
\ *L
\ *| GWL_EXSTYLE    | Retrieves the extended window styles. For more information, see CreateWindowEx. |
\ *| GWL_STYLE      | Retrieves the window styles. |
\ *| GWL_WNDPROC    | Retrieves the address of the window procedure, or a handle representing the address of the window procedure. You must use the CallWindowProc function to call the window procedure. |
\ *| GWL_HINSTANCE  | Retrieves a handle to the application instance. |
\ *| GWL_HWNDPARENT | Retrieves a handle to the parent window, if any. |
\ *| GWL_ID         | Retrieves the identifier of the window. |
\ *| GWL_USERDATA   | Retrieves the 32-bit value associated with the window. Each window has a corresponding 32-bit value intended for use by the application that created the window. This value is initially zero. |
                hWnd Call GetWindowLong ;M

:M SetWindowLong:  ( value index -- oldval )
\ *G The SetWindowLong function changes an attribute of the window. The function also sets the
\ ** 32-bit (long) value at the specified offset into the extra window memory.
\ *L
\ *| GWL_EXSTYLE   | Sets a new extended window style. For more information, see CreateWindowEx. |
\ *| GWL_STYLE     | Sets a new window style. |
\ *| GWL_WNDPROC   | Sets a new address for the window procedure. Windows NT/2000: You cannot change this attribute if the window does not belong to the same process as the calling thread. |
\ *| GWL_HINSTANCE | Sets a new application instance handle. |
\ *| GWL_ID        | Sets a new identifier of the window. |
\ *| GWL_USERDATA  | Sets the 32-bit value associated with the window. Each window has a corresponding 32-bit value intended for use by the application that created the window. This value is initially zero. |
                hWnd Call SetWindowLong ;M

:M GetStyle:    ( -- style )
\ *G Retrieves the window styles of a running window.
                GWL_STYLE GetWindowLong: self ;M

:M SetStyle:    ( style -- )
\ *G Sets a new window style of a running window.
                GWL_STYLE SetWindowLong: self drop ;M

:M +Style:      ( style -- )
\ *G Add a window style to a running window.
                GetStyle: self OR SetStyle: self ;M

:M -Style:      ( style -- )
\ *G Remove a window style from a running window.
                INVERT GetStyle: self AND SetStyle: self ;M

:M SetFocus:    ( -- )
\ *G The SetFocus function sets the keyboard focus to the window. The window must be
\ ** attached to the calling thread's message queue.
                hWnd Call SetFocus drop  ;M

:M SetForegroundWindow: ( -- )
\ *G The SetForegroundWindow function puts the thread that created the specified window
\ ** into the foreground and activates the window. Keyboard input is directed to the window,
\ ** and various visual cues are changed for the user. The system assigns a slightly higher
\ ** priority to the thread that created the foreground window than it does to other threads. \n
\ ** The foreground window is the window at the top of the Z order. It is the window that the
\ ** user is working with. In a preemptive multitasking environment, you should generally let the
\ ** user control which window is the foreground window. \n
\ ** Windows 98, Windows 2000: The system restricts which processes can set the foreground window.
\ ** A process can set the foreground window only if one of the following conditions is true: \n
\ ** - The process is the foreground process. \n
\ ** - The process was started by the foreground process. \n
\ ** - The process received the last input event. \n
\ ** - There is no foreground process. \n
\ ** - The foreground process is being debugged. \n
\ ** - The foreground is not locked (see LockSetForegroundWindow). \n
\ ** - The foreground lock time-out has expired (see SPI_GETFOREGROUNDLOCKTIMEOUT in SystemParametersInfo). \n
\ ** - Windows 2000: No menus are active. \n
\ ** With this change, an application cannot force a window to the foreground while the user is
\ ** working with another window. Instead, SetForegroundWindow will activate the window (see SetActiveWindow)
\ ** and call the FlashWindowEx function to notify the user. For more information, see Foreground and
\ ** Background Windows. \n
\ ** A process that can set the foreground window can enable another process to set the foreground window by
\ ** calling the AllowSetForegroundWindow function. The process specified by dwProcessId loses the ability to
\ ** set the foreground window the next time the user generates input, unless the input is directed at that
\ ** process, or the next time a process calls AllowSetForegroundWindow, unless that process is specified. \n
\ ** The foreground process can disable calls to SetForegroundWindow by calling the LockSetForegroundWindow function.
                hWnd (SetForegroundWindow) ;M

:M SetActiveWindow:     ( -- )
\ *G The SetActiveWindow function activates a window. The window must be attached to the calling thread's message queue. \n
\ ** The SetActiveWindow function activates a window, but not if the application is in the background. The window will be
\ ** brought into the foreground (top of Z order) if its application is in the foreground when the system activates the window. \n
\ ** If the window identified by the hWnd parameter was created by the calling thread, the active window status of the calling
\ ** thread is set to hWnd. Otherwise, the active window status of the calling thread is set to NULL. \n
\ ** By using the AttachThreadInput function, a thread can attach its input processing to another thread.
\ ** This allows a thread to call SetActiveWindow to activate a window attached to another thread's message queue.
                hWnd (SetActiveWindow) ;M

:M MessageBox:  ( szText szTitle style -- result )
\ *G The MessageBox function creates, displays, and operates a message box. The message box contains an
\ ** application-defined message and title, plus any combination of predefined icons and push buttons.
\ *L
\ *| szText  | Pointer to a null-terminated string that contains the message to be displayed. |
\ *| szTitle | Pointer to a null-terminated string that contains the dialog box title. If this parameter is NULL, the default title Error is used. |
\ *| Type    | Specifies the contents and behavior of the dialog box. This parameter can be a combination of flags from the following groups of flags. |
\ *P To indicate the buttons displayed in the message box, specify one of the following values. |
\ *L
\ *| MB_ABORTRETRYIGNORE  | The message box contains three push buttons: Abort, Retry, and Ignore. |
\ *| MB_CANCELTRYCONTINUE | Windows 2000: The message box contains three push buttons: Cancel, Try Again, Continue. Use this message box type instead of MB_ABORTRETRYIGNORE. |
\ *| MB_HELP              | Adds a Help button to the message box. When the user clicks the Help button or presses F1, the system sends a WM_HELP message to the owner. |
\ *| MB_OK                | The message box contains one push button: OK. This is the default. |
\ *| MB_OKCANCEL          | The message box contains two push buttons: OK and Cancel. |
\ *| MB_RETRYCANCEL       | The message box contains two push buttons: Retry and Cancel. |
\ *| MB_YESNO             | The message box contains two push buttons: Yes and No. |
\ *| MB_YESNOCANCEL       | The message box contains three push buttons: Yes, No, and Cancel. |
\ *P To display an icon in the message box, specify one of the following values.
\ *L
\ *| MB_ICONEXCLAMATION, MB_ICONWARNING  | An exclamation-point icon appears in the message box. |
\ *| MB_ICONINFORMATION, MB_ICONASTERISK | An icon consisting of a lowercase letter i in a circle appears in the message box. |
\ *| MB_ICONQUESTION                     | A question-mark icon appears in the message box. |
\ *| MB_ICONSTOP, MB_ICONERROR, MB_ICONHAND | A stop-sign icon appears in the message box. |
\ *P To indicate the default button, specify one of the following values.
\ *L
\ *| MB_DEFBUTTON1 | The first button is the default button. MB_DEFBUTTON1 is the default unless MB_DEFBUTTON2, MB_DEFBUTTON3, or MB_DEFBUTTON4 is specified.
\ *| MB_DEFBUTTON2 | The second button is the default button. |
\ *| MB_DEFBUTTON3 | The third button is the default button. |
\ *| MB_DEFBUTTON4 | The fourth button is the default button. |
\ *P To specify other options, use one or more of the following values.
\ *L
\ *| MB_RIGHT         | The text is right-justified. |
\ *| MB_SETFOREGROUND | The message box becomes the foreground window. Internally, the system calls the SetForegroundWindow function for the message box. |
\ *| MB_TOPMOST       | The message box is created with the WS_EX_TOPMOST window style. |
\ *P If the function succeeds, the return value is one of the following menu-item values.
\ *L
\ *| IDABORT    | Abort button was selected. |
\ *| IDCANCEL   | Cancel button was selected. |
\ *| IDCONTINUE | Continue button was selected. |
\ *| IDIGNORE   | Ignore button was selected. |
\ *| IDNO No    | button was selected. |
\ *| IDOK OK    | button was selected. |
\ *| IDRETRY    | Retry button was selected. |
\ *| IDTRYAGAIN | Try Again button was selected. |
\ *| IDYES      | Yes button was selected. |
                3reverse hWnd Call MessageBox ;M

:M InvalidateRect: ( bgflag rectangle -- )
\ *G The InvalidateRect function adds a rectangle to the window's update region.
\ ** The update region represents the portion of the window's client area that must be redrawn.
\ *L
\ *| lpRect | Pointer to a RECT structure that contains the client coordinates of the rectangle to be added to the update region. If this parameter is NULL, the entire client area is added to the update region. |
\ *| bErase | Specifies whether the background within the update region is to be erased when the update region is processed. If this parameter is TRUE, the background is erased when the BeginPaint function is called. |
                hWnd call InvalidateRect ?win-error ;M

:M GetDlgItem:  ( id -- handle )
\ *G The GetDlgItem function retrieves a handle of the control (id) in the window.
                hWnd Call GetDlgItem ;M

:M GetDlgItemText:  ( addr len id -- len )
\ *G The GetDlgItemText function retrieves the title or text associated with a control in the window.
                >r swap r> hWnd Call GetDlgItemText ;M

:M SetDlgItemText:  ( addr len id -- )
\ *G The SetDlgItemText function sets the title or text of a control in then window.
                >r asciiz r> hWnd Call SetDlgItemText drop ;M

:M SetDlgItemFocus: ( id -- )
\ *G Set the focus to the control (id) in the window.
                GetDlgItem: self Call SetFocus drop ;M

:M SelectDlgItemAll: ( id -- )
\ *G Selects all characters in the edit control (id). You can use this forn an edit control
\ ** or a rich edit control.
                >r -1 0 EM_SETSEL r> hWnd Call SendDlgItemMessage drop ;M

:M IsDlgButtonChecked: ( id -- f1 )
\ *G The IsDlgButtonChecked function determines whether a button control has a check mark next to
\ ** it or whether a three-state button control is grayed, checked, or neither.
                hWnd Call IsDlgButtonChecked ;M

:M CheckDlgButton: ( uCheck id -- )
\ *G The CheckDlgButton function changes the check state of a button control.
\ ** Possible values for uCheck are:
\ *L
\ *| BST_CHECKED       | Sets the button state to checked. |
\ *| BST_INDETERMINATE | Sets the button state to grayed, indicating an indeterminate state. Use this value only if the button has the BS_3STATE or BS_AUTO3STATE style. |
\ *| BST_UNCHECKED     | Sets the button state to cleared |
                hWnd Call CheckDlgButton drop ;M

:M SetDlgItemAlign: ( flag id -- )
\ *G Set the text-alignment for a control (id) in the window. \n
\ ** The current position is updated after each text output call.
\ ** The current position is used as the reference point.
\ ** Possible values for flag are:
\ *L
\ *| 0  | The reference point will be on the left edge of the bounding rectangle. |
\ *| 1  | The reference point will be on the right edge of the bounding rectangle. |
\ *| 2  | The reference point will be aligned horizontally with the center of the bounding rectangle. |
                GetDlgItem: self (SetTextAlign) ;M

:M SetAlign:    ( flag id -- )          \ DEPRECATED
\ *G Obsolescent Method use SetDlgItemAlign: instead.
                SetDlgItemAlign: self ;M DEPRECATED

:M EnableDlgItem: ( flag id -- )
\ *G Enable or disable a control (id) in the window.
\ ** Possible values for flag are:
\ *L
\ *| 0  | disable |
\ *| 1  | enable |
                GetDlgItem: self Call EnableWindow drop ;M

:M ShowDlgItem: ( flag id -- )
\ *G Hide or show a control (id) in the window.
\ ** Possible values for flag are:
\ *L
\ *| 0  | hide |
\ *| 1  | show |
                swap if SW_SHOWNORMAL else SW_HIDE
                then swap GetDlgItem: self Call ShowWindow drop ;M

:M CheckRadioButton: ( check_id first_id last_id -- )
\ *G The CheckRadioButton function adds a check mark to (checks) a specified radio button
\ ** in a group and removes a check mark from (clears) all other radio buttons in the group.
\ *L
\ *| check_id | Specifies the identifier of the radio button to select. |
\ *| first_id | Specifies the identifier of the first radio button in the group. |
\ *| last_id  | Specifies the identifier of the last radio button in the group. |
                swap hWnd Call CheckRadioButton drop ;M

:M SendDlgItemMessage: ( lParam wParam message id -- long )
\ *G Send a message to the control (id) in the window.
                hWnd Call SendDlgItemMessage ;M

:M SetDlgItemFont: ( FontObject id -- )
\ *G Specify the font that the control (id) is to use when drawing text. \n
\ ** FontObject must be the HANDLE of a font. If this parameter is NULL, the control uses the
\ ** default system font to draw text.
                1 -rot WM_SETFONT swap SendDlgItemMessage: self ;M

\ The following definitions are for handling Dialog messages and have been moved
\ here rather than have multiple copies of the code in different descendants

: ?DoAddDialogList ( -- )        \ Needs to be in On_Init: for all dialogs and dialog-windows.
        AmDialog 0<> dialoglink @ 0= and if dialoglink Dialog-link add-link then ;

: ?DoRemoveDialogList ( -- )     \ Needs to be in On_Done: for all dialogs and dialog-windows.
        AmDialog 0<> dialoglink @ 0<> and if dialoglink \ Normally this is achieved through inheritance
        Dialog-link un-link drop dialoglink off then ; \ by using On_Done: Super.

: +DialogList  ( -- )           \ link into dialog list in Start:
\ *G Used so window responds to Dialog messages. Used by ModeLessDialog DialogWindow and
\ ** MdiDialog classes but can be added to any descendants of class Window (including
\ ** descendants of Child-Window) so they can respond to dialog messages. Can also be
\ ** used programatically.
        1 to AmDialog hwnd if ?DoAddDialogList then ;

: -DialogList ( -- )            \ don't link from dialog list in Start:
\ *G Disable responding to dialog messages. This was mainly used for the ~: destructor method
\ ** though is no longer needed. Can also be used programatically.
        hwnd if ?DoRemoveDialogList then 0 to AmDialog  ;

: DoDialogMsg { pMsg flag -- pMsg f | pMsg FALSE }
        Dialog-link                       \ all dialog handles
        begin   @ dup 0<>                 \ while not end of chain
                flag and                  \ and haven't found a handler
        while   dup>r cell- @
                -if     pMsg swap
                        Call IsDialogMessage
                then 0= to flag
                r>
        repeat  drop pMsg flag ;

msg-chain chain-add DoDialogMsg

\ moved here for both windows and controls

:M WM_CREATE    ( hwnd msg wparam lparam -- res )
                On_Init: [ self ] false ;M

:M On_Init:     ( -- )
\ *G Thing's to do during creation of the window.
\ ** Default does ?DoAddDialogList.
                ?DoAddDialogList ;M

:M On_Done:     ( -- )
\ *G Thing's to do when the window will be destroyed. Default does ?DoRemoveDialogList.
                ?DoRemoveDialogList ;M

;CLASS
\ *G End of generic-window class

in-system

: zero-image-windows ( -- )                   \ Zero all window handles.
                windows-link
                begin   @ ?dup
                while   dup cell+ @
                        >image ?dup if off then
                repeat  ;

pre-save-image-chain chain-add zero-image-windows

\ *Z
