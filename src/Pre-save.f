\ $Id: Pre-save.f,v 1.9 2013/12/09 21:25:16 georgeahubert Exp $

in-system

Require Imageman.f

: Zero_conhndl    ( -- )
\ *G Make sure console handle in image is zero.
                 &of _conhndl >image off ;

pre-save-image-chain chain-add Zero_conhndl

: Trim-image-list ( addr -- )
\ *G Given the head of a list or chain remove all those items not in the image.
\ ** This is designed to be used as part of the pre-save-image-chain.
                 begin dup
                   begin @ dup in-image? over 0= or until
                 tuck swap >image ! ?dup 0= until ;

: Trim-image-chains ( -- )
\ *G Trim chains in image.
                chain-link
                begin   @ ?dup
                while   dup cell+ @ Trim-image-list
                repeat  ;

: Trim-image-errors ( -- )
                THROW_MSGS Trim-image-list ;

pre-save-image-chain chain-add Trim-image-chains
pre-save-image-chain chain-add Trim-image-errors

: init-image-handles  ( -- )
                handles-list
                begin   @ ?dup
                while   0 over cell+ >image dup if ! else 2drop then
                repeat  ;

pre-save-image-chain chain-add init-image-handles

: Init-turnkey-find ( -- )
                turnkeyed? if ['] parmfind is-image find then ;

pre-save-image-chain chain-add Init-turnkey-find

: Init-turnkey-nodebug ( -- )
                turnkeyed? if ['] noop is-image save-src
                              ['] noop is-image ?unsave-src then ;

pre-save-image-chain chain-add Init-turnkey-nodebug


: Init?EnableConsoleMessages ( -- )
                ['] noop is-image ?EnableConsoleMessages ;

pre-save-image-chain chain-add Init?EnableConsoleMessages

: PreInitAppID  ( -- )
                NewAppID &of MyAppID >image !
                RunUnique &of MyRunUnique >image !
                0 &of RunUnique >image !
                0 &of NewAppID >image !
                0 to RunUnique                \ restore defaults
                0 to NewAppID ;

 pre-save-image-chain chain-add PreInitAppID

dpr-warning-off

: pre-init-system-locks-off ( -- )
\ *G Set all the system deferred words for locking and unlocking to noops in the image.
\ ** This is done for the system so that at start-up code that uses
\ ** them will work correctly before the locks are initialised.
\ ** Also the allocated memory link is zeroed.
     ['] noop is-image (controllock)
     ['] noop is-image (controlunlock)
     ['] noop is-image (dialoglock)         \ no longer needed
     ['] noop is-image (dialogunlock)       \ no longer needed
     ['] noop is-image (classnamelock)
     ['] noop is-image (classnameunlock)
     ['] noop is-image (pointerlock)
     ['] noop is-image (pointerunlock)
     ['] noop is-image (dynlock)
     ['] noop is-image (dynunlock)
     ['] noop is-image (gdilock)
     ['] noop is-image (gdiunlock)
     ['] noop is-image (memlock)
     ['] noop is-image (memunlock)
     0 malloc-link >image !
;

dpr-warning-on

pre-save-image-chain chain-add pre-init-system-locks-off

in-previous
