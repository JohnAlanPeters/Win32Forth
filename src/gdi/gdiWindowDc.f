\ *D doc\classes\
\ *! gdiWindowDc
\ *T gdiWindowDc -- Window device context class
\ *Q Version 1.0
\ ** This GDI class library was written and placed in the Public Domain
\ ** in 2005 by Dirk Busch
\ *S Glossary

cr .( Loading GDI class library - Window device context...)

needs gdiDC.f

internal
external

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
:class gdiWindowDC <super gdiDC
\ *G Window device context class

int hWnd \ handle of the window in which this device context is used

:M ClassInit:   ( -- )
        ClassInit: super
        0 to hWnd
        ;M

:M Release: ( -- )
\ *G The Release: method releases a device context (DC), freeing it
\ ** for use by other applications. The effect of the ReleaseDC function depends
\ ** on the type of DC. It frees only common and window DCs. It has no effect on
\ ** class or private DCs.
        hWnd ?dup
        if   hObject swap call ReleaseDC ?win-error
             0 to hWnd
        then ;M

:M Destroy:     ( -- )
        Release: self
        Destroy: super
        ;M

: SetWindow     ( hWnd -- f )
        Release: self
        dup to hWnd call IsWindow ;

: SetHandle     ( hDC -- f )
        to hObject
        Valid?: super ;

:M GetDC:    ( hWnd -- f )
\ *G The GetDC method retrieves a handle to a display device context
\ ** for the client area of a specified window.
        SetWindow
        if   hWnd call GetDC
        else NULL
        then SetHandle
        ;M

:M GetDCEx:     ( hrgnClip flags hWnd -- f )
\ *G The GetDCEx method  retrieves a handle to a display device context
\ ** for the client area of a specified window or for the entire screen.
\ ** You can use the returned handle in subsequent GDI functions to draw in the DC.
\ *P This function is an extension to the GetDC function, which gives an application
\ ** more control over how and whether clipping occurs in the client area.
\ *P \i hrgnClip \d Specifies a clipping region that may be combined with the visible region
\ ** of the DC. If the value of flags is DCX_INTERSECTRGN or DCX_EXCLUDERGN, then the
\ ** operating system assumes ownership of the region and will automatically delete it
\ ** when it is no longer needed. In this case, applications should not use the region
\ ** not even delete it after a successful call to GetDCEx.
\ *P \i flags \d Specifies how the DC is created. This parameter can be one or more of the
\ ** following values.
\ *P \b DCX_WINDOW \d Returns a DC that corresponds to the window rectangle rather
\ ** than the client rectangle.
\ *P \b DCX_CACHE \d Returns a DC from the cache, rather than the OWNDC or CLASSDC
\ ** window. Essentially overrides CS_OWNDC and CS_CLASSDC.
\ *P \b DCX_PARENTCLIP \d Uses the visible region of the parent window. The parent's
\ ** WS_CLIPCHILDREN and CS_PARENTDC style bits are ignored. The
\ ** origin is set to the upper-left corner of the window identified
\ ** by hWnd.
\ *P \b DCX_CLIPSIBLINGS \d Excludes the visible regions of all sibling windows above the
\ ** window identified by hWnd.
\ *P \b DCX_CLIPCHILDREN \d Excludes the visible regions of all child windows below the
\ ** window identified by hWnd.
\ *P \b DCX_NORESETATTRS \d Does not reset the attributes of this DC to the default attributes
\ ** when this DC is released.
\ *P \b DCX_LOCKWINDOWUPDATE \d Allows drawing even if there is a LockWindowUpdate call in effect
\ ** that would otherwise exclude this window. Used for drawing during
\ ** tracking.
\ *P \b DCX_EXCLUDERGN \d The clipping region identified by hrgnClip is excluded from the
\ ** visible region of the returned DC.
\ *P \b DCX_INTERSECTRGN \d The clipping region identified by hrgnClip is intersected with the
\ ** visible region of the returned DC.
\ *P \b DCX_VALIDATE \d When specified with DCX_INTERSECTUPDATE, causes the DC to be
\ ** completely validated. Using this function with both DCX_INTERSECTUPDATE
\ ** and DCX_VALIDATE is identical to using the BeginPaint function.
        SetWindow
        if   swap hWnd call GetDCEx
        else NULL
        then SetHandle
        ;M

:M GetWindowDC: ( hWnd -- f )
\ *G The GetWindowDC method retrieves the device context (DC) for the entire
\ ** window, including title bar, menus, and scroll bars. A window device
\ ** context permits painting anywhere in a window, because the origin of
\ ** the device context is the upper-left corner of the window instead of
\ ** the client area.
        SetWindow
        if   hWnd call GetWindowDC
        else NULL
        then SetHandle
        ;M

:M GetDCOrg:    ( -- x y )
\ *G The GetDCOrgEx function retrieves the final translation origin for a specified device
\ ** context (DC). The final translation origin specifies an offset that the system uses to
\ ** translate device coordinates into client coordinates (for coordinates in an application's
\ ** window).
        Addr: POINT hObject call GetDCOrgEx ?win-error
        GetX: POINT GetY: POINT ;M

;class
\ *G End of gdiWindowDC  class

module

\ *Z
