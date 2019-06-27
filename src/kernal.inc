; =============================================================================================================================
;
;  C64 Kernal Equates
; 
; =============================================================================================================================

;Label   Jump   Vector Real  Function                           Function Input/Output                    Register Usage
;        addr    addr  code  Description                        Parameters                             entry  return  used
;-------------------------------------------------------------------------------------------------------------------------
CINT   = $FF81;  ----  FF5B  init VIC & screen editor                                                  - - -  - - -  A X Y
IOINIT = $FF84;  ----  FDA3  initialize CIA & IRQ                                                      - - -  - - -  A X Y
RAMTAS = $FF87;  ----  FD50  RAM test & search RAM end                                                 - - -  - - -  A X Y
RESTOR = $FF8A;  ----  FD15  restore default I/O vectors                                               - - -  - - -  A - Y
VECTOR = $FF8D;  ----  FD1A  read/set I/O vectors               in: C=0 moves from Y/X to vectors      - X Y  - X -  A - Y
;                                                                   C=1 moves vectors to Y/X           - X Y  - X -  A - Y
SETMSG = $FF90;  ----  FE18  enable/disable KERNAL messages     in: A bit7=1 error msgs on             A - -  - - -  A - -
;                                                                     bit6=1 control msgs on
SECOND = $FF93;  ----  EDB9  send secondary addr after listen   in: A=secondary address                A - -  - - -  A - -
TKSA   = $FF96;  ----  EDC7  send secondary addr after talk     in: A=secondary address                A - -  - - -  A - -
MEMTOP = $FF99;  ----  FE25  read/set top of memory             in: C=0; Y/X address                   - X Y  - X Y  - - -
;                                                               out:C=1; Y/X address                   - - -  - X Y  - X Y
MEMBOT = $FF9C;  ----  FE34  read/set bottom of memory          in: C=0; Y/X address                   - X Y  - X Y  - - -
;                                                               out:C=1; Y/X address                   - - -  - X Y  - X Y
SCNKEY = $FF9F;  ----  EA87  scan keyboard                                                             - - -  - - -  A X Y
SETTMO = $FFA2;  ----  FE21  set IEEE timeout                   in: A bit7=1 disable, bit7=0 enable    A - -  A - -  - - -
ACPTR  = $FFA5;  ----  EE13  input byte from SERIAL             out:A=byte, C=1 and ST=2 if timeout    - - -  A - -  A - -
CIOUT  = $FFA8;  ----  EDDD  output byte to SERIAL              in: A=byte, C=1 and ST=3 if timeout    A - -  A - -  - - -
UNTLK  = $FFAB;  ----  EDEF  untalk all SERIAL devices                                                 - - -  - - -  A - -
UNLSN  = $FFAE;  ----  EDFE  unlisten all SERIAL devices                                               - - -  - - -  A - -
LISTEN = $FFB1;  ----  ED0C  make SERIAL device listen          in: A=device number                    A - -  - - -  A - -
TALK   = $FFB4;  ----  ED09  make SERIAL device talk            in: A=device number                    A - -  - - -  A - -
READST = $FFB7;  ----  FE07  read I/O status byte               out:A=status byte                      - - -  A - -  A - -
SETLFS = $FFBA;  ----  FE00  set file parameters                in: A=logical file number              A X Y  A X Y  - - -
;                                                                   X=device number
;                                                                   Y=secondary addr
SETNAM = $FFBD;  ----  FDF9  set file name                      in: A=length of filename               A X Y  A X Y  - - -
;                                                                   Y/X=pointer to name addr
OPEN   = $FFC0;  031A  F34A  open log.file after SETLFS,SETNAM  out:A=error# if C=1                    - - -  - - -  A X Y
CLOSE  = $FFC3;  031C  F291  close a logical file               in: A=logical file number              A - -  - - -  A X Y
CHKIN  = $FFC6;  031E  F20E  open channel for input             in: X=logical file number              - X -  - - -  A X -
CHKOUT = $FFC9;  0320  F250  open channel for output            in: X=logical file number              - X -  - - -  A X -
CLRCHN = $FFCC;  0322  F333  restore default devices                                                   - - -  - - -  A X -
CHRIN  = $FFCF;  0324  F157  input character                    out:A=character, C=1 and ST=error      - - -  A - -  A - -
CHROUT = $FFD2;  0326  F1CA  output character                   in: A=character, C=1 and ST=error      A - -  A - -  - - -
LOAD   = $FFD5;  0330  F49E  load after call SETLFS,SETNAM      in: A=0 load, a=1 verify               A X Y  A X Y  A X Y
;                                                                   Y/X = dest.addr if sec.addr=0
SAVE   = $FFD8;  0332  F5DD  save after call SETLFS,SETNAM      in: A=zero page pointer to start.addr  A X Y  - - -  A X Y
;                                                                   Y/X=ending address
SETTIM = $FFDB;  ----  F6E4  set jiffy clock                    in: A=MSB, X=middle, Y=LSB             A X Y  - - -  - - -
RDTIM  = $FFDE;  ----  F6DD  read jiffy clock                   out:A=MSB, X=middle, Y=LSB             - - -  A X Y  A X Y
STOP   = $FFE1;  0328  F6ED  check stop key                     out:Z=0 if STOP not used; X unchanged  - - -  A - -  A - -
;                                                                   Z=1 if STOP used; X changed        - - -  A - -  A X -
;                                                                   A=last GFX_LINE of keyboard matrix
GETIN  = $FFE4;  032A  F13E  get a byte from channel            out:keyboard:A=0 if puffer empty       - - -  A - -  A X Y
;                                                                   RS232:status byte                  - - -  A - -  A - -
;                                                                   serial:status byte                 - - -  A - -  A - -
;                                                                   tape:status byte                   - - -  A - -  A - Y
CLALL  = $FFE7;  032C  F32F  close or abort all files                                                  - - -  - - -  A X -
UDTIM  = $FFEA;  ----  F69B  update jiffy clock                                                        - - -  - - -  A X -
SCREEN = $FFED;  ----  E505  return screen size                 out:X=columns, Y=rows                  - - -  - X Y  - X Y
PLOT   = $FFF0;  ----  E50A  read/set cursor position           in: C=0, X=row, Y=column               - X Y  - X Y  - - -
;                                                               out:C=1, X=row, Y=column               - - -  - X Y  - X Y
IOBASE = $FFF3;  ----  E500  returns the addr of I/O devices    out:Y/X=addr($DC00)                    - - -  - X Y  - X Y

;