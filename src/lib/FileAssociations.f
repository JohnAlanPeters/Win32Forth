\ FileAssociations.f         Utility to register a file extension to open a program.  Rod Oakford August 2005

\               A subkey with the name of the file extension (e.g. .mpg) is added in HKEY_CLASSES_ROOT.
\               The default value of this key is set to a TypeName which is added as another subkey of HKEY_CLASSES_ROOT.
\               If this .ext already exists the previous TypeName is saved (and restored when the association is deleted).
\               Further subkeys are added to the TypeName key to define the Icon and Command String to Open the program.
\
\               Win2k and later require deletion of the previous Command String for a new association to work if the user
\               has changed the association using Folder Options\File Types (rather than with RegEdit or an installer).
\
\               s" .ext"  s" Type" s" App.exe"  SetAssociation
\               s" .ext"  s" App.exe"  DeleteAssociation

cr .( Loading File Associations)

INTERNAL

Create TypeName  32 allot             \ this key will be called App.ext
Create FileExtension 8 allot          \ the file extension including the .
Create PreviousKey 32 allot           \ this key will be called App.bak to hold the previous Type Name
Create FileType  32 allot             \ the description that appears under the Type heading in explorer
Create DefaultIcon 256 allot          \ full path to Icon, with index in .exe
Create CommandLine 256 allot          \ full pathname to App.exe with "%1" and any options (e.g. /Play)
Create Options  8 allot

: SetHKCRPath ( -- )
        HKEY_CLASSES_ROOT to regBaseKey
        BaseReg off  ProgReg off ;

: RestoreRegPath ( -- )
        HKEY_CURRENT_USER to regBaseKey
        s" SOFTWARE\" BaseReg place
        PROGREG-INIT ;

: DeleteTypeNameSubKey ( s" SubKey" -- )   \ deletes key HKEY_CLASSES_ROOT\<TypeName>\<SubKey>
        TypeName count ProgReg place  ProgReg +place
        ProgReg count asciiz
        HKEY_CLASSES_ROOT Call RegDeleteKey
        IF
            s" Unable to delete " pad place
            progreg count pad +place
            pad count asciiz
            z" DeleteSubKey"
            MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop
        THEN 
        ;

: DeleteKeyValue ( hKey s" Value Name" -- )   \ deletes value HKEY_CLASSES_ROOT\<Key Name>\<Value Name>
        ProgReg place
        ProgReg count
        asciiz swap Call RegDeleteValue
        IF
            s" Unable to delete " pad place
            progreg count pad +place
            pad count asciiz
            z" DeleteKeyValue"
            MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop
        THEN 
        ;

: SaveDefaultValue ( -- )   \ will be empty for a new extension
        s" " FileExtension count RegGetString
        PreviousKey count  FileExtension count  RegSetString ;
  
: RestoreDefaultValue ( -- )   \ if previous key exists
        PreviousKey count  FileExtension count  RegGetString  RegType @ REG_SZ =
        IF  s" "  FileExtension count  RegSetString  ELSE  2drop  THEN ;

: DeleteExtension ( -- )   \ if default value is empty, otherwise just delete previous key
        s" " FileExtension count RegGetString nip 0=
        IF  FileExtension count  asciiz  HKEY_CLASSES_ROOT Call RegDeleteKey drop
        ELSE  FileExtension count  RegGetKey dup  PreviousKey count  DeleteKeyValue (RegCloseKey) drop
        THEN ;

EXTERNAL

: DeleteAssociation ( s" .ext"  s" App.exe" -- )
        "minus-ext"  2dup TypeName place  PreviousKey place  s" .bak" PreviousKey +place
        2dup FileExtension place  TypeName +place
        SetHKCRPath
        s" " FileExtension count RegGetString  TypeName  count  STR=
        IF
            RestoreDefaultValue
            DeleteExtension
            s" \Shell\Open\Command"  DeleteTypeNameSubKey
            s" \Shell\Open"          DeleteTypeNameSubKey
            s" \Shell"               DeleteTypeNameSubKey
            s" \DefaultIcon"         DeleteTypeNameSubKey
            s" "                     DeleteTypeNameSubKey
        ELSE
            s" Unable to delete " pad place
            FileExtension count pad +place
            pad count asciiz
            z" Delete Association"
            MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop
        THEN
        RestoreRegPath ;

: SetAssociation ( s" .ext"  s" Type"  s" App.exe </Options>" -- )
        2dup bl scan 2dup Options place nip -   \ first word only, rest to options  
        2dup "minus-ext"  2dup TypeName place  PreviousKey place  s" .bak" PreviousKey +place
        "path-file   \ get full path name of App.exe
        IF
            pad place
            s"  not found in current path" pad +place
            pad count asciiz
            z" Set Association"
            MB_ICONEXCLAMATION MB_OK or NULL MessageBox drop
            4drop
        ELSE
            2dup DefaultIcon place  s" ,0" DefaultIcon +place
            s$ '"' pad place  pad +place  s$ '" "%1"' pad +place  Options count pad +place  pad count CommandLine place
            FileType place
            2dup FileExtension place  TypeName +place
            SetHKCRPath
            RestoreDefaultValue
            SaveDefaultValue
            TypeName count  s" "  FileExtension count  RegSetString
            FileType count  s" "  TypeName count       RegSetString
            DefaultIcon count  s" "  TypeName count pad place  s" \DefaultIcon"        pad +place  pad count RegSetString
            Commandline count  s" "  TypeName count pad place  s" \Shell\Open\Command" pad +place  pad count RegSetString
            RestoreRegPath
        THEN ;

MODULE

\s
: ss ( -- )   s" .sku"  s" Sudoku File"  s" Sudoku.exe"  SetAssociation ;
: dd ( -- )   s" .sku"  s" Sudoku.exe"  DeleteAssociation ;
