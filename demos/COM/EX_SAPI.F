\ $Id: EX_SAPI.F,v 1.2 2005/09/18 11:10:30 dbu_de Exp $

\ Example of Speech API
\ Thomas Dixon

needs FCOM.F

\ SAPI 5.0 typelibrary
5 0 typelib {C866CA3A-32F7-11D2-9602-00C04F8EE628}


ISpVoice ComIFace voice

\ Create voice instance
voice ISpVoice 1 0 SpVoice CoCreateInstance drop

0 0 u" Hello World!" drop voice speak .

\ Say it slower
-9 voice setrate .
0 0 u" I'm talking slower now." drop voice speak .

\ Say it faster
5 voice setrate .
0 0 u" I'm talking fast now." drop voice speak .

\ Say it higher
0 voice setrate .



\ Example of how to build it as an exe!

: main ( -- )
  voice ISpVoice 1 0 SpVoice CoCreateInstance
   if true s" Unable to Create SPVoice!" ?messagebox bye then
  0 0 u" Hello World!" drop voice speak
   if true s" Unable to Speak!" ?messagebox bye then
  0 bye ;

\ ' main turnkey speak.exe
