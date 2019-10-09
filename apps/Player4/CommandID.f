\ $Id: CommandID.f,v 1.6 2012/05/08 20:57:38 georgeahubert Exp $

\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
cr .( Loading Menu Command ID's...)

: NewID ( <name> -- )
        defined
        IF  drop
        ELSE NextID swap count ['] constant execute-parsing
        THEN ;

IdCounter constant IDM_FIRST

\ File menu
NewID IDM_OPEN_FILE
NewID IDM_OPEN_FOLDER
NewID IDM_OPEN_PLAYLIST
NewID IDM_QUIT

\ Catalog menu
NewID IDM_ADD_FILES
NewID IDM_IMPORT_FOLDER
NewID IDM_START/RESUME

\ Options menu
NewID IDM_VIEW_50
NewID IDM_VIEW_100
NewID IDM_VIEW_200
NewID IDM_VIEW_FULLSCREEN
NewID IDM_AUDIO_ON
NewID IDM_AUDIO_OFF

\ Help menu
NewID IDM_ABOUT

\ Other commands
NewID IDM_PAUSE/RESUME
NewID IDM_STOP
NewID IDM_NEXT
NewID IDM_REWIND
NewID IDM_FORWARD

NewID IDM_STOPPLAYER

IdCounter constant IDM_LAST

: allot-erase   ( n -- )
                here over allot swap erase ;

Create CommandTable IDM_LAST IDM_FIRST - cells allot-erase

: IsCommand?    ( ID -- f )
                IDM_FIRST IDM_LAST within ;

: >CommandTable ( ID -- addr )
                dup IsCommand?
                if   IDM_FIRST - cells CommandTable +
                else drop abort" error - command ID out of range"
                then ;

: DoCommand     ( ID -- )
                >CommandTable @ ?dup IF execute THEN ;

: SetCommand    ( ID -- )
                last @ name> swap >CommandTable ! ;
\s
