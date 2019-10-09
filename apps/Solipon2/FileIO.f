\ $Id: FileIO.f,v 1.3 2008/06/29 05:00:45 camilleforth Exp $


FileOpenDialog OpenGame   "Open Game" "SoliPion (*.SOL)|*.SOL|All (*.*)|*.*|"
FileSaveDialog SaveGame   "Save Game" "SoliPion (*.SOL)|*.SOL|All (*.*)|*.*|"


\ ---------------------------------------------------------------
\               Open a Game
\ ---------------------------------------------------------------

defer !bests
: nothing false ;
' nothing is !bests
0 value gameloaded?

: (load-game)   ( addr len -- )
                { \ hfile -- }
        r/w open-file abort" open-file" to hfile

        smallstring 19 hfile read-file 2drop
        smallstring 3 s" SOL" compare 0= dup if true  to put-by? then
        smallstring 3 s" PLA" compare 0= dup if false to put-by? then
        or
        IF   string-player-name      20      hfile read-file 2drop
             &of shift-x             cell    hfile read-file 2drop
             &of shift-y             cell    hfile read-file 2drop
             &of moves               cell    hfile read-file 2drop
             moves-table      moves cells    hfile read-file 2drop

             \ for the Thing...
             coords2 72 cells hfile read-file drop 0<>
             if   &of max-pawns cell hfile read-file drop 0<>
             else false
             then to random-board?
        THEN

        hfile close-file drop
;

: open-game     { \ open$ hfile --  }
        max-path LocalAlloc: open$
        GetHandle: SOLIPIONW Start: OpenGame dup c@ \ ( -- a1 n1 )
        IF   count open$ place

             open$ count (load-game)

             true to show?
             moves 1- dup dup max-counter >
             if   to max-counter  to counter !bests
             else 2drop
             then

             true to gameloaded?
        ELSE DROP
        THEN ;

\ ---------------------------------------------------------------
\               Re-Open the game
\ ---------------------------------------------------------------

:noname         ( -- )
            0 to tempo
        false to show?

        in-memory?
        IF   counter 1+ to moves
        ELSE S" GAME.SOL" (load-game)
        THEN ; is re-open-game

\ ---------------------------------------------------------------
\               Save the Game
\ ---------------------------------------------------------------

: (save-game)   ( addr len -- )
                { \ hfile -- }
        r/w create-file abort" create-file" to hfile

        put-by?
        if   s" PLA"
        else s" SOL"
        then                          hfile write-file drop
        get-local-time
        time-buf                16    hfile write-file drop
        string-player-name      20    hfile write-file drop
        &of shift-x             cell  hfile write-file drop
        &of shift-y             cell  hfile write-file drop
        counter 1+ to moves
        &of moves               cell  hfile write-file drop
        moves-table      moves cells  hfile write-file drop

        random-board?
        if   coords2        72 cells  hfile write-file drop \ for the Thing...
             &of max-pawns      cell  hfile write-file drop
        then

        hfile close-file drop
;

:noname ( -- )
        in-memory?
        if   counter 1+ to moves
        else s" GAME.SOL" (save-game)
        then ; is save-game

\ ---------------------------------------------------------------
\               Save the Game As
\ ---------------------------------------------------------------

: save-game-as  { \ save$  -- }

        max-path    LocalAlloc: save$

        auto-save?
        if   counter 0 <# # # # #> save$ place
             s" .SOL" save$ +place
             save$ count delete-file drop
             save$ dup c@
        else s" Save the Game As : " SetTitle: SaveGame
             GetHandle: SOLIPIONW Start: SaveGame dup c@ \ ( -- a1 n1 )
        then

        IF   count (save-game)
        ELSE drop
        THEN ;

\ ---------------------------------------------------------------
\               Save the bests-table
\ ---------------------------------------------------------------
: save-bests    { \ best$ hfile -- }
        max-path LocalAlloc: best$
        S" solipion.dat" best$ place
        best$ count r/w open-file 0=

        if   to hfile
             smallstring 3 hfile read-file 2drop
        else drop
             best$ count r/w create-file drop to hfile
             s" SOL" 2dup                hfile write-file drop
                     smallstring swap cmove
             get-local-time
             time-buf         16         hfile write-file drop

        then

        smallstring 3 s" SOL" compare 0=
        if
                    stamper  16         hfile write-file drop
                bests-table 220         hfile write-file drop

        then
                                        hfile close-file drop

        ;
