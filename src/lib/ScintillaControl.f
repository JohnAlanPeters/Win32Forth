\ $Id: ScintillaControl.f,v 1.12 2011/09/14 13:35:09 georgeahubert Exp $
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Mittwoch, Juni 09 2004 - dbu
\ Updated: Dienstag, Juni 29 2004 - dbu
\
\ A wrapper class for the "Scintilla source code edit control".
\ See www.scintilla.org for more information about the control.

\ Saturday, May 06 2006  Added methods for printing - Rod

cr .( Loading Scintilla Control...)

ANEW -ScintillaControl.f


\ -----------------------------------------------------------------------------
\ Constant's "stolen" from Scintilla.h
\ -----------------------------------------------------------------------------

INTERNAL

EXTERNAL

#define INVALID_POSITION -1
#define SCI_START 2000
#define SCI_OPTIONAL_START 3000
#define SCI_LEXER_START 4000
#define SCI_ADDTEXT 2001
#define SCI_ADDSTYLEDTEXT 2002
#define SCI_INSERTTEXT 2003
#define SCI_CLEARALL 2004
#define SCI_CLEARDOCUMENTSTYLE 2005
#define SCI_GETLENGTH 2006
#define SCI_GETCHARAT 2007
#define SCI_GETCURRENTPOS 2008
#define SCI_GETANCHOR 2009
#define SCI_GETSTYLEAT 2010
#define SCI_REDO 2011
#define SCI_SETUNDOCOLLECTION 2012
#define SCI_SELECTALL 2013
#define SCI_SETSAVEPOINT 2014
#define SCI_GETSTYLEDTEXT 2015
#define SCI_CANREDO 2016
#define SCI_MARKERLINEFROMHANDLE 2017
#define SCI_MARKERDELETEHANDLE 2018
#define SCI_GETUNDOCOLLECTION 2019
#define SCWS_INVISIBLE 0
#define SCWS_VISIBLEALWAYS 1
#define SCWS_VISIBLEAFTERINDENT 2
#define SCI_GETVIEWWS 2020
#define SCI_SETVIEWWS 2021
#define SCI_POSITIONFROMPOINT 2022
#define SCI_POSITIONFROMPOINTCLOSE 2023
#define SCI_GOTOLINE 2024
#define SCI_GOTOPOS 2025
#define SCI_SETANCHOR 2026
#define SCI_GETCURLINE 2027
#define SCI_GETENDSTYLED 2028
#define SC_EOL_CRLF 0
#define SC_EOL_CR 1
#define SC_EOL_LF 2
#define SCI_CONVERTEOLS 2029
#define SCI_GETEOLMODE 2030
#define SCI_SETEOLMODE 2031
#define SCI_STARTSTYLING 2032
#define SCI_SETSTYLING 2033
#define SCI_GETBUFFEREDDRAW 2034
#define SCI_SETBUFFEREDDRAW 2035
#define SCI_SETTABWIDTH 2036
#define SCI_GETTABWIDTH 2121
#define SC_CP_UTF8 65001
#define SCI_SETCODEPAGE 2037
#define SCI_SETUSEPALETTE 2039
#define MARKER_MAX 31
#define SC_MARK_CIRCLE 0
#define SC_MARK_ROUNDRECT 1
#define SC_MARK_ARROW 2
#define SC_MARK_SMALLRECT 3
#define SC_MARK_SHORTARROW 4
#define SC_MARK_EMPTY 5
#define SC_MARK_ARROWDOWN 6
#define SC_MARK_MINUS 7
#define SC_MARK_PLUS 8
#define SC_MARK_VLINE 9
#define SC_MARK_LCORNER 10
#define SC_MARK_TCORNER 11
#define SC_MARK_BOXPLUS 12
#define SC_MARK_BOXPLUSCONNECTED 13
#define SC_MARK_BOXMINUS 14
#define SC_MARK_BOXMINUSCONNECTED 15
#define SC_MARK_LCORNERCURVE 16
#define SC_MARK_TCORNERCURVE 17
#define SC_MARK_CIRCLEPLUS 18
#define SC_MARK_CIRCLEPLUSCONNECTED 19
#define SC_MARK_CIRCLEMINUS 20
#define SC_MARK_CIRCLEMINUSCONNECTED 21
#define SC_MARK_BACKGROUND 22
#define SC_MARK_DOTDOTDOT 23
#define SC_MARK_ARROWS 24
#define SC_MARK_PIXMAP 25
#define SC_MARK_FULLRECT 26
#define SC_MARK_LEFTRECT 27
#define SC_MARK_AVAILABLE 28
#define SC_MARK_UNDERLINE 29
#define SC_MARK_CHARACTER 10000
#define SC_MARKNUM_FOLDEREND 25
#define SC_MARKNUM_FOLDEROPENMID 26
#define SC_MARKNUM_FOLDERMIDTAIL 27
#define SC_MARKNUM_FOLDERTAIL 28
#define SC_MARKNUM_FOLDERSUB 29
#define SC_MARKNUM_FOLDER 30
#define SC_MARKNUM_FOLDEROPEN 31
#define SC_MASK_FOLDERS 0xFE000000
#define SCI_MARKERDEFINE 2040
#define SCI_MARKERSETFORE 2041
#define SCI_MARKERSETBACK 2042
#define SCI_MARKERADD 2043
#define SCI_MARKERDELETE 2044
#define SCI_MARKERDELETEALL 2045
#define SCI_MARKERGET 2046
#define SCI_MARKERNEXT 2047
#define SCI_MARKERPREVIOUS 2048
#define SCI_MARKERDEFINEPIXMAP 2049
#define SCI_MARKERADDSET 2466
#define SCI_MARKERSETALPHA 2476
#define SC_MARGIN_SYMBOL 0
#define SC_MARGIN_NUMBER 1
#define SC_MARGIN_BACK 2
#define SC_MARGIN_FORE 3
#define SC_MARGIN_TEXT 4
#define SC_MARGIN_RTEXT 5
#define SCI_SETMARGINTYPEN 2240
#define SCI_GETMARGINTYPEN 2241
#define SCI_SETMARGINWIDTHN 2242
#define SCI_GETMARGINWIDTHN 2243
#define SCI_SETMARGINMASKN 2244
#define SCI_GETMARGINMASKN 2245
#define SCI_SETMARGINSENSITIVEN 2246
#define SCI_GETMARGINSENSITIVEN 2247
#define STYLE_DEFAULT 32
#define STYLE_LINENUMBER 33
#define STYLE_BRACELIGHT 34
#define STYLE_BRACEBAD 35
#define STYLE_CONTROLCHAR 36
#define STYLE_INDENTGUIDE 37
#define STYLE_CALLTIP 38
#define STYLE_LASTPREDEFINED 39
#define STYLE_MAX 255
#define SC_CHARSET_ANSI 0
#define SC_CHARSET_DEFAULT 1
#define SC_CHARSET_BALTIC 186
#define SC_CHARSET_CHINESEBIG5 136
#define SC_CHARSET_EASTEUROPE 238
#define SC_CHARSET_GB2312 134
#define SC_CHARSET_GREEK 161
#define SC_CHARSET_HANGUL 129
#define SC_CHARSET_MAC 77
#define SC_CHARSET_OEM 255
#define SC_CHARSET_RUSSIAN 204
#define SC_CHARSET_CYRILLIC 1251
#define SC_CHARSET_SHIFTJIS 128
#define SC_CHARSET_SYMBOL 2
#define SC_CHARSET_TURKISH 162
#define SC_CHARSET_JOHAB 130
#define SC_CHARSET_HEBREW 177
#define SC_CHARSET_ARABIC 178
#define SC_CHARSET_VIETNAMESE 163
#define SC_CHARSET_THAI 222
#define SC_CHARSET_8859_15 1000
#define SCI_STYLECLEARALL 2050
#define SCI_STYLESETFORE 2051
#define SCI_STYLESETBACK 2052
#define SCI_STYLESETBOLD 2053
#define SCI_STYLESETITALIC 2054
#define SCI_STYLESETSIZE 2055
#define SCI_STYLESETFONT 2056
#define SCI_STYLESETEOLFILLED 2057
#define SCI_STYLERESETDEFAULT 2058
#define SCI_STYLESETUNDERLINE 2059
#define SC_CASE_MIXED 0
#define SC_CASE_UPPER 1
#define SC_CASE_LOWER 2
#define SCI_STYLEGETFORE 2481
#define SCI_STYLEGETBACK 2482
#define SCI_STYLEGETBOLD 2483
#define SCI_STYLEGETITALIC 2484
#define SCI_STYLEGETSIZE 2485
#define SCI_STYLEGETFONT 2486
#define SCI_STYLEGETEOLFILLED 2487
#define SCI_STYLEGETUNDERLINE 2488
#define SCI_STYLEGETCASE 2489
#define SCI_STYLEGETCHARACTERSET 2490
#define SCI_STYLEGETVISIBLE 2491
#define SCI_STYLEGETCHANGEABLE 2492
#define SCI_STYLEGETHOTSPOT 2493
#define SCI_STYLESETCASE 2060
#define SCI_STYLESETCHARACTERSET 2066
#define SCI_STYLESETHOTSPOT 2409
#define SCI_SETSELFORE 2067
#define SCI_SETSELBACK 2068
#define SCI_GETSELALPHA 2477
#define SCI_SETSELALPHA 2478
#define SCI_GETSELEOLFILLED 2479
#define SCI_SETSELEOLFILLED 2480
#define SCI_SETCARETFORE 2069
#define SCI_ASSIGNCMDKEY 2070
#define SCI_CLEARCMDKEY 2071
#define SCI_CLEARALLCMDKEYS 2072
#define SCI_SETSTYLINGEX 2073
#define SCI_STYLESETVISIBLE 2074
#define SCI_GETCARETPERIOD 2075
#define SCI_SETCARETPERIOD 2076
#define SCI_SETWORDCHARS 2077
#define SCI_BEGINUNDOACTION 2078
#define SCI_ENDUNDOACTION 2079
#define INDIC_PLAIN 0
#define INDIC_SQUIGGLE 1
#define INDIC_TT 2
#define INDIC_DIAGONAL 3
#define INDIC_STRIKE 4
#define INDIC_HIDDEN 5
#define INDIC_BOX 6
#define INDIC_ROUNDBOX 7
#define INDIC_MAX 31
#define INDIC_CONTAINER 8
#define INDIC0_MASK 0x20
#define INDIC1_MASK 0x40
#define INDIC2_MASK 0x80
#define INDICS_MASK 0xE0
#define SCI_INDICSETSTYLE 2080
#define SCI_INDICGETSTYLE 2081
#define SCI_INDICSETFORE 2082
#define SCI_INDICGETFORE 2083
#define SCI_INDICSETUNDER 2510
#define SCI_INDICGETUNDER 2511
#define SCI_SETWHITESPACEFORE 2084
#define SCI_SETWHITESPACEBACK 2085
#define SCI_SETWHITESPACESIZE 2086
#define SCI_GETWHITESPACESIZE 2087
#define SCI_SETSTYLEBITS 2090
#define SCI_GETSTYLEBITS 2091
#define SCI_SETLINESTATE 2092
#define SCI_GETLINESTATE 2093
#define SCI_GETMAXLINESTATE 2094
#define SCI_GETCARETLINEVISIBLE 2095
#define SCI_SETCARETLINEVISIBLE 2096
#define SCI_GETCARETLINEBACK 2097
#define SCI_SETCARETLINEBACK 2098
#define SCI_STYLESETCHANGEABLE 2099
#define SCI_AUTOCSHOW 2100
#define SCI_AUTOCCANCEL 2101
#define SCI_AUTOCACTIVE 2102
#define SCI_AUTOCPOSSTART 2103
#define SCI_AUTOCCOMPLETE 2104
#define SCI_AUTOCSTOPS 2105
#define SCI_AUTOCSETSEPARATOR 2106
#define SCI_AUTOCGETSEPARATOR 2107
#define SCI_AUTOCSELECT 2108
#define SCI_AUTOCSETCANCELATSTART 2110
#define SCI_AUTOCGETCANCELATSTART 2111
#define SCI_AUTOCSETFILLUPS 2112
#define SCI_AUTOCSETCHOOSESINGLE 2113
#define SCI_AUTOCGETCHOOSESINGLE 2114
#define SCI_AUTOCSETIGNORECASE 2115
#define SCI_AUTOCGETIGNORECASE 2116
#define SCI_USERLISTSHOW 2117
#define SCI_AUTOCSETAUTOHIDE 2118
#define SCI_AUTOCGETAUTOHIDE 2119
#define SCI_AUTOCSETDROPRESTOFWORD 2270
#define SCI_AUTOCGETDROPRESTOFWORD 2271
#define SCI_REGISTERIMAGE 2405
#define SCI_CLEARREGISTEREDIMAGES 2408
#define SCI_AUTOCGETTYPESEPARATOR 2285
#define SCI_AUTOCSETTYPESEPARATOR 2286
#define SCI_AUTOCSETMAXWIDTH 2208
#define SCI_AUTOCGETMAXWIDTH 2209
#define SCI_AUTOCSETMAXHEIGHT 2210
#define SCI_AUTOCGETMAXHEIGHT 2211
#define SCI_SETINDENT 2122
#define SCI_GETINDENT 2123
#define SCI_SETUSETABS 2124
#define SCI_GETUSETABS 2125
#define SCI_SETLINEINDENTATION 2126
#define SCI_GETLINEINDENTATION 2127
#define SCI_GETLINEINDENTPOSITION 2128
#define SCI_GETCOLUMN 2129
#define SCI_SETHSCROLLBAR 2130
#define SCI_GETHSCROLLBAR 2131
#define SC_IV_NONE 0
#define SC_IV_REAL 1
#define SC_IV_LOOKFORWARD 2
#define SC_IV_LOOKBOTH 3
#define SCI_SETINDENTATIONGUIDES 2132
#define SCI_GETINDENTATIONGUIDES 2133
#define SCI_SETHIGHLIGHTGUIDE 2134
#define SCI_GETHIGHLIGHTGUIDE 2135
#define SCI_GETLINEENDPOSITION 2136
#define SCI_GETCODEPAGE 2137
#define SCI_GETCARETFORE 2138
#define SCI_GETUSEPALETTE 2139
#define SCI_GETREADONLY 2140
#define SCI_SETCURRENTPOS 2141
#define SCI_SETSELECTIONSTART 2142
#define SCI_GETSELECTIONSTART 2143
#define SCI_SETSELECTIONEND 2144
#define SCI_GETSELECTIONEND 2145
#define SCI_SETPRINTMAGNIFICATION 2146
#define SCI_GETPRINTMAGNIFICATION 2147
#define SC_PRINT_NORMAL 0
#define SC_PRINT_INVERTLIGHT 1
#define SC_PRINT_BLACKONWHITE 2
#define SC_PRINT_COLOURONWHITE 3
#define SC_PRINT_COLOURONWHITEDEFAULTBG 4
#define SCI_SETPRINTCOLOURMODE 2148
#define SCI_GETPRINTCOLOURMODE 2149
#define SCFIND_WHOLEWORD 2
#define SCFIND_MATCHCASE 4
#define SCFIND_WORDSTART 0x00100000
#define SCFIND_REGEXP 0x00200000
#define SCFIND_POSIX 0x00400000
#define SCI_FINDTEXT 2150
#define SCI_FORMATRANGE 2151
#define SCI_GETFIRSTVISIBLELINE 2152
#define SCI_GETLINE 2153
#define SCI_GETLINECOUNT 2154
#define SCI_SETMARGINLEFT 2155
#define SCI_GETMARGINLEFT 2156
#define SCI_SETMARGINRIGHT 2157
#define SCI_GETMARGINRIGHT 2158
#define SCI_GETMODIFY 2159
#define SCI_SETSEL 2160
#define SCI_GETSELTEXT 2161
#define SCI_GETTEXTRANGE 2162
#define SCI_HIDESELECTION 2163
#define SCI_POINTXFROMPOSITION 2164
#define SCI_POINTYFROMPOSITION 2165
#define SCI_LINEFROMPOSITION 2166
#define SCI_POSITIONFROMLINE 2167
#define SCI_LINESCROLL 2168
#define SCI_SCROLLCARET 2169
#define SCI_REPLACESEL 2170
#define SCI_SETREADONLY 2171
#define SCI_NULL 2172
#define SCI_CANPASTE 2173
#define SCI_CANUNDO 2174
#define SCI_EMPTYUNDOBUFFER 2175
#define SCI_UNDO 2176
#define SCI_CUT 2177
#define SCI_COPY 2178
#define SCI_PASTE 2179
#define SCI_CLEAR 2180
#define SCI_SETTEXT 2181
#define SCI_GETTEXT 2182
#define SCI_GETTEXTLENGTH 2183
#define SCI_GETDIRECTFUNCTION 2184
#define SCI_GETDIRECTPOINTER 2185
#define SCI_SETOVERTYPE 2186
#define SCI_GETOVERTYPE 2187
#define SCI_SETCARETWIDTH 2188
#define SCI_GETCARETWIDTH 2189
#define SCI_SETTARGETSTART 2190
#define SCI_GETTARGETSTART 2191
#define SCI_SETTARGETEND 2192
#define SCI_GETTARGETEND 2193
#define SCI_REPLACETARGET 2194
#define SCI_REPLACETARGETRE 2195
#define SCI_SEARCHINTARGET 2197
#define SCI_SETSEARCHFLAGS 2198
#define SCI_GETSEARCHFLAGS 2199
#define SCI_CALLTIPSHOW 2200
#define SCI_CALLTIPCANCEL 2201
#define SCI_CALLTIPACTIVE 2202
#define SCI_CALLTIPPOSSTART 2203
#define SCI_CALLTIPSETHLT 2204
#define SCI_CALLTIPSETBACK 2205
#define SCI_CALLTIPSETFORE 2206
#define SCI_CALLTIPSETFOREHLT 2207
#define SCI_CALLTIPUSESTYLE 2212
#define SCI_VISIBLEFROMDOCLINE 2220
#define SCI_DOCLINEFROMVISIBLE 2221
#define SCI_WRAPCOUNT 2235
#define SC_FOLDLEVELBASE 0x400
#define SC_FOLDLEVELWHITEFLAG 0x1000
#define SC_FOLDLEVELHEADERFLAG 0x2000
#define SC_FOLDLEVELNUMBERMASK 0x0FFF
#define SCI_SETFOLDLEVEL 2222
#define SCI_GETFOLDLEVEL 2223
#define SCI_GETLASTCHILD 2224
#define SCI_GETFOLDPARENT 2225
#define SCI_SHOWLINES 2226
#define SCI_HIDELINES 2227
#define SCI_GETLINEVISIBLE 2228
#define SCI_SETFOLDEXPANDED 2229
#define SCI_GETFOLDEXPANDED 2230
#define SCI_TOGGLEFOLD 2231
#define SCI_ENSUREVISIBLE 2232
#define SC_FOLDFLAG_LINEBEFORE_EXPANDED 0x0002
#define SC_FOLDFLAG_LINEBEFORE_CONTRACTED 0x0004
#define SC_FOLDFLAG_LINEAFTER_EXPANDED 0x0008
#define SC_FOLDFLAG_LINEAFTER_CONTRACTED 0x0010
#define SC_FOLDFLAG_LEVELNUMBERS 0x0040
#define SCI_SETFOLDFLAGS 2233
#define SCI_ENSUREVISIBLEENFORCEPOLICY 2234
#define SCI_SETTABINDENTS 2260
#define SCI_GETTABINDENTS 2261
#define SCI_SETBACKSPACEUNINDENTS 2262
#define SCI_GETBACKSPACEUNINDENTS 2263
#define SC_TIME_FOREVER 10000000
#define SCI_SETMOUSEDWELLTIME 2264
#define SCI_GETMOUSEDWELLTIME 2265
#define SCI_WORDSTARTPOSITION 2266
#define SCI_WORDENDPOSITION 2267
#define SC_WRAP_NONE 0
#define SC_WRAP_WORD 1
#define SC_WRAP_CHAR 2
#define SCI_SETWRAPMODE 2268
#define SCI_GETWRAPMODE 2269
#define SC_WRAPVISUALFLAG_NONE 0x0000
#define SC_WRAPVISUALFLAG_END 0x0001
#define SC_WRAPVISUALFLAG_START 0x0002
#define SCI_SETWRAPVISUALFLAGS 2460
#define SCI_GETWRAPVISUALFLAGS 2461
#define SC_WRAPVISUALFLAGLOC_DEFAULT 0x0000
#define SC_WRAPVISUALFLAGLOC_END_BY_TEXT 0x0001
#define SC_WRAPVISUALFLAGLOC_START_BY_TEXT 0x0002
#define SCI_SETWRAPVISUALFLAGSLOCATION 2462
#define SCI_GETWRAPVISUALFLAGSLOCATION 2463
#define SCI_SETWRAPSTARTINDENT 2464
#define SCI_GETWRAPSTARTINDENT 2465
#define SC_WRAPINDENT_FIXED 0
#define SC_WRAPINDENT_SAME 1
#define SC_WRAPINDENT_INDENT 2
#define SCI_SETWRAPINDENTMODE 2472
#define SCI_GETWRAPINDENTMODE 2473
#define SC_CACHE_NONE 0
#define SC_CACHE_CARET 1
#define SC_CACHE_PAGE 2
#define SC_CACHE_DOCUMENT 3
#define SCI_SETLAYOUTCACHE 2272
#define SCI_GETLAYOUTCACHE 2273
#define SCI_SETSCROLLWIDTH 2274
#define SCI_GETSCROLLWIDTH 2275
#define SCI_SETSCROLLWIDTHTRACKING 2516
#define SCI_GETSCROLLWIDTHTRACKING 2517
#define SCI_TEXTWIDTH 2276
#define SCI_SETENDATLASTLINE 2277
#define SCI_GETENDATLASTLINE 2278
#define SCI_TEXTHEIGHT 2279
#define SCI_SETVSCROLLBAR 2280
#define SCI_GETVSCROLLBAR 2281
#define SCI_APPENDTEXT 2282
#define SCI_GETTWOPHASEDRAW 2283
#define SCI_SETTWOPHASEDRAW 2284
#define SC_EFF_QUALITY_MASK 0xF
#define SC_EFF_QUALITY_DEFAULT 0
#define SC_EFF_QUALITY_NON_ANTIALIASED 1
#define SC_EFF_QUALITY_ANTIALIASED 2
#define SC_EFF_QUALITY_LCD_OPTIMIZED 3
#define SCI_SETFONTQUALITY 2611
#define SCI_GETFONTQUALITY 2612
#define SCI_SETFIRSTVISIBLELINE 2613
#define SC_MULTIPASTE_ONCE 0
#define SC_MULTIPASTE_EACH 1
#define SCI_SETMULTIPASTE 2614
#define SCI_GETMULTIPASTE 2615
#define SCI_GETTAG 2616
#define SCI_TARGETFROMSELECTION 2287
#define SCI_LINESJOIN 2288
#define SCI_LINESSPLIT 2289
#define SCI_SETFOLDMARGINCOLOUR 2290
#define SCI_SETFOLDMARGINHICOLOUR 2291
#define SCI_LINEDOWN 2300
#define SCI_LINEDOWNEXTEND 2301
#define SCI_LINEUP 2302
#define SCI_LINEUPEXTEND 2303
#define SCI_CHARLEFT 2304
#define SCI_CHARLEFTEXTEND 2305
#define SCI_CHARRIGHT 2306
#define SCI_CHARRIGHTEXTEND 2307
#define SCI_WORDLEFT 2308
#define SCI_WORDLEFTEXTEND 2309
#define SCI_WORDRIGHT 2310
#define SCI_WORDRIGHTEXTEND 2311
#define SCI_HOME 2312
#define SCI_HOMEEXTEND 2313
#define SCI_LINEEND 2314
#define SCI_LINEENDEXTEND 2315
#define SCI_DOCUMENTSTART 2316
#define SCI_DOCUMENTSTARTEXTEND 2317
#define SCI_DOCUMENTEND 2318
#define SCI_DOCUMENTENDEXTEND 2319
#define SCI_PAGEUP 2320
#define SCI_PAGEUPEXTEND 2321
#define SCI_PAGEDOWN 2322
#define SCI_PAGEDOWNEXTEND 2323
#define SCI_EDITTOGGLEOVERTYPE 2324
#define SCI_CANCEL 2325
#define SCI_DELETEBACK 2326
#define SCI_TAB 2327
#define SCI_BACKTAB 2328
#define SCI_NEWLINE 2329
#define SCI_FORMFEED 2330
#define SCI_VCHOME 2331
#define SCI_VCHOMEEXTEND 2332
#define SCI_ZOOMIN 2333
#define SCI_ZOOMOUT 2334
#define SCI_DELWORDLEFT 2335
#define SCI_DELWORDRIGHT 2336
#define SCI_DELWORDRIGHTEND 2518
#define SCI_LINECUT 2337
#define SCI_LINEDELETE 2338
#define SCI_LINETRANSPOSE 2339
#define SCI_LINEDUPLICATE 2404
#define SCI_LOWERCASE 2340
#define SCI_UPPERCASE 2341
#define SCI_LINESCROLLDOWN 2342
#define SCI_LINESCROLLUP 2343
#define SCI_DELETEBACKNOTLINE 2344
#define SCI_HOMEDISPLAY 2345
#define SCI_HOMEDISPLAYEXTEND 2346
#define SCI_LINEENDDISPLAY 2347
#define SCI_LINEENDDISPLAYEXTEND 2348
#define SCI_HOMEWRAP 2349
#define SCI_HOMEWRAPEXTEND 2450
#define SCI_LINEENDWRAP 2451
#define SCI_LINEENDWRAPEXTEND 2452
#define SCI_VCHOMEWRAP 2453
#define SCI_VCHOMEWRAPEXTEND 2454
#define SCI_LINECOPY 2455
#define SCI_MOVECARETINSIDEVIEW 2401
#define SCI_LINELENGTH 2350
#define SCI_BRACEHIGHLIGHT 2351
#define SCI_BRACEBADLIGHT 2352
#define SCI_BRACEMATCH 2353
#define SCI_GETVIEWEOL 2355
#define SCI_SETVIEWEOL 2356
#define SCI_GETDOCPOINTER 2357
#define SCI_SETDOCPOINTER 2358
#define SCI_SETMODEVENTMASK 2359
#define EDGE_NONE 0
#define EDGE_LINE 1
#define EDGE_BACKGROUND 2
#define SCI_GETEDGECOLUMN 2360
#define SCI_SETEDGECOLUMN 2361
#define SCI_GETEDGEMODE 2362
#define SCI_SETEDGEMODE 2363
#define SCI_GETEDGECOLOUR 2364
#define SCI_SETEDGECOLOUR 2365
#define SCI_SEARCHANCHOR 2366
#define SCI_SEARCHNEXT 2367
#define SCI_SEARCHPREV 2368
#define SCI_LINESONSCREEN 2370
#define SCI_USEPOPUP 2371
#define SCI_SELECTIONISRECTANGLE 2372
#define SCI_SETZOOM 2373
#define SCI_GETZOOM 2374
#define SCI_CREATEDOCUMENT 2375
#define SCI_ADDREFDOCUMENT 2376
#define SCI_RELEASEDOCUMENT 2377
#define SCI_GETMODEVENTMASK 2378
#define SCI_SETFOCUS 2380
#define SCI_GETFOCUS 2381
#define SC_STATUS_OK 0
#define SC_STATUS_FAILURE 1
#define SC_STATUS_BADALLOC 2
#define SCI_SETSTATUS 2382
#define SCI_GETSTATUS 2383
#define SCI_SETMOUSEDOWNCAPTURES 2384
#define SCI_GETMOUSEDOWNCAPTURES 2385
#define SC_CURSORNORMAL -1
#define SC_CURSORWAIT 4
#define SCI_SETCURSOR 2386
#define SCI_GETCURSOR 2387
#define SCI_SETCONTROLCHARSYMBOL 2388
#define SCI_GETCONTROLCHARSYMBOL 2389
#define SCI_WORDPARTLEFT 2390
#define SCI_WORDPARTLEFTEXTEND 2391
#define SCI_WORDPARTRIGHT 2392
#define SCI_WORDPARTRIGHTEXTEND 2393
#define VISIBLE_SLOP 0x01
#define VISIBLE_STRICT 0x04
#define SCI_SETVISIBLEPOLICY 2394
#define SCI_DELLINELEFT 2395
#define SCI_DELLINERIGHT 2396
#define SCI_SETXOFFSET 2397
#define SCI_GETXOFFSET 2398
#define SCI_CHOOSECARETX 2399
#define SCI_GRABFOCUS 2400
#define CARET_SLOP 0x01
#define CARET_STRICT 0x04
#define CARET_JUMPS 0x10
#define CARET_EVEN 0x08
#define SCI_SETXCARETPOLICY 2402
#define SCI_SETYCARETPOLICY 2403
#define SCI_SETPRINTWRAPMODE 2406
#define SCI_GETPRINTWRAPMODE 2407
#define SCI_SETHOTSPOTACTIVEFORE 2410
#define SCI_GETHOTSPOTACTIVEFORE 2494
#define SCI_SETHOTSPOTACTIVEBACK 2411
#define SCI_GETHOTSPOTACTIVEBACK 2495
#define SCI_SETHOTSPOTACTIVEUNDERLINE 2412
#define SCI_GETHOTSPOTACTIVEUNDERLINE 2496
#define SCI_SETHOTSPOTSINGLELINE 2421
#define SCI_GETHOTSPOTSINGLELINE 2497
#define SCI_PARADOWN 2413
#define SCI_PARADOWNEXTEND 2414
#define SCI_PARAUP 2415
#define SCI_PARAUPEXTEND 2416
#define SCI_POSITIONBEFORE 2417
#define SCI_POSITIONAFTER 2418
#define SCI_COPYRANGE 2419
#define SCI_COPYTEXT 2420
#define SC_SEL_STREAM 0
#define SC_SEL_RECTANGLE 1
#define SC_SEL_LINES 2
#define SC_SEL_THIN 3
#define SCI_SETSELECTIONMODE 2422
#define SCI_GETSELECTIONMODE 2423
#define SCI_GETLINESELSTARTPOSITION 2424
#define SCI_GETLINESELENDPOSITION 2425
#define SCI_LINEDOWNRECTEXTEND 2426
#define SCI_LINEUPRECTEXTEND 2427
#define SCI_CHARLEFTRECTEXTEND 2428
#define SCI_CHARRIGHTRECTEXTEND 2429
#define SCI_HOMERECTEXTEND 2430
#define SCI_VCHOMERECTEXTEND 2431
#define SCI_LINEENDRECTEXTEND 2432
#define SCI_PAGEUPRECTEXTEND 2433
#define SCI_PAGEDOWNRECTEXTEND 2434
#define SCI_STUTTEREDPAGEUP 2435
#define SCI_STUTTEREDPAGEUPEXTEND 2436
#define SCI_STUTTEREDPAGEDOWN 2437
#define SCI_STUTTEREDPAGEDOWNEXTEND 2438
#define SCI_WORDLEFTEND 2439
#define SCI_WORDLEFTENDEXTEND 2440
#define SCI_WORDRIGHTEND 2441
#define SCI_WORDRIGHTENDEXTEND 2442
#define SCI_SETWHITESPACECHARS 2443
#define SCI_SETCHARSDEFAULT 2444
#define SCI_AUTOCGETCURRENT 2445
#define SCI_AUTOCGETCURRENTTEXT 2610
#define SCI_ALLOCATE 2446
#define SCI_TARGETASUTF8 2447
#define SCI_SETLENGTHFORENCODE 2448
#define SCI_ENCODEDFROMUTF8 2449
#define SCI_FINDCOLUMN 2456
#define SCI_GETCARETSTICKY 2457
#define SCI_SETCARETSTICKY 2458
#define SC_CARETSTICKY_OFF 0
#define SC_CARETSTICKY_ON 1
#define SC_CARETSTICKY_WHITESPACE 2
#define SCI_TOGGLECARETSTICKY 2459
#define SCI_SETPASTECONVERTENDINGS 2467
#define SCI_GETPASTECONVERTENDINGS 2468
#define SCI_SELECTIONDUPLICATE 2469
#define SC_ALPHA_TRANSPARENT 0
#define SC_ALPHA_OPAQUE 255
#define SC_ALPHA_NOALPHA 256
#define SCI_SETCARETLINEBACKALPHA 2470
#define SCI_GETCARETLINEBACKALPHA 2471
#define CARETSTYLE_INVISIBLE 0
#define CARETSTYLE_LINE 1
#define CARETSTYLE_BLOCK 2
#define SCI_SETCARETSTYLE 2512
#define SCI_GETCARETSTYLE 2513
#define SCI_SETINDICATORCURRENT 2500
#define SCI_GETINDICATORCURRENT 2501
#define SCI_SETINDICATORVALUE 2502
#define SCI_GETINDICATORVALUE 2503
#define SCI_INDICATORFILLRANGE 2504
#define SCI_INDICATORCLEARRANGE 2505
#define SCI_INDICATORALLONFOR 2506
#define SCI_INDICATORVALUEAT 2507
#define SCI_INDICATORSTART 2508
#define SCI_INDICATOREND 2509
#define SCI_SETPOSITIONCACHE 2514
#define SCI_GETPOSITIONCACHE 2515
#define SCI_COPYALLOWLINE 2519
#define SCI_GETCHARACTERPOINTER 2520
#define SCI_SETKEYSUNICODE 2521
#define SCI_GETKEYSUNICODE 2522
#define SCI_INDICSETALPHA 2523
#define SCI_INDICGETALPHA 2524
#define SCI_SETEXTRAASCENT 2525
#define SCI_GETEXTRAASCENT 2526
#define SCI_SETEXTRADESCENT 2527
#define SCI_GETEXTRADESCENT 2528
#define SCI_MARKERSYMBOLDEFINED 2529
#define SCI_MARGINSETTEXT 2530
#define SCI_MARGINGETTEXT 2531
#define SCI_MARGINSETSTYLE 2532
#define SCI_MARGINGETSTYLE 2533
#define SCI_MARGINSETSTYLES 2534
#define SCI_MARGINGETSTYLES 2535
#define SCI_MARGINTEXTCLEARALL 2536
#define SCI_MARGINSETSTYLEOFFSET 2537
#define SCI_MARGINGETSTYLEOFFSET 2538
#define SCI_ANNOTATIONSETTEXT 2540
#define SCI_ANNOTATIONGETTEXT 2541
#define SCI_ANNOTATIONSETSTYLE 2542
#define SCI_ANNOTATIONGETSTYLE 2543
#define SCI_ANNOTATIONSETSTYLES 2544
#define SCI_ANNOTATIONGETSTYLES 2545
#define SCI_ANNOTATIONGETLINES 2546
#define SCI_ANNOTATIONCLEARALL 2547
#define ANNOTATION_HIDDEN 0
#define ANNOTATION_STANDARD 1
#define ANNOTATION_BOXED 2
#define SCI_ANNOTATIONSETVISIBLE 2548
#define SCI_ANNOTATIONGETVISIBLE 2549
#define SCI_ANNOTATIONSETSTYLEOFFSET 2550
#define SCI_ANNOTATIONGETSTYLEOFFSET 2551
#define UNDO_MAY_COALESCE 1
#define SCI_ADDUNDOACTION 2560
#define SCI_CHARPOSITIONFROMPOINT 2561
#define SCI_CHARPOSITIONFROMPOINTCLOSE 2562
#define SCI_SETMULTIPLESELECTION 2563
#define SCI_GETMULTIPLESELECTION 2564
#define SCI_SETADDITIONALSELECTIONTYPING 2565
#define SCI_GETADDITIONALSELECTIONTYPING 2566
#define SCI_SETADDITIONALCARETSBLINK 2567
#define SCI_GETADDITIONALCARETSBLINK 2568
#define SCI_SETADDITIONALCARETSVISIBLE 2608
#define SCI_GETADDITIONALCARETSVISIBLE 2609
#define SCI_GETSELECTIONS 2570
#define SCI_CLEARSELECTIONS 2571
#define SCI_SETSELECTION 2572
#define SCI_ADDSELECTION 2573
#define SCI_SETMAINSELECTION 2574
#define SCI_GETMAINSELECTION 2575
#define SCI_SETSELECTIONNCARET 2576
#define SCI_GETSELECTIONNCARET 2577
#define SCI_SETSELECTIONNANCHOR 2578
#define SCI_GETSELECTIONNANCHOR 2579
#define SCI_SETSELECTIONNCARETVIRTUALSPACE 2580
#define SCI_GETSELECTIONNCARETVIRTUALSPACE 2581
#define SCI_SETSELECTIONNANCHORVIRTUALSPACE 2582
#define SCI_GETSELECTIONNANCHORVIRTUALSPACE 2583
#define SCI_SETSELECTIONNSTART 2584
#define SCI_GETSELECTIONNSTART 2585
#define SCI_SETSELECTIONNEND 2586
#define SCI_GETSELECTIONNEND 2587
#define SCI_SETRECTANGULARSELECTIONCARET 2588
#define SCI_GETRECTANGULARSELECTIONCARET 2589
#define SCI_SETRECTANGULARSELECTIONANCHOR 2590
#define SCI_GETRECTANGULARSELECTIONANCHOR 2591
#define SCI_SETRECTANGULARSELECTIONCARETVIRTUALSPACE 2592
#define SCI_GETRECTANGULARSELECTIONCARETVIRTUALSPACE 2593
#define SCI_SETRECTANGULARSELECTIONANCHORVIRTUALSPACE 2594
#define SCI_GETRECTANGULARSELECTIONANCHORVIRTUALSPACE 2595
#define SCVS_NONE 0
#define SCVS_RECTANGULARSELECTION 1
#define SCVS_USERACCESSIBLE 2
#define SCI_SETVIRTUALSPACEOPTIONS 2596
#define SCI_GETVIRTUALSPACEOPTIONS 2597
#define SCI_SETRECTANGULARSELECTIONMODIFIER 2598
#define SCI_GETRECTANGULARSELECTIONMODIFIER 2599
#define SCI_SETADDITIONALSELFORE 2600
#define SCI_SETADDITIONALSELBACK 2601
#define SCI_SETADDITIONALSELALPHA 2602
#define SCI_GETADDITIONALSELALPHA 2603
#define SCI_SETADDITIONALCARETFORE 2604
#define SCI_GETADDITIONALCARETFORE 2605
#define SCI_ROTATESELECTION 2606
#define SCI_SWAPMAINANCHORCARET 2607
#define SCI_CHANGELEXERSTATE 2617
#define SCI_CONTRACTEDFOLDNEXT 2618
#define SCI_VERTICALCENTRECARET 2619
#define SCI_STARTRECORD 3001
#define SCI_STOPRECORD 3002
#define SCI_SETLEXER 4001
#define SCI_GETLEXER 4002
#define SCI_COLOURISE 4003
#define SCI_SETPROPERTY 4004
#define KEYWORDSET_MAX 8
#define SCI_SETKEYWORDS 4005
#define SCI_SETLEXERLANGUAGE 4006
#define SCI_LOADLEXERLIBRARY 4007
#define SCI_GETPROPERTY 4008
#define SCI_GETPROPERTYEXPANDED 4009
#define SCI_GETPROPERTYINT 4010
#define SCI_GETSTYLEBITSNEEDED 4011
#define SCI_GETLEXERLANGUAGE 4012
#define SCI_PRIVATELEXERCALL 4013
#define SCI_PROPERTYNAMES 4014
#define SC_TYPE_BOOLEAN 0
#define SC_TYPE_INTEGER 1
#define SC_TYPE_STRING 2
#define SCI_PROPERTYTYPE 4015
#define SCI_DESCRIBEPROPERTY 4016
#define SCI_DESCRIBEKEYWORDSETS 4017
#define SC_MOD_INSERTTEXT 0x1
#define SC_MOD_DELETETEXT 0x2
#define SC_MOD_CHANGESTYLE 0x4
#define SC_MOD_CHANGEFOLD 0x8
#define SC_PERFORMED_USER 0x10
#define SC_PERFORMED_UNDO 0x20
#define SC_PERFORMED_REDO 0x40
#define SC_MULTISTEPUNDOREDO 0x80
#define SC_LASTSTEPINUNDOREDO 0x100
#define SC_MOD_CHANGEMARKER 0x200
#define SC_MOD_BEFOREINSERT 0x400
#define SC_MOD_BEFOREDELETE 0x800
#define SC_MULTILINEUNDOREDO 0x1000
#define SC_STARTACTION 0x2000
#define SC_MOD_CHANGEINDICATOR 0x4000
#define SC_MOD_CHANGELINESTATE 0x8000
#define SC_MOD_CHANGEMARGIN 0x10000
#define SC_MOD_CHANGEANNOTATION 0x20000
#define SC_MOD_CONTAINER 0x40000
#define SC_MOD_LEXERSTATE 0x80000
#define SC_MODEVENTMASKALL 0xFFFFF
#define SCEN_CHANGE 768
#define SCEN_SETFOCUS 512
#define SCEN_KILLFOCUS 256
#define SCK_DOWN 300
#define SCK_UP 301
#define SCK_LEFT 302
#define SCK_RIGHT 303
#define SCK_HOME 304
#define SCK_END 305
#define SCK_PRIOR 306
#define SCK_NEXT 307
#define SCK_DELETE 308
#define SCK_INSERT 309
#define SCK_ESCAPE 7
#define SCK_BACK 8
#define SCK_TAB 9
#define SCK_RETURN 13
#define SCK_ADD 310
#define SCK_SUBTRACT 311
#define SCK_DIVIDE 312
#define SCK_WIN 313
#define SCK_RWIN 314
#define SCK_MENU 315
#define SCMOD_NORM 0
#define SCMOD_SHIFT 1
#define SCMOD_CTRL 2
#define SCMOD_ALT 4
#define SCMOD_SUPER 8
#define SCN_STYLENEEDED 2000
#define SCN_CHARADDED 2001
#define SCN_SAVEPOINTREACHED 2002
#define SCN_SAVEPOINTLEFT 2003
#define SCN_MODIFYATTEMPTRO 2004
#define SCN_KEY 2005
#define SCN_DOUBLECLICK 2006
#define SCN_UPDATEUI 2007
#define SCN_MODIFIED 2008
#define SCN_MACRORECORD 2009
#define SCN_MARGINCLICK 2010
#define SCN_NEEDSHOWN 2011
#define SCN_PAINTED 2013
#define SCN_USERLISTSELECTION 2014
#define SCN_URIDROPPED 2015
#define SCN_DWELLSTART 2016
#define SCN_DWELLEND 2017
#define SCN_ZOOM 2018
#define SCN_HOTSPOTCLICK 2019
#define SCN_HOTSPOTDOUBLECLICK 2020
#define SCN_CALLTIPCLICK 2021
#define SCN_AUTOCSELECTION 2022
#define SCN_INDICATORCLICK 2023
#define SCN_INDICATORRELEASE 2024
#define SCN_AUTOCCANCELLED 2025
#define SCN_AUTOCCHARDELETED 2026
#define SCN_HOTSPOTRELEASECLICK 2027


\ -----------------------------------------------------------------------------
\ Constant's "stolen" from SciLexer.h
\ -----------------------------------------------------------------------------

#define SCLEX_CONTAINER 0
#define SCLEX_NULL      1
#define SCLEX_FORTH     52


\ -----------------------------------------------------------------------------
\ Class "ScintillaControl"
\ This is the wrapper Class for the "Scintilla source code edit control"
\ -----------------------------------------------------------------------------

:Class ScintillaControl <Super CONTROL

int SelectionMode

:M WindowStyle: ( -- Style )
                WindowStyle: SUPER
                WS_TABSTOP or
                ;M

:M ClassInit:   ( -- )
                ClassInit: Super
                SC_SEL_STREAM to SelectionMode \ normal text selection
                ;M

:M Start:       ( Parent -- )
                TO Parent
                z" Scintilla" Create-Control
                ;M

\ -----------------------------------------------------------------------------
\ -----------------------------------------------------------------------------

Record: CharacterRange
        int crMin
        int crMax
;RecordSize: /CharacterRange

Record: TextRange
        int trMin
        int trMax
        int trText
;RecordSize: /TextRange

Record: TextToFind
        int ttfMin
        int ttfMax
        int ttrAddr
        int ttfStart
        int ttfEnd
;RecordSize: /TextToFind


\ -----------------------------------------------------------------------------
\ Text retrieval and modification
\
\ Each character in a Scintilla document is followed by an associated byte of
\ styling information. The combination of a character byte and a style byte is
\ called a cell. Style bytes are interpreted as a style index in the low 5 bits
\ and as 3 individual bits of indicators. This allows 32 fundamental styles,
\ which is enough for most languages, and three independent indicators so that,
\ for example, syntax errors, deprecated names and bad indentation could all be
\ displayed at once. The number of bits used for styles can be altered with
\ SetStyleBits: up to a maximum of 7 bits. The remaining bits can be used for
\ indicators.
\
\ Positions within the Scintilla document refer to a character or the gap before
\ that character. The first character in a document is 0, the second 1 and so on.
\ If a document contains nLen characters, the last character is numbered nLen-1.
\ The caret exists between character positions and can be located from before
\ the first character (0) to after the last character (nLen).
\
\ There are places where the caret can not go where two character bytes make up
\ one character. This occurs when a DBCS character from a language like Japanese
\ is included in the document or when line ends are marked with the CP/M standard
\ of a carriage return followed by a line feed. The INVALID_POSITION constant
\ represents an invalid position within the document.
\
\ All lines of text in Scintilla are the same height, and this height is
\ calculated from the largest font in any current style. This restriction is for
\ performance; if lines differed in height then calculations involving
\ positioning of text would require the text to be styled first.
\ -----------------------------------------------------------------------------

\ This returns len-1 characters of text from the start of the document plus
\ one terminating 0 character.
:M GetText:     ( addr len -- )
                SCI_GETTEXT SendMessage:Self drop ;M

\ This replaces all the text in the document with the zero terminated text
\ string you pass in.
:M SetText:     ( addr -- )
                0 SCI_SETTEXT SendMessage:Self drop ;M

\ This tells Scintilla that the current state of the document is unmodified.
\ This is usually done when the file is saved or loaded.
:M SetSavepoint: ( -- )
                0 0 SCI_SETSAVEPOINT SendMessage:Self drop ;M

\ This fills the buffer defined by addr with the contents of the nominated line
\ (lines start at 0). The buffer is not terminated by a 0 character.
\ The returned value is the number of characters copied to the buffer.
:M GetLine:     ( #line addr -- n )
                swap SCI_GETLINE SendMessage:Self ;M

\ The currently selected text between the anchor and the current position is
\ replaced by the 0 terminated text string. If the anchor and current position
\ are the same, the text is inserted at the caret position. The caret is
\ positioned after the inserted text and the caret is scrolled into view.
:M ReplaceSel:  ( addr -- )
                0 SCI_REPLACESEL SendMessage:Self drop ;M

\ Set the read-only flag for the document.
:M SetReadOnly: ( flag -- )
                0 swap SCI_SETREADONLY SendMessage:Self drop ;M

\ Get the read-only flag for the document.
:M GetReadOnly: ( -- flag )
                0 0 SCI_GETREADONLY SendMessage:Self ;M

\ This collects the text between the positions nMin and nMax and copies it to
\ addr If nMax is -1, text is returned to the end of the document. The text is
\ 0 terminated, so you must supply a buffer that is at least 1 character longer
\ than the number of characters you wish to read. The return value is the length
\ of the returned text not including the terminating 0.
:M GetTextRange: ( nMin nMax addr -- n )
                to trText to trMax to trMin
                TextRange 0 SCI_GETTEXTRANGE SendMessage:Self ;M

\ This collects styled text into a buffer using two bytes for each cell, with
\ the character at the lower address of each pair and the style byte at the
\ upper address. Characters between the positions nMin and nMax are copied to
\ addr. Two 0 bytes are added to the end of the text, so the buffer that addr
\ points at must be at least 2*(nMax-nMin)+2 bytes long. No check is made for
\ sensible values of nMin or nMax. Positions outside the document return
\ character codes and style bytes of 0.
:M GetStyledText: ( nMin nMax addr -- n )
                to trText to trMax to trMin
                TextRange 0 SCI_GETSTYLEDTEXT SendMessage:Self ;M

\ Allocate a document buffer large enough to store a given number of bytes. The
\ document will not be made smaller than its current contents.
:M Allocate:    ( n -- n )
                0 swap SCI_ALLOCATE SendMessage:Self drop ;M

\ This inserts the first length characters from the string at the current
\ position. This will include any 0's in the string that you might have expected
\ to stop the insert operation. The current position is set at the end of the
\ inserted text, but it is not scrolled into view.
:M AddText:     ( addr len -- )
                SCI_ADDTEXT SendMessage:Self drop ;M

\ This behaves just like AddText:, but inserts styled text.
:M AddStyledText: ( addr len -- )
                SCI_ADDSTYLEDTEXT SendMessage:Self drop ;M

\ This adds the first length characters from the string to the end of the
\ document. This will include any 0's in the string that you might have expected
\ to stop the operation. The current selection is not changed and the new text
\ is not scrolled into view.
:M AppendText:  ( addr len -- )
                swap SCI_APPENDTEXT SendMessage:Self drop ;M

\ This inserts the zero terminated text string at position pos or at the current
\ position if pos is -1. The current position is set at the end of the inserted
\ text, but it is not scrolled into view.
:M InsertText:  ( pos addr -- )
                swap SCI_INSERTTEXT SendMessage:Self drop ;M

\ Unless the document is read-only, this deletes all the text.
:M ClearAll:    ( -- )
                0 0 SCI_CLEARALL SendMessage:Self drop ;M

\ When wanting to completely restyle the document, for example after choosing a
\ lexer, the SCI_CLEARDOCUMENTSTYLE can be used to clear all styling information
\ and reset the folding state.
:M ClearDocumentStyle: ( -- )
                0 0 SCI_CLEARDOCUMENTSTYLE SendMessage:Self drop ;M

\ This returns the character at pos in the document or 0 if pos is negative or
\ past the end of the document.
:M GetCharAt:   ( pos -- char )
                0 swap SCI_GETCHARAT SendMessage:Self ;M

\ This returns the style at pos in the document, or 0 if pos is negative or past
\ the end of the document.
:M GetStyleAt:  ( pos -- style )
                0 swap SCI_GETCHARAT SendMessage:Self ;M

\ Set the number of bits in each cell to use for styling, to a maximum of
\ 7 style bits. The remaining bits can be used as indicators. The standard
\ setting is 5 bits.
:M SetStyleBits: ( bits -- )
                0 swap SCI_GETCHARAT SendMessage:Self drop ;M

\ Get the number of bits in each cell to use for styling.
:M GetStyleBits: ( -- )
                0 0 SCI_GETSTYLEBITS SendMessage:Self ;M


\ -----------------------------------------------------------------------------
\ Searching
\
\ Several of the search routines use flag options, which include a simple
\ regular expression search. Combine the flag options by adding them:
\
\ SCFIND_MATCHCASE A match only occurs with text that matches the case of the
\                  search string.
\ SCFIND_WHOLEWORD A match only occurs if the characters before and after are
\                  not word characters.
\ SCFIND_WORDSTART A match only occurs if the character before is not a word
\                  character.
\ SCFIND_REGEXP    The search string should be interpreted as a regular
\                  expression.
\ SCFIND_POSIX     Treat regular expression in a more POSIX compatible manner by
\                  interpreting bare ( and ) for tagged sections rather than
\                  \( and \).
\
\ If SCFIND_REGEXP is not included in the searchFlags, you can search backwards
\ to find the previous occurrence of a search string by setting the end of the
\ search range before the start. If SCFIND_REGEXP is included, searches are
\ always from a lower position to a higher position, even if the search range is
\ backwards.
\
\ In a regular expression, special characters interpreted are:
\
\ .      Matches any character
\ \(     This marks the start of a region for tagging a match.
\ \)     This marks the end of a tagged region.
\ \n     Where n is 1 through 9 refers to the first through ninth tagged region
\        when replacing. For example, if the search string was Fred\([1-9]\)XXX
\        and the replace string was Sam\1YYY, when applied to Fred2XXX this
\        would generate Sam2YYY.
\ \<     This matches the start of a word using Scintilla's definitions of words.
\ \>     This matches the end of a word using Scintilla's definition of words.
\ \x     This allows you to use a character x that would otherwise have a special
\        meaning. For example, \[ would be interpreted as [ and not as the start
\        of a character set.
\ [...]  This indicates a set of characters, for example, [abc] means any of the
\        characters a, b or c. You can also use ranges, for example [a-z] for any
\        lower case character.
\ [^...] The complement of the characters in the set. For example, [^A-Za-z]
\        means any character except an alphabetic character.
\ ^      This matches the start of a line (unless used inside a set, see above).
\ $      This matches the end of a line.
\ *      This matches 0 or more times. For example, Sa*m matches Sm, Sam, Saam,
\        Saaam and so on.
\ +      This matches 1 or more times. For example, Sa+m matches Sam, Saam, Saaam
\        and so on.
\ -----------------------------------------------------------------------------

\ This message searches for text in the document. It does not use or move the
\ current selection. The searchFlags argument controls the search type, which
\ includes regular expression searches.
\
\ Set nMin nMax with the range of positions in the document to search. If
\ SCFIND_REGEXP is not included in the flags, you can search backwards by
\ setting nMax less than nMin. If SCFIND_REGEXP is included, the search is always
\ forwards (even if nMax is less than nMin). Set the addr to point at a zero
\ terminated text string holding the search pattern. If your language makes the
\ use of FindText: difficult, you should consider using SearchInTarget: instead.
\
\ The return value is false if the search fails or the position of the start of
\ the found text if it succeeds. The nStart and nEnd are the start and end
\ positions of the found text.
:M FindText:    ( Flags nMin nMax addr -- nStart nEnd flag )
                to ttrAddr to ttfMax to ttfMin
                TextToFind swap SCI_FINDTEXT SendMessage:Self -1 =
                if   0 0 false
                else ttfStart ttfEnd true
                then ;M

\ SearchNext: and SearchPrev: search for the next and previous occurrence of the
\ zero terminated search string pointed at by text. The search is modified by
\ the searchFlags. If you request a regular expression, SearchPrev: finds the
\ first occurrence of the search string in the document, not the previous one
\ before the anchor point.
\
\ The return value is -1 if nothing is found, otherwise the return value is the
\ start position of the matching text. The selection is updated to show the
\ matched text, but is not scrolled into view.
:M SearchNext:  ( Flags addr -- n )
                swap SCI_SEARCHNEXT SendMessage:Self ;M

:M SearchPrev:  ( Flags addr -- n )
                swap SCI_SEARCHPREV SendMessage:Self ;M

\ SearchAnchor: sets the search start point used by SearchNext: and SearchPrev:
\ to the start of the current selection, that is, the end of the selection that
\ is nearer to the start of the document. You should always call this before
\ calling either of SearchNext: or SearchPrev:.
:M SearchAnchor: ( -- )
                0 0 SCI_SEARCHANCHOR SendMessage:Self drop ;M


\ -----------------------------------------------------------------------------
\ Search and replace using the target
\
\ Using ReplaceSel:, modifications cause scrolling and other visible changes,
\ which may take some time and cause unwanted display updates. If performing
\ many changes, such as a replace all command, the target can be used instead.
\ First, set the target, ie. the range to be replaced. Then call ReplaceTarget:
\ or ReplaceTargetRegular:
\
\ Searching can be performed within the target range with SearchInTarget:,
\ which uses a counted string to allow searching for null characters. It returns
\ the length of range or -1 for failure, in which case the target is not moved.
\ The flags used by SearchInTarget: such as SCFIND_MATCHCASE, SCFIND_WHOLEWORD,
\ SCFIND_WORDSTART, and SCFIND_REGEXP can be set with SetSearchFlags:
\ SearchInTarget: may be simpler for some clients to use than FindText:,
\ as that requires using a pointer to a structure.
\ -----------------------------------------------------------------------------

\ These functions set and return the start and end of the target. When searching
\ in non-regular expression mode, you can set start greater than end to find the
\ last matching text in the target rather than the first matching text. The target
\ is also set by a successful SearchInTarget:.
:M SetTargetStart:  ( pos -- )
                0 swap SCI_SETTARGETSTART SendMessage:Self drop ;M

:M GetTargetStart:  ( -- pos )
                0 0 SCI_GETTARGETSTART SendMessage:Self  ;M

:M SetTargetEnd:  ( pos -- )
                0 swap SCI_SETTARGETEND SendMessage:Self drop ;M

:M GetTargetEnd:  ( -- pos )
                0 0 SCI_GETTARGETEND SendMessage:Self  ;M

\ Set the target start and end to the start and end positions of the selection.
:M TargetFromSelection:  ( -- )
                0 0 SCI_TARGETFROMSELECTION SendMessage:Self drop ;M

\ These get and set the searchFlags used by SearchInTarget:. There are several
\ option flags including a simple regular expression search.
:M SetSearchFlags:  ( Flags -- )
                0 swap SCI_SETSEARCHFLAGS SendMessage:Self drop ;M

:M GetSearchFlags:  ( -- Flags  )
                0 0 SCI_GETSEARCHFLAGS SendMessage:Self  ;M

\ This searches for the first occurrence of a text string in the target defined
\ by SetTargetStart: and SetTargetEnd: The text string is not zero terminated;
\ the size is set by length. The search is modified by the search flags set by
\ SetSearchFlags:. If the search succeeds, the target is set to the found text
\ and the return value is the position of the start of the matching text. If the
\ search fails, the result is -1.
:M SearchInTarget:  ( addr len -- n )
                 SCI_SEARCHINTARGET SendMessage:Self ;M

\ If length is -1, text is a zero terminated string, otherwise length sets the
\ number of character to replace the target with. The return value is the length
\ of the replacement string.
\ Note that the recommanded way to delete text in the document is to set the
\ target to the text to be removed, and to perform a replace target with an empty
\ string.
:M ReplaceTarget:  ( addr len -- n )
                SCI_REPLACETARGET SendMessage:Self ;M

\ This replaces the target using regular expressions. If length is -1, text is
\ a zero terminated string, otherwise length is the number of characters to use.
\ The replacement string is formed from the text string with any sequences of
\ \1 through \9 replaced by tagged matches from the most recent regular expression
\ search. The return value is the length of the replacement string.
:M ReplaceTargetRegular:  ( addr len -- n )
                swap SCI_REPLACETARGETRE SendMessage:Self ;M


\ -----------------------------------------------------------------------------
\ Overtype
\ -----------------------------------------------------------------------------

\ When overtype is enabled, each typed character replaces the character to the
\ right of the text caret. When overtype is disabled, characters are inserted at
\ the caret. GetOverType: returns TRUE (1) if overtyping is active, otherwise
\ FALSE (0) will be returned. Use SetOverType: to set the overtype mode.
:M SetOverType: ( flag -- )
                0 swap SCI_SETOVERTYPE SendMessage:Self drop ;M

:M GetOverType: ( -- flag )
                0 0 SCI_GETOVERTYPE SendMessage:Self ;M


\ -----------------------------------------------------------------------------
\ Cut, copy and paste
\ -----------------------------------------------------------------------------

\ These commands perform the standard tasks of cutting and copying data to the
\ clipboard, pasting from the clipboard into the document, and clearing the
\ document. CanPaste: returns non-zero if the document isn't read-only and if
\ the selection doesn't contain protected text. If you need a "can copy" or
\ "can cut", use GetSelectionStart: - GetSelectionEnd:, which will be non-zero
\ if you can copy or cut to the clipboard.
:M Cut:         ( -- )
                0 0 SCI_CUT SendMessage:Self drop ;M

:M Copy:        ( -- )
                0 0 SCI_COPY SendMessage:Self drop ;M

:M Paste:       ( -- )
                0 0 SCI_PASTE SendMessage:Self drop ;M

:M Clear:       ( -- )
                0 0 SCI_CLEAR SendMessage:Self drop ;M

:M CanPaste:    ( -- flag )
                0 0 SCI_CANPASTE SendMessage:Self ;M

\ CopyRange: copies a range of text from the document to the system clipboard.
:M CopyRange:   ( start end -- )
                SCI_COPY SendMessage:Self drop ;M

\ CopyText: copies a supplied piece of text to the system clipboard.
:M CopyText:    ( addr len -- )
                swap SCI_COPYTEXT SendMessage:Self drop ;M


\ -----------------------------------------------------------------------------
\ Error handling
\ -----------------------------------------------------------------------------

\ If an error occurs, Scintilla may set an internal error number that can be
\ retrieved with SCI_GETSTATUS. Not currently used but will be in the future.
\ To clear the error status call SCI_SETSTATUS(0).
:M SetStatus:   ( n -- )
                0 SCI_SETSTATUS SendMessage:Self drop ;M

:M GetStatus:   ( -- n )
                0 0 SCI_GETSTATUS SendMessage:Self ;M


\ -----------------------------------------------------------------------------
\ Undo and Redo
\
\ Scintilla has multiple level undo and redo. It will continue to collect undoable
\ actions until memory runs out. Scintilla saves actions that change the document.
\ Scintilla does not save caret and selection movements, view scrolling and the
\ like. Sequences of typing or deleting are compressed into single actions to make
\ it easier to undo and redo at a sensible level of detail. Sequences of actions
\ can be combined into actions that are undone as a unit. These sequences occur
\ between BeginUndoAction: and EndUndoAction: messages. These sequences can
\ be nested and only the top-level sequences are undone as units.
\ -----------------------------------------------------------------------------

\ undoes one action, or if the undo buffer has reached a EndUndoAction: point,
\ all the actions back to the corresponding BeginUndoAction:
:M Undo:        ( -- )
                0 0 SCI_UNDO SendMessage:Self drop ;M

\ returns 0 if there is nothing to undo, and 1 if there is. You would typically
\ use the result of this message to enable/disable the Edit menu Undo command.
:M CanUndo:     ( -- n )
                0 0 SCI_CANUNDO SendMessage:Self ;M

\ undoes the effect of the last SCI_UNDO operation.
:M Redo:        ( -- )
                0 0 SCI_REDO SendMessage:Self drop ;M

\ returns 0 if there is no action to redo and 1 if there are undo actions to redo.
\ You could typically use the result of this message to enable/disable the Edit
\ menu Redo command
:M CanRedo:     ( -- n )
                0 0 SCI_CANREDO SendMessage:Self ;M

\ This command tells Scintilla to forget any saved undo or redo history. It also
\ sets the save point to the start of the undo buffer, so the document will appear
\ to be unmodified. This does not cause the SCN_SAVEPOINTREACHED notification to
\ be sent to the container.
:M EmptyUndoBuffer: ( -- )
                0 0 SCI_EMPTYUNDOBUFFER SendMessage:Self drop ;M

\ You can control whether Scintilla collects undo information with SetUndoCollection:.
\ Pass in true (1) to collect information and false (0) to stop collecting. If
\ you stop collection, you should also use EmptyUndoBuffer: to avoid the undo
\ buffer being unsynchronized with the data in the buffer.
:M SetUndoCollection: ( n -- )
                0 SCI_SETUNDOCOLLECTION SendMessage:Self drop ;M

:M GetUndoCollection: ( -- n )
                0 0 SCI_GETUNDOCOLLECTION SendMessage:Self ;M

\ Send these two messages to Scintilla to mark the beginning and end of a set of
\ operations that you want to undo all as one operation but that you have to
\ generate as several operations. Alternatively, you can use these to mark a set
\ of operations that you do not want to have combined with the preceding or
\ following operations if they are undone.
:M BeginUndoAction: ( -- )
                0 0 SCI_BEGINUNDOACTION SendMessage:Self drop ;M

:M EndUndoAction: ( -- )
                0 0 SCI_ENDUNDOACTION SendMessage:Self drop ;M


\ -----------------------------------------------------------------------------
\ Selection and information
\
\ Scintilla maintains a selection that stretches between two points, the anchor
\ and the current position. If the anchor and the current position are the same,
\ there is no selected text. Positions in the document range from 0 (before the
\ first character), to the document size (after the last character). If you use
\ messages, there is nothing to stop you setting a position that is in the middle
\ of a CRLF pair, or in the middle of a 2 byte character. However, keyboard
\ commands will not move the caret into such positions.
\ -----------------------------------------------------------------------------

\ return the length of the document in characters.
:M GetTextLength:   ( -- n )
                0 0 SCI_GETTEXTLENGTH SendMessage:Self ;M

\ This returns the number of lines in the document. An empty document contains 1
\ line. A document holding only an end of line sequence has 2 lines.
:M GetLineCount: ( -- n )
                0 0 SCI_GETLINECOUNT SendMessage:Self ;M

\ This returns the line number of the first visible line in the Scintilla view.
\ The first line in the document is numbered 0.
:M GetFirstVisibleLine: ( -- n )
                0 0 SCI_GETFIRSTVISIBLELINE SendMessage:Self ;M

\ This returns the number of complete lines visible on the screen. With a constant
\ line height, this is the vertical space available divided by the line separation.
\ Unless you arrange to size your window to an integral number of lines, there may
\ be a partial line visible at the bottom of the view.
:M LinesOnScreen: ( -- n )
                0 0 SCI_LINESONSCREEN SendMessage:Self ;M

\ This returns non-zero if the document is modified and 0 if it is unmodified.
\ The modified status of a document is determined by the undo position relative
\ to the save point. The save point is set by SetSavepoint:, usually when you
\ have saved data to a file.
\ If you need to be notified when the document becomes modified, Scintilla notifies
\ the container that it has entered or left the save point with the
\ SCN_SAVEPOINTREACHED and SCN_SAVEPOINTLEFT notification messages.
:M GetModify:   ( -- n )
                0 0 SCI_GETMODIFY SendMessage:Self ;M

\ This message sets both the anchor and the current position. If currentPos is
\ negative, it means the end of the document. If anchorPos is negative, it means
\ remove any selection (i.e. set the anchor to the same position as currentPos).
\ The caret is scrolled into view after this operation.
:M SetSel:      ( anchorPos currentPos -- )
                swap SCI_SETSEL SendMessage:Self drop ;M

\ This removes any selection, sets the caret at pos and scrolls the view to make
\ the caret visible, if necessary. The anchor position is set the same as the
\ current position.
:M GotoPos:     ( pos -- )
                0 swap SCI_GOTOPOS SendMessage:Self drop ;M

\ This removes any selection and sets the caret at the start of line number line
\ and scrolls the view (if needed) to make it visible. The anchor position is set
\ the same as the current position. If line is outside the lines in the document
\ (first line is 0), the line set is the first or last.
:M GotoLine:    ( line -- )
                0 swap SCI_GOTOLINE SendMessage:Self drop ;M

\ This sets the current position and creates a selection between the anchor and
\ the current position. The caret is not scrolled into view.
:M SetCurrentPos: ( pos -- )
                0 swap SCI_SETCURRENTPOS SendMessage:Self drop ;M

\ This returns the current position.
:M GetCurrentPos: ( -- pos )
                0 0 SCI_GETCURRENTPOS SendMessage:Self ;M

\ This sets the anchor position and creates a selection between the anchor
\ position and the current position. The caret is not scrolled into view.
:M SetAnchor:   ( pos -- )
                0 swap SCI_SETANCHOR SendMessage:Self drop ;M

\ This returns the current anchor position.
:M GetAnchor:   ( -- pos )
                0 0 SCI_GETANCHOR SendMessage:Self ;M

\ These set the selection based on the assumption that the anchor position is
\ less than the current position. They do not make the caret visible.
:M SetSelectionStart: ( pos -- )
                0 swap SCI_SETSELECTIONSTART SendMessage:Self drop ;M

:M SetSelectionEnd: ( pos -- )
                0 swap SCI_SETSELECTIONEND SendMessage:Self drop ;M

\ These return the start and end of the selection without regard to which end is
\ the current position and which is the anchor. GetSelectionStart: returns
\ the smaller of the current position or the anchor position. GetSelectionEnd:
\ returns the larger of the two values.
:M GetSelectionStart: ( -- pos )
                0 0 SCI_GETSELECTIONSTART SendMessage:Self ;M

:M GetSelectionEnd: ( -- pos )
                0 0 SCI_GETSELECTIONEND SendMessage:Self ;M

\ This selects all the text in the document. The current position is not
\ scrolled into view.
:M SelectAll:   ( -- )
                0 0 SCI_SELECTALL SendMessage:Self drop ;M

\ This message returns the line that contains the position pos in the document.
\ The return value is 0 if pos <= 0. The return value is the last line if pos is
\ beyond the end of the document.
:M LineFromPosition: ( pos -- line )
                0 swap SCI_LINEFROMPOSITION SendMessage:Self ;M

\ This returns the document position that corresponds with the start of the line.
\ If line is negative, the position of the line holding the start of the selection
\ is returned. If line is greater than the lines in the document, the return value
\ is -1. If line is equal to the number of lines in the document (i.e. 1 line past
\ the last line), the return value is the end of the document.
:M PositionFromLine: ( line -- pos )
                0 swap SCI_POSITIONFROMLINE SendMessage:Self ;M

\ This returns the position at the end of the line, before any line end characters.
\ If line is negative, the result is 0. If line is the last line in the document,
\ (which does not have any end of line characters), the result is the size of the
\ document. If line is negative, the result is -1. If line is >= GetLineCount:
\ the result is undefined.
:M GetLineEndPosition: ( line -- pos )
                0 swap SCI_GETLINEENDPOSITION SendMessage:Self ;M

\ This returns the length of the line, including any line end characters. If line
\ is negative or beyond the last line in the document, the result is 0.
:M LineLength:  ( line -- len )
                0 swap SCI_LINELENGTH SendMessage:Self ;M

\ This copies the currently selected text and a terminating 0 byte to the text
\ buffer. If the text argument is 0 then the length that should be allocated
\ to store the entire selection is returned.
:M GetSelText:  ( text -- len )
                0 ( no SWAP here!!! ) SCI_GETSELTEXT SendMessage:Self ;M

\ This retrieves the text of the line containing the caret and returns the
\ position within the line of the caret. Pass in text pointing at a buffer large
\ enough to hold the text you wish to retrieve and a terminating 0 character. Set
\ Len to the length of the buffer. If the text argument is 0 then the length that
\ should be allocated to store the entire current line is returned.
:M GetCurLine:  ( len text -- len )
                swap SCI_GETCURLINE SendMessage:Self ;M

\ This returns 1 if the current selection is in rectangle mode, 0 if not.
:M SelectionIsRectangle: ( -- n )
                0 0 SCI_SELECTIONISRECTANGLE SendMessage:Self ;M

\ The two functions set and get the selection mode, which can be stream
\ (SC_SEL_STREAM=1) or rectangular (SC_SEL_RECTANGLE=2) or by lines
\ (SC_SEL_LINES=3). When set in these modes, regular caret moves will extend or
\ reduce the selection, until the mode is cancelled by a call with same value or
\ with Cancle: The get function returns the current mode even if the selection
\ was made by mouse or with regular extended moves.
:M SetSelectionMode:  ( mode -- )
                dup to SelectionMode
                0 swap SCI_SETSELECTIONMODE SendMessage:Self drop ;M

:M GetSelectionMode:  ( -- mode )
                0 0 SCI_GETSELECTIONMODE SendMessage:Self ;M

\ Retrieve the position of the start and end of the selection at the given line
\ with INVALID_POSITION returned if no selection on this line.
:M GetLineSelStartPosition:  ( line -- pos )
                0 SCI_GETLINESELSTARTPOSITION SendMessage:Self ;M

:M GetLineSelEndPosition:  ( line -- pos )
                0 swap SCI_GETLINESELENDPOSITION SendMessage:Self ;M

\ If the caret is off the top or bottom of the view, it is moved to the nearest
\ line that is visible to its current position. Any selection is lost.
:M MoveCaretInsideView:  ( -- )
                0 0 SCI_MOVECARETINSIDEVIEW SendMessage:Self drop ;M

\ These messages return the start and end of words using the same definition of
\ words as used internally within Scintilla. You can set your own list of
\ characters that count as words with SCI_SETWORDCHARS. The position sets the
\ start or the search, which is forwards when searching for the end and backwards
\ when searching for the start.
\ Set onlyWordCharacters to true (1) to stop searching at the first non-word
\ character in the search direction. If onlyWordCharacters is false (0), the
\ first character in the search direction sets the type of the search as word or
\ non-word and the search stops at the first non-matching character. Searches are
\ also terminated by the start or end of the document.
:M WordEndPosition:  ( position onlyWordCharacters -- )
                swap SCI_WORDENDPOSITION SendMessage:Self drop ;M

:M WordStartPosition:  ( position onlyWordCharacters -- )
                swap SCI_WORDSTARTPOSITION SendMessage:Self drop ;M

:M SetWordChars: ( addr -- )
                0 SCI_SETWORDCHARS SendMessage:Self drop ;M

\ These messages return the position before and after another position in the
\ document taking into account the current code page. The minimum position
\ returned is 0 and the maximum is the last position in the document. If called
\ with a position within a multi byte character will return the position of the
\ start/end of that character.
:M PositionBefore: ( -- pos )
                0 0 SCI_POSITIONBEFORE SendMessage:Self ;M

:M PositionAfter: ( -- pos )
                0 0 SCI_POSITIONAFTER SendMessage:Self ;M

\ This returns the pixel width of a string drawn in the given styleNumber which
\ can be used, for example, to decide how wide to make the line number margin in
\ order to display a given number of numerals.
:M TextWidth:   ( styleNumber text -- width )
                swap SCI_TEXTWIDTH SendMessage:Self ;M

\ This returns the height in pixels of a particular line. Currently all lines
\ are the same height.
:M TextHeight:  ( line -- height )
                0 SCI_TEXTHEIGHT SendMessage:Self ;M

\ This message returns the column number of a position pos within the document
\ taking the width of tabs into account. This returns the column number of the
\ last tab on the line before pos, plus the number of characters between the last
\ tab and pos. If there are no tab characters on the line, the return value is
\ the number of characters up to the position on the line. In both cases, double
\ byte characters count as a single character. This is probably only useful with
\ monospaced fonts.
:M GetColumn:   ( pos -- n )
                0 SCI_GETCOLUMN SendMessage:Self ;M

\ PositionFromPoint: finds the closest character position to a point and
\ PositionFromPointClose: is similar but returns -1 if the point is outside
\ the window or not close to any characters.
:M PositionFromPoint:  ( x y -- n )
                swap SCI_POSITIONFROMPOINT SendMessage:Self ;M

:M PositionFromPointClose:  ( x y -- n )
                swap SCI_POSITIONFROMPOINTCLOSE SendMessage:Self ;M

\ These messages return the x and y display pixel location of text at position
\ pos in the document.
:M PointFromPositionX: ( pos -- x )
                0 SCI_POINTXFROMPOSITION SendMessage:Self ;M

:M PointFromPositionY: ( pos -- y )
                0 SCI_POINTYFROMPOSITION SendMessage:Self ;M

\ The normal state is to make the selection visible by drawing it as set by
\ SetSelBefore: and SetSelBack:. However, if you hide the selection, it is
\ drawn as normal text.
:M HideSelection: ( hide -- )
                0 SCI_HIDESELECTION SendMessage:Self drop ;M

\ Scintilla remembers the x value of the last position horizontally moved to
\ explicitly by the user and this value is then used when moving vertically such
\ as by using the up and down keys. This message sets the current x position of
\ the caret as the remembered value.
:M ChooseCaretX: ( -- )
                0 0 SCI_CHOOSECARETX SendMessage:Self drop ;M


\ -----------------------------------------------------------------------------
\ Style definition
\ While the style setting messages mentioned above change the style numbers
\ associated with text, these messages define how those style numbers are
\ interpreted visually. There are 128 lexer styles that can be set, numbered 0
\ to STYLEMAX (127). Unless you use SCI_SETSTYLEBITS to change the number of
\ style bits, styles 0 to 31 are used to set the text attributes.
\ -----------------------------------------------------------------------------

\ Text is drawn in the foreground colour. The space in each character cell that
\ is not occupied by the character is drawn in the background colour.
:M StyleSetFore: ( styleNumber colour -- )
                swap SCI_STYLESETFORE SendMessage:Self drop ;M

:M StyleSetBack: ( styleNumber colour -- )
                swap SCI_STYLESETBACK SendMessage:Self drop ;M


\ -----------------------------------------------------------------------------
\ Scrolling and automatic scrolling
\ -----------------------------------------------------------------------------

\ This will attempt to scroll the display by the number of columns and lines
\ that you specify. Positive line values increase the line number at the top of
\ the screen (i.e. they move the text upwards as far as the user is concerned),
\ Negative line values do the reverse.
\ The column measure is the width of a space in the default style. Positive
\ values increase the column at the left edge of the view (i.e. they move the
\ text leftwards as far as the user is concerned). Negative values do the reverse.
:M LineScroll:  ( line column -- )
                swap SCI_LINESCROLL SendMessage:Self drop ;M

\ If the current position (this is the caret if there is no selection) is not
\ visible, the view is scrolled to make it visible according to the current
\ caret policy.
:M ScrollCaret: ( -- )
                0 0 SCI_SCROLLCARET SendMessage:Self drop ;M

\ These set the caret policy. The value of caretPolicy is a combination of
\ CARET_SLOP, CARET_STRICT, CARET_JUMPS and CARET_EVEN.
\
\ CARET_SLOP   If set, we can define a slop value: caretSlop. This value defines
\              an unwanted zone (UZ) where the caret is... unwanted. This zone
\              is defined as a number of pixels near the vertical margins, and
\              as a number of lines near the horizontal margins. By keeping the
\              caret away from the edges, it is seen within its context. This
\              makes it likely that the identifier that the caret is on can be
\              completely seen, and that the current line is seen with some of
\              the lines following it, which are often dependent on that line.
\ CARET_STRICT If set, the policy set by CARET_SLOP is enforced... strictly. The
\              caret is centred on the display if caretSlop is not set, and
\              cannot go in the UZ if caretSlop is set.
\ CARET_JUMPS  If set, the display is moved more energetically so the caret can
\              move in the same direction longer before the policy is applied
\              again. '3UZ' notation is used to indicate three time the size of
\              the UZ as a distance to the margin.
\ CARET_EVEN   If not set, instead of having symmetrical UZs, the left and bottom
\              UZs are extended up to right and top UZs respectively. This way,
\              we favour the displaying of useful information: the beginning of
\              lines, where most code reside, and the lines after the caret, for
\              example, the body of a function.
:M SetCaretPolicyX: ( caretPolicy caretSlop -- )
                swap SCI_SETXCARETPOLICY SendMessage:Self drop ;M

:M SetCaretPolicyY: ( caretPolicy caretSlop -- )
                swap SCI_SETYCARETPOLICY SendMessage:Self drop ;M

\ This determines how the vertical positioning is determined when
\ EnsureVisibleEnforcePolicy: is called. It takes VISIBLE_SLOP and VISIBLE_STRICT
\ flags for the policy parameter.
:M SetVisiblePolicy: ( caretPolicy caretSlop -- )
                swap SCI_SETVISIBLEPOLICY SendMessage:Self drop ;M

\ The horizontal scroll bar is only displayed if it is needed for the assumed
\ width. If you never wish to see it, call 0 SetHScrollbar: Use 1 SetHScrollbar:
\ to enable it again. SCI_GETHSCROLLBAR returns the current state. The default
\ state is to display it when needed.
:M SetHScrollbar: ( visible -- )
                0 SCI_SETHSCROLLBAR SendMessage:Self drop ;M

:M GetHScrollbar: ( -- visible )
                0 0 SCI_GETHSCROLLBAR SendMessage:Self ;M

\ By default, the vertical scroll bar is always displayed when required. You can
\ choose to hide or show it with SetVScrollbar: and get the current state with
\ GetVScrollbar:
:M SetVScrollbar: ( visible -- )
                0 SCI_SETVSCROLLBAR SendMessage:Self drop ;M

:M GetVScrollbar: ( -- visible )
                0 0 SCI_GETVSCROLLBAR SendMessage:Self ;M

\ The xOffset is the horizontal scroll position in pixels of the start of the
\ text view. A value of 0 is the normal position with the first text column
\ visible at the left of the view.
:M SetXOffset:  ( offset -- )
                0 SCI_SETXOFFSET SendMessage:Self drop ;M

:M GetXOffset: ( -- offset )
                0 0 SCI_GETXOFFSET SendMessage:Self ;M

\ For performance, Scintilla does not measure the display width of the document
\ to determine the properties of the horizontal scroll bar. Instead, an assumed
\ width is used. These messages set and get the document width in pixels assumed
\ by Scintilla. The default value is 2000.
:M SetScrollWidth:  ( pixelWidth -- )
                0 SCI_SETSCROLLWIDTH SendMessage:Self drop ;M

:M GetScrollWidth: ( -- pixelWidth )
                0 0 SCI_GETSCROLLWIDTH SendMessage:Self ;M

\ SetEndAtLastLine: sets the scroll range so that maximum scroll position has
\ the last line at the bottom of the view (default). Setting this to false allows
\ scrolling one page below the last line.
:M SetEndAtLastLine:  ( endAtLastLine -- )
                0 SCI_SETENDATLASTLINE SendMessage:Self drop ;M

:M GetEndAtLastLine: ( -- endAtLastLine )
                0 0 SCI_GETENDATLASTLINE SendMessage:Self ;M


\ -----------------------------------------------------------------------------
\ White space
\ -----------------------------------------------------------------------------

\ White space can be made visible which may useful for languages in which white
\ space is significant, such as Python. Space characters appear as small centred
\ dots and tab characters as light arrows pointing to the right. There are also
\ ways to control the display of end of line characters. The two messages set
\ and get the white space display mode. The wsMode argument can be one of:
\
\ SCWS_INVISIBLE          The normal display mode with white space displayed as
\                         an empty background colour.
\ SCWS_VISIBLEALWAYS      White space characters are drawn as dots and arrows,
\ SCWS_VISIBLEAFTERINDENT White space used for indentation is displayed normally
\                         but after the first visible character, it is shown as
\                         dots and arrows.
:M SetWhiteSpace: ( wsMode -- )
                0 swap SCI_SETVIEWWS SendMessage:Self drop ;M

:M GetWhiteSpace: ( wsMode -- )
                0 0 SCI_GETVIEWWS SendMessage:Self ;M

\ By default, the colour of visible white space is determined by the lexer in use.
\ The foreground and/or background colour of all visible white space can be set
\ globally, overriding the lexer's colours with SetWhiteSpaceFore: and
\ SetWhiteSpaceBack:.
:M SetWhiteSpaceFore: ( useWhitespaceForeColour colour -- )
                swap SCI_SETWHITESPACEFORE SendMessage:Self drop ;M

:M SetWhiteSpaceBack: ( useWhitespaceBackColour colour -- )
                swap SCI_SETWHITESPACEBACK SendMessage:Self drop ;M


\ -----------------------------------------------------------------------------
\ Cursor
\ -----------------------------------------------------------------------------

\ The cursor is normally chosen in a context sensitive way, so it will be
\ different over the margin than when over the text. When performing a slow action,
\ you may wish to change to a wait cursor. You set the cursor type with SetCursor:
\ The curType argument can be:
\
\ SC_CURSORNORMAL The normal cursor is displayed.
\ SC_CURSORWAIT   The wait cursor is displayed when the mouse is over or owned
\                 by the Scintilla window.
:M SetCursor:   ( curType -- )
                0 SCI_SETCURSOR SendMessage:Self drop ;M

:M GetCursor:   ( -- curType )
                0 0 SCI_GETCURSOR SendMessage:Self ;M


\ -----------------------------------------------------------------------------
\ Mouse capture
\ -----------------------------------------------------------------------------

\ When the mouse is pressed inside Scintilla, it is captured so future mouse
\ movement events are sent to Scintilla. This behavior may be turned off with
\ 0 SetCapture:.
:M SetCapture:  ( captures -- )
                0 SCI_SETMOUSEDOWNCAPTURES SendMessage:Self drop ;M

:M GetCapture:  ( -- captures )
                0 0 SCI_GETMOUSEDOWNCAPTURES SendMessage:Self ;M


\ -----------------------------------------------------------------------------
\ Line endings
\
\ Scintilla can interpret any of the three major line end conventions, Macintosh (\r),
\ Unix (\n) and CP/M / DOS / Windows (\r\n). When the user presses the Enter key,
\ one of these line end strings is inserted into the buffer. The default is \r\n
\ in Windows and \n in Unix, but this can be changed with the SetEolMode: message.
\ You can also convert the entire document to one of these line endings with SCI_CONVERTEOLS.
\ Finally, you can choose to display the line endings with SCI_SETVIEWEOL.
\ -----------------------------------------------------------------------------

\ sets the characters that are added into the document when the user presses the
\ Enter key. You can set eolMode to one of SC_EOL_CRLF, SC_EOL_CR, or SC_EOL_LF.
:M SetEOL:      ( eolMode -- )
                0 swap SCI_SETEOLMODE SendMessage:Self drop ;M

:M GetEOL:      ( -- eolMode )
                0 0 SCI_GETEOLMODE SendMessage:Self ;M

\ This message changes all the end of line characters in the document to match
\ eolMode. Valid values are: SC_EOL_CRLF, SC_EOL_CR, or SC_EOL_LF.
:M ConvertEOL:  ( eolMode -- )
                0 swap SCI_CONVERTEOLS SendMessage:Self drop ;M

\ Normally, the end of line characters are hidden, but SCI_SETVIEWEOL allows you
\ to display (or hide) them by setting visible true (or false). The visible
\ rendering of the end of line characters is similar to (CR), (LF), or (CR)(LF).
\ SCI_GETVIEWEOL returns the current state.
:M SetViewEOL:  ( visible -- )
                0 swap SCI_SETVIEWEOL SendMessage:Self drop ;M

:M GetViewEOL:  ( -- visible )
                0 0 SCI_GETVIEWEOL SendMessage:Self ;M


\ -----------------------------------------------------------------------------
\ Styling
\
\ The styling messages allow you to assign styles to text. The standard Scintilla
\ settings divide the 8 style bits available for each character into 5 bits
\ (0 to 4 = styles 0 to 31) that set a style and three bits (5 to 7) that define
\ indicators. You can change the balance between styles and indicators with
\ SCI_SETSTYLEBITS. If your styling needs can be met by one of the standard lexers,
\ or if you can write your own, then a lexer is probably the easiest way to style
\ your document. If you choose to use the container to do the styling you can use
\ the SCI_SETLEXER command to select SCLEX_CONTAINER, in which case the container
\ is sent a SCN_STYLENEEDED notification each time text needs styling for display.
\ As another alternative, you might use idle time to style the document. Even if
\ you use a lexer, you might use the styling commands to mark errors detected by
\ a compiler. The following commands can be used.
\ -----------------------------------------------------------------------------

\ Scintilla keeps a record of the last character that is likely to be styled
\ correctly. This is moved forwards when characters after it are styled and moved
\ backwards if changes are made to the text of the document before it. Before
\ drawing text, this position is checked to see if any styling is needed and, if
\ so, a SCN_STYLENEEDED notification message is sent to the container. The container
\ can send GetEndStyled: to work out where it needs to start styling. Scintilla
\ will always ask to style whole lines.
:M GetEndStyled:  ( -- n )
                0 0 SCI_GETENDSTYLED SendMessage:Self ;M

\ This prepares for styling by setting the styling position pos to start at and
\ a mask indicating which bits of the style bytes can be set. The mask allows
\ styling to occur over several passes, with, for example, basic styling done on
\ an initial pass to ensure that the text of the code is seen quickly and correctly,
\ and then a second slower pass, detecting syntax errors and using indicators to
\ show where these are. For example, with the standard settings of 5 style bits
\ and 3 indicator bits, you would use a mask value of 31 (0x1f) if you were setting
\ text styles and did not want to change the indicators. After StartStyling:
\ send multiple SetStyling: messages for each lexical entity to style.
:M StartStyling:  ( pos mask -- )
                swap SCI_STARTSTYLING SendMessage:Self drop ;M

\ This message sets the style of length characters starting at the styling position
\ and then increases the styling position by length, ready for the next call. If
\ sCell is the style byte, the operation is:
\ if ((sCell & mask) != style) sCell = (sCell & ~mask) | (style & mask);
:M SetStyling:  ( length style -- )
                swap SCI_SETSTYLING SendMessage:Self drop ;M

\ As an alternative to SCI_SETSTYLING, which applies the same style to each byte,
\ you can use this message which specifies the styles for each of length bytes
\ from the styling position and then increases the styling position by length,
\ ready for the next call. The length styling bytes pointed at by styles should
\ not contain any bits not set in mask.
:M SetStylingEx: ( styles length -- )
                SCI_SETSTYLINGEX SendMessage:Self drop ;M

\ As well as the 8 bits of lexical state stored for each character there is also
\ an integer stored for each line. This can be used for longer lived parse states
\ such as what the current scripting language is in an ASP page. Use SCI_SETLINESTATE
\ to set the integer value and SCI_GETLINESTATE to get the value.
:M SetLineState:  ( line value -- )
                swap SCI_SETLINESTATE SendMessage:Self drop ;M

:M GetLineState:  ( line -- value )
                0 swap SCI_GETLINESTATE SendMessage:Self ;M

\ This returns the last line that has any line state.
:M GetMaxLineState:  ( -- value )
                0 0 SCI_GETMAXLINESTATE SendMessage:Self ;M


\ -----------------------------------------------------------------------------
\ Style definition
\ -----------------------------------------------------------------------------

:M StyleSetFont:  ( styleNumber fontName -- )
                swap SCI_STYLESETFONT SendMessage:Self drop ;M

:M SetFont:	{ TheFont -- }
		STYLE_DEFAULT GetFaceName: TheFont asciiz StyleSetFont: self
		GetDC: self >r
		LOGPIXELSY r@ Call GetDeviceCaps >r
		GetHeight: TheFont 72 *  r> / abs STYLE_DEFAULT SCI_STYLESETSIZE SendMessage:SelfDrop
		GetWeight: TheFont 700 = STYLE_DEFAULT SCI_STYLESETBOLD SendMessage:SelfDrop
		GetItalic: TheFont STYLE_DEFAULT SCI_STYLESETITALIC SendMessage:SelfDrop
		r> ReleaseDc: self ;M

\ -----------------------------------------------------------------------------
\ Popup edit menu
\ -----------------------------------------------------------------------------

\ Clicking the wrong button on the mouse pops up a short default editing menu.
\ This may be turned off with SCI_USEPOPUP(0). If you turn it off, context menu
\ commands (in Windows, WM_CONTEXTMENU) will not be handled by Scintilla, so the
\ parent of the Scintilla window will have the opportunity to handle the message.
:M UsePopUp:  	( flag -- )
                0 swap SCI_USEPOPUP SendMessage:Self drop ;M

\ -----------------------------------------------------------------------------
\ Lexer
\ -----------------------------------------------------------------------------

\ You can select the lexer to use with an integer code from the SCLEX_*
\ enumeration in Scintilla.h. There are two codes in this sequence that do not
\ use lexers: SCLEX_NULL to select no lexing action and SCLEX_CONTAINER which
\ sends the SCN_STYLENEEDED notification to the container whenever a range of
\ text needs to be styled. You cannot use the SCLEX_AUTOMATIC value; this
\ identifies additional external lexers that Scintilla assigns unused lexer
\ numbers to.
:M SetLexer:    ( lexer -- )
                0 swap SCI_SETLEXER SendMessage:Self drop ;M

:M GetLexer:    ( -- lexer )
                0 0 SCI_GETLEXER SendMessage:Self ;M

\ You can set up to 9 lists of keywords for use by the current lexer. keyWordSet
\ can be 0 to 8 (actually 0 to KEYWORDSET_MAX) and selects which keyword list to
\ replace. keyWordList is a list of keywords separated by spaces, tabs, "\n" or
\ "\r" or any combination of these. It is expected that the keywords will be
\ composed of standard ASCII printing characters, but there is nothing to stop
\ you using any non-separator character codes from 1 to 255 (except common sense).

:M SetKeyWords: ( keyWordSet keyWordList -- )
                swap SCI_SETKEYWORDS SendMessage:Self drop ;M

\ This forces the current lexer or the container (if the lexer is set to
\ SCLEX_CONTAINER) to style the document between startPos and endPos. If endPos
\ is -1, the document is styled from startPos to the end. If the "fold" property
\ is set to "1" and your lexer or container supports folding, fold levels are
\ also set. This message causes a redraw.
:M Colourise:   ( startPos endPos -- )
                IDC_WAIT NULL call LoadCursor call SetCursor >r \ set wait cursor
                swap SCI_COLOURISE SendMessage:Self drop
                r> call SetCursor drop   \ restore cursor
		;M

\ -----------------------------------------------------------------------------
\  Margins
\
\ There may be up to three margins to the left of the text display, plus a gap
\ either side of the text. Each margin can be set to display either symbols or
\ line numbers with SCI_SETMARGINTYPEN. The markers that can be displayed in each
\ margin are set with SCI_SETMARGINMASKN. Any markers not associated with a visible
\ margin will be displayed as changes in background colour in the text. A width
\ in pixels can be set for each margin. Margins with a zero width are ignored
\ completely. You can choose if a mouse click in a margin sends a SCN_MARGINCLICK
\ notification to the container or selects a line of text.
\ -----------------------------------------------------------------------------

\ Margin 0 will be set for displaying of line numbers
:M ShowLineNumbers:	( -- )
	SC_MARGIN_NUMBER 0 SCI_SETMARGINTYPEN SendMessage:Self	drop
	z" 99999" STYLE_DEFAULT SCI_TEXTWIDTH SendMessage:Self	\ get width required
	0 SCI_SETMARGINWIDTHN SendMessage:Self drop ;M  \ set width of line number margin

:M HideLineNumbers:	( -- )
	0 0 SCI_SETMARGINWIDTHN SendMessage:Self drop ;M

\ -----------------------------------------------------------------------------
\  Keyboard commands
\
\ To allow the container application to perform any of the actions available to
\ the user with keyboard, all the keyboard actions are messages. They do not take
\ any parameters.
\
\ See: ..\..\doc\ScintillaDoc.html#KeyboardCommands for a complete List of the
\ keyboard commands
\ -----------------------------------------------------------------------------

\ Execute a Keyboard command
:M KeyCommand:	( n -- )
	0 0 rot SendMessage:Self drop ;M

\ -----------------------------------------------------------------------------
\ Line wrapping
\ By default, Scintilla does not wrap lines of text. If you enable line wrapping,
\ lines wider than the window width are continued on the following lines. Lines are
\ broken after space or tab characters or between runs of different styles. If this
\ is not possible because a word in one style is wider than the window then the break
\ occurs after the last character that completely fits on the line. The horizontal
\ scroll bar does not appear when wrap mode is on.
\
\ For wrapped lines Scintilla can draw visual flags (little arrows) at end of a a
\ subline of a wrapped line and at begin of the next subline. These can be enabled
\ individually, but if Scintilla draws the visual flag at begin of the next subline
\ this subline will be indented by one char. Independent from drawing a visual flag
\ at the begin the subline can have an indention.
\
\ Much of the time used by Scintilla is spent on laying out and drawing text. The
\ same text layout calculations may be performed many times even when the data used
\ in these calculations does not change. To avoid these unnecessary calculations in
\ some circumstances, the line layout cache can store the results of the calculations.
\ The cache is invalidated whenever the underlying data, such as the contents or styling
\ of the document changes. Caching the layout of the whole document has the most effect,
\ making dynamic line wrap as much as 20 times faster but this requires 7 times the
\ memory required by the document contents plus around 80 bytes per line.
\
\ Wrapping is not performed immediately there is a change but is delayed until the display
\ is redrawn. This delay improves peformance by allowing a set of changes to be performed
\ and then wrapped and displayed once. Because of this, some operations may not occur as
\ expected. If a file is read and the scroll position moved to a particular line in the
\ text, such as occurs when a container tries to restore a previous editing session, then
\ the scroll position will have been determined before wrapping so an unexpected range of
\ text will be displayed. To scroll to the position correctly, delay the scroll until the
\ wrapping has been performed by waiting for an initial SCN_PAINTED notification.
\ -----------------------------------------------------------------------------

\ Set wrapMode to SC_WRAP_WORD (1) to enable line wrapping and to SC_WRAP_NONE (0) to
\ disable line wrapping.
:M SetWrapMode: ( wrapMode -- )
                0 swap SCI_SETWRAPMODE SendMessage:Self drop ;M

:M GetWrapMode: ( -- wrapMode )
                0 0 SCI_GETWRAPMODE SendMessage:Self  ;M

\ You can enable the drawing of visual flags to indicate a line is wrapped. Bits set
\ in wrapVisualFlags determine which visual flags are drawn. Symbol Value Effect
\ SC_WRAPVISUALFLAG_NONE  0 No visual flags
\ SC_WRAPVISUALFLAG_END   1 Visual flag at end of subline of a wrapped line.
\ SC_WRAPVISUALFLAG_START 2 Visual flag at begin of subline of a wrapped line.
\ Subline is indented by at least 1 to make room for the flag.
:M SetWrapVisualFlags: ( wrapVisualFlags -- )
                0 swap SCI_SETWRAPVISUALFLAGS SendMessage:Self  ;M

:M getWrapVisualFlags: ( -- wrapVisualFlags )
                0 0 SCI_GETWRAPVISUALFLAGS SendMessage:Self drop ;M

\ You can set wether the visual flags to indicate a line is wrapped are drawn near
\ the border or near the text. Bits set in wrapVisualFlagsLocation set the location
\ to near the text for the corresponding visual flag. Symbol Value Effect
\ SC_WRAPVISUALFLAGLOC_DEFAULT       0 Visual flags drawn near border
\ SC_WRAPVISUALFLAGLOC_END_BY_TEXT   1 Visual flag at end of subline drawn near text
\ SC_WRAPVISUALFLAGLOC_START_BY_TEXT 2 Visual flag at begin of subline drawn near text
:M SetWrapVisualFlagsLocation: ( wrapVisualFlagsLocation -- )
                0 swap SCI_SETWRAPVISUALFLAGSLOCATION SendMessage:Self  ;M

:M getWrapVisualFlagsLocation: ( -- wrapVisualFlagsLocation )
                0 0 SCI_GETWRAPVISUALFLAGSLOCATION SendMessage:Self drop ;M

\ SCI_SETWRAPSTARTINDENT sets the size of indentation of sublines for wrapped lines
\ in terms of the width of a space in STYLE_DEFAULT. There are no limits on indent
\ sizes, but values less than 0 or large values may have undesirable effects.
\ The indention of sublines is independent of visual flags, but if SC_WRAPVISUALFLAG_START
\ is set an indent of at least 1 is used.
:M SetWrapStartIdent: ( indent -- )
                0 swap SCI_SETWRAPSTARTINDENT SendMessage:Self  ;M

:M getWrapStartIdent: ( -- indent )
                0 0 SCI_GETWRAPSTARTINDENT SendMessage:Self drop ;M

\ You can set cacheMode to one of the symbols in the table:
\ Symbol Value Layout cached for these lines
\ SC_CACHE_NONE     0 No lines are cached.
\ SC_CACHE_CARET    1 The line containing the text caret. This is the default.
\ SC_CACHE_PAGE     2 Visible lines plus the line containing the caret.
\ SC_CACHE_DOCUMENT 3 All lines in the document.
:M SetLayoutCache: ( cacheMode -- )
                0 swap SCI_SETLAYOUTCACHE SendMessage:Self  ;M

:M GetLayoutCache: ( -- cacheMode )
                0 0 SCI_GETLAYOUTCACHE SendMessage:Self drop ;M

\ Split a range of lines indicated by the target into lines that are at most
\ pixelWidth wide. Splitting occurs on word boundaries wherever possible in a
\ similar manner to line wrapping. When pixelWidth is 0 then the width of the
\ window is used.
:M LineSplit:	( pixelWidth -- )
                0 swap SCI_LINESSPLIT SendMessage:Self  ;M

\ Join a range of lines indicated by the target into one line by removing line
\ end characters. Where this would lead to no space between words, an extra space
\ is inserted.
:M LinesJoin:	( -- )
                0 0 SCI_LINESJOIN SendMessage:Self  ;M


\ -----------------------------------------------------------------------------
\ Tabs
\ -----------------------------------------------------------------------------

\ SCI_SETTABWIDTH sets the size of a tab as a multiple of the size of a space
\ character in STYLE_DEFAULT. The default tab width is 8 characters. There are
\ no limits on tab sizes, but values less than 1 or large values may have undesirable
\ effects.
:M SetTabWidth:	( widthInChars -- )
                0 swap SCI_SETTABWIDTH SendMessage:Self drop ;M

:M GetTabWidth:	( -- widthInChars )
                0 0 SCI_GETTABWIDTH SendMessage:Self ;M

\ SCI_SETUSETABS determines whether indentation should be created out of a mixture
\ of tabs and spaces or be based purely on spaces. Set useTabs to false (0) to create
\ all tabs and indents out of spaces. The default is true. You can use SCI_GETCOLUMN
\ to get the column of a position taking the width of a tab into account.
:M SetUseTabs:	( useTabs -- )
                0 swap SCI_SETUSETABS SendMessage:Self drop ;M

:M GetUseTabs:	( -- useTabs )
                0 0 SCI_GETUSETABS SendMessage:Self ;M


\ -----------------------------------------------------------------------------
\ Printing
\ -----------------------------------------------------------------------------

Record: RangeToFormat
    int hdcPrinter
    int hdcTarget
    rectangle Pagesize
    rectangle rcPage
    int cpMin         \ CharacterRange
    int cpMax
;Record

:M FormatRange: ( f -- n )   RangeToFormat swap SCI_FORMATRANGE SendMessage:Self ;M

\ assume PSD_INTHOUSANDTHSOFINCHES used in PageSetup
: Xpixels ( n -- n )   DPI: ThePrinter drop 1000 */ ;
: Ypixels ( n -- n )   DPI: ThePrinter nip 1000 */ ;
\ if PSD_INHUNDREDTHSOFMILLIMETERS used replace 1000 with 2540

: SetFormatRange ( -- )
        GetHandle: ThePrinter dup to hdcPrinter to hdcTarget
        rtMargin @ Xpixels  rtMargin cell+ @ Ypixels
        Width: ThePrinter  rtMargin 2 cells+ @ Xpixels -
        Height: ThePrinter  rtMargin 3 cells+ @ Ypixels -
        SetRect: PageSize  EraseRect: rcPage
        0 to cpMin  GetTextLength: self to cpMax
        ;

:M Print: ( -- )
        hWnd  hwndOwner !
        1 nFromPage w!

\   Find number of pages needed to print the file using the default printer
        hDevMode 2@   \ save selected printer
        Auto-print-init  PutHandle: ThePrinter
        SetFormatRange
        SaveDC: ThePrinter
        ( PageNo ) 1
        BEGIN
            FALSE FormatRange: self to cpMin
            dup nMaxPage <  cpMin cpMax <  and
        WHILE  1+
        REPEAT  dup nToPage w! nMaxPage w!
        RestoreDC: ThePrinter
        print-close
        hDevMode 2!   \ restore selected printer
\   Number of pages is put into nToPage and nMaxPage

        false
        PD_HIDEPRINTTOFILE
        nToPage w@ print-init2  ?dup
        IF
            PutHandle: ThePrinter
\            FileName 1+ DocName !
            SetFormatRange
            Print-flags  PD_SELECTION and
            IF  GetSelectionStart: self to cpMin  GetSelectionEnd: self to cpMax  THEN
\            Print-flags  PD_CURRENTPAGE and
\            IF  GetFirstVisibleLine: self dup PositionFromLine: self to cpMin  LinesOnScreen: self + 1- PositionFromLine: self to cpMax  THEN
            SaveDC: ThePrinter
            print-start
            ( PageNo ) 1
            BEGIN
                dup  Get-frompage  Get-topage  between
                IF  start-page  TRUE FormatRange: self to cpMin  end-page
                ELSE  FALSE FormatRange: self to cpMin
                THEN
                dup nMaxPage <  cpMin cpMax <  and
            WHILE  1+
            REPEAT  drop ( last PageNo )
            print-end
            RestoreDC: ThePrinter
            print-close
        THEN
        ;M

:M WM_TIMER  	{ h m w l -- res } \ override so we can get a flashing cursor in scintilla control
                old-WndProc
                IF      h m w l old-WndProc CallWindowProc
                ELSE	0
                THEN	;M

:M On_MouseMove: { h m w -- }
                w MK_LBUTTON and        \ click and dragging?
                if   SelectionMode SetSelectionMode: self
                then    ;M

;Class

INTERNAL

0 value hLibScintilla

EXTERNAL

: InitScintillaControl ( -- ) \ Init the Scintilla Control, must be called once at startup
                hLibScintilla 0=
                if  z" w32fScintilla.dll" Call LoadLibrary dup to hLibScintilla
                    NULL = Abort" w32fScintilla.dll not found"
                then ;

: ExitScintillaControl ( -- ) \ Deinit the Scintilla Control, must be called once at exit
                hLibScintilla
		if   hLibScintilla Call FreeLibrary drop
		     0 to hLibScintilla
		then ;

MODULE

