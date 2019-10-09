\ $Id: Sound.f,v 1.1 2008/04/30 15:58:01 dbu_de Exp $

     WinLibrary winmm.dll

     0 value <hypothesis>busy?
     0 value <hypothesis>handle
     0 value <hypothesis>flag?
     0 value <hypothesis>size


: playthat
        SND_ASYNC SND_MEMORY or SND_NODEFAULT or NULL ROT Call PlaySound drop ;

: find-file     ( addr len -- addr1 len1 )
        search-path off \ clear path list
        s" ."       "fpath+ \ current dir is first
        &forthdir count "fpath+
        s" apps\Solipon2" "fpath+

        "path-file drop
        ;

: <<<hypothesis>>> ( -- )
        <hypothesis>busy? ?exit
        true to <hypothesis>busy?
        <hypothesis>flag? 0=
        if      true to <hypothesis>flag?
                s" ep7.wav" find-file r/o open-file drop >r
                r@ file-size drop d>s to <hypothesis>size
                r@ <hypothesis>size malloc to <hypothesis>handle
                <hypothesis>handle <hypothesis>size r@ read-file 2drop
                r> close-file drop

        then
        <hypothesis>flag? music? and
        if
                <hypothesis>handle playthat
        then
        false to <hypothesis>busy?
          ;


        0 value <ding>busy?
        0 value <ding>handle
        0 value <ding>flag?
        0 value <ding>size

: <<<ding>>>    ( -- )
        <ding>busy?  ?exit
        true to <ding>busy?
        <ding>flag? 0=
        if      true to <ding>flag?
                s" av7.wav" find-file r/o open-file drop >r
                r@ file-size drop d>s to <ding>size
                r@ <ding>size malloc to <ding>handle
                <ding>handle <ding>size r@ read-file 2drop
                r> close-file drop
        then
        <ding>flag? music? and
        if
                <ding>handle playthat
        then
        false to <ding>busy?
        ;

        0 value <bleep1>busy?
        0 value <bleep1>handle
        0 value <bleep1>flag?
        0 value <bleep1>size
: <<<bleep1>>>  ( -- )
        <bleep1>busy?  ?exit
        true to <bleep1>busy?
        <bleep1>flag? 0=
        if
                true to <bleep1>flag?
                s" bleep7.wav" find-file r/o open-file drop >r
                r@ file-size drop d>s to <bleep1>size
                r@ <bleep1>size malloc to <bleep1>handle
                <bleep1>handle <bleep1>size r@ read-file 2drop
                r> close-file drop
        then
        <bleep1>flag? music? and
        if
                <bleep1>handle playthat

        then
        false to <bleep1>busy?
        ;




       0 value <yahoo>busy?
       0 value <yahoo>handle
       0 value <yahoo>flag?
       0 value <yahoo>size
: <<<yahoo>>>   ( -- )
        <yahoo>busy?  ?exit
        true to <yahoo>busy?
        <yahoo>flag? 0=
        if      true to <yahoo>flag?
                s" yahoo.wav" find-file r/o open-file drop >r
                r@ file-size drop d>s to <yahoo>size
                r@ <yahoo>size malloc to <yahoo>handle
                <yahoo>handle <yahoo>size r@ read-file 2drop
                r> close-file drop
        then
        <yahoo>flag? music? and
        if
                <yahoo>handle playthat
        then
        false to <yahoo>busy?
        ;


        0 value <applause>busy?
        0 value <applause>handle
        0 value <applause>flag?
        0 value <applause>size

: <<<applause>>> ( -- )
        <applause>busy?  ?exit
        true to <applause>busy?
        <applause>flag? 0=
        if      true to <applause>flag?
                s" applause7.wav" find-file r/o open-file drop >r
                r@ file-size drop d>s to <applause>size
                r@ <applause>size malloc to <applause>handle
                <applause>handle <applause>size r@ read-file 2drop
                r> close-file drop
        then
        music? <applause>flag? and
        if
                <applause>handle playthat
        then
        false to <applause>busy?
        ;
