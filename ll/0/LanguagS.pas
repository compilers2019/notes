UNIT LanguagS;
(* Scanner generated by Coco/R (Pascal version) *)

INTERFACE

CONST
  CommentMax = 10000;
TYPE
  CommentStr = ARRAY [0 .. CommentMax] OF CHAR;
VAR
  src:         FILE;         (*source/list files. To be opened by the main pgm*)
  lst:         TEXT;
  directory:   STRING;       (*of source file*)
  line, col:   INTEGER;      (*line and column of current symbol*)
  len:         LONGINT;      (*length of current symbol*)
  pos:         LONGINT;      (*file position of current symbol*)
  nextLine:    INTEGER;      (*line of lookahead symbol*)
  nextCol:     INTEGER;      (*column of lookahead symbol*)
  nextLen:     LONGINT;      (*length of lookahead symbol*)
  nextPos:     LONGINT;      (*file position of lookahead symbol*)
  errors:      INTEGER;      (*number of detected errors*)
  seenComment: BOOLEAN;      (*TRUE if comments have been registered*)
  Error:       PROCEDURE (nr, line, col: INTEGER; pos: LONGINT);

PROCEDURE Get (VAR sym: INTEGER);
(* Gets next symbol from source file *)

PROCEDURE GetString (pos: LONGINT; len: INTEGER; VAR s: STRING);
(* Retrieves exact string of max length len from position pos in source file *)

PROCEDURE GetName (pos: LONGINT; len: INTEGER; VAR s: STRING);
(* Retrieves name of symbol of length len at position pos in source file *)

FUNCTION CharAt (pos: LONGINT): CHAR;
(* Returns exact character at position pos in source file *)

PROCEDURE GetComment (VAR comment: CommentStr; pos: INTEGER; VAR length: INTEGER);
(* IF seenComment
     THEN concatenates and extracts previously scanned comments into comment,
          starting at comment[pos], and computes length; seenComment := FALSE
     ELSE returns length := 0 *)

PROCEDURE _Reset;
(* Reads and stores source file internally *)

IMPLEMENTATION

CONST
  no_Sym = 12; (*error token code*)
  (* not only for errors but also for not finished states of scanner analysis *)
  eof = #26; (*MS-DOS eof*)
  LF  = #10;
  CR  = #13;
  EF  = #0;
  EL  = CR;
  BlkSize = 16384;
TYPE
  BufBlock   = ARRAY [0 .. BlkSize-1] OF CHAR;
  Buffer     = ARRAY [0 .. 31] OF ^BufBlock;
  StartTable = ARRAY [0 .. 255] OF INTEGER;
  GetCH      = FUNCTION (pos: LONGINT) : CHAR;
  CommentPtr = ^ CommentRec;
  CommentRec = RECORD
                 begCom, endCom : LONGINT;
                 next : CommentPtr;
               END;
VAR
  lastCh,
  ch:        CHAR;       (*current input character*)
  curLine:   INTEGER;    (*current input line (may be higher than line)*)
  lineStart: LONGINT;    (*start position of current line*)
  apx:       LONGINT;    (*length of appendix (CONTEXT phrase)*)
  oldEols:   INTEGER;    (*number of _EOLs in a comment*)
  bp, bp0:   LONGINT;    (*current position in buf
                           (bp0: position of current token)*)
  LBlkSize:  LONGINT;    (*BlkSize*)
  inputLen:  LONGINT;    (*source file size*)
  buf:       Buffer;     (*source buffer for low-level access*)
  start:     StartTable; (*start state for every character*)
  CurrentCh: GetCH;
  firstComment, lastComment: CommentPtr;

PROCEDURE Err (nr, line, col: INTEGER; pos: LONGINT); FAR;
  BEGIN
    INC(errors)
  END;

PROCEDURE NextCh;
(* Return global variable ch *)
  BEGIN
    lastCh := ch; INC(bp); ch := CurrentCh(bp);
    IF (ch = EL) OR (ch = LF) AND (lastCh <> EL) THEN BEGIN
      INC(curLine); lineStart := bp
    END
  END;

FUNCTION Comment: BOOLEAN;
  LABEL
    999;
  VAR
    level, startLine: INTEGER;
    oldLineStart : LONGINT;
    beginC, endC : LONGINT;
    nextComment : CommentPtr;
  BEGIN
    beginC := bp;
    level := 1; startLine := curLine; oldLineStart := lineStart;
    
    Comment := FALSE;
    999:
    endC := bp; DEC(endC);
    IF endC > beginC THEN BEGIN
      seenComment := TRUE;
      NEW(nextComment);
      nextComment^.begCom := beginC;
      nextComment^.endCom := endC;
      nextComment^.next := NIL;
      IF firstComment = NIL
        THEN firstComment := nextComment
        ELSE lastComment^.next := nextComment;
      lastComment := nextComment
    END
  END;

PROCEDURE GetComment (VAR comment: CommentStr; pos: INTEGER; VAR length: INTEGER);
  VAR
    this : CommentPtr;
  BEGIN
    length := 0;
    WHILE firstComment <> NIL DO BEGIN
      this := firstComment;
      WHILE (pos + length <= CommentMax) AND (this^.begCom <= this^.endCom) DO
        BEGIN
          comment[pos + length] := CharAt(this^.begCom);
          INC(length); INC(this^.begCom);
        END;
      firstComment := firstComment^.next;
      DISPOSE(this)
    END;
    seenComment := FALSE;
  END;

PROCEDURE Get (VAR sym: INTEGER);
  VAR
    state: INTEGER;

  FUNCTION Equal (s: STRING): BOOLEAN;
    VAR
      i: INTEGER;
      q: LONGINT;
    BEGIN
      IF nextLen <> Length(s) THEN BEGIN Equal := FALSE; EXIT END;
      i := 1; q := bp0;
      WHILE i <= nextLen DO BEGIN
        IF CurrentCh(q) <> s[i] THEN BEGIN Equal := FALSE; EXIT END;
        INC(i); INC(q)
      END;
      Equal := TRUE
    END;

  PROCEDURE CheckLiteral;
    BEGIN
      CASE CurrentCh(bp0) OF
        'B': IF Equal('BEGIN') THEN BEGIN sym := 5; 
             END;
        'C': IF Equal('CONDITION') THEN BEGIN sym := 10; 
             END;
        'E': IF Equal('END') THEN BEGIN sym := 11; 
             END;
        'F': IF Equal('FOREVER') THEN BEGIN sym := 6; 
             END;
        'P': IF Equal('PROGRAM') THEN BEGIN sym := 4; 
             END;
        'R': IF Equal('REPEAT') THEN BEGIN sym := 7; 
             END;
        'S': IF Equal('STATEMENT') THEN BEGIN sym := 8; 
             END;
        'U': IF Equal('UNTIL') THEN BEGIN sym := 9; 
             END;
      ELSE BEGIN END
      END
    END;

  BEGIN (*Get*)
    WHILE (ch = ' ') OR
          ((ch >= CHR(9)) AND (ch <= CHR(10)) OR
          (ch = CHR(13))) DO NextCh;
    pos := nextPos;   nextPos := bp;
    col := nextCol;   nextCol := bp - lineStart;
    line := nextLine; nextLine := curLine;
    len := nextLen;   nextLen := 0;
    apx := 0; state := start[ORD(ch)]; bp0 := bp;
    WHILE TRUE DO BEGIN
      NextCh; INC(nextLen);
      CASE state OF
         1: IF ((ch >= '0') AND (ch <= '9') OR
               (ch >= 'A') AND (ch <= 'Z') OR
               (ch >= 'a') AND (ch <= 'z')) THEN BEGIN 
            END ELSE BEGIN sym := 1; CheckLiteral; EXIT; END;
         2: BEGIN sym := 2; EXIT; END;
         3: BEGIN sym := 3; EXIT; END;
         4: BEGIN sym := 0; ch := #0; DEC(bp); EXIT END;
      ELSE BEGIN sym := no_Sym; EXIT (*NextCh already done*) END;
      END
    END
  END;

PROCEDURE GetString (pos: LONGINT; len: INTEGER; VAR s: STRING);
  VAR
    i: INTEGER;
    p: LONGINT;
  BEGIN
    IF len > 255 THEN len := 255;
    p := pos; i := 1;
    WHILE i <= len DO BEGIN
      s[i] := CharAt(p); INC(i); INC(p)
    END;
    s[0] := CHR(len);
  END;

PROCEDURE GetName (pos: LONGINT; len: INTEGER; VAR s: STRING);
  VAR
    i: INTEGER;
    p: LONGINT;
  BEGIN
    IF len > 255 THEN len := 255;
    p := pos; i := 1;
    WHILE i <= len DO BEGIN
      s[i] := CurrentCh(p); INC(i); INC(p)
    END;
    s[0] := CHR(len);
  END;

FUNCTION CharAt (pos: LONGINT): CHAR;
  VAR
    ch : CHAR;
  BEGIN
    IF pos >= inputLen THEN BEGIN CharAt := EF; EXIT; END;
    ch := buf[pos DIV LBlkSize]^[pos MOD LBlkSize];
    IF ch <> eof THEN CharAt := ch ELSE CharAt := EF
  END;

FUNCTION CapChAt (pos: LONGINT): CHAR; FAR;
  VAR
    ch : CHAR;
  BEGIN
    IF pos >= inputLen THEN BEGIN CapChAt := EF; EXIT; END;
    ch := upcase(buf[pos DIV LBlkSize]^[pos MOD LBlkSize]);
    IF ch <> eof THEN CapChAt := ch ELSE CapChAt := EF
  END;

PROCEDURE _Reset;
  VAR
    len: LONGINT;
    i, read: INTEGER;
  BEGIN (*assert: src has been opened*)
    len := FileSize(src); i := 0; inputLen := len;
    WHILE len > LBlkSize DO BEGIN
      NEW(buf[i]);
      read := BlkSize; BlockRead(src, buf[i]^, read);
      len := len - read; INC(i)
    END;
    NEW(buf[i]);
    read := len; BlockRead(src, buf[i]^, read);
    buf[i]^[read] := EF;
    curLine := 1; lineStart := -2; bp := -1;
    oldEols := 0; apx := 0; errors := 0;
    NextCh;
  END;

BEGIN
  CurrentCh := CharAt;
  start[  0] :=  4; start[  1] :=  5; start[  2] :=  5; start[  3] :=  5; 
  start[  4] :=  5; start[  5] :=  5; start[  6] :=  5; start[  7] :=  5; 
  start[  8] :=  5; start[  9] :=  5; start[ 10] :=  5; start[ 11] :=  5; 
  start[ 12] :=  5; start[ 13] :=  5; start[ 14] :=  5; start[ 15] :=  5; 
  start[ 16] :=  5; start[ 17] :=  5; start[ 18] :=  5; start[ 19] :=  5; 
  start[ 20] :=  5; start[ 21] :=  5; start[ 22] :=  5; start[ 23] :=  5; 
  start[ 24] :=  5; start[ 25] :=  5; start[ 26] :=  5; start[ 27] :=  5; 
  start[ 28] :=  5; start[ 29] :=  5; start[ 30] :=  5; start[ 31] :=  5; 
  start[ 32] :=  5; start[ 33] :=  5; start[ 34] :=  5; start[ 35] :=  5; 
  start[ 36] :=  5; start[ 37] :=  5; start[ 38] :=  5; start[ 39] :=  5; 
  start[ 40] :=  5; start[ 41] :=  5; start[ 42] :=  5; start[ 43] :=  5; 
  start[ 44] :=  5; start[ 45] :=  5; start[ 46] :=  3; start[ 47] :=  5; 
  start[ 48] :=  5; start[ 49] :=  5; start[ 50] :=  5; start[ 51] :=  5; 
  start[ 52] :=  5; start[ 53] :=  5; start[ 54] :=  5; start[ 55] :=  5; 
  start[ 56] :=  5; start[ 57] :=  5; start[ 58] :=  5; start[ 59] :=  2; 
  start[ 60] :=  5; start[ 61] :=  5; start[ 62] :=  5; start[ 63] :=  5; 
  start[ 64] :=  5; start[ 65] :=  1; start[ 66] :=  1; start[ 67] :=  1; 
  start[ 68] :=  1; start[ 69] :=  1; start[ 70] :=  1; start[ 71] :=  1; 
  start[ 72] :=  1; start[ 73] :=  1; start[ 74] :=  1; start[ 75] :=  1; 
  start[ 76] :=  1; start[ 77] :=  1; start[ 78] :=  1; start[ 79] :=  1; 
  start[ 80] :=  1; start[ 81] :=  1; start[ 82] :=  1; start[ 83] :=  1; 
  start[ 84] :=  1; start[ 85] :=  1; start[ 86] :=  1; start[ 87] :=  1; 
  start[ 88] :=  1; start[ 89] :=  1; start[ 90] :=  1; start[ 91] :=  5; 
  start[ 92] :=  5; start[ 93] :=  5; start[ 94] :=  5; start[ 95] :=  5; 
  start[ 96] :=  5; start[ 97] :=  1; start[ 98] :=  1; start[ 99] :=  1; 
  start[100] :=  1; start[101] :=  1; start[102] :=  1; start[103] :=  1; 
  start[104] :=  1; start[105] :=  1; start[106] :=  1; start[107] :=  1; 
  start[108] :=  1; start[109] :=  1; start[110] :=  1; start[111] :=  1; 
  start[112] :=  1; start[113] :=  1; start[114] :=  1; start[115] :=  1; 
  start[116] :=  1; start[117] :=  1; start[118] :=  1; start[119] :=  1; 
  start[120] :=  1; start[121] :=  1; start[122] :=  1; start[123] :=  5; 
  start[124] :=  5; start[125] :=  5; start[126] :=  5; start[127] :=  5; 
  start[128] :=  5; start[129] :=  5; start[130] :=  5; start[131] :=  5; 
  start[132] :=  5; start[133] :=  5; start[134] :=  5; start[135] :=  5; 
  start[136] :=  5; start[137] :=  5; start[138] :=  5; start[139] :=  5; 
  start[140] :=  5; start[141] :=  5; start[142] :=  5; start[143] :=  5; 
  start[144] :=  5; start[145] :=  5; start[146] :=  5; start[147] :=  5; 
  start[148] :=  5; start[149] :=  5; start[150] :=  5; start[151] :=  5; 
  start[152] :=  5; start[153] :=  5; start[154] :=  5; start[155] :=  5; 
  start[156] :=  5; start[157] :=  5; start[158] :=  5; start[159] :=  5; 
  start[160] :=  5; start[161] :=  5; start[162] :=  5; start[163] :=  5; 
  start[164] :=  5; start[165] :=  5; start[166] :=  5; start[167] :=  5; 
  start[168] :=  5; start[169] :=  5; start[170] :=  5; start[171] :=  5; 
  start[172] :=  5; start[173] :=  5; start[174] :=  5; start[175] :=  5; 
  start[176] :=  5; start[177] :=  5; start[178] :=  5; start[179] :=  5; 
  start[180] :=  5; start[181] :=  5; start[182] :=  5; start[183] :=  5; 
  start[184] :=  5; start[185] :=  5; start[186] :=  5; start[187] :=  5; 
  start[188] :=  5; start[189] :=  5; start[190] :=  5; start[191] :=  5; 
  start[192] :=  5; start[193] :=  5; start[194] :=  5; start[195] :=  5; 
  start[196] :=  5; start[197] :=  5; start[198] :=  5; start[199] :=  5; 
  start[200] :=  5; start[201] :=  5; start[202] :=  5; start[203] :=  5; 
  start[204] :=  5; start[205] :=  5; start[206] :=  5; start[207] :=  5; 
  start[208] :=  5; start[209] :=  5; start[210] :=  5; start[211] :=  5; 
  start[212] :=  5; start[213] :=  5; start[214] :=  5; start[215] :=  5; 
  start[216] :=  5; start[217] :=  5; start[218] :=  5; start[219] :=  5; 
  start[220] :=  5; start[221] :=  5; start[222] :=  5; start[223] :=  5; 
  start[224] :=  5; start[225] :=  5; start[226] :=  5; start[227] :=  5; 
  start[228] :=  5; start[229] :=  5; start[230] :=  5; start[231] :=  5; 
  start[232] :=  5; start[233] :=  5; start[234] :=  5; start[235] :=  5; 
  start[236] :=  5; start[237] :=  5; start[238] :=  5; start[239] :=  5; 
  start[240] :=  5; start[241] :=  5; start[242] :=  5; start[243] :=  5; 
  start[244] :=  5; start[245] :=  5; start[246] :=  5; start[247] :=  5; 
  start[248] :=  5; start[249] :=  5; start[250] :=  5; start[251] :=  5; 
  start[252] :=  5; start[253] :=  5; start[254] :=  5; start[255] :=  5; 
  Error := Err; LBlkSize := BlkSize; lastCh := EF;
  firstComment := NIL; seenComment := FALSE;
END. (* LanguagS *)
