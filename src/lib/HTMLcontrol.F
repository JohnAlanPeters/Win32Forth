\ $Id: HTMLcontrol.F,v 1.4 2006/01/14 12:28:21 dbu_de Exp $

\ HTML Control
\ Thomas Dixon

\ *D doc\classes\
\ *! HTMLcontrol
\ *T HTMLcontrol -- HTML control
\ *P This class is using the MSHTML ActiveX control
\ ** so you must install the MS Internet Explorer to use it.
\ *S Glossary

anew -HtmlControl.f

needs AXControl

\ Load MSHTML TypeLibrary
1 1 typelib {EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}

\ We Build off the Generic ActiveX Control
:CLASS HTMLControl           <SUPER AXControl
\ *G HTML control class.

  CELL bytes Web        \ pointer to IWebBrowser2 interface
  16 bytes xtra         \ xtra space for api calls

:M Start: ( Parent -- )
\ *G Start the control
        Start: super
        xtra WebBrowser StringFromCLSID abort" Unable to Get WebBrowser CLSID!"
        xtra @ AXUCreate: self
        Web IWebBrowser2 QueryInterface: self
          abort" Unable to get the IWebBrowser2 Interface!"
        ;M

:M On_Done: ( -- )
        Web @ if
          Web COM IWebBrowser2 Release drop 0 Web ! then ;M

\ Browser Methods
:M GetLocationURL:      ( -- str len )
\ *G Retrieves the URL of the resource that the browser is currently displaying.
        xtra Web COM IWebBrowser2 GetLocationURL drop
        xtra @ dup >r zunicount >ascii r> call SysFreeString drop ;M

:M GetLocationName:     ( -- str len )
\ *G Retrieves the name of the resource that the browser is currently displaying.
        xtra Web COM IWebBrowser2 GetLocationName drop
        xtra @ dup >r zunicount >ascii r> SysFreeString drop ;M

:M GetType:     ( -- str len )
\ *G Retrieves the type name of the contained document object.
        xtra Web COM IWebBrowser2 GetType drop
        xtra @ dup >r zunicount >ascii r> SysFreeString drop ;M

:M Busy?:       ( -- flag )
\ *G Retrieves a boolean value that indicates whether the browser is engaged in a
\ ** downloading operation or other activity.
        xtra Web COM IWebBrowser2 GetBusy drop xtra @ 1 and ;M

:M Offline?:    ( -- flag )
\ *G Retrieves a Boolean value indicating whether the browser is currently operating
\ ** in offline mode.
        xtra Web COM IWebBrowser2 GetOffline drop xtra @ 1 and ;M

\ Navigation Functions

:M GoURL:       ( str len -- )
\ *G Navigates to a resource identified by a Uniform Resource
\ ** Locator (URL) or to the file identified by a full path.
        >unicode drop >r
        0 0 0 0 r> Web COM IWebBrowser2 Navigate drop ;M

:M SetURL:      ( zUrl -- )
\ *G Navigates to a resource identified by a Uniform Resource
\ ** Locator (URL) or to the file identified by a full path.
                zcount GoURL: self ;M

:M GoHome:      ( -- )
\ *G Navigates to the current home or start page.
        Web COM IWebBrowser2 GoHome drop ;M

:M GoSearch:    ( -- )
\ *G Navigates to the current search page.
        Web COM IWebBrowser2 GoSearch drop ;M

:M GoForward:   ( -- )
\ *G Navigates forward one item in the history list.
        Web COM IWebBrowser2 GoForward drop ;M

:M GoBack:      ( -- )
\ *G Navigates backward one item in the history list.
        Web COM IWebBrowser2 GoBack drop ;M

:M Refresh:     ( -- )
\ *G Reloads the file that the browser is currently displaying.
        Web COM IWebBrowser2 Refresh drop ;M

:M Stop:        ( -- )
\ *G Cancels any pending navigation or download operation and
\ ** stops any dynamic page elements, such as background sounds
\ ** and animations.
        Web COM IWebBrowser2 Stop drop ;M

;CLASS
\ *G End of HTML control class

\ We don't need the typelibrary anymore, so unload it now.
free-lasttypelib

\ *Z
