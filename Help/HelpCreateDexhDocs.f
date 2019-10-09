\ $Id: HelpCreateDexhDocs.f,v 1.12 2014/08/15 13:29:52 jos_ven Exp $

\ Adapted from Dexh-CreateDocs.f & Win32fDexh.f -- April 2008 - Camille Doiteau

anew -HelpCreateDexhDocs.f

needs help\HelpDexh.f

create NoTrailer
       0 c,

0 value OLDtrailer

: -tr           ( -- ) \ Stop output of the HTML trailer.
                OLDtrailer 0=
                if   HTMLtrailer to OLDtrailer
                     NoTrailer   to HTMLtrailer
                then ;

: +tr           ( -- ) \ Restart output of the HTML trailer.
                OLDtrailer ?DUP
                if   to HTMLtrailer
                     0 to OLDtrailer
                then ;


: create-doc    ( addrf len addrhtm len -- )
\ Create win32forth htm document from source file to a new htm file. You must
\ give both filenames, subpathes and extensions. The win32forth search path is
\ automatically preprended.
                Prepend<home>\ $outfile place
                Prepend<home>\ $infile place
                (dexh) ;

: append-doc    ( addrf len addrhtm len -- )
\ Append win32forth htm document from source file to an existing htm file.
\ You must give both filenames, subpathes and extensions. The win32forth search
\ path is automatically preprended. Use +tr and -tr to handle appending or not
\ the html trailer
                Prepend<home>\ $outfile place
                Prepend<home>\ $infile place
                $infile count r/o OPEN-FILE abort" Missing input file" to infile
                $outfile count w/o OPEN-FILE abort" Can't open file" to outfile
                outfile FILE-SIZE drop outfile REPOSITION-FILE drop
                ((dexh))
                outfile CLOSE-FILE drop
                infile CLOSE-FILE drop ;


\ ------------------------------------------------------------------------------
cr .( Creating Win32Forth dexh documentation...)
\ ------------------------------------------------------------------------------

     \ classes related documentation

     \ Windows, dialogs and controls
     s" src\generic.f"            s" help\html\class-generic.htm"     create-doc
     s" src\window.f"             s" help\html\class-window.htm"      create-doc
     s" src\lib\TrayWindow.f"     s" help\html\class-TrayWindow.htm"  create-doc
     s" src\lib\TimerWindow.f"    s" help\html\class-TimerWindow.htm" create-doc
     s" src\childwnd.f"           s" help\html\class-childwnd.htm"    create-doc
     s" src\dialog.f"             s" help\html\class-dialog.htm"      create-doc
     s" src\control.f"            s" help\html\class-control.htm"     create-doc
 -tr s" src\controls.f"           s" help\html\class-controls.htm"    create-doc
     s" src\lib\StatusBar.f"      s" help\html\class-controls.htm"      append-doc
     s" src\lib\Textbox.f"        s" help\html\class-controls.htm"      append-doc
     s" src\lib\Listbox.f"        s" help\html\class-controls.htm"      append-doc
     s" src\lib\UpDownControl.f"  s" help\html\class-controls.htm"      append-doc
     s" src\lib\Buttons.f"        s" help\html\class-controls.htm"      append-doc
     s" src\lib\Label.f"          s" help\html\class-controls.htm"      append-doc
     s" src\lib\ProgressBar.f"    s" help\html\class-controls.htm"      append-doc
     s" src\lib\TrackBar.f"       s" help\html\class-controls.htm"      append-doc
     s" src\lib\ScrollBar.f"      s" help\html\class-controls.htm"      append-doc
     s" src\lib\Calendar.f"       s" help\html\class-controls.htm"      append-doc
     s" src\lib\TabControl.f"     s" help\html\class-controls.htm"      append-doc
 +tr s" src\lib\ButtonBar.f"      s" help\html\class-controls.htm"      append-doc

     s" src\lib\MdiDialog.f"      s" help\html\class-MdiDialog.htm"   create-doc
     s" src\lib\AXControl.f"      s" help\html\class-AXControl.htm"   create-doc

 -tr s" src\lib\HTMLcontrol.f"    s" help\html\class-HTMLcontrol.htm" create-doc
 +tr s" demos\HtmlControlDemo.f"  s" help\html\class-HTMLcontrol.htm"   append-doc
 -tr s" src\lib\Mdi.f"            s" help\html\class-Mdi.htm"         create-doc
 +tr s" demos\MdiExample.f"       s" help\html\class-Mdi.htm"           append-doc

     \ GDI class library
     s" src\gdi\gdiStruct.f"      s" help\html\class-gdiStruct.htm"     create-doc
     s" src\gdi\gdiBase.f"        s" help\html\class-gdiBase.htm"       create-doc
     s" src\gdi\gdiPen.f"         s" help\html\class-gdiPen.htm"        create-doc
     s" src\gdi\gdiBrush.f"       s" help\html\class-gdiBrush.htm"      create-doc
     s" src\gdi\gdiBitmap.f"      s" help\html\class-gdiBitmap.htm"     create-doc
     s" src\gdi\gdiFont.f"        s" help\html\class-gdiFont.htm"       create-doc
     s" src\gdi\gdiMetafile.f"    s" help\html\class-gdiMetafile.htm"   create-doc
     s" src\gdi\gdiDC.f"          s" help\html\class-gdiDC.htm"         create-doc
     s" src\gdi\gdiWindowDC.f"    s" help\html\class-gdiWindowDC.htm"   create-doc
     s" src\gdi\gdiMetafileDC.f"  s" help\html\class-gdiMetafileDC.htm" create-doc

     \ other classes
     s" src\lib\file.f"           s" help\html\class-file.htm"          create-doc
     s" src\lib\MultiTaskingClass.f" s" help\html\class-MultiTaskingClass.htm"  create-doc

     s" src\lib\SQLite.f"         s" help\html\class-SQLite.htm"        create-doc
     s" src\lib\extDC.f"          s" help\html\class-ExtDC.htm"         create-doc
     s" src\lib\bitmapDC.f"       s" help\html\class-BitmapDC.htm"      create-doc

     \ ADO
     s" src\lib\Ado.f"            s" help\html\class-Ado.htm"           create-doc

     \ Sock & Socket server
     s" src\lib\Sock.f"                     s" help\html\dexh-Sock.htm"       create-doc
     s" apps\Internet\WebServer\sockserv.f" s" help\html\dexh-sockserver.htm"   create-doc
     s" apps\Internet\WebServer\webserver.f" s" help\html\dexh-webserver.htm"   create-doc

     \ non-class documentation

     s" src\lib\AcceleratorTables.f" s" help\html\dexh-AcceleratorTables.htm"  create-doc
     s" src\lib\task.f"              s" help\html\dexh-task.htm"               create-doc
     s" src\Module.f"                s" help\html\dexh-Module.htm"             create-doc
     s" src\Classdbg.f"              s" help\html\dexh-Classdbg.htm"           create-doc
     s" src\float.f"                 s" help\html\dexh-float.htm"              create-doc
     s" src\Callback.f"              s" help\html\dexh-Callback.htm"           create-doc
     s" src\paths.f"                 s" help\html\dexh-paths.htm"              create-doc
     s" src\interpif.f"              s" help\html\dexh-interpif.htm"           create-doc
     s" src\floadcmdline.f"          s" help\html\dexh-floadcmdline.htm"       create-doc
     s" src\lib\block.f"             s" help\html\dexh-block.htm"              create-doc
     s" src\lib\unicode.f"           s" help\html\dexh-unicode.htm"            create-doc
     s" src\ansfile.f"               s" help\html\dexh-ansfile.htm"            create-doc
     s" src\lib\switch.f"            s" help\html\dexh-switch.htm"             create-doc
     s" src\tools\dexh.f"            s" help\html\dexh-helpdexh.htm"           create-doc
     s" help\HelpMain.f"             s" help\html\dexh-HelpMain.htm"           create-doc
     s" src\w32fmsg.f"               s" help\html\dexh-w32fmsg.htm"            create-doc

cr .( Win32Forth dexh documentation successfully created)
