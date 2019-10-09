\ $Id: Compatibility.f,v 1.4 2009/08/16 18:50:37 georgeahubert Exp $

cr .( Loading Compatibility.f : compatibility with other Forth systems ...)




\ ****************************** COMPATIBILITY ******************************** \
\                                                                               \
\  This file contains words that are not part of Win32Forth but can be found    \
\  in other Forth systems.                                                      \
\                                                                               \
\  It may help you including "foreign" forth sources in win32forth, either      \
\  by giving you an equivalent in win32Forth or by including this file in       \
\  your application.                                                            \
\                                                                               \
\ ***************************************************************************** \


only Forth also definitions

\ ------------------------------------------------------------------------------
\ candidates
\ ------------------------------------------------------------------------------

\ REQUIRE           --> NEEDS
\ END-CODE          --> ;C
\ [ENDIF]           --> [THEN]
\ #ENDIF            --> #THEN
\ ENDIF             --> THEN
\ ...



\s
