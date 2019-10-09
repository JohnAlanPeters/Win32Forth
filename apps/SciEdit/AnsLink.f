\ $Id: AnsLink.f,v 1.2 2005/06/02 21:14:54 alex_mcdonald Exp $

anew -AnsLink.f

internal

\ ------------------------------------------------------------------------
\ Create a table with all ANS-FORTH words
\ ------------------------------------------------------------------------

: CREATE-HTML-LINK-TABLE ( -- )
	create ;

: ANS-TABLE-ENTRY	 ( word filename label -- addr len )
	BL WORD COUNT ",
	BL WORD COUNT ",
	BL WORD COUNT ", ;

: CLOSE-HTML-LINK-TABLE	 ( -- )
	0 , ;

CREATE-HTML-LINK-TABLE ANS-WORDS

(               NAME                FILENAME        REFERENCE )
(               ------------------  -----------     --------- )
ANS-TABLE-ENTRY ."                  dpans6.htm      6.1.0190
ANS-TABLE-ENTRY :                   dpans6.htm      6.1.0450
ANS-TABLE-ENTRY ;                   dpans6.htm      6.1.0460
ANS-TABLE-ENTRY ABORT"              dpans6.htm      6.1.0680
ANS-TABLE-ENTRY CHAR                dpans6.htm      6.1.0895
ANS-TABLE-ENTRY CONSTANT            dpans6.htm      6.1.0950
ANS-TABLE-ENTRY CREATE              dpans6.htm      6.1.1000
ANS-TABLE-ENTRY DECIMAL             dpans6.htm      6.1.1170
ANS-TABLE-ENTRY S"                  dpans6.htm      6.1.2165
ANS-TABLE-ENTRY VARIABLE            dpans6.htm      6.1.2410
ANS-TABLE-ENTRY [                   dpans6.htm      6.1.2500
ANS-TABLE-ENTRY [']                 dpans6.htm      6.1.2510
ANS-TABLE-ENTRY [CHAR]              dpans6.htm      6.1.2520
ANS-TABLE-ENTRY ]                   dpans6.htm      6.1.2540
ANS-TABLE-ENTRY C"                  dpans6.htm      6.2.0855
ANS-TABLE-ENTRY FALSE               dpans6.htm      6.2.1485
ANS-TABLE-ENTRY HEX                 dpans6.htm      6.2.1660
ANS-TABLE-ENTRY MARKER              dpans6.htm      6.2.1850
ANS-TABLE-ENTRY VALUE               dpans6.htm      6.2.2405
ANS-TABLE-ENTRY 2CONSTANT           dpans8.htm      8.6.1.0360
ANS-TABLE-ENTRY 2VARIABLE           dpans8.htm      8.6.1.0440
ANS-TABLE-ENTRY INCLUDED            dpans11.htm     11.6.1.1718
ANS-TABLE-ENTRY FCONSTANT           dpans12.htm     12.6.1.1492
ANS-TABLE-ENTRY FVARIABLE           dpans12.htm     12.6.1.1630
ANS-TABLE-ENTRY ;CODE               dpans15.htm     15.6.2.0470
ANS-TABLE-ENTRY CODE                dpans15.htm     15.6.2.0930
ANS-TABLE-ENTRY [IF]                dpans15.htm     15.6.2.2532
ANS-TABLE-ENTRY LOCALS|             dpans13.htm     13.6.2.1795
ANS-TABLE-ENTRY |                   dpans13.htm     13.6.2.1795
ANS-TABLE-ENTRY BL                  dpans6.htm      6.1.0770
ANS-TABLE-ENTRY WORD                dpans6.htm      6.1.2450
ANS-TABLE-ENTRY PARSE               dpans6.htm      6.2.2008
ANS-TABLE-ENTRY !                   dpans6.htm      6.1.0010
ANS-TABLE-ENTRY #                   dpans6.htm      6.1.0030
ANS-TABLE-ENTRY #>                  dpans6.htm      6.1.0040
ANS-TABLE-ENTRY #S                  dpans6.htm      6.1.0050
ANS-TABLE-ENTRY '                   dpans6.htm      6.1.0070
ANS-TABLE-ENTRY *                   dpans6.htm      6.1.0090
ANS-TABLE-ENTRY */                  dpans6.htm      6.1.0100
ANS-TABLE-ENTRY */MOD               dpans6.htm      6.1.0110
ANS-TABLE-ENTRY +                   dpans6.htm      6.1.0120
ANS-TABLE-ENTRY +!                  dpans6.htm      6.1.0130
ANS-TABLE-ENTRY +LOOP               dpans6.htm      6.1.0140
ANS-TABLE-ENTRY ,                   dpans6.htm      6.1.0150
ANS-TABLE-ENTRY -                   dpans6.htm      6.1.0160
ANS-TABLE-ENTRY .                   dpans6.htm      6.1.0180
ANS-TABLE-ENTRY /                   dpans6.htm      6.1.0230
ANS-TABLE-ENTRY /MOD                dpans6.htm      6.1.0240
ANS-TABLE-ENTRY 0<                  dpans6.htm      6.1.0250
ANS-TABLE-ENTRY 0=                  dpans6.htm      6.1.0270
ANS-TABLE-ENTRY 1+                  dpans6.htm      6.1.0290
ANS-TABLE-ENTRY 1-                  dpans6.htm      6.1.0300
ANS-TABLE-ENTRY 2!                  dpans6.htm      6.1.0310
ANS-TABLE-ENTRY 2*                  dpans6.htm      6.1.0320
ANS-TABLE-ENTRY 2/                  dpans6.htm      6.1.0330
ANS-TABLE-ENTRY 2@                  dpans6.htm      6.1.0350
ANS-TABLE-ENTRY 2DROP               dpans6.htm      6.1.0370
ANS-TABLE-ENTRY 2DUP                dpans6.htm      6.1.0380
ANS-TABLE-ENTRY 2OVER               dpans6.htm      6.1.0400
ANS-TABLE-ENTRY 2SWAP               dpans6.htm      6.1.0430
ANS-TABLE-ENTRY <                   dpans6.htm      6.1.0480
ANS-TABLE-ENTRY <#                  dpans6.htm      6.1.0490
ANS-TABLE-ENTRY =                   dpans6.htm      6.1.0530
ANS-TABLE-ENTRY >                   dpans6.htm      6.1.0540
ANS-TABLE-ENTRY >BODY               dpans6.htm      6.1.0550
ANS-TABLE-ENTRY >IN                 dpans6.htm      6.1.0560
ANS-TABLE-ENTRY >NUMBER             dpans6.htm      6.1.0570
ANS-TABLE-ENTRY >R                  dpans6.htm      6.1.0580
ANS-TABLE-ENTRY ?DUP                dpans6.htm      6.1.0630
ANS-TABLE-ENTRY @                   dpans6.htm      6.1.0650
ANS-TABLE-ENTRY ABORT               dpans6.htm      6.1.0670
ANS-TABLE-ENTRY ABS                 dpans6.htm      6.1.0690
ANS-TABLE-ENTRY ACCEPT              dpans6.htm      6.1.0695
ANS-TABLE-ENTRY ALIGN               dpans6.htm      6.1.0705
ANS-TABLE-ENTRY ALIGNED             dpans6.htm      6.1.0706
ANS-TABLE-ENTRY ALLOT               dpans6.htm      6.1.0710
ANS-TABLE-ENTRY AND                 dpans6.htm      6.1.0720
ANS-TABLE-ENTRY BASE                dpans6.htm      6.1.0750
ANS-TABLE-ENTRY BEGIN               dpans6.htm      6.1.0760
ANS-TABLE-ENTRY C!                  dpans6.htm      6.1.0850
ANS-TABLE-ENTRY C,                  dpans6.htm      6.1.0860
ANS-TABLE-ENTRY C@                  dpans6.htm      6.1.0870
ANS-TABLE-ENTRY CELL+               dpans6.htm      6.1.0880
ANS-TABLE-ENTRY CELLS               dpans6.htm      6.1.0890
ANS-TABLE-ENTRY CHAR+               dpans6.htm      6.1.0897
ANS-TABLE-ENTRY CHARS               dpans6.htm      6.1.0898
ANS-TABLE-ENTRY COUNT               dpans6.htm      6.1.0980
ANS-TABLE-ENTRY CR                  dpans6.htm      6.1.0990
ANS-TABLE-ENTRY DEPTH               dpans6.htm      6.1.1200
ANS-TABLE-ENTRY DO                  dpans6.htm      6.1.1240
ANS-TABLE-ENTRY DOES>               dpans6.htm      6.1.1250
ANS-TABLE-ENTRY DROP                dpans6.htm      6.1.1260
ANS-TABLE-ENTRY DUP                 dpans6.htm      6.1.1290
ANS-TABLE-ENTRY ELSE                dpans6.htm      6.1.1310
ANS-TABLE-ENTRY EMIT                dpans6.htm      6.1.1320
ANS-TABLE-ENTRY ENVIRONMENT?        dpans6.htm      6.1.1345
ANS-TABLE-ENTRY EVALUATE            dpans6.htm      6.1.1360
ANS-TABLE-ENTRY EXECUTE             dpans6.htm      6.1.1370
ANS-TABLE-ENTRY EXIT                dpans6.htm      6.1.1380
ANS-TABLE-ENTRY FILL                dpans6.htm      6.1.1540
ANS-TABLE-ENTRY FIND                dpans6.htm      6.1.1550
ANS-TABLE-ENTRY FM/MOD              dpans6.htm      6.1.1561
ANS-TABLE-ENTRY HERE                dpans6.htm      6.1.1650
ANS-TABLE-ENTRY HOLD                dpans6.htm      6.1.1670
ANS-TABLE-ENTRY I                   dpans6.htm      6.1.1680
ANS-TABLE-ENTRY IF                  dpans6.htm      6.1.1700
ANS-TABLE-ENTRY IMMEDIATE           dpans6.htm      6.1.1710
ANS-TABLE-ENTRY INVERT              dpans6.htm      6.1.1720
ANS-TABLE-ENTRY J                   dpans6.htm      6.1.1730
ANS-TABLE-ENTRY KEY                 dpans6.htm      6.1.1750
ANS-TABLE-ENTRY LEAVE               dpans6.htm      6.1.1760
ANS-TABLE-ENTRY LITERAL             dpans6.htm      6.1.1780
ANS-TABLE-ENTRY LOOP                dpans6.htm      6.1.1800
ANS-TABLE-ENTRY LSHIFT              dpans6.htm      6.1.1805
ANS-TABLE-ENTRY M*                  dpans6.htm      6.1.1810
ANS-TABLE-ENTRY MAX                 dpans6.htm      6.1.1870
ANS-TABLE-ENTRY MIN                 dpans6.htm      6.1.1880
ANS-TABLE-ENTRY MOD                 dpans6.htm      6.1.1890
ANS-TABLE-ENTRY MOVE                dpans6.htm      6.1.1900
ANS-TABLE-ENTRY NEGATE              dpans6.htm      6.1.1910
ANS-TABLE-ENTRY OR                  dpans6.htm      6.1.1980
ANS-TABLE-ENTRY OVER                dpans6.htm      6.1.1990
ANS-TABLE-ENTRY POSTPONE            dpans6.htm      6.1.2033
ANS-TABLE-ENTRY QUIT                dpans6.htm      6.1.2050
ANS-TABLE-ENTRY R>                  dpans6.htm      6.1.2060
ANS-TABLE-ENTRY R@                  dpans6.htm      6.1.2070
ANS-TABLE-ENTRY RECURSE             dpans6.htm      6.1.2120
ANS-TABLE-ENTRY REPEAT              dpans6.htm      6.1.2140
ANS-TABLE-ENTRY ROT                 dpans6.htm      6.1.2160
ANS-TABLE-ENTRY RSHIFT              dpans6.htm      6.1.2162
ANS-TABLE-ENTRY S>D                 dpans6.htm      6.1.2170
ANS-TABLE-ENTRY SIGN                dpans6.htm      6.1.2210
ANS-TABLE-ENTRY SM/REM              dpans6.htm      6.1.2214
ANS-TABLE-ENTRY SOURCE              dpans6.htm      6.1.2216
ANS-TABLE-ENTRY SPACE               dpans6.htm      6.1.2220
ANS-TABLE-ENTRY SPACES              dpans6.htm      6.1.2230
ANS-TABLE-ENTRY STATE               dpans6.htm      6.1.2250
ANS-TABLE-ENTRY SWAP                dpans6.htm      6.1.2260
ANS-TABLE-ENTRY THEN                dpans6.htm      6.1.2270
ANS-TABLE-ENTRY TYPE                dpans6.htm      6.1.2310
ANS-TABLE-ENTRY U.                  dpans6.htm      6.1.2320
ANS-TABLE-ENTRY U<                  dpans6.htm      6.1.2340
ANS-TABLE-ENTRY UM*                 dpans6.htm      6.1.2360
ANS-TABLE-ENTRY UM/MOD              dpans6.htm      6.1.2370
ANS-TABLE-ENTRY UNLOOP              dpans6.htm      6.1.2380
ANS-TABLE-ENTRY UNTIL               dpans6.htm      6.1.2390
ANS-TABLE-ENTRY WHILE               dpans6.htm      6.1.2430
ANS-TABLE-ENTRY XOR                 dpans6.htm      6.1.2490
ANS-TABLE-ENTRY #TIB                dpans6.htm      6.2.0060
ANS-TABLE-ENTRY .R                  dpans6.htm      6.2.0210
ANS-TABLE-ENTRY 0<>                 dpans6.htm      6.2.0260
ANS-TABLE-ENTRY 0>                  dpans6.htm      6.2.0280
ANS-TABLE-ENTRY 2>R                 dpans6.htm      6.2.0340
ANS-TABLE-ENTRY 2R>                 dpans6.htm      6.2.0410
ANS-TABLE-ENTRY 2R@                 dpans6.htm      6.2.0415
ANS-TABLE-ENTRY :NONAME             dpans6.htm      6.2.0455
ANS-TABLE-ENTRY <>                  dpans6.htm      6.2.0500
ANS-TABLE-ENTRY ?DO                 dpans6.htm      6.2.0620
ANS-TABLE-ENTRY AGAIN               dpans6.htm      6.2.0700
ANS-TABLE-ENTRY CASE                dpans6.htm      6.2.0873
ANS-TABLE-ENTRY COMPILE,            dpans6.htm      6.2.0945
ANS-TABLE-ENTRY CONVERT             dpans6.htm      6.2.0970
ANS-TABLE-ENTRY ENDCASE             dpans6.htm      6.2.1342
ANS-TABLE-ENTRY ENDOF               dpans6.htm      6.2.1343
ANS-TABLE-ENTRY ERASE               dpans6.htm      6.2.1350
ANS-TABLE-ENTRY EXPECT              dpans6.htm      6.2.1390
ANS-TABLE-ENTRY NIP                 dpans6.htm      6.2.1930
ANS-TABLE-ENTRY OF                  dpans6.htm      6.2.1950
ANS-TABLE-ENTRY PAD                 dpans6.htm      6.2.2000
ANS-TABLE-ENTRY PICK                dpans6.htm      6.2.2030
ANS-TABLE-ENTRY QUERY               dpans6.htm      6.2.2040
ANS-TABLE-ENTRY REFILL              dpans6.htm      6.2.2125
ANS-TABLE-ENTRY RESTORE-INPUT       dpans6.htm      6.2.2148
ANS-TABLE-ENTRY ROLL                dpans6.htm      6.2.2150
ANS-TABLE-ENTRY SAVE-INPUT          dpans6.htm      6.2.2182
ANS-TABLE-ENTRY SOURCE-ID           dpans6.htm      6.2.2218
ANS-TABLE-ENTRY SPAN                dpans6.htm      6.2.2240
ANS-TABLE-ENTRY TIB                 dpans6.htm      6.2.2290
ANS-TABLE-ENTRY TO                  dpans6.htm      6.2.2295
ANS-TABLE-ENTRY TRUE                dpans6.htm      6.2.2298
ANS-TABLE-ENTRY TUCK                dpans6.htm      6.2.2300
ANS-TABLE-ENTRY U.R                 dpans6.htm      6.2.2330
ANS-TABLE-ENTRY U>                  dpans6.htm      6.2.2350
ANS-TABLE-ENTRY UNUSED              dpans6.htm      6.2.2395
ANS-TABLE-ENTRY WITHIN              dpans6.htm      6.2.2440
ANS-TABLE-ENTRY [COMPILE]           dpans6.htm      6.2.2530
ANS-TABLE-ENTRY BLK                 dpans7.htm      7.6.1.0790
ANS-TABLE-ENTRY BLOCK               dpans7.htm      7.6.1.0800
ANS-TABLE-ENTRY BUFFER              dpans7.htm      7.6.1.0820
ANS-TABLE-ENTRY FLUSH               dpans7.htm      7.6.1.1559
ANS-TABLE-ENTRY LOAD                dpans7.htm      7.6.1.1790
ANS-TABLE-ENTRY SAVE-BUFFERS        dpans7.htm      7.6.1.2180
ANS-TABLE-ENTRY UPDATE              dpans7.htm      7.6.1.2400
ANS-TABLE-ENTRY EMPTY-BUFFERS       dpans7.htm      7.6.2.1330
ANS-TABLE-ENTRY LIST                dpans7.htm      7.6.2.1770
ANS-TABLE-ENTRY SCR                 dpans7.htm      7.6.2.2190
ANS-TABLE-ENTRY THRU                dpans7.htm      7.6.2.2280
ANS-TABLE-ENTRY 2LITERAL            dpans8.htm      8.6.1.0390
ANS-TABLE-ENTRY D+                  dpans8.htm      8.6.1.1040
ANS-TABLE-ENTRY D-                  dpans8.htm      8.6.1.1050
ANS-TABLE-ENTRY D.                  dpans8.htm      8.6.1.1060
ANS-TABLE-ENTRY D.R                 dpans8.htm      8.6.1.1070
ANS-TABLE-ENTRY D0<                 dpans8.htm      8.6.1.1075
ANS-TABLE-ENTRY D0=                 dpans8.htm      8.6.1.1080
ANS-TABLE-ENTRY D2*                 dpans8.htm      8.6.1.1090
ANS-TABLE-ENTRY D2/                 dpans8.htm      8.6.1.1100
ANS-TABLE-ENTRY D<                  dpans8.htm      8.6.1.1110
ANS-TABLE-ENTRY D=                  dpans8.htm      8.6.1.1120
ANS-TABLE-ENTRY D>S                 dpans8.htm      8.6.1.1140
ANS-TABLE-ENTRY DABS                dpans8.htm      8.6.1.1160
ANS-TABLE-ENTRY DMAX                dpans8.htm      8.6.1.1210
ANS-TABLE-ENTRY DMIN                dpans8.htm      8.6.1.1220
ANS-TABLE-ENTRY DNEGATE             dpans8.htm      8.6.1.1230
ANS-TABLE-ENTRY M*/                 dpans8.htm      8.6.1.1820
ANS-TABLE-ENTRY M+                  dpans8.htm      8.6.1.1830
ANS-TABLE-ENTRY 2ROT                dpans8.htm      8.6.2.0420
ANS-TABLE-ENTRY DU<                 dpans8.htm      8.6.2.1270
ANS-TABLE-ENTRY CATCH               dpans9.htm      9.6.1.0875
ANS-TABLE-ENTRY THROW               dpans9.htm      9.6.1.2275
ANS-TABLE-ENTRY AT-XY               dpans10.htm     10.6.1.0742
ANS-TABLE-ENTRY KEY?                dpans10.htm     10.6.1.1755
ANS-TABLE-ENTRY PAGE                dpans10.htm     10.6.1.2005
ANS-TABLE-ENTRY EKEY                dpans10.htm     10.6.2.1305
ANS-TABLE-ENTRY EKEY>CHAR           dpans10.htm     10.6.2.1306
ANS-TABLE-ENTRY EKEY?               dpans10.htm     10.6.2.1307
ANS-TABLE-ENTRY EMIT?               dpans10.htm     10.6.2.1325
ANS-TABLE-ENTRY MS                  dpans10.htm     10.6.2.1905
ANS-TABLE-ENTRY TIME&DATE           dpans10.htm     10.6.2.2292
ANS-TABLE-ENTRY BIN                 dpans11.htm     11.6.1.0765
ANS-TABLE-ENTRY CLOSE-FILE          dpans11.htm     11.6.1.0900
ANS-TABLE-ENTRY CREATE-FILE         dpans11.htm     11.6.1.1010
ANS-TABLE-ENTRY DELETE-FILE         dpans11.htm     11.6.1.1190
ANS-TABLE-ENTRY FILE-POSITION       dpans11.htm     11.6.1.1520
ANS-TABLE-ENTRY FILE-SIZE           dpans11.htm     11.6.1.1522
ANS-TABLE-ENTRY INCLUDE-FILE        dpans11.htm     11.6.1.1717
ANS-TABLE-ENTRY OPEN-FILE           dpans11.htm     11.6.1.1970
ANS-TABLE-ENTRY R/O                 dpans11.htm     11.6.1.2054
ANS-TABLE-ENTRY R/W                 dpans11.htm     11.6.1.2056
ANS-TABLE-ENTRY READ-FILE           dpans11.htm     11.6.1.2080
ANS-TABLE-ENTRY READ-LINE           dpans11.htm     11.6.1.2090
ANS-TABLE-ENTRY REPOSITION-FILE     dpans11.htm     11.6.1.2142
ANS-TABLE-ENTRY RESIZE-FILE         dpans11.htm     11.6.1.2147
ANS-TABLE-ENTRY W/O                 dpans11.htm     11.6.1.2425
ANS-TABLE-ENTRY WRITE-FILE          dpans11.htm     11.6.1.2480
ANS-TABLE-ENTRY WRITE-LINE          dpans11.htm     11.6.1.2485
ANS-TABLE-ENTRY FILE-STATUS         dpans11.htm     11.6.2.1524
ANS-TABLE-ENTRY FLUSH-FILE          dpans11.htm     11.6.2.1560
ANS-TABLE-ENTRY RENAME-FILE         dpans11.htm     11.6.2.2130
ANS-TABLE-ENTRY >FLOAT              dpans12.htm     12.6.1.0558
ANS-TABLE-ENTRY D>F                 dpans12.htm     12.6.1.1130
ANS-TABLE-ENTRY F!                  dpans12.htm     12.6.1.1400
ANS-TABLE-ENTRY F*                  dpans12.htm     12.6.1.1410
ANS-TABLE-ENTRY F+                  dpans12.htm     12.6.1.1420
ANS-TABLE-ENTRY F-                  dpans12.htm     12.6.1.1425
ANS-TABLE-ENTRY F/                  dpans12.htm     12.6.1.1430
ANS-TABLE-ENTRY F0<                 dpans12.htm     12.6.1.1440
ANS-TABLE-ENTRY F0=                 dpans12.htm     12.6.1.1450
ANS-TABLE-ENTRY F<                  dpans12.htm     12.6.1.1460
ANS-TABLE-ENTRY F>D                 dpans12.htm     12.6.1.1460
ANS-TABLE-ENTRY F@                  dpans12.htm     12.6.1.1472
ANS-TABLE-ENTRY FALIGN              dpans12.htm     12.6.1.1479
ANS-TABLE-ENTRY FALIGNED            dpans12.htm     12.6.1.1483
ANS-TABLE-ENTRY FDEPTH              dpans12.htm     12.6.1.1497
ANS-TABLE-ENTRY FDROP               dpans12.htm     12.6.1.1500
ANS-TABLE-ENTRY FDUP                dpans12.htm     12.6.1.1510
ANS-TABLE-ENTRY FLITERAL            dpans12.htm     12.6.1.1552
ANS-TABLE-ENTRY FLOAT+              dpans12.htm     12.6.1.1555
ANS-TABLE-ENTRY FLOATS              dpans12.htm     12.6.1.1556
ANS-TABLE-ENTRY FLOOR               dpans12.htm     12.6.1.1558
ANS-TABLE-ENTRY FMAX                dpans12.htm     12.6.1.1562
ANS-TABLE-ENTRY FMIN                dpans12.htm     12.6.1.1565
ANS-TABLE-ENTRY FNEGATE             dpans12.htm     12.6.1.1567
ANS-TABLE-ENTRY FOVER               dpans12.htm     12.6.1.1600
ANS-TABLE-ENTRY FROT                dpans12.htm     12.6.1.1610
ANS-TABLE-ENTRY FROUND              dpans12.htm     12.6.1.1612
ANS-TABLE-ENTRY FSWAP               dpans12.htm     12.6.1.1620
ANS-TABLE-ENTRY REPRESENT           dpans12.htm     12.6.1.2143
ANS-TABLE-ENTRY DF!                 dpans12.htm     12.6.2.1203
ANS-TABLE-ENTRY DF@                 dpans12.htm     12.6.2.1204
ANS-TABLE-ENTRY DFALIGN             dpans12.htm     12.6.2.1205
ANS-TABLE-ENTRY DFALIGNED           dpans12.htm     12.6.2.1207
ANS-TABLE-ENTRY DFLOAT+             dpans12.htm     12.6.2.1208
ANS-TABLE-ENTRY DFLOATS             dpans12.htm     12.6.2.1209
ANS-TABLE-ENTRY F**                 dpans12.htm     12.6.2.1415
ANS-TABLE-ENTRY F.                  dpans12.htm     12.6.2.1427
ANS-TABLE-ENTRY FABS                dpans12.htm     12.6.2.1474
ANS-TABLE-ENTRY FACOS               dpans12.htm     12.6.2.1476
ANS-TABLE-ENTRY FACOSH              dpans12.htm     12.6.2.1477
ANS-TABLE-ENTRY FALOG               dpans12.htm     12.6.2.1484
ANS-TABLE-ENTRY FASIN               dpans12.htm     12.6.2.1486
ANS-TABLE-ENTRY FASINH              dpans12.htm     12.6.2.1487
ANS-TABLE-ENTRY FATAN               dpans12.htm     12.6.2.1488
ANS-TABLE-ENTRY FATAN2              dpans12.htm     12.6.2.1489
ANS-TABLE-ENTRY FATANH              dpans12.htm     12.6.2.1491
ANS-TABLE-ENTRY FCOS                dpans12.htm     12.6.2.1493
ANS-TABLE-ENTRY FCOSH               dpans12.htm     12.6.2.1494
ANS-TABLE-ENTRY FE.                 dpans12.htm     12.6.2.1513
ANS-TABLE-ENTRY FEXP                dpans12.htm     12.6.2.1515
ANS-TABLE-ENTRY FEXPM1              dpans12.htm     12.6.2.1516
ANS-TABLE-ENTRY FLN                 dpans12.htm     12.6.2.1553
ANS-TABLE-ENTRY FLNP1               dpans12.htm     12.6.2.1554
ANS-TABLE-ENTRY FLOG                dpans12.htm     12.6.2.1557
ANS-TABLE-ENTRY FS.                 dpans12.htm     12.6.2.1613
ANS-TABLE-ENTRY FSIN                dpans12.htm     12.6.2.1614
ANS-TABLE-ENTRY FSINCOS             dpans12.htm     12.6.2.1616
ANS-TABLE-ENTRY FSINH               dpans12.htm     12.6.2.1617
ANS-TABLE-ENTRY FSQRT               dpans12.htm     12.6.2.1618
ANS-TABLE-ENTRY FTAN                dpans12.htm     12.6.2.1625
ANS-TABLE-ENTRY FTANH               dpans12.htm     12.6.2.1626
ANS-TABLE-ENTRY F~                  dpans12.htm     12.6.2.1640
ANS-TABLE-ENTRY PRECISION           dpans12.htm     12.6.2.2035
ANS-TABLE-ENTRY SET-PRECISION       dpans12.htm     12.6.2.2200
ANS-TABLE-ENTRY SF!                 dpans12.htm     12.6.2.2202
ANS-TABLE-ENTRY SF@                 dpans12.htm     12.6.2.2203
ANS-TABLE-ENTRY SFALIGN             dpans12.htm     12.6.2.2204
ANS-TABLE-ENTRY SFALIGNED           dpans12.htm     12.6.2.2206
ANS-TABLE-ENTRY SFLOAT+             dpans12.htm     12.6.2.2207
ANS-TABLE-ENTRY SFLOATS             dpans12.htm     12.6.2.2208
ANS-TABLE-ENTRY (LOCAL)             dpans13.htm     13.6.1.0086
ANS-TABLE-ENTRY ALLOCATE            dpans14.htm     14.6.1.0707
ANS-TABLE-ENTRY FREE                dpans14.htm     14.6.1.1605
ANS-TABLE-ENTRY RESIZE              dpans14.htm     14.6.1.2145
ANS-TABLE-ENTRY .S                  dpans15.htm     15.6.1.0220
ANS-TABLE-ENTRY ?                   dpans15.htm     15.6.1.0600
ANS-TABLE-ENTRY DUMP                dpans15.htm     15.6.1.1280
ANS-TABLE-ENTRY SEE                 dpans15.htm     15.6.1.2194
ANS-TABLE-ENTRY WORDS               dpans15.htm     15.6.1.2465
ANS-TABLE-ENTRY AHEAD               dpans15.htm     15.6.2.0702
ANS-TABLE-ENTRY ASSEMBLER           dpans15.htm     15.6.2.0740
ANS-TABLE-ENTRY BYE                 dpans15.htm     15.6.2.0830
ANS-TABLE-ENTRY CS-PICK             dpans15.htm     15.6.2.1015
ANS-TABLE-ENTRY CS-ROLL             dpans15.htm     15.6.2.1020
ANS-TABLE-ENTRY EDITOR              dpans15.htm     15.6.2.1300
ANS-TABLE-ENTRY FORGET              dpans15.htm     15.6.2.1580
ANS-TABLE-ENTRY [ELSE]              dpans15.htm     15.6.2.2531
ANS-TABLE-ENTRY [THEN]              dpans15.htm     15.6.2.2533
ANS-TABLE-ENTRY DEFINITIONS         dpans16.htm     16.6.1.1180
ANS-TABLE-ENTRY FORTH-WORDLIST      dpans16.htm     16.6.1.1595
ANS-TABLE-ENTRY GET-CURRENT         dpans16.htm     16.6.1.1643
ANS-TABLE-ENTRY GET-ORDER           dpans16.htm     16.6.1.1647
ANS-TABLE-ENTRY SEARCH-WORDLIST     dpans16.htm     16.6.1.2192
ANS-TABLE-ENTRY SET-CURRENT         dpans16.htm     16.6.1.2195
ANS-TABLE-ENTRY SET-ORDER           dpans16.htm     16.6.1.2197
ANS-TABLE-ENTRY WORDLIST            dpans16.htm     16.6.1.2460
ANS-TABLE-ENTRY ALSO                dpans16.htm     16.6.2.0715
ANS-TABLE-ENTRY FORTH               dpans16.htm     16.6.2.1590
ANS-TABLE-ENTRY ONLY                dpans16.htm     16.6.2.1965
ANS-TABLE-ENTRY ORDER               dpans16.htm     16.6.2.1985
ANS-TABLE-ENTRY PREVIOUS            dpans16.htm     16.6.2.2037
ANS-TABLE-ENTRY -TRAILING           dpans17.htm     17.6.1.0170
ANS-TABLE-ENTRY /STRING             dpans17.htm     17.6.1.0245
ANS-TABLE-ENTRY BLANK               dpans17.htm     17.6.1.0780
ANS-TABLE-ENTRY CMOVE               dpans17.htm     17.6.1.0910
ANS-TABLE-ENTRY CMOVE>              dpans17.htm     17.6.1.0920
ANS-TABLE-ENTRY COMPARE             dpans17.htm     17.6.1.0935
ANS-TABLE-ENTRY SEARCH              dpans17.htm     17.6.1.2191
ANS-TABLE-ENTRY SLITERAL            dpans17.htm     17.6.1.2212
ANS-TABLE-ENTRY (                   dpans6.htm      6.1.0080
ANS-TABLE-ENTRY .(                  dpans6.htm      6.2.0200
ANS-TABLE-ENTRY \                   dpans6.htm      6.2.2535

CLOSE-HTML-LINK-TABLE

: skip-string	( adr -- adr1 )
		count + ;

: GetAnsWord	( adr len -- adr1 ) \ get address of ANS-word in table
		?dup
		if   ANS-WORDS >r
		     begin  2dup r@ count dup
		     while  ISTR= 0<>
			    if 2drop r> exit then
			    r> skip-string skip-string skip-string >r
		     repeat 2drop 2drop 2drop r>drop NULL
		else drop NULL
		then ;

external

: IsAnsWord?	( adr len -- f ) \ check if string adr/len is a ANS-word
		GetAnsWord 0<> ;

: GetAnsLink	( adr len -- adr1 len1 ) \ get HTML reference for ANS-word
		GetAnsWord ?dup
		if   s" doc\dpans\" pad place
		     skip-string dup count pad +place
		     s" #" pad +place
		     skip-string count pad +place
		     pad count Prepend<home>\
		else 0 0
		then ;

module
