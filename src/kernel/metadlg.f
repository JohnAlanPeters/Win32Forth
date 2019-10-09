\ $Id: metadlg.f,v 1.2 2008/08/02 22:11:09 camilleforth Exp $

cr .( Loading META FKERNEL Dialog)


needs MetaDlg.frm

\ -------------------- Meta Dialog --------------------


:Object META-DIALOG <SUPER MetaDlg

int result

int sysmem
int appmem
int codemem

int defsysmem
int defappmem
int defcodemem

:M ClassInit:   ( -- )
                ClassInit: super
                0 to appmem
                0 to sysmem
                0 to codemem
                0 to defappmem
                0 to defsysmem
                0 to defcodemem
                ;M

:M GetAppMem:   ( -- appmemory )     appmem ;M
:M GetSysMem:   ( -- sysmemory )     sysmem ;M
:M GetCodeMem:  ( -- codememory )    codemem ;M

:M SetAppMem:   ( appmemory -- )     TO appmem ;M
:M SetSysMem:   ( sysmemory -- )     TO sysmem ;M
:M SetCodeMem:  ( codememory -- )    TO codemem ;M

:M SetDefAppMem:   ( appmemory -- )  TO defappmem ;M
:M SetDefSysMem:   ( sysmemory -- )  TO defsysmem ;M
:M SetDefCodeMem:  ( codememory -- ) TO defcodemem ;M

:M SetEdit:     ( -- )
                appmem 0 <# #s #>  SetText: TxtAppMem
                sysmem 0 <# #s #>  SetText: TxtSysMem
                codemem 0 <# #s #> SetText: TxtCodeMem
                ;M

:M SetDefault:  ( -- ) \ restore default values
                defappmem SetAppMem: self
                defsysmem SetSysMem: self
                defcodemem SetCodeMem: self
                SetEdit: self
                ;M

:M GetResult:   { \ memory$ flag -- flg }
                64 localAlloc: memory$
                0 to flag
                GetText: TxtAppMem memory$ place
                memory$ count number? abs +to flag drop to appmem
                GetText: TxtSysMem memory$ place
                memory$ count number? abs +to flag drop to sysmem
                GetText: TxtCodeMem memory$ place
                memory$ count number? abs +to flag drop to codemem
                flag
                ;M

: command-func	( id obj -- )
                drop
                case
                  GetId: BtnOK      of GetResult: self
                                       3 = \ if all are ok, then we are done
                                       if   Close: self 1 to result
                                       else beep
                                       then endof
                  GetId: BtnCancel  of Close: self
                                       0 to result endof
                  GetId: BtnRestore of SetDefault: self endof
                endcase ;

:M Start:       ( parent -- result ) \ 1=ok 0=canceled
                SetParentWindow: self
                start: super
                begin winpause Hwnd 0= until
                result
                ;M

:M On_Init:	( -- )
                IDOK     SetID: BtnOK        \ so that return and Esc work
                IDCANCEL SetId: BtnCancel
		On_Init: Super
                GetStyle: BtnOK BS_DEFPUSHBUTTON OR SetStyle: BtnOK
                SetEdit: self
 		['] command-func SetCommand: self
		;m
;Object


