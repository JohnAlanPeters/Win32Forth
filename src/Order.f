\ $Id: Order.f,v 1.7 2011/05/25 20:48:54 georgeahubert Exp $

\ Vocabulary search order specification

cr .( Loading Vocabulary...)

in-application

19 CONSTANT #THREADS        \ default number of threads for a vocabulary
 7 CONSTANT #LEXTHREADS     \ deafult for a lexicon

: #WORDLIST     ( #threads -- wid )
                1 MAX 511 MIN DUP ,
                ['] "HEADER ,             \ to create entries
                ['] (SEARCH-WID) ,        \ to search the wordlist
                0 ,                       \ to iterate the wordlist
                VOC-LINK LINK,
                HERE DUP>R OVER CELLS ALLOT
                           SWAP CELLS ERASE R> ;

: WORDLIST      ( -- wid )
                #THREADS #WORDLIST ;

: GET-CURRENT   ( -- wid )
                CURRENT @ ;

: SET-CURRENT   ( wid -- )
                CURRENT ! ;

: SWAP-CURRENT  ( wid1 - wid2 ) \ change current to wid1, return old wid2
                GET-CURRENT SWAP SET-CURRENT ;

in-previous

: (VOC)         ( #threads -<name>- -- )
                HEADER DOVOC ,
                #WORDLIST DROP ;

: #LEXICON      ( #threads -<name>- -- )
                >APPLICATION (VOC) APPLICATION> ;

: LEXICON       ( -- )                   \ like a vocabulary, but in APP space
                #LEXTHREADS #LEXICON ;

: #VOCABULARY   ( #threads -<name>- )
                >SYSTEM (VOC) SYSTEM> ;

: VOCABULARY    ( <name> -- ) \ create a new vocabulary
                #THREADS #VOCABULARY ;

: DEFINITIONS   ( -- )                \ Sets the topmost context vocabulary as current
                CONTEXT @ SET-CURRENT ;

in-application

: ALSO          ( -- )                \ Duplicates topmost vocabulary in the search order
                CONTEXT DUP CELL+  #VOCS 1- CELLS MOVE ;

: ONLY          ( -- )                \ Removes all vocs from search order down to ROOT
\in-system-ok   CONTEXT #VOCS CELLS ERASE  ROOT ALSO VOC-ALSO ;

: PREVIOUS      ( -- )                \ Removes the topmost vocabulary from the search order
                CONTEXT DUP CELL+ SWAP  #VOCS CELLS MOVE
                CONTEXT @ 0=
\in-system-ok   IF      ROOT
                THEN    VOC-ALSO ;

in-previous

: FORTH-WORDLIST ( -- wid )
                ['] FORTH VCFA>VOC ;

in-application

: GET-ORDER     ( -- widn .. wid1 n ) \ get the whole search-order
                DEPTH >R
                0 #VOCS 1-
                DO      CONTEXT I CELLS+ @
                        DUP 0=
                        IF      DROP
                        THEN
            -1 +LOOP    DEPTH R> - ;

: SET-ORDER     ( widn .. wid1 n -- ) \ set the whole search-order
                DUP 0<
                IF      DROP ONLY
                ELSE    CONTEXT #VOCS CELLS ERASE
                        0
                        ?DO     CONTEXT I CELLS+ !
                        LOOP    VOC-ALSO
                THEN    ;

in-previous

: +ORDER        ( wid - )       \ add wid to search order
                >R GET-ORDER 1+ R> SWAP SET-ORDER ;

: VOC:          ( wid 'word' - ) \ define 'word' in vocabulary wid
                SWAP-CURRENT >R : R> SET-CURRENT ;

ROOT DEFINITIONS

' FORTH             ALIAS FORTH
' FORTH-WORDLIST    ALIAS FORTH-WORDLIST
' SET-ORDER         ALIAS SET-ORDER

ONLY FORTH ALSO DEFINITIONS

variable anyvoc

: anyfind       ( a1 -- cfa f1 )         \ find a word in any vocabulary
                anyvoc off
                dup c@ 0=
                if      0 exit
                then
                find ?dup 0=
                if      context @ >r
                        voc-link
                        begin   @ ?dup
                        while   dup vlink>voc ( #threads cells - )
                                dup voc>vcfa
                                ?IsClass 0=
                                if      context !  \ set voc
                                        over find ?dup
                                        if      2nip
                                                context @ anyvoc !
                                                r> context !
                                                EXIT      \ *** EXITS HERE ****
                                        then
                                then    drop
                        repeat  0
                        r> context !
                        anyvoc off
                then    ;

: "anyfind      { adr len \ find$ -- cfa f1 }
                MAXSTRING LocalAlloc: find$
                adr len find$ place
                find$ anyfind ;

13 #VOCABULARY EDITOR
43 #VOCABULARY ASSEMBLER
