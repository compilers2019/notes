UNIT LanguagP;
(* Parser generated by Coco/R (Pascal version) *)

INTERFACE

PROCEDURE Parse;

FUNCTION Successful : BOOLEAN;
(* Returns TRUE if no errors have been recorded while parsing *)

PROCEDURE SynError (errNo: INTEGER);
(* Report syntax error with specified errNo *)

PROCEDURE SemError (errNo: INTEGER);
(* Report semantic error with specified errNo *)

PROCEDURE LexString (VAR Lex : STRING);
(* Retrieves Lex as exact spelling of current token *)

PROCEDURE LexName (VAR Lex : STRING);
(* Retrieves Lex as name of current token (capitalized if IGNORE CASE) *)

PROCEDURE LookAheadString (VAR Lex : STRING);
(* Retrieves Lex as exact spelling of lookahead token *)

PROCEDURE LookAheadName (VAR Lex : STRING);
(* Retrieves Lex as name of lookahead token (capitalized if IGNORE CASE) *)

IMPLEMENTATION

USES LanguagS;




CONST
  maxT = 12;
  minErrDist  =  2;  (* minimal distance (good tokens) between two errors *)
  setsize     = 16;  (* sets are stored in 16 bits *)

TYPE
  BITSET = SET OF 0 .. 15;
  SymbolSet = ARRAY [0 .. maxT DIV setsize] OF BITSET;

VAR
  symSet:  ARRAY [0 ..   0] OF SymbolSet; (*symSet[0] = allSyncSyms*)
  errDist: INTEGER;   (* number of symbols recognized since last error *)
  sym:     INTEGER;   (* current input symbol *)

PROCEDURE  SemError (errNo: INTEGER);
  BEGIN
    IF errDist >= minErrDist THEN BEGIN
      LanguagS.Error(errNo, LanguagS.line, LanguagS.col, LanguagS.pos);
    END;
    errDist := 0;
  END;

PROCEDURE  SynError (errNo: INTEGER);
  BEGIN
    IF errDist >= minErrDist THEN BEGIN
      LanguagS.Error(errNo, LanguagS.nextLine, LanguagS.nextCol, LanguagS.nextPos);
    END;
    errDist := 0;
  END;

PROCEDURE  Get;
  VAR
    s: STRING;
  BEGIN
    REPEAT
      LanguagS.Get(sym);
      IF sym <= maxT THEN
        INC(errDist)
      ELSE BEGIN
        
      END;
    UNTIL sym <= maxT
  END;

FUNCTION  _In (VAR s: SymbolSet; x: INTEGER): BOOLEAN;
  BEGIN
    _In := x MOD setsize IN s[x DIV setsize];
  END;

PROCEDURE  Expect (n: INTEGER);
  BEGIN
    IF sym = n THEN Get ELSE SynError(n);
  END;

PROCEDURE  ExpectWeak (n, follow: INTEGER);
  BEGIN
    IF sym = n
    THEN Get
    ELSE BEGIN
      SynError(n); WHILE NOT _In(symSet[follow], sym) DO Get;
    END
  END;

FUNCTION  WeakSeparator (n, syFol, repFol: INTEGER): BOOLEAN;
  VAR
    s: SymbolSet;
    i: INTEGER;
  BEGIN
    IF sym = n
    THEN BEGIN Get; WeakSeparator := TRUE; EXIT; END
    ELSE IF _In(symSet[repFol], sym) THEN BEGIN WeakSeparator := FALSE; exit END
    ELSE BEGIN
      i := 0;
      WHILE i <= maxT DIV setsize DO BEGIN
        s[i] := symSet[0, i] + symSet[syFol, i] + symSet[repFol, i]; INC(i)
      END;
      SynError(n); WHILE NOT _In(s, sym) DO Get;
      WeakSeparator := _In(symSet[syFol], sym)
    END
  END;

PROCEDURE LexName (VAR Lex : STRING);
  BEGIN
    LanguagS.GetName(LanguagS.pos, LanguagS.len, Lex)
  END;

PROCEDURE LexString (VAR Lex : STRING);
  BEGIN
    LanguagS.GetString(LanguagS.pos, LanguagS.len, Lex)
  END;

PROCEDURE LookAheadName (VAR Lex : STRING);
  BEGIN
    LanguagS.GetName(LanguagS.nextPos, LanguagS.nextLen, Lex)
  END;

PROCEDURE LookAheadString (VAR Lex : STRING);
  BEGIN
    LanguagS.GetString(LanguagS.nextPos, LanguagS.nextLen, Lex)
  END;

FUNCTION Successful : BOOLEAN;
  BEGIN
    Successful := LanguagS.errors = 0
  END;

PROCEDURE _statement; FORWARD;
PROCEDURE _forever; FORWARD;
PROCEDURE _condition; FORWARD;
PROCEDURE _until; FORWARD;
PROCEDURE _statementSeq; FORWARD;
PROCEDURE _repeat; FORWARD;
PROCEDURE _end; FORWARD;
PROCEDURE _repeatStatement; FORWARD;
PROCEDURE _bgn; FORWARD;
PROCEDURE _name; FORWARD;
PROCEDURE _prg; FORWARD;
PROCEDURE _Language; FORWARD;

PROCEDURE _statement;
  BEGIN
    Expect(7);
  END;

PROCEDURE _forever;
  BEGIN
    Expect(10);
  END;

PROCEDURE _condition;
  BEGIN
    Expect(9);
  END;

PROCEDURE _until;
  BEGIN
    Expect(8);
  END;

PROCEDURE _statementSeq;
  BEGIN
    WHILE (sym = 7) DO BEGIN
      _statement;
    END;
  END;

PROCEDURE _repeat;
  BEGIN
    Expect(6);
  END;

PROCEDURE _end;
  BEGIN
    Expect(11);
  END;

PROCEDURE _repeatStatement;
  BEGIN
    IF (sym = 6) THEN BEGIN
      _repeat;
      _statementSeq;
      _until;
      _condition;
    END ELSE IF (sym = 6) THEN BEGIN
      _repeat;
      _statementSeq;
      _forever;
    END ELSE BEGIN SynError(13);
    END;
  END;

PROCEDURE _bgn;
  BEGIN
    Expect(5);
  END;

PROCEDURE _name;
  BEGIN
    Expect(1);
  END;

PROCEDURE _prg;
  BEGIN
    Expect(4);
  END;

PROCEDURE _Language;
  BEGIN
    _prg;
    _name;
    Expect(2);
    _bgn;
    IF (sym = 6) THEN BEGIN
      _repeatStatement;
    END;
    _end;
    _name;
    Expect(3);
  END;



PROCEDURE  Parse;
  BEGIN
    _Reset; Get;
    _Language;

  END;

BEGIN
  errDist := minErrDist;
  symSet[ 0, 0] := [0];
END. (* LanguagP *)
