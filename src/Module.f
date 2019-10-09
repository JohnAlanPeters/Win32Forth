\ $Id: Module.f,v 1.7 2012/05/08 19:25:32 georgeahubert Exp $

\ MODULE.F              Local Definitions for Modules           by Tom Zimmer

\ G.Hubert May 8th, 2003 - 21:46
\ Modified to reset state if an error occurs during loading, allowing modules
\ to be built even if the hidden vocabulary is the context vocabulary.
\ Also added PRIVATE so that internal words are placed in the specified vocabulary

\ Modified to do error handling via reset-stacks in QUIT so that modules can span
\ multiple files  8Aug03 gah

\ Modified INTERNAL to only start a new module if pre-voc is zero or the hidden vocabulary is not
\ at the top of the search order to allow using either MODULE or PREVIOUS to be used to end
\ a module

\ *D doc
\ *! p-module W32F module
\ *T Using the Module Wordset
\ *P Win32Forth implements the ANSI search-order wordset and extensions as well as it's
\ ** own set of words for constructing modules. Since the module wordset works by manipulating
\ ** the search order then care should be taken when using the module wordset and search order
\ ** wordset together. If the search order is changed with the search order words it should be
\ ** restored to it's previous state before any of the words INTERNAL EXTERNAL or MODULE are
\ ** executed. Similarly since the object compiler also manipulates the search order the same
\ ** criterion applies while building classes or objects (with :OBJECT). The words INTERNAL
\ ** EXTERNAL and MODULE should not be executed within a CLASS or OBJECT although they can
\ ** be used before and after the CLASS or OBJECT.

\ *S Error Handling

\ *P If an uncaught error occurs while building a module then the default error handler resets
\ ** the state of the module wordset as though the module had been finished correctly.

cr .( Loading Modules...)

only forth also hidden also definitions

0 value pre-voc         \ previous vocabulary

defer hidden-voc ' hidden is-default hidden-voc

: set-hidden ['] hidden is hidden-voc ; set-hidden

forth definitions

\ *S Glossary

: (PRIVATE)     ( xt-of-voc -- )  \ W32F         Module System
\ *G Set the vocabulary for internal definitions for the next module to be built.
\ ** This is a non-parsing version of the word PRIVATE.
                dup @ [ ' forth @ ] literal
                <> abort" must be a Vocabulary"
                is hidden-voc ;

: PRIVATE       ( -<voc>- )       \ W32F         Module System
\ *G Set the vocabulary for internal definitions for the next module to be built.
\ ** This is a parsing version of the word (PRIVATE).
                ' (private) ;

: INTERNAL      ( -- )            \ W32F         Module System
\ *G If a module hasn't yet been started or the internal vocabulary isn't the context
\ ** vocabulary add the internal vocabulary to the search order and save the current
\ ** vocabulary as the external vocabulary, then make the current vocabulary the internal
\ ** vocabulary. If a module is already being built then make the current vocabulary
\ ** the internal vocabulary.
                context @ [ ' hidden-voc >body ] literal @
                vcfa>voc = pre-voc and                \ 0 if starting module
                if      hidden-voc definitions        \ just do definitions
                else    current @ to pre-voc          \ else save current
                        also hidden-voc definitions   \ and do definitions
                then    ;

: EXTERNAL      ( -- )            \ W32F         Module System
\ *G Make the external vocabulary the current vocabulary.
                pre-voc 0= abort" Use Only while building a module"
                pre-voc current ! ;

: MODULE        ( -- )            \ W32F         Module System
\ *G Complete the module by making the external vocabulary the current vocabulary,
\ ** removing the internal vocabulary from the search order if it's the context
\ ** vocabulary and resetting the internal vocabulary to hidden.
                EXTERNAL
                context @ [ ' hidden-voc >body ] literal @
                vcfa>voc =
                if      previous                \ remove the internal vocabulary
                then    0 to pre-voc set-hidden ;

also hidden definitions

\ changed to use the reset-stack-chain
\ January 22nd, 2004 - 13:53 dbu

: (RESET-STACKS) ( -- ) \ Used by RESET-STACKS for protection
                 pre-voc if module then ;

\in-system-ok reset-stack-chain chain-add (RESET-STACKS)

only forth also definitions

\S
\ *Z
