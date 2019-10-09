\ File Pl_Toolset.f
\ Some helper words for Player4th

anew -Pl_Toolset.f

internal

external

[undefined] 2+ [if]
CODE 2+         ( n1 -- n2 ) \ add two to n1
        add     ebx, # 2
        next    c;
[then]

[undefined] 2nip [if]
CODE 2nip       ( n1 n2 n3 n4 -- n3 n4 ) \ 2swap 2drop
        pop     eax
        mov     4 [esp], eax
        pop     eax
        next    c;
[then]

\ search for char in string, return string till
\ char and rest of string after char
\ May 23rd, 2003 - 17:14 dbu
: /get  { str len char \ str1 len1 -- str len str1 len1 }
        str len char scan  to len1 to str1
        len1 0>
        if   len len1 - to len
             str1 1+ to str1
             len1 1- ?dup if to len1 then
        then str len str1 len1 ;

: get/  ( str1 len2 char -- str1' len1' str2 len2 )
        /get 2swap ;

internal

create string0$ maxstring allot
create string1$ maxstring allot

: IsFileType?   ( addr len addr1 len1 -- f )
        string1$ place string0$ place
        string0$ count ".EXT-ONLY" 2dup upper
        string1$ count 2dup upper
        compare 0= ;

: (IsValidFileType?)      { addr len addr1 len1 -- f }
        addr1 len1
        begin  [char] ; get/ addr len 2swap
               IsFileType? 0<> over 0= or
        until  nip 0<> ;

create valid-sound-ext ," .mp3;.wma;.midi;.mid;.wav;"
create valid-video-ext ," .mpeg;.mpg;.mp2;.mp4;.mpa;.wmv;.avi;.dat;"

external

: GetShortPathName      ( addr len -- addr1 len1 )
        string0$ place string0$ +null
        maxstring string1$ string0$ 1+ Call GetShortPathName drop
        string1$ zcount ;

: (.ms) ( ms -- addr len )
        1000 /mod 60 /mod 60 /mod
                              2 .#" string1$  place
        s" :" string1$ +place 2 .#" string1$ +place
        s" :" string1$ +place 2 .#" string1$ +place
        s" ." string1$ +place 3 .#" string1$ +place

        string1$ count ;

: type-of-media ( addr len -- addr len f ) \ true if it's a video file
        2dup valid-video-ext count (IsValidFileType?) ;

: IsRealMedia? ( addr len -- f ) \ true if it's a RealPlayer file
        s" .rm" IsFileType? ;

: IsValidFileType?      ( addr len -- f )
        2dup valid-sound-ext count (IsValidFileType?) >r
             valid-video-ext count (IsValidFileType?) r> or ;

: xywh>ltrb     ( x y width height -- left top right bottom )
        2over \ x y  w h x y
        rot   \ x y  w x y h
        +     \ x y  w x y+h
        -rot  \ x y  y+h w x
        +     \ x y  y+h w+x
        swap ;


: GetTempPath ( - adr n)    pad dup maxstring call GetTempPath ;

: GetLongPathName ( z"short$ - full$ n )

\ GetLongPathName() isn't supported under Win95, NT 3.51 and NT4,
\ so we can only use it under Win98, WinME and Win2000 and later.
[ version# ((version)) 0. 2swap >number 3drop 7 < dup ] [if]
[ winver win95 = winver winnt351 = or winver winnt4 = or and ] [then]
[if]  \ For V6.xx.xx older OSs
        zcount pad place pad count
[ELSE]
        maxstring pad rot call GetLongPathName pad swap
[ENDIF]
        ;

: SetFileAttributes ( z"name" attrib - )   swap 1+ call SetFileAttributes drop ;

: copy-file-silent  { \ from$ to$ -- }   ( from-full-spec cnt to-full-spec cnt - )
                max-path localAlloc: from$
                max-path localAlloc: to$
                 to$    place to$   +NULL
                 from$  place from$ +NULL
                 false
                 to$    1+
                 from$  1+
                Call CopyFile  ?winerror
                to$ FILE_ATTRIBUTE_NORMAL SetFileAttributes
                ;

: AddTargetFile ( Basedir$ cnt  file$ cnt - Full$ )
       pad place 2dup pad +place pad count

 ;
: CopyFiles  ( target cnt - )
    s" Catalog.dat" 2over AddTargetFile copy-file-silent
    s" Player4.exe" 2over AddTargetFile copy-file-silent
    s" PathMediaFiles.dat"  2swap AddTargetFile copy-file-silent

 ;

: RomBoot? ( - flag )
    current-dir$ 1+ call GetFileAttributes
    FILE_ATTRIBUTE_READONLY and  FILE_ATTRIBUTE_READONLY =
 ;

: RomBoot ( - flag )
   RomBoot? dup
        if      temp$ maxstring erase
                GetTempPath drop  GetLongPathName temp$ place
                temp$ count 2dup CopyFiles
                drop  $current-dir! drop
        then
 ;

module
