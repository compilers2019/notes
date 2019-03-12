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
  no_Sym = 18; (*error token code*)
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
        'C': IF Equal('CONDITION') THEN BEGIN sym := 11; 
             END;
        'E': IF Equal('ELSE') THEN BEGIN sym := 15; 
             END ELSE IF Equal('END') THEN BEGIN sym := 17; 
             END ELSE IF Equal('ENDIF') THEN BEGIN sym := 16; 
             END;
        'F': IF Equal('FOREVER') THEN BEGIN sym := 12; 
             END;
        'I': IF Equal('IF') THEN BEGIN sym := 13; 
             END;
        'P': IF Equal('PROGRAM') THEN BEGIN sym := 4; 
             END;
        'R': IF Equal('REPEAT') THEN BEGIN sym := 8; 
             END;
        'T': IF Equal('THEN') THEN BEGIN sym := 14; 
             END;
        'U': IF Equal('UNTIL') THEN BEGIN sym := 10; 
             END;
        'o': IF Equal('otherstatement') THEN BEGIN sym := 9; 
             END;
        'u': IF Equal('using') THEN BEGIN sym := 7; 
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
         4: BEGIN sym := 6; EXIT; END;
         5: BEGIN sym := 0; ch := #0; DEC(bp); EXIT END;
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
  start[  0] :=  5; start[  1] :=  6; start[  2] :=  6; start[  3] :=  6; 
  start[  4] :=  6; start[  5] :=  6; start[  6] :=  6; start[  7] :=  6; 
  start[  8] :=  6; start[  9] :=  6; start[ 10] :=  6; start[ 11] :=  6; 
  start[ 12] :=  6; start[ 13] :=  6; start[ 14] :=  6; start[ 15] :=  6; 
  start[ 16] :=  6; start[ 17] :=  6; start[ 18] :=  6; start[ 19] :=  6; 
  start[ 20] :=  6; start[ 21] :=  6; start[ 22] :=  6; start[ 23] :=  6; 
  start[ 24] :=  6; start[ 25] :=  6; start[ 26] :=  6; start[ 27] :=  6; 
  start[ 28] :=  6; start[ 29] :=  6; start[ 30] :=  6; start[ 31] :=  6; 
  start[ 32] :=  6; start[ 33] :=  6; start[ 34] :=  6; start[ 35] :=  6; 
  start[ 36] :=  6; start[ 37] :=  6; start[ 38] :=  6; start[ 39] :=  6; 
  start[ 40] :=  6; start[ 41] :=  6; start[ 42] :=  6; start[ 43] :=  6; 
  start[ 44] :=  6; start[ 45] :=  6; start[ 46] :=  3; start[ 47] :=  6; 
  start[ 48] :=  6; start[ 49] :=  6; start[ 50] :=  6; start[ 51] :=  6; 
  start[ 52] :=  6; start[ 53] :=  6; start[ 54] :=  6; start[ 55] :=  6; 
  start[ 56] :=  6; start[ 57] :=  6; start[ 58] :=  6; start[ 59] :=  2; 
  start[ 60] :=  6; start[ 61] :=  4; start[ 62] :=  6; start[ 63] :=  6; 
  start[ 64] :=  6; start[ 65] :=  1; start[ 66] :=  1; start[ 67] :=  1; 
  start[ 68] :=  1; start[ 69] :=  1; start[ 70] :=  1; start[ 71] :=  1; 
  start[ 72] :=  1; start[ 73] :=  1; start[ 74] :=  1; start[ 75] :=  1; 
  start[ 76] :=  1; start[ 77] :=  1; start[ 78] :=  1; start[ 79] :=  1; 
  start[ 80] :=  1; start[ 81] :=  1; start[ 82] :=  1; start[ 83] :=  1; 
  start[ 84] :=  1; start[ 85] :=  1; start[ 86] :=  1; start[ 87] :=  1; 
  start[ 88] :=  1; start[ 89] :=  1; start[ 90] :=  1; start[ 91] :=  6; 
  start[ 92] :=  6; start[ 93] :=  6; start[ 94] :=  6; start[ 95] :=  6; 
  start[ 96] :=  6; start[ 97] :=  1; start[ 98] :=  1; start[ 99] :=  1; 
  start[100] :=  1; start[101] :=  1; start[102] :=  1; start[103] :=  1; 
  start[104] :=  1; start[105] :=  1; start[106] :=  1; start[107] :=  1; 
  start[108] :=  1; start[109] :=  1; start[110] :=  1; start[111] :=  1; 
  start[112] :=  1; start[113] :=  1; start[114] :=  1; start[115] :=  1; 
  start[116] :=  1; start[117] :=  1; start[118] :=  1; start[119] :=  1; 
  start[120] :=  1; start[121] :=  1; start[122] :=  1; start[123] :=  6; 
  start[124] :=  6; start[125] :=  6; start[126] :=  6; start[127] :=  6; 
  start[128] :=  6; start[129] :=  6; start[130] :=  6; start[131] :=  6; 
  start[132] :=  6; start[133] :=  6; start[134] :=  6; start[135] :=  6; 
  start[136] :=  6; start[137] :=  6; start[138] :=  6; start[139] :=  6; 
  start[140] :=  6; start[141] :=  6; start[142] :=  6; start[143] :=  6; 
  start[144] :=  6; start[145] :=  6; start[146] :=  6; start[147] :=  6; 
  start[148] :=  6; start[149] :=  6; start[150] :=  6; start[151] :=  6; 
  start[152] :=  6; start[153] :=  6; start[154] :=  6; start[155] :=  6; 
  start[156] :=  6; start[157] :=  6; start[158] :=  6; start[159] :=  6; 
  start[160] :=  6; start[161] :=  6; start[162] :=  6; start[163] :=  6; 
  start[164] :=  6; start[165] :=  6; start[166] :=  6; start[167] :=  6; 
  start[168] :=  6; start[169] :=  6; start[170] :=  6; start[171] :=  6; 
  start[172] :=  6; start[173] :=  6; start[174] :=  6; start[175] :=  6; 
  start[176] :=  6; start[177] :=  6; start[178] :=  6; start[179] :=  6; 
  start[180] :=  6; start[181] :=  6; start[182] :=  6; start[183] :=  6; 
  start[184] :=  6; start[185] :=  6; start[186] :=  6; start[187] :=  6; 
  start[188] :=  6; start[189] :=  6; start[190] :=  6; start[191] :=  6; 
  start[192] :=  6; start[193] :=  6; start[194] :=  6; start[195] :=  6; 
  start[196] :=  6; start[197] :=  6; start[198] :=  6; start[199] :=  6; 
  start[200] :=  6; start[201] :=  6; start[202] :=  6; start[203] :=  6; 
  start[204] :=  6; start[205] :=  6; start[206] :=  6; start[207] :=  6; 
  start[208] :=  6; start[209] :=  6; start[210] :=  6; start[211] :=  6; 
  start[212] :=  6; start[213] :=  6; start[214] :=  6; start[215] :=  6; 
  start[216] :=  6; start[217] :=  6; start[218] :=  6; start[219] :=  6; 
  start[220] :=  6; start[221] :=  6; start[222] :=  6; start[223] :=  6; 
  start[224] :=  6; start[225] :=  6; start[226] :=  6; start[227] :=  6; 
  start[228] :=  6; start[229] :=  6; start[230] :=  6; start[231] :=  6; 
  start[232] :=  6; start[233] :=  6; start[234] :=  6; start[235] :=  6; 
  start[236] :=  6; start[237] :=  6; start[238] :=  6; start[239] :=  6; 
  start[240] :=  6; start[241] :=  6; start[242] :=  6; start[243] :=  6; 
  start[244] :=  6; start[245] :=  6; start[246] :=  6; start[247] :=  6; 
  start[248] :=  6; start[249] :=  6; start[250] :=  6; start[251] :=  6; 
  start[252] :=  6; start[253] :=  6; start[254] :=  6; start[255] :=  6; 
  Error := Err; LBlkSize := BlkSize; lastCh := EF;
  firstComment := NIL; seenComment := FALSE;
END. (* LanguagS *)
