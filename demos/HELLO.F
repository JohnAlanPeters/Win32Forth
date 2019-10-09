\ $Id: HELLO.F,v 1.3 2005/05/17 22:25:25 alex_mcdonald Exp $

\ hello.f
\ Andrew McKewan

\ Demo for simple "Hello World" windows app.
\ See also WINHELLO.F for a similar example using objects.

ONLY FORTH ALSO DEFINITIONS

defined cleanup nip [if] cleanup [then]

ANEW PROGRAM

: AppName    Z" HelloApp"    ;
: Title      Z" Hello World" ;

\ Here we get to draw in the window. The counter will increment every
\ time PAINT is called.
: .HELLO  { hdc counter -- }
        counter 0 <#  S"  times" "HOLD  #S  S" Repainted " "HOLD  #>
        swap 20 20 hdc call TextOut drop ;

\ the counter is stored in the window extra memory
: COUNTER@  ( hwnd -- n )  0 swap Call GetWindowLong ;
: COUNTER!  ( n hwnd -- )  0 swap Call SetWindowLong DROP ;

create ps 64 allot ( paintstruct )

\ update counter every time we repaint window
: PAINT  { hWnd \ hDC -- }
        ps hWnd Call BeginPaint to hDC
        hDC hWnd COUNTER@ .HELLO
        hWnd COUNTER@ 1+ hWnd COUNTER!  ( increment counter )
        ps hWnd Call EndPaint DROP ;

\ Define the window procedure
: (HELLO-WNDPROC)  { hWnd msg wParam lParam -- result }

        msg CASE

        WM_CREATE OF
                1 hWnd COUNTER!
                0 200 1 hWnd Call SetTimer drop
                ENDOF

        WM_PAINT OF
                hWnd PAINT
                ENDOF

        WM_TIMER OF
                1 0 hWnd Call InvalidateRect drop
                ENDOF

        WM_DESTROY OF
                1 hWnd Call KillTimer drop
\                TURNKEY IF  0 Call PostQuitMessage  THEN
                ENDOF

        ( DEFAULT )
                lParam wParam msg hWnd Call DefWindowProc  EXIT

        ENDCASE 0 ;

4 callback hello-wndproc (hello-wndproc)

\ Create a WNDCLASS structure and register the class.
: REGISTER-CLASS  ( -- F )
        HERE
                CS_HREDRAW CS_VREDRAW or ,  ( class style )
                HELLO-WNDPROC ,
                0 , ( class extra )
                4 , ( window extra )  ( for counter )
                AppInst ,
                IDI_APPLICATION NULL Call LoadIcon ,
                IDC_ARROW NULL       Call LoadCursor ,
                WHITE_BRUSH          Call GetStockObject ,
                NULL , ( hMenu )
                AppName ,
        DUP Call RegisterClass
        SWAP DP ! ;

\ Create the window
: CREATE-HELLO-WINDOW  ( -- f )
        0                       \ creation parameters
        AppInst                 \ instance handle
        0                       \ menu
        ConHndl                 \ parent window
        200 300 100 100         \ window position ( h w y x )
        WS_OVERLAPPEDWINDOW     \ window style
        Title                   \ window title
        AppName                 \ class name
        0                       \ exended style
        Call CreateWindowEx ;

0 VALUE hWnd
: DEMO  ( -- )
        REGISTER-CLASS 0= IF CR ." register class failed " THEN
        CREATE-HELLO-WINDOW TO hWnd
        hWnd 0= ABORT" create window failed"
        1 hWnd Call ShowWindow DROP
        hWnd Call UpdateWindow DROP ;

: CLEANUP  ( -- )
        hWnd Call DestroyWindow DROP
        AppInst AppName Call UnregisterClass DROP ;


CR .( Type 'DEMO' to run program )


