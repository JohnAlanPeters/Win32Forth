\ $id: checksum.f $

Require mapfile.f

map-handle exemap

: (mapfile)     ( addr len -- a1 n1 )      \ map file name into memory
                exemap open-map-file
                abort" Failed to open and map the file!"
                exemap >hfileAddress @
                exemap >hfileLength  @ ;

: mapfile       ( "name" -- a1 n1 )
                /parse-s$ count (mapfile) ;

: unmapfile     ( -- )                  \ unmap and close the file
                exemap close-map-file drop ;

$d8 offset >checksum

winLibrary imagehlp

4 proc CheckSumMappedFile

variable oldSum
variable Checksum

: (Getsum)      ( addr len -- checksum )
                2>r checksum oldsum 2r> (mapfile) swap call CheckSumMappedFile drop
                checksum @ ;

: (GetChecksum) ( addr len -- checksum )
                (getsum) unmapfile ;

: (AddChecksum) ( addr len -- )
                (Getsum) exemap >hfileAddress @ >checksum ! unmapfile ;

: GetChecksum   ( "name" -- checksum )
                /parse-s$ count (GetChecksum) ;

: AddChecksum   ( "name" -- )
                /parse-s$ count (AddChecksum) ;
