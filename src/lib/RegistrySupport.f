\ $Id: RegistrySupport.f,v 1.2 2011/04/19 20:30:04 georgeahubert Exp $

\ RegistrySupport.f       Extensions to the words in Registry.f  by Rod Oakford
\                   July 20th, 2004   Works in v6.09.xx and later

\                   SetRegistryValue and GetRegistryValue are like
\                   RegSetString and RegGetString except that they take
\                   an extra parameter RegType.  For REG_DWORD the integer value
\                   is returned and the length is 4.  For REG_BINARY and REG_SZ
\                   address and length are returned.  The registry key no longer
\                   includes "Settings" but any key name can be set in progreg.
\                   Values are set in the key HKEY_CURRENT_USER\Software\<progreg>

\                   Words are also included to save and restore sets of registry entries.
\                   A registry entry requires:
\                   Address, Length, DefaultAddress, DefaultLength, Reg Type and Reg Value Name
\                   For REG_DWORD length is omitted and default value is just an integer.
\                   For REG_SZ the address of a counted string and the max length that
\                   will be returned (to prevent a buffer overrun) are needed in address,
\                   the default value needs address and length.
\                   For REG_BINARY address and length are needed for both address and default.
\                   Please see the example at the end of this file.
\                   The addresses of Height, Width, OriginX, and OriginY in an object derived
\                   from class Window are obtained using the &OF: method

cr .( Loading Registry Support...)

INTERNAL

[UNDEFINED] Messagebox [IF]   \ must not be MessageBox in v6.09.08 or Windows procedure is found
: MessageBox ( szText szTitle style hOwnerWindow -- result )
            >r  -rot  swap  r>
            Call MessageBox ;
[THEN]

0 value RegistryTable    \ address of current registry table in dictionary
0 value CurrentSet       \ address of data in current registry entries set
0 value RegEntries       \ number of registry entries in current set
0 value CurrentRegEntry  \ index of registry entry in registry table
50 value MaxLength       \ the maximum length of a ValueName incl null (clipped if longer)
                         \ 50 makes a reg entry 64 bytes long ( 50 + count + 13 )
: RegistryTableEntry ( n -- a )   RegistryTable CurrentRegEntry MaxLength 14 + * + + MaxLength + ;
: ValueName ( -- a n )      MaxLength negate RegistryTableEntry count ;
: RegistryType ( -- n )     1 RegistryTableEntry c@ ;
: DefaultLength ( -- n )    2 RegistryTableEntry w@ ;
: DefaultAddress ( -- a )   4 RegistryTableEntry  @ ;
: Length ( -- n )           8 RegistryTableEntry w@ ;
: Address ( -- a )          10 RegistryTableEntry @ ;
: UpdateAddress ( a n -- )
        RegistryType
        Case
            REG_DWORD   of  drop Address !            endof
            REG_BINARY  of  drop Address Length move  endof
            ( REG_SZ default )  -rot  Length min  Address place
        EndCase
        ;
: SetCurrentRegSet ( a -- )   dup to CurrentSet  dup @ to RegEntries
        cell+ dup @ to RegistryTable  cell+ count progreg place ;

EXTERNAL

: SetRegistryValue  { a1 n1 a2 n2 RegType \ khdl -- }   \ a1,n1=value string, a2,n2=key string
        0 0 RegGetKey to khdl                 \ no s" settings", include in progreg if needed
        khdl -1 = IF  EXIT  THEN              \ just return, ignore error
        a1 n1 asciiz                          \ null-terminate value string
        RegType REG_SZ = IF  1 +to n1  THEN   \ include null in count for REG_SZ
        n1 swap
        RegType
        0 a2  2dup n2 + c!                    \ null-terminate key string
        khdl Call RegSetValueEx drop
        khdl Call RegCloseKey drop
        ;

: GetRegistryValue ( a1 n1 RegType -- a2 n2 )            \ a1,n1=key string, a2,n2=value string
        >r  0 0 RegGetString                             \ n2=0 if key not found
        RegType @
        Case
            REG_DWORD   of  drop @  RegLen @  endof      \ for REG_DWORD a2=the value, n2=4
            REG_BINARY  of  drop    RegLen @  endof      \ no extra 0 in length
            ( REG_SZ default )
        EndCase
        dup r> RegType @ = not and
        IF                                               \ RegType not as requested and n2>0
            z" Registry type different"
            z" GetRegistrySetting"
            MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop
        THEN
        ;

: RegistrySet ( a n <name> -- )   \ creates a new named registry entries set
        Create  here >r  ( RegEntries ) 0 ,  ( RegistryTable ) 0 ,  ( s" KeyName" ) dup c, Z",
                here r@ cell+ !  r> SetCurrentRegSet
        Does> ( -- )   SetCurrentRegSet ;

: Entries ( -- )    here CurrentSet cell+ !  0 to RegEntries ;

: RegEntry  ( Address a [n]  Default a [n]  RegistryType n  <"RegValueName"> -- )
        MaxLength
        here ,"Text"
        dup c@ MaxLength min over c!   \ clip RegValueName to MaxLength characters incl null
        here - + 1+ allot              \ allot for counted string and null (MaxLength 1+)
        dup c,
        REG_DWORD = IF  4 swap 4  THEN
        w, , w, ,
        1 +to RegEntries
        ;

: EndEntries ( -- )   RegEntries CurrentSet ! ;

: SaveSettings ( -- )
        RegEntries 0 ?DO
            i to CurrentRegEntry
            Address Length
            RegistryType REG_SZ = IF  drop count  THEN
            ValueName RegistryType SetRegistryValue
        LOOP
        ;

: DefaultSettings ( -- )
        RegEntries 0 ?DO
            i to CurrentRegEntry
            DefaultAddress DefaultLength
            UpdateAddress
        LOOP
        ;

: RestoreSettings ( -- )
        RegEntries 0 ?DO
            i to CurrentRegEntry
            ValueName RegistryType GetRegistryValue
            RegType @ REG_SZ REG_DWORD between  over or 0= IF  2drop DefaultAddress DefaultLength  THEN
            UpdateAddress
        LOOP
        ;

: DeleteKey ( -- )   \ deletes key HKEY_CURRENT_USER\Software\<progreg>
        basereg count pad place   \ Software\
        progreg count pad +place   \ user defined key
        pad count asciiz
        HKEY_CURRENT_USER Call RegDeleteKey
        IF
            s" Unable to delete " pad place
            progreg count pad +place
            pad count asciiz
            z" DeleteKey"
            MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop
        THEN
        ;

MODULE


\s

\ RegistryExample
\               An example on how to save Window and other settings in the registry by Rod Oakford
\               Fload this file, resize the window, close the window, window settings are saved.

\             1.  Near the beginning of an application define some sets of registry entries that
\               you will want to save and restore e.g.
\               s" MyName\MyApp\WindowPlacement" RegistrySet WindowSettings
\               These sets are initially empty but contain the registry key name.  This is placed
\               in progreg when the "RegSetName" e.g. WindowSettings is executed and values are saved
\               (or restored) in the key HKEY_CURRENT_USER\Software\<progreg>

\             2.  Near the end of the application add specific entries to these sets then SaveSettings,
\               DefaultSettings and RestoreSettings will work.

\               A registry entry contains an address of the bytes to save, a default value which
\               will be used if the key is not found, the type of registry entry (REG_DWORD, REG_BINARY
\               or REG_SZ) and the name of the registry setting value.  A set of registry enties is
\               stored in a Registry table in the dictionary which is selected when "RegSetName" is
\               executed.

\               NOTE if you set a menu with MyMenu SetMenuBar: self you must also
\               override the late bound method WindowHasMenu: to return TRUE
\               otherwise the start size of the window will be wrong.  Even so
\               the height will still be wrong if the menu wraps to two or more rows.
\               (AdjustWindowRect does not take this into account)
\               It is better to use MyMenu to CurrentMenu in ClassInit:
\               otherwise you are setting the default menu then replacing it.


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ **********EXAMPLE**********
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ Needs RegistrySupport


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define two registry sets
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

s" MyName\MyApp\Window"   RegistrySet WindowSettings
s" MyName\MyApp\Options"  RegistrySet Options


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define a simple window
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 value WindowState

:Object Frame   <Super Window

:M ClassInit:
        ClassInit: super
\        MyMenu to CurrentMenu
        ;M

:M WindowHasMenu: ( -- f )   True ;M   \ default menu will be displayed if another is not set

:M On_Size: ( h m w -- h m w )
        dup to WindowState   \ get WindowState, don't save size of maximised or minimised window
        ;M

:M On_Done:
        MenuHandle: CurrentMenu Call DestroyMenu drop   \ need to destroy menu in v6.09
        ZeroMenu: CurrentMenu                           \ otherwise window won't open again
        On_Done: super
        WindowState SIZE_RESTORED = IF  WindowSettings SaveSettings  THEN
        Options SaveSettings
        ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Some other values to save and restore
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Create Title ," Window Title"   \ limited later to 9 characters in Options entries
Create DefTitle ," Default"
Create BinaryData  -1 , -1 ,
Create DefaultBin  1 c, 2 c, 3 c, 4 c, 5 c, 6 c, 7 c, 8 c,
False value Toolbar?


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Registry settings
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WindowSettings entries
\ Address        Length    Default Value    Reg Type                Reg Value Name
&of: Frame.width ( 4 )     300              REG_DWORD     RegEntry  "WindowWidth"
&of: Frame.height          200              REG_DWORD     RegEntry  "WindowHeight"
&of: Frame.originX         100              REG_DWORD     RegEntry  "WindowLeft"
&of: Frame.originY         100              REG_DWORD     RegEntry  "WindowTop"
EndEntries

Options entries
\ Address        Length    Default Value    Reg Type                Reg Value Name
' Toolbar? 4 +   ( 4 )     True             REG_DWORD     RegEntry  "Toolbar?"
Title            9         DefTitle count   REG_SZ        RegEntry  "Title"
BinaryData       8         DefaultBin 8     REG_BINARY    RegEntry  "BinaryData"
EndEntries


: go
        WindowSettings RestoreSettings
        Start: frame
        Title count SetText: frame
        ;
go


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Other testing words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: Close ( -- )   Close: frame ;

: ShowData ( -- )
        cr ." Window: "  Frame.width .  Frame.height .  Frame.originX .  Frame.originY .
        cr ." Title: "  Title count type
        cr ." Binary: "  BinaryData  8 0 DO  dup i + c@ .  LOOP  drop
        cr ." Toolbar: "  Toolbar?  IF  ." True"  ELSE  ." False"  THEN
        ;

: Open ( -- )
        WindowSettings RestoreSettings
        Options RestoreSettings
        Start: frame
        Title count SetText: frame
        ShowData
        ;

: Default ( -- )
        WindowSettings DefaultSettings
        Options DefaultSettings
        Start: frame
        Title count SetText: frame
        ShowData
        ;

: S1 ( -- )   WindowSettings  SaveSettings ;
: S2 ( -- )   Options  SaveSettings ;
: N1 ( -- )   BinaryData 8 erase  s" New Title" Title place
                false to Toolbar?  S2  open ;
: N2 ( -- )   BinaryData 8 -1 fill  s" Old Title" Title place
                true to Toolbar?  S2  open ;
: D1 ( -- )   WindowSettings  DeleteKey ;
: D2 ( -- )   Options  DeleteKey ;

comment:

DeleteKey should be fairly safe as it will not delete keys containing subkeys.
To delete MyName from the registry entirely delete Window, Options then MyApp first:

s" MyName" RegistrySet MyName
s" MyName\MyApp" RegistrySet MyApp
WindowSettings DeleteKey
Options DeleteKey
MyApp DeleteKey
MyName DeleteKey

comment;
