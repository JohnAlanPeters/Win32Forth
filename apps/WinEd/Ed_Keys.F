\ $Id: Ed_Keys.F,v 1.11 2013/11/28 19:13:25 georgeahubert Exp $
\
\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 64    View
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: View-before-bye { \ last-entry -- }
      decimal
      -1 to last-entry
      entry# >r
      save-defaults
      FALSE to term-canceled?         \ initially NOT canceled
      entry-max 0
      DO    i to entry#             \ select the hyper file index
            edit-changed?
            IF    save-minutes 0>
                  IF    save-text
                  ELSE  i to last-entry
                        refresh-screen
                        z" Save the changes to the current file before quitting?"
                        z" The Current File Has Been Modified!"
                        MB_YESNOCANCEL MB_ICONSTOP or
                        WinEdMessageBox: EditorWindow
                        CASE
                              IDYES     OF    save-text               ENDOF
                              IDNO      OF    FALSE to edit-changed?
                                              update-mirrors          ENDOF
                              IDCANCEL  OF    TRUE to term-canceled?  ENDOF
                        ENDCASE
                  THEN
            THEN
            term-canceled? ?LEAVE
      LOOP
      last-entry -1 <>
      IF      last-entry SetStack: EditWindow
      ELSE    r@ to entry#
      THEN    r>drop ;

: view-release  ( -- )                          \ release the editors buffers
        DestroyWindow: FrameWindow
        text-ptr ?dup IF release 0 to text-ptr THEN
        line-tbl ?dup IF release 0 to line-tbl THEN  ;

unload-chain chain-add-before view-release         \ make sure memory is released

: viewbye       ( -- )
        view-before-bye
        term-canceled? 0=
        IF   [ Action-of BYE compile, ]
        THEN    ;

: "viewmessage  ( a1 n1 )       \ force all message window on top of application
        GetHandle: FrameWindow
        IF      StartPos: FrameWindow 100 100 rot + >r + r> message-origin
        THEN
        [ also HIDDEN ] _"message [ previous ] ;

: "topviewmessage  ( a1 n1 )
        GetHandle: FrameWindow
        IF      StartPos: FrameWindow 100 100 rot + >r + r> message-origin
        THEN
        [ also HIDDEN ] _"top-message [ previous ] ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 65    Include some improvements  by Robert Ackerman for John Peters
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

2 value ppchar ( n -- ) \ number of blank lines to skip between sections

: +VSCR ( -- )           \ down 1 screen ending with 2 or more empty lines
        0               \ count of empty lines
        BEGIN   dup -1 > cursor-line file-lines 1- < and \ ?end of file
        WHILE
                cursor-line 1+ to cursor-line   \ inc line
                get-cursor-line cur-buf @ 0=    \ inc count if empty line
                IF      1+
                ELSE  ppchar 1- >
                THEN
        REPEAT
        -1 =
        IF      cursor-line to line-cur refresh-screen
        ELSE    line-cur to cursor-line
        THEN ;

: -VSCR  ( -- )                  \ up 1 screen ending with 2 or more empty lines
        cursor-line ppchar >                    \ at least n lines above
        IF      cursor-line 1- to cursor-line   \ up one line
                get-cursor-line cur-buf @ 0=    \ line is empty
                IF cursor-line 1- to cursor-line  \ up a line
                        get-cursor-line cur-buf @ 0=   \ true->2 empty lines
                        IF
                                BEGIN   cur-buf @ 0= cursor-line 0> and \ until top or non-empty
                                WHILE   cursor-line 1- to cursor-line
                                        get-cursor-line
                                REPEAT
                        THEN
                THEN
        THEN
        0
        BEGIN   dup ppchar < cursor-line 0> and
        WHILE
                cursor-line 1- to cursor-line
                get-cursor-line cur-buf @ 0=
                IF      1+
                ELSE    drop 0
                THEN
        REPEAT
        cursor-line + dup to line-cur to cursor-line
        refresh-screen ;

\ Here is the version with no line length limit:
: OVERSTRIKE-CHARACTER  ( char -- )             \ was _overstrike
        dup bl >= over 0xff <= and
        IF      get-cursor-line
                cur-buf lcount drop             \ start of text in buffer
                cursor-col + c!                 \ put character into buffer
                cur-buf @ cursor-col max
                1+ "LCLIP" cur-buf !            \ increment buf size
                put-cursor-line
                file-has-changed
                1 +col-cursor
        ELSE    drop beep
        THEN ;

: INSERT/OVERSTRIKE-CHARACTER  ( char -- ) \ modified word replaces the original
        browse?
        IF      beep \ new May 20th, 2003 - 18:57 dbu
                drop EXIT
        THEN
        delete-highlight

        ( Test for ins/over mode and do it. jap )
        overstrike @
        IF overstrike-character      \ was _overstrike-character or what!!
        ELSE _insert-character
        THEN
        ?wrap-word
        refresh-line ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 66    These words handle the backspace properly when in the overstrike mode
\       Robert Ackerman with John Peters on March 9th, 2002 - 10:15 to 11:20
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: DEL-CHAR      ( -- )          \  sub for k_delete  \ Working ok.
        overstrike @
        IF      bl overstrike-character
        ELSE    delete-character
        THEN ;

: DO-BS         ( -- )          \ sub for k_backspace
        overstrike @
        IF      cursor-col 0>
                IF      cursor-col 1- dup to cursor-col
                        bl overstrike-character
                        to cursor-col
                THEN
        ELSE    do-backspace
        THEN ;

defer _Control+W ' close-text is _control+w

: toggle-colons-only ( -- )    \ RDA
        cursor-line to line-cur
        colons-only 0= dup to colons-only
        if setcolontbl then
        refresh-screen ;

: toggle-insert ( -- )
        overstrike @ 0= overstrike !
        ReTitle: EditorWindow ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 67    The main editor loop
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: handle-keyboard-interpretation
                  BEGIN key?                   \ handle keyboard interpretation
                  WHILE key?
                        IF    key rem-sendkey  \ just send keys to Forth console
                        THEN
                  REPEAT ;

also hidden  \ for menukey-more

: SMS-WEW-key-Con-doc-interp-send
            BEGIN   SetMultiStatus: EditorWindow
                    key menukey-more           \ handle keyboard interpretation
                    false \ interpreting?
            WHILE   rem-sendkey                \ just send keys to Forth console
            REPEAT ;
previous

: VIEW-KEY-LOOP ( -- )
      BEGIN
            depth to saved-depth            \ so we can check stack depth
            ibeam-cursor
            RefreshCursor: DocWindow
            ShowCursor: DocWindow
            EditMode: Win-EdToolbar
            SMS-WEW-key-Con-doc-interp-send
            SetFocus: DocWindow
            HideCursor: DocWindow
            CASE

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 68    Control key bindings
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

      'A'     +k_control            OF      highlight-all               ENDOF
      'A'     +k_control +k_shift   OF      toggle-colons-only          ENDOF
      'B'     +k_control            OF      debug-word                  ENDOF
      'B'     +k_control +k_shift   OF      debug-word                  ENDOF
      'C'     +k_control            OF      copy-text                   ENDOF
      'D'     +k_control            OF      debug-buttons               ENDOF
      'D'     +k_control +k_shift   OF      revert-text ( see also Q )  ENDOF
      'E'     +k_control            OF      my-application              ENDOF
      'E'     +k_control +k_shift   OF      expand-tabs                 ENDOF
      'F'     +k_control            OF      replace-text                ENDOF
      'F'     +k_control +k_shift   OF      find-in-files               ENDOF
      'G'     +k_control            OF      delete-character            ENDOF
      'H'     +k_control +k_shift   OF      make-hex                    ENDOF
      'L'     +k_control            OF      load-active-file            ENDOF

[ also HIDDEN ]  [DEFINED]  replay-macro [IF]
      'M'     +k_control +k_shift   OF      replay-macro                ENDOF
[THEN]  [ previous ]
      'N'     +k_control            OF      new-text                    ENDOF
      'O'     +k_control            OF      open-text                   ENDOF
      'O'     +k_control +k_shift   OF      open-text-highlighted       ENDOF
      'P'     +k_control            OF      print-text                  ENDOF
      'P'     +k_control +k_shift   OF      text-options                ENDOF
      'Q'     +k_control            OF      highlight-mark              ENDOF
      'Q'     +k_control +k_shift   OF      revert-text ( see also D )  ENDOF
      'R'     +k_control            OF      reformat-text               ENDOF
      'S'     +k_control            OF      save-text                   ENDOF

[ also HIDDEN ]  [DEFINED]  repeat-amacro [IF]
      'R'     +k_control +k_shift   OF      EditorWindow repeat-amacro  ENDOF
      'S'     +k_control +k_shift   OF      Start/Stop-macro            ENDOF
[THEN]  [ previous ]

      'T'     +k_control            OF      word-delete                 ENDOF
      'T'     +k_control +k_shift   OF      word-undelete               ENDOF
      'U'     +k_control            OF      highlight-case-toggle       ENDOF
      'V'     +k_control            OF      Paste-text                  ENDOF
      'V'     +k_control +k_shift   OF      Paste-date/time             ENDOF
      'W'     +k_control            OF      _control+w                  ENDOF
      'W'     +k_control +k_shift   OF      close-all-text              ENDOF
      'X'     +k_control            OF      cut-text                    ENDOF
      'Y'     +k_control            OF      line-delete                 ENDOF
      'Z'     +k_control            OF      word-undelete               ENDOF

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 69    Function key bindings   +SCR is 1 page down
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

      k_F1                          OF      w32f-doc                    ENDOF
      k_F1    +k_control            OF      word-help                   ENDOF
      k_F2                          OF      toggle-colons-only          ENDOF
      k_F3                          OF      find-text-again             ENDOF
      k_F3    +k_shift              OF      back-find-text-again        ENDOF
      k_F3    +k_control            OF      find-text-highlight         ENDOF
      k_F3    +k_shift +k_control   OF      replace-text                ENDOF

[ also HIDDEN ]  [DEFINED]  replay-macro [IF]
      k_F5                          OF      replay-macro                ENDOF
[THEN]  [ previous ]

      k_F5    +k_control +k_shift   OF      cwords                      ENDOF
      k_F7                          OF      browse-toggle               ENDOF
      k_F9                          OF      hyper-link                  ENDOF
      k_F9    +k_control            OF      next-hyper-link             ENDOF
      k_F9    +k_shift              OF      browse-toggle               ENDOF
      k_F9    +k_control +k_shift   OF      word-link                   ENDOF
      k_F10                         OF      close-text                  ENDOF
      k_F10   +k_shift              OF      save-all-text bye           ENDOF
      k_F11                         OF      temp-text                   ENDOF
      k_F11   +k_control +k_shift   OF      do-html-link                ENDOF
      k_F12   +k_control +k_shift   OF      save-text-pc                ENDOF
      k_F12                         OF      save-and-load               ENDOF

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 70    PgDn, End, Home
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

      k_down                        OF      1 +row-cursor               ENDOF
      k_down  +k_control            OF      1 +row-scroll               ENDOF
      k_down  +k_shift              OF      highlight-down              ENDOF
      k_end                         OF      end-line                    ENDOF
      k_end   +k_shift              OF      highlight-end-line          ENDOF
      k_end   +k_control            OF      end-doc                     ENDOF
      k_end   +k_shift +k_control   OF      highlight-end-doc           ENDOF
      k_home                        OF      home-line                   ENDOF
      k_home  +k_shift              OF      highlight-home-line         ENDOF
      k_home  +k_control            OF      home-doc                    ENDOF
      k_home  +k_shift +k_control   OF      highlight-home-doc          ENDOF

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 71    Arrow left
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

      k_left                        OF      character-left              ENDOF
      k_left  +k_control            OF      word-left                   ENDOF
      k_left  +k_shift              OF      highlight-left              ENDOF
      k_left  +k_shift +k_control   OF      highlight-word-left         ENDOF

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 72    PgDn  PgUp
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

      k_pgdn                        OF      1 +page-cursor              ENDOF
      k_pgdn  +k_control            OF      next-link                   ENDOF
      k_pgdn  +k_shift              OF      +VSCR                       ENDOF
      k_pgup                        OF      -1 +page-cursor             ENDOF
      k_pgup  +k_control            OF      prev-link                   ENDOF
      k_pgup  +k_shift              OF      -VSCR                       ENDOF

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 73    Right-Arrow   Up-Arrow
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
      k_right                       OF      character-right             ENDOF
      k_right +k_control            OF      word-right                  ENDOF
      k_right +k_shift              OF      highlight-right             ENDOF
      k_right +k_shift +k_control   OF      highlight-word-right        ENDOF
      k_up                          OF      -1 +row-cursor              ENDOF
      k_up    +k_control            OF      -1 +row-scroll              ENDOF
      k_up    +k_shift              OF      highlight-up                ENDOF

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ 74    Mode, Select, Copy, Paste, Tab, Del, Goto-line, Insert\Over-strike
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

      k_tab                         OF      insert-tab                  ENDOF
      k_tab   +k_shift              OF      back-tab                    ENDOF
      k_insert                      OF      toggle-insert               ENDOF
      k_insert +k_shift             OF      paste-text                  ENDOF
      k_insert +k_control           OF      copy-text                   ENDOF
      k_delete                      OF      delete-character            ENDOF
      k_delete  +k_shift            OF      cut-text                    ENDOF
      k_delete  +k_control          OF      word-delete                 ENDOF
      k_BACKSPACE                   OF      do-bs                       ENDOF
      k_BACKSPACE   +k_shift        OF      next-window                 ENDOF
      k_ESC                         OF      do-esc                      ENDOF
      k_LF                          OF      goto-line                   ENDOF
      k_CR                          OF      smart-cr                    ENDOF
                                        dup insert/overstrike-character
        ENDCASE
      AGAIN   ;
