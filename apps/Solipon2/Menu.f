\ $Id: Menu.f,v 1.2 2008/05/03 08:44:05 dbu_de Exp $

ToolBar Solipion-Tool-Bar1 "SOLIPION.BMP"
     0 PictureButton                    'N' +k_control pushkey  ; \ New
        ButtonInfo"  New Game "
     1 PictureButton                    'O' +k_control pushkey  ; \ Open
        ButtonInfo"  Open "
     1 PictureButton                    'R' +k_control pushkey  ; \ Re-open
        ButtonInfo"  Re-Open "
     2 PictureButton                    'E' +k_control pushkey  ; \ Save
        ButtonInfo"  Save "
     2 PictureButton                    'S' +k_control pushkey  ; \ Save As
        ButtonInfo"  Save As "
     3 PictureButton                    'T' +k_control pushkey  ; \ Print
        ButtonInfo"  Print Text "
    17 PictureButton                    'B' +k_control pushkey  ; \ Print bmp
        ButtonInfo"  Print Bitmap "
    11 PictureButton                    'A' +k_control pushkey ;  \ Automatic
        ButtonInfo"  Automatic "
    12 PictureButton                k_left  +k_control pushkey  ; \ Shrinking
        ButtonInfo"  Shrinking "
     4 PictureButton                k_right +k_control pushkey  ; \ Enlarge
        ButtonInfo"  Enlarge "
    13 PictureButton               k_scroll +k_control pushkey  ; \ To last move
        ButtonInfo"  To Last Move "
    14 PictureButton                k_pgdn  +k_control pushkey  ; \ To next move
        ButtonInfo"  To Next Move "
     9 PictureButton                 k_down +k_control pushkey  ; \
        ButtonInfo"  Minus the Tempo "
    10 PictureButton                   k_up +k_control pushkey  ; \
        ButtonInfo"  More Tempo "
    15 PictureButton                    'W' +k_control pushkey  ; \
        ButtonInfo"  On/Off the sound"
    16 PictureButton                    'H' +k_control pushkey  ; \ Table of Bests Scores
        ButtonInfo"  Table of Bests Scores"
ENDBAR


defer EnableMenuBar

: (random-board?)
        random-board? 0= to random-board? EnableMenuBar ;

POPUPBAR Solipion-Popup-bar

    POPUP " "
        MENUITEM        "&New Game "         'N' +k_control pushkey      ;
        MENUITEM        "&Automatic Game "   'A' +k_control pushkey      ;
        MENUSEPARATOR
        :MenuItem mp_random1 "&Random board"             (random-board?) ;
        MENUSEPARATOR
        MENUITEM        "&Open  "            'O' +k_control pushkey      ;
        MENUITEM        "&Re-open  "         'R' +k_control pushkey      ;
        MENUSEPARATOR
        MENUITEM        "&Save "             'E' +k_control pushkey      ;
        MENUITEM        "Save &As "          'S' +k_control pushkey      ;
        MENUSEPARATOR
        MENUITEM        "Print &Text"        'T' +k_control pushkey      ;
        MENUITEM        "Print &Bitmap"      'B' +k_control pushkey      ;
        MENUSEPARATOR
        MENUITEM        "&Quit"              'Q' +k_control pushkey      ;
ENDBAR

MENUBAR Solipion-Menu-bar

    POPUP "&Game"
        MENUITEM     "&New           \tCtrl+N"      'N' +k_control pushkey ;
        MENUITEM     "&Automatic     \tCtrl+A"      'A' +k_control pushkey ;
        MENUSEPARATOR
        :MenuItem mp_random2 "&Random board"               (random-board?) ;
        MENUSEPARATOR
        MENUITEM     "&Open...       \tCtrl+O"      'O' +k_control pushkey ;
        MENUITEM     "&Re-Open       \tCtrl+R"      'R' +k_control pushkey ;
        MENUSEPARATOR
        MENUITEM     "&Save \tCtrl+E"               'E' +k_control pushkey ;
        MENUITEM     "Save &As... \tCtrl+S"         'S' +k_control pushkey ;
        MENUSEPARATOR
        MENUITEM     "Print Setup... \tCtrl+Shift+P" 'P' +k_control +k_shift pushkey ;
        MENUITEM     "&Print Text... \tCtrl+P"       'P' +k_control pushkey ;
        MENUITEM     "&Print Bitmap... \tCtrl+B"     'B' +k_control pushkey ;
        MENUSEPARATOR
        MENUITEM     "Quit          \tCtrl+Q"        'Q' +k_control pushkey ;

    POPUP "&About..."
        MENUITEM     "SoliPion"                     k_F1 +k_control pushkey ;
ENDBAR

:noname	( -- )  \ enable/disable the menu items
        random-board? Check: mp_random1
        random-board? Check: mp_random2
; is EnableMenuBar
