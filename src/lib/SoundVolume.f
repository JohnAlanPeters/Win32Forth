\ $Id: SoundVolume.f,v 1.4 2011/08/10 16:17:08 georgeahubert Exp $
\
\ Written: by Dirk Busch
\ Licence: Public Domain

anew -SoundVolume.f

WinLibrary winmm.dll

internal
external

\ -----------------------------------------------------------------------------
\ Turn the sound on and off
\ -----------------------------------------------------------------------------

: volume!       ( left-sound-volume right-sound-volume -- )     \ W32F  sound
\ *G Set the volume level of the waveform-audio output device.
        depth 2 >=
        if 0max 99 min 65535 100 */ 65536 * swap
           0max 99 min 65535 100 */ +
           0 Call waveOutSetVolume drop
        else cr ." No enough parameters !!! "
        then ;

: volume@       ( -- left-sound-volume right-sound-volume )     \ W32F  sound
\ *G Retrieves the current volume level of the waveform-audio output device.
\ ** If a device does not support both left and right volume control,
\ ** the low-order word of dwVolume specifies the volume level,
\ ** and the high-order word is ignored.
\ ** Then the right-sound-volume will be 0.
        { \ sound-volume --  }
        &OF sound-volume 0 call waveOutGetVolume MMSYSERR_NOERROR =
        if   sound-volume word-split
        else 0 0
        then ;

: Sound?        ( -- f )        \ W32F  sound
\ *G Check if sound is on.
        volume@ 0> swap 0> or ;

internal

0 value volume-left
0 value volume-right

external

: SoundOn       ( -- )          \ W32F  sound
\ *G Turn the sound back on after turning it off.
        Sound? 0=
        if   volume-left volume-right volume!
             0 to volume-right 0 to volume-left
        then ;

: SoundOff      ( -- )          \ W32F  sound
\ *G Turn sound off.
        Sound?
        if   volume@ to volume-right to volume-left
             0 0 volume!
        then ;

: SoundOnOff    ( -- )          \ W32F  sound
\ *G Toggle sound
        Sound? 0=
        if   SoundOn
        else SoundOff
        then ;

module

\ *Z
