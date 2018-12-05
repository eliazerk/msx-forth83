
V9990 Tests

----
only definitions FORTH also
vocabulary MSX-V9990

FORTH definitions
\ nothing

MSX-V9990 definitions
decimal 2 5 thru      \ constans
decimal 6 14 thru 
decimal 15 18 thru \ Scrolls...

----
\ constants

hex 60 constant #V9BASE

#V9BASE 0 + constant #V9VRAM
#V9BASE 1 + constant #V9PALETTE
#V9BASE 2 + constant #V9CMD
#V9BASE 3 + constant #V9REGDATA
#V9BASE 4 + constant #V9REGSEL
#V9BASE 5 + constant #V9STATUS   \ R/O
#V9BASE 6 + constant #V9INTFLAG
#V9BASE 7 + constant #V9SYSCTL   \ W/O
#V9BASE F + constant #V9RESERVED

----
\ constants

decimal
0 constant #V9R-VRAM-W#0
1 constant #V9R-VRAM-W#1
2 constant #V9R-VRAM-W#2
3 constant #V9R-VRAM-R#0
4 constant #V9R-VRAM-R#1
5 constant #V9R-VRAM-R#2
6 constant #V9R-SCREEN-RW#0
7 constant #V9R-SCREEN-RW#1
8 constant #V9R-CTL-RW
9 constant #V9R-INT-RW#0
10 constant #V9R-INT-RW#1
11 constant #V9R-INT-RW#2
12 constant #V9R-INT-RW#3
----
\ constants
decimal
13 constant #V9R-PALETTECTL-W
14 constant #V9R-PALETTEPTR-W
15 constant #V9R-BACKDROP-RW
16 constant #V9R-DISPLAYADJ-RW
17 constant #V9R-SCROLL-AY-RW#0
18 constant #V9R-SCROLL-AY-RW#1
19 constant #V9R-SCROLL-AX-RW#0
20 constant #V9R-SCROLL-AX-RW#1
21 constant #V9R-SCROLL-BY-RW#0
22 constant #V9R-SCROLL-BY-RW#1
23 constant #V9R-SCROLL-BX-RW#0
24 constant #V9R-SCROLL-BX-RW#1
----
\ constants
decimal
25 constant #V9R-SPRITEGEN-RW
26 constant #V9R-LCDCTL-RW
27 constant #V9R-PRIORITYCTL-RW
28 constant #V9R-SPRITEPALETTECTL-W

32 constant #V9R-COMMAND-W#0
52 constant #V9R-COMMAND-W#20
53 constant #V9R-COMMAND-R#0
54 constant #V9R-COMMAND-R#1
----
\ V9REG! ( n reg -- )

: V9REG! ( n reg -- )
  #V9REGSEL PC!  #V9REGDATA PC! ;

hex
: V9REG+1! ( n reg -- )
  3F AND
  #V9REGSEL PC!  #V9REGDATA PC! ;

: V9REG@ ( reg -- n )
  #V9REGSEL PC!  #V9REGDATA PC@ ;
----
\ V9PALETTE!, V9PALETTE@, V9RGBPALETTE!

: V9PALETTE! ( n -- )
   #V9PALETTE PC! ;

: V9PALETTE@ ( -- n )
   #V9PALETTE PC@ ;

: V9RGBPALETTE! ( b g r -- )
   V9PALETTE!   V9PALETTE!   V9PALETTE! ;
----
\ V9BUILD-PAL, rgb, ( r g b -- )

: V9BUILD-PAL ( compile: number-rgb-entries <name> -- )
   create ,
   does> dup @ swap 2+ swap
   0 do
     dup c@ V9PALETTE! 1+
     dup c@ V9PALETTE! 1+
     dup c@ V9PALETTE! 1+
   loop drop ;

: rgb, ( r g b -- )
   rot ( g b r ) c, 
   swap ( b g ) c, c, ;

----
\ D24BITS ( D -- msb mid lsb )

\ Double to 24 bits
code D24BITS ( D -- msb mid lsb )
   H POP   D POP
   0 H MVI   H PUSH   \ MSB
   D L MOV   H PUSH   \ MID
   E L MOV   H PUSH   \ LSB
   next
end-code

----
\ 2VRAM!! ( D-addr -- )

\ Set VRAM write address
: 2VRAM!! ( D-addr -- )
   D24BITS
   #V9R-VRAM-W#0 V9REG!   \ LSB
   #V9R-VRAM-W#1 V9REG!   \ MID
   #V9R-VRAM-W#2 V9REG!   \ MSB
;
----
\ VRAM!! ( addr -- )

\ 16bit number to 2x 8bit numbers
code n2b ( n -- msb lsb )
   H POP
   0 D MVI
   H E MOV   D PUSH
   L E MOV   D PUSH
   next
end-code

: VRAM!! ( addr -- )
   n2b
   #V9R-VRAM-W#0 V9REG!   \ LSB
   #V9R-VRAM-W#1 V9REG!   \ MSB
;
----
\ >VRAM ( b -- ), >V9REGDATA ( b -- )

: >VRAM ( b -- )
   #V9VRAM PC! ;

: >V9REGDATA ( b -- )
  #V9REGDATA PC!  ;
----
\ DISPLAY ( f -- )

hex
: DISPLAY-ENABLE ( -- )
  #V9R-CTL-RW V9REG@
  80 or
  #V9R-CTL-RW V9REG! ;

hex
: DISPLAY-DISABLE ( -- )
  #V9R-CTL-RW V9REG@
  7F and
  #V9R-CTL-RW V9REG! ;

: DISPLAY ( f -- )
  IF display-enable ELSE display-disable THEN ;
----
\ SPRITES ( f -- )

hex
: SPRITES-ENABLE ( -- )
  #V9R-CTL-RW V9REG@
  BF and
  #V9R-CTL-RW V9REG! ;

hex
: SPRITES-DISABLE ( -- )
  #V9R-CTL-RW V9REG@
  40 or
  #V9R-CTL-RW V9REG! ;

: SPRITES ( f -- )
  IF sprites-enable ELSE sprites-disable THEN ;
----
\ Scroll A/B constants and variables
hex
00 constant #SCROLL-MODE-ROLLIMAGE
40 constant #SCROLL-MODE-ROLL256
80 constant #SCROLL-MODE-ROLL512

variable SCROLL-A-MODE
#SCROLL-MODE-ROLLIMAGE SCROLL-A-MODE !

variable SCROLL-B-MODE
#SCROLL-MODE-ROLLIMAGE SCROLL-B-MODE !
----
\ SET-SCROLL-A-MODE ( n -- ), SET-SCROLL-B-MODE ( n -- )

hex
: SET-SCROLL-A-MODE ( n -- )
  00C0 and SCROLL-A-MODE ! ;

hex
: SET-SCROLL-B-MODE ( n -- )
  00C0 and SCROLL-B-MODE ! ;
----
\ SCROOL-AX ( n -- ), SCROOL-AY ( n -- )

hex
: SCROOL-AX ( n -- )
  dup
  7 and #V9R-SCROLL-AX-RW#0 V9REG+1!  \ bits 2..0
  u2/ u2/ u2/ >V9REGDATA ;            \ bits 10..3

hex
: SCROLL-AY ( n -- )
  n2b ( n -- msb lsb )
  #V9R-SCROLL-AY-RW#0 V9REG+1!             \ bits  7..0
  1F and SCROLL-A-MODE C@ or >V9REGDATA ;  \ bits 12..8

----
\ SCROOL-BX ( n -- ), SCROLL-BY ( n --)

hex
: SCROOL-BX ( n -- )
  dup
  7 and #V9R-SCROLL-BX-RW#0 V9REG+1!  \ bits 2..0
  u2/ u2/ u2/ 3F and >V9REGDATA ;     \ bits 10..3
  
hex
: SCROLL-BY ( n --)
  n2b ( n -- msb lsb )
  #V9R-SCROLL-BY-RW#0 V9REG+1!             \ bits 7..0
  01 and SCROLL-B-MODE C@ or >V9REGDATA ;  \ bits 8
----

\ http://msxbanzai.tni.nl/v9990/manual.html
\ http://www.map.grauw.nl/resources/video/yamaha_v9990.pdf

hex
40 constant #XIMM-1024PX
10 constant #CLRM-4BPP
80 constant #DSPM-BMP
00 constant #DCKM-1/4XTAL
----

: PAT-OFFSET ( pat -- addr )
   32 mod 4 * swap
   32 / 1024 * + ;

: DPATA-ADDR ( pat row -- d-addr )
   swap pat-offset 0 rot
   128 * 0 D+ ;

hex
: DPATB-ADDR ( pat row -- d-addr )
   40000. D+ ;
----
