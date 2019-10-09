\ *D doc\classes\
\ *! gdiFont
\ *T gdiFont -- Class for GDI Fonts.
\ *Q Version 1.0
\ ** This GDI class library was written and placed in the Public Domain
\ ** in 2005 by Dirk Busch
\ *S Glossary

cr .( Loading GDI class library - Font...)

needs gdiBase.f

internal
external

\ ----------------------------------------------------------------------
\ ----------------------------------------------------------------------
\ *W <a name="gdiFont"></a>
:Class gdiFont  <Super GdiObject
\ *G GDI Font class

Record: LOGFONT
                int   lfHeight          \ width  in pixels, device specific
                int   lfWidth           \ height in pixels, device specific
                int   lfEscapement
                int   lfOrientation     \ in 10ths of a degree
                int   lfWeight
                byte  lfItalic          \ TRUE/FALSE
                byte  lfUnderline       \ TRUE/FALSE
                byte  lfStrikeOut       \ TRUE/FALSE
                byte  lfCharSet
                byte  lfOutPrecision
                byte  lfClipPrecision
                byte  lfQuality
                byte  lfPitchAndFamily
    LF_FACESIZE bytes lfFaceName        \ the font name
;RecordSize: sizeof(LOGFONT)

Record: &CHOOSEFONT
                int   lStructSize
                int   hwndOwner
                int   hDC
                int   lpLogFont
                int   iPointSize
                int   Flags
                int   rgbColors
                int   lCustData
                int   lpfnHook
                int   lpTemplateName
                int   hInstance
                int   lpszStyle
                short nFontType
                short ___MISSING_ALIGNMENT__
                int   nSizeMin
                int   nSizeMax
;RecordSize: sizeof(CHOOSEFONT)

:M ClassInit:   ( -- )
        ClassInit: super

        \ init LOGFONT record
        14                  to lfHeight
         9                  to lfWidth
         0                  to lfEscapement
         0                  to lfOrientation    \ in 10th degrees
        FW_DONTCARE         to lfWeight
        FALSE               to lfItalic
        FALSE               to lfUnderline
        FALSE               to lfStrikeOut
        ANSI_CHARSET        to lfCharSet
        OUT_TT_PRECIS       to lfOutPrecision
        CLIP_DEFAULT_PRECIS to lfClipPrecision
        PROOF_QUALITY       to lfQuality
        FIXED_PITCH 0x04 or
        FF_SWISS or         to lfPitchAndFamily \ font family
        lfFaceName LF_FACESIZE erase   \ clear font name
        s" Courier New" lfFaceName swap move \ move in default name

        \ init &CHOOSEFONT record
        sizeof(CHOOSEFONT) to lStructSize
        LOGFONT            to lpLogFont
        [ CF_SCREENFONTS CF_INITTOLOGFONTSTRUCT or ] literal to Flags
        null to hwndOwner
        null to hDC
        0    to iPointSize
        0    to rgbColors
        0    to lCustData
        null to lpfnHook
        null to lpTemplateName
        null to hInstance
        0    to lpszStyle
        0    to nFontType
        0    to nSizeMin
        0    to nSizeMax
        ;M

:M SetHeight:         ( n1 -- )
\ *G Set the height, in logical units, of the font's character cell or character. The character
\ ** height value (also known as the em height) is the character cell height value minus the
\ ** internal-leading value. The font mapper interprets the value specified in lfHeight in the
\ ** following manner.
\ *L
\ *| > 0 | The font mapper transforms this value into device units and matches it against the cell height of the available fonts. |
\ *| 0   | The font mapper uses a default height value when it searches for a match. |
\ *| < 0 | The font mapper transforms this value into device units and matches its absolute value against the character height of the available fonts. |
\ *P For all height comparisons, the font mapper looks for the largest font that does not exceed
\ ** the requested size. This mapping occurs when the font is used for the first time.
        to lfHeight          ;M

:M SetWidth:          ( n1 -- )
\ *G Specifies the average width, in logical units, of characters in the font. If lfWidth is zero,
\ ** the aspect ratio of the device is matched against the digitization aspect ratio of the available
\ ** fonts to find the closest match, determined by the absolute value of the difference.
        to lfWidth           ;M

:M SetEscapement:     ( n1 -- )
\ *G Set the angle, in tenths of degrees, between the escapement vector and the x-axis of the device.
\ ** The escapement vector is parallel to the base line of a row of text. \n
\ ** Windows NT/ 2000: When the graphics mode is set to GM_ADVANCED, you can specify the escapement
\ ** angle of the string independently of the orientation angle of the string's characters. \n
\ ** When the graphics mode is set to GM_COMPATIBLE, lfEscapement specifies both the escapement and
\ ** orientation. You should set lfEscapement and lfOrientation to the same value. \n
\ ** Windows 95: The lfEscapement member specifies both the escapement and orientation. You should set
\ ** lfEscapement and lfOrientation to the same value.
        to lfEscapement      ;M

:M SetOrientation:    ( n1 -- )
\ *G Set the angle, in tenths of degrees, between each character's base line and the x-axis of the device.
        to lfOrientation     ;M   \ 10th/degree increments

:M SetWeight:         ( n1 -- )
\ *G Specifies the weight of the font in the range 0 through 1000. For example, 400 is normal and 700 is bold.
\ ** If this value is zero, a default weight is used. The following values are defined for convenience.
\ *L
\ *| FW_DONTCARE        | 0   |
\ *| FW_THIN            | 100 |
\ *| FW_EXTRALIGHT      | 200 |
\ *| FW_ULTRALIGHT      | 200 |
\ *| FW_LIGHT           | 300 |
\ *| FW_NORMAL          | 400 |
\ *| FW_REGULAR         | 400 |
\ *| FW_MEDIUM          | 500 |
\ *| FW_SEMIBOLD        | 600 |
\ *| FW_DEMIBOLD        | 600 |
\ *| FW_BOLD            | 700 |
\ *| FW_EXTRABOLD       | 800 |
\ *| FW_ULTRABOLD       | 800 |
\ *| FW_HEAVY           | 900 |
\ *| FW_BLACK           | 900 |
        to lfWeight          ;M

:M SetItalic:         ( f1 -- )
\ *G Specifies an italic font if set to TRUE.
        to lfItalic          ;M

:M SetUnderline:      ( f1 -- )
\ *G Specifies an underlined font if set to TRUE.
        to lfUnderline       ;M

:M SetStrikeOut:      ( f1 -- )
\ *G Specifies a strikeout font if set to TRUE.
        to lfStrikeOut       ;M

:M SetCharSet:        ( n1 -- )
\ *G Specifies the character set. The following values are predefined.
\ *L
\ *| ANSI_CHARSET        |
\ *| BALTIC_CHARSET      |
\ *| CHINESEBIG5_CHARSET |
\ *| DEFAULT_CHARSET     |
\ *| EASTEUROPE_CHARSET  |
\ *| GB2312_CHARSET      |
\ *| GREEK_CHARSET       |
\ *| HANGUL_CHARSET      |
\ *| MAC_CHARSET         |
\ *| OEM_CHARSET         |
\ *| RUSSIAN_CHARSET     |
\ *| SHIFTJIS_CHARSET    |
\ *| SYMBOL_CHARSET      |
\ *| TURKISH_CHARSET     |
\ *P Windows NT/ 2000 or Middle-Eastern Windows 3.1 or later:
\ *L
\ *| HEBREW_CHARSET |
\ *| ARABIC_CHARSET |
\ *P Windows NT/ 2000 or Thai Windows 3.1 or later:
\ *L
\ *| THAI_CHARSET |
\ *P The OEM_CHARSET value specifies a character set that is operating-system dependent.
\ ** Windows 95/98: You can use the DEFAULT_CHARSET value to allow the name and size of a font
\ ** to fully describe the logical font. If the specified font name does not exist, a font from
\ ** any character set can be substituted for the specified font, so you should use DEFAULT_CHARSET
\ ** sparingly to avoid unexpected results. \n
\ ** Windows NT/ 2000: DEFAULT_CHARSET is set to a value based on the current system locale. For
\ ** example, when the system locale is English (United States), it is set as ANSI_CHARSET. \n
\ ** Fonts with other character sets may exist in the operating system. If an application uses a
\ ** font with an unknown character set, it should not attempt to translate or interpret strings
\ ** that are rendered with that font. \n
\ ** This parameter is important in the font mapping process. To ensure consistent results, specify
\ ** a specific character set. If you specify a typeface name in the lfFaceName member, make sure
\ ** that the lfCharSet value matches the character set of the typeface specified in lfFaceName.
        to lfCharSet         ;M

:M SetOutPrecision:   ( n1 -- )
\ *G Specifies the output precision. The output precision defines how closely the output must match
\ ** the requested font's height, width, character orientation, escapement, pitch, and font type. It can
\ ** be one of the following values.
\ *L
\ *| OUT_CHARACTER_PRECIS Not used.
\ *| OUT_DEFAULT_PRECIS | Specifies the default font mapper behavior. |
\ *| OUT_DEVICE_PRECIS  | Instructs the font mapper to choose a Device font when the system contains multiple fonts with the same name. |
\ *| OUT_OUTLINE_PRECIS | Windows NT/ 2000: This value instructs the font mapper to choose from TrueType and other outline-based fonts. |
\ *| OUT_RASTER_PRECIS  | Instructs the font mapper to choose a raster font when the system contains multiple fonts with the same name. |
\ *| OUT_TT_ONLY_PRECIS | Instructs the font mapper to choose from only TrueType fonts. If there are no TrueType fonts installed in the system, the font mapper returns to default behavior. |
\ *| OUT_TT_PRECIS      | Instructs the font mapper to choose a TrueType font when the system contains multiple fonts with the same name. |
\ *P Applications can use the OUT_DEVICE_PRECIS, OUT_RASTER_PRECIS, and OUT_TT_PRECIS values to control
\ ** how the font mapper chooses a font when the operating system contains more than one font with a
\ ** specified name. For example, if an operating system contains a font named Symbol in raster and TrueType
\ ** form, specifying OUT_TT_PRECIS forces the font mapper to choose the TrueType version. Specifying
\ ** OUT_TT_ONLY_PRECIS forces the font mapper to choose a TrueType font, even if it must substitute a TrueType
\ ** font of another name.
        to lfOutPrecision    ;M

:M SetClipPrecision:  ( n1 -- )
\ *G Specifies the clipping precision. The clipping precision defines how to clip characters that are partially
\ ** outside the clipping region. It can be one or more of the following values.
\ *L
\ *| CLIP_DEFAULT_PRECIS   | Specifies default clipping behavior. |
\ *| CLIP_CHARACTER_PRECIS | Not used. |
\ *| CLIP_EMBEDDED         | You must specify this flag to use an embedded read-only font. |
\ *| CLIP_LH_ANGLES        | When this value is used, the rotation for all fonts depends on whether the orientation of the coordinate system is left-handed or right-handed.
\ *P For more information about the orientation of coordinate systems, see the description of the nOrientation parameter |
        to lfClipPrecision   ;M

:M SetQuality:        ( n1 -- )
\ *G Specifies the output quality. The output quality defines how carefully the graphics device interface (GDI) must
\ ** attempt to match the logical-font attributes to those of an actual physical font. It can be one of the following
\ ** values.
\ *L
\ *| ANTIALIASED_QUALITY | Font is always antialiased if the font supports it and the size of the font is not too small or too large. |
\ *| DEFAULT_QUALITY     | Appearance of the font does not matter. |
\ *| DRAFT_QUALITY       | Appearance of the font is less important than when PROOF_QUALITY is used. For GDI raster fonts, scaling is enabled, which means that more font sizes are available, but the quality may be lower. <
\ *| NONANTIALIASED_QUALITY | Font is never antialiased. |
\ *| PROOF_QUALITY      | Character quality of the font is more important than exact matching of the logical-font attributes. |
\ *P If neither ANTIALIASED_QUALITY nor NONANTIALIASED_QUALITY is selected, the font is antialiased only if the user chooses
\ ** smooth screen fonts in Control Panel.
        to lfQuality         ;M

:M SetPitchAndFamily: ( n1 -- )
\ *G Specifies the pitch and family of the font. The two low-order bits specify the pitch of the font and can
\ ** be one of the following values.
\ *L
\ *| DEFAULT_PITCH  |
\ *| FIXED_PITCH    |
\ *| VARIABLE_PITCH |
\ *P Bits 4 through 7 of the member specify the font family and can be one of the following values.
\ *L
\ *| FF_DECORATIVE
\ *| FF_DONTCARE
\ *| FF_MODERN
\ *| FF_ROMAN
\ *| FF_SCRIPT
\ *| FF_SWISS
\ *P The proper value can be obtained by using the Boolean OR operator to join one pitch constant with one
\ ** family constant.
\ *P Font families describe the look of a font in a general way. They are intended for specifying fonts
\ ** when the exact typeface desired is not available. The values for font families are as follows.
\ *L
\ *| FF_DECORATIVE | Novelty fonts. Old English is an example. |
\ *| FF_DONTCARE   | Don't care or don't know. |
\ *| FF_MODERN     | Fonts with constant stroke width (monospace), with or without serifs. Monospace fonts are usually modern. Pica, Elite, and CourierNew® are examples. |
\ *| FF_ROMAN      | Fonts with variable stroke width (proportional) and with serifs. MS® Serif is an example. |
\ *| FF_SCRIPT     | Fonts designed to look like handwriting. Script and Cursive are examples. |
\ *| FF_SWISS      | Fonts with variable stroke width (proportional) and without serifs. MS® Sans Serif is an example. |
        to lfPitchAndFamily  ;M

:M SetFaceName: ( a1 n1 -- )
\ *G Specifies the typeface name of the font. The length of this string must not exceed 32 characters, including
\ ** the null terminator. The EnumFontFamilies function can be used to enumerate the typeface names of all
\ ** currently available fonts. If lfFaceName is an empty string, GDI uses the first font that matches the other
\ ** specified attributes.
        lfFaceName LF_FACESIZE erase
        LF_FACESIZE 1- min lfFaceName swap move
        ;M

:M GetHeight:         ( -- n1 )
\ *G Fet the height, in logical units, of the font's character cell or character
        lfHeight          ;M

:M GetWidth:          ( -- n1 )
\ *G Get the average width, in logical units, of characters in the font
        lfWidth           ;M

:M GetEscapement:     ( -- n1 )
\ *G Get the angle, in tenths of degrees, between the escapement vector and the x-axis of
\ ** the device. The escapement vector is parallel to the base line of a row of text.
        lfEscapement      ;M

:M GetOrientation:    ( -- n1 )
\ *G Get the angle, in tenths of degrees, between each character's base line and the x-axis of the device.
        lfOrientation     ;M

:M GetWeight:         ( -- n1 )
\ *G Get the weight of the font
        lfWeight          ;M

:M GetItalic:         ( -- f1 )
\ *G TRUE if it's an italic font.
        lfItalic          ;M

:M GetUnderline:      ( -- f1 )
\ *G TRUE if it's a underlined font.
        lfUnderline       ;M

:M GetStrikeOut:      ( -- f1 )
\ *G TRUE if it's a strikeout font.
        lfStrikeOut       ;M

:M GetCharSet:        ( -- n1 )
\ *G Get the character set.
        lfCharSet         ;M

:M GetOutPrecision:   ( -- n1 )
\ *G Get the output precision.
        lfOutPrecision    ;M

:M GetClipPrecision:  ( -- n1 )
\ *G Get the clipping precision
        lfClipPrecision   ;M

:M GetQuality:        ( -- n1 )
\ *G Get the output quality.
        lfQuality         ;M

:M GetPitchAndFamily: ( -- n1 )
\ *G Get the pitch and family of the font.
        lfPitchAndFamily  ;M

:M GetFaceName: ( -- a1 n1 )
\ *G Get the typeface name of the font.
        lfFaceName LF_FACESIZE 2dup 0 scan nip - ;M

:M GetLogfont:        ( -- n1 )
\ *G Get the address of the LOGFONT structure
        LOGFONT           ;M

:M Create:      ( -- f )
\ *G Create a new font. If the current font handle is valid, the font will be destroyed.
        LOGFONT Call CreateFontIndirect SetHandle: super
        Valid?: super ;M

: Choose        ( hWnd -- f )
        to hwndOwner
        &CHOOSEFONT call ChooseFont
        if   Create: self
        else false
        then ;

:M Choose:      ( hWnd -- f )
\ *G Open a dialog to choose a Screen font. If the dialog is closed with OK, the font
\ ** will be created.
        NULL to hDC
        [ CF_SCREENFONTS CF_INITTOLOGFONTSTRUCT or ] literal to Flags
        Choose ;M

:M ChoosePrinter: ( hWnd hDC -- f )
\ *G Open a dialog to choose a Printer font for the PrinterDC hDC. If the dialog is closed
\ ** with OK, the fontwill be created.
        GetGdiObjectHandle to hDC
        [ CF_PRINTERFONTS CF_INITTOLOGFONTSTRUCT or ] literal to Flags
        Choose ;M
;Class
\ *G End of gdiFont class

module

\ *Z
