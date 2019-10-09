\ $Id: BitmapDC.f,v 1.1 2008/04/30 15:51:09 dbu_de Exp $

\ *D doc\classes\
\ *! BitmapDC
\ *T bitmap-dc -- Bitmap device context class.
\ *S Glossary

cr .( Loading Bitmap device context class.... )

only forth also definitions

in-application

require lib/ExtDC.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ bitmap-dc class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:class bitmap-dc <super ext-windc
\ *G Bitmap device context class.
\ ** This can be used for buffered drawing.

int bitmap
int bitmap-width
int bitmap-height

:M ClassInit:   ( -- )
\ *G Init the class
                ClassInit: super
                0 to bitmap
                0 to bitmap-width
                0 to bitmap-height
                ;M

:M Valid?:      ( -- f )
\ *G Check if it's save to use this device.
                Valid?: super bitmap 0<> and ;M

:M Fill:        { color_object \ -- }
\ *G Fill the display bitmap with a specified color.
                Valid?: self
                if   0 0 bitmap-width bitmap-height color_object FillArea: super
                then ;M

:m FillArea:    ( color_object -- )
\ *G Fill the display bitmap with a specified color.
                Fill: self ;m

:m Destroy:     ( -- )
\ *G Destroys the display bitmap.

                \ first we destroy the device context
                Destroy: super

                \ and than the bitmap
                bitmap 0<>
                if   bitmap call DeleteObject ?win-error
                     0 to bitmap
                then ;M

:M Init:        { width height RefDC \ -- }
\ *G Create the display bitmap and select it to our device context.
\ ** Our device context will be compatible to the reference device.

                Destroy: self

                width 0> height 0> and
                if   width  to bitmap-width
                     height to bitmap-height

                     CreateCompatibleDC: RefDC ?dup
                     if   SetHandle: super
                          bitmap-width bitmap-height CreateCompatibleBitmap: RefDC ?dup
                          if   dup to bitmap       SelectObject: super drop
                               OEM_FIXED_FONT SelectStockObject: super drop
                               WHITE_PEN      SelectStockObject: super drop
                               BLACK                 SetBkColor: super
                               WHITE               SetTextColor: super

                               BLACK Fill: self
                          then
                     then
                then ;m

:m Paint:       { ps_left ps_top ps_right ps_bottom DestDC -- }
\ *G Draw the display bitmap into the destination device condtext.
                Valid?: self
                if   SRCCOPY                 \ blitmode
                     ps_left ps_top          \ sourcex,y
                     self                    \ sourcedc
                     ps_right ps_bottom      \ sizex,y
                     ps_left ps_top          \ destinationx,y
                     BitBlt: DestDC
                then ;M

:m ~:           ( -- )
\ *G Clean up on dispose.
                Destroy: self ;m

;class
\ *G End of bitmap-dc class

\ *Z
