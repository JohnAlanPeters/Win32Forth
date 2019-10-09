\ $Id: DexH-CreateDocs.f,v 1.23 2008/12/23 21:12:06 camilleforth Exp $

anew -DexH-CreateDocs.f

needs tools/w32fdexh.f

\ *D doc
\ *! p-dexh-createdocs Docs W32F                                                                 )
\ *T Documenting Win32Forth

internal
external

: create-docs   ( -- )  \ W32F  tool
\ *G Create the documentation for Win32Forth from
\ ** the source files.
\ *P Not all files have been marked up yet. If you feel like doing some
\ ** then drop us a line at
\ *W <a href="http://groups.yahoo.com/group/win32forth">win32forth at Yahoo</a>
\ *P VOLUNTEERS are always welcome.
        \ create a new gloassary file if needed
        1 to create-glossary-file?
        output-new

        \ classes
        W32FClassDocs
\
        \ Windows, dialogs and controls
        s" src\generic.f"               create-doc
        s" src\window.f"                create-doc
        s" src\lib\TrayWindow.f"        create-doc
        s" src\lib\TimerWindow.f"       create-doc
        s" src\childwnd.f"              create-doc
        s" src\dialog.f"                create-doc
        s" src\control.f"               create-doc
    -tr s" src\controls.f"              create-doc
        s" src\lib\StatusBar.f"         create-doc
        s" src\lib\Textbox.f"           create-doc
        s" src\lib\Listbox.f"           create-doc
        s" src\lib\UpDownControl.f"     create-doc
        s" src\lib\Buttons.f"           create-doc
        s" src\lib\Label.f"             create-doc
        s" src\lib\ProgressBar.f"       create-doc
        s" src\lib\TrackBar.f"          create-doc
        s" src\lib\ScrollBar.f"         create-doc
        s" src\lib\Calendar.f"          create-doc
        s" src\lib\TabControl.f"        create-doc
    +tr s" src\lib\ButtonBar.f"         create-doc
\
        s" src\lib\MdiDialog.f"         create-doc
        s" src\lib\AXControl.F"         create-doc
\
    -tr s" src\lib\HTMLcontrol.F"       create-doc
    +tr s" demos\HtmlControlDemo.f"     create-doc
    -tr s" src\lib\Mdi.F"               create-doc
    +tr s" demos\MdiExample.f"          create-doc
\
        \ GDI class library
        s" src\gdi\gdiStruct.f"         create-doc
        s" src\gdi\gdiBase.f"           create-doc
        s" src\gdi\gdiPen.f"            create-doc
        s" src\gdi\gdiBrush.f"          create-doc
        s" src\gdi\gdiBitmap.f"         create-doc
        s" src\gdi\gdiFont.f"           create-doc
        s" src\gdi\gdiMetafile.f"       create-doc
        s" src\gdi\gdiDC.f"             create-doc
        s" src\gdi\gdiWindowDC.f"       create-doc
        s" src\gdi\gdiMetafileDC.f"     create-doc
\
        \ other classes
        s" src\lib\file.f"              create-doc
        s" src\lib\SQLite.F"            create-doc
        s" src\lib\ExtDC.F"             create-doc
        s" src\lib\BitmapDC.F"          create-doc
\
        \ ADO
        s" src\lib\Ado.f"               create-doc

        \ other documentation
        W32FDocs
\
        s" src\lib\AcceleratorTables.f" create-doc
        s" src\lib\task.f"              create-doc
        s" src\Module.f"                create-doc
        s" src\Classdbg.f"              create-doc
        s" src\FLOAT.F"                 create-doc
        s" src\console\NoConsole.f"     create-doc
        s" src\Callback.f"              create-doc
        s" src\paths.f"                 create-doc
        s" src\interpif.f"              create-doc
        s" src\floadcmdline.f"          create-doc
        s" src\tools\W32fdexh.f"        create-doc
        s" src\tools\DexH-CreateDocs.f" create-doc
        s" src\lib\Sock.f"              create-doc

        s" apps\Internet\WebServer\sockserv.f" create-doc
        ;

module

\ also hidden
\ debug create-doc

cls
create-docs

\ *Z
