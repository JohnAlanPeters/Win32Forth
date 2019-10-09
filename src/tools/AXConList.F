\ $Id: AXConList.F,v 1.1 2005/09/18 11:10:31 dbu_de Exp $

\ Dump all installed ActiveX Controls to the console
\ Thomas Dixon

anew -AXConList.f

needs fcom \ include the com library

internal

in-system

\ define some guids
UUID StdComponentCategoriesMgr {0002E005-0000-0000-C000-000000000046}
UUID AXControl {40FC6ED4-2438-11cf-A3DB-080036F12502}

\ I couldn't find a typelibrary for these interfaces, so I must statically
\ define them.  There are only two, so it's not bad.

IUnknown Interface ICatInformation {0002E013-0000-0000-C000-000000000046}
ICatInformation Open-Interface
  3 3  IMethod EnumCategories ( *ppenumCategoryInfo lcid -- hres )
  4 4  IMethod GetCategoryDesc ( *pszDesc lcid rcatid -- hres )
  6 5  IMethod EnumClassesOfCategories ( *ppenumClsid rgcatidReq cReq rgcatidImpl cImp -- hres )
  6 6  IMethod IsClassOfCategories ( rgcatidReq cReq rgcatidImpl n clsid -- hres )
  3 7  IMethod EnumImplCategoriesOfClass ( *ppenumCatid rclsid -- hres )
  3 8  IMethod EnumReqCategoriesOfClass ( *ppenumCatid clsid -- hres )
Close-Interface

IUnknown Interface IEnumGUID {0002E000-0000-0000-C000-000000000046}
IEnumGUID Open-Interface
  4 3  IMethod Next ( *n *rgelt celt -- hres )
  2 4  IMethod Skip ( *celt -- hres )
  1 5  IMethod Reset ( -- hres )
  2 6  IMethod Clone ( *ppenum -- hres )
Close-Interface

\ Make a few interfaces
ICatInformation comiface catinfo
IEnumGUID comiface enumg

create tempguid 16 allot \ temporary guid buffer

external

\ word to list controls
: .axcontrols ( -- ) cr ." Listing all ActiveX controls:" cr
  catinfo ICatInformation 1 0 StdComponentCategoriesMgr CoCreateInstance
    abort" Unable to initialize Control Manager!"
  enumg pad 0 axcontrol 1 catinfo EnumClassesOfCategories drop
  enumg reset drop
  begin 0 tempguid 1 enumg next 0= while

    pad tempguid StringFromCLSID 0=
    if ."   " pad @ zunicount unitype then

    pad 1 tempguid call OleRegGetUserType 0=
    if ."   " pad @ zunicount unitype then

    cr repeat
  enumg IReleaseref drop
  catinfo IReleaseref drop ;


MODULE

.axcontrols

in-application
