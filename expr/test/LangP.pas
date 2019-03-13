UNIT LangP;
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

USES LangS;




CONST
  maxT = 22;
  minErrDist  =  2;  (* minimal distance (good tokens) between two errors *)
  setsize     = 16;  (* sets are stored in 16 bits *)

TYPE
  BITSET = SET OF 0 .. 15;
  SymbolSet = ARRAY [0 .. maxT DIV setsize] OF BITSET;

VAR
  symSet:  ARRAY [0 ..   1] OF SymbolSet; (*symSet[0] = allSyncSyms*)
  errDist: INTEGER;   (* number of symbols recognized since last error *)
  sym:     INTEGER;   (* current input symbol *)

PROCEDURE  SemError (errNo: INTEGER);
  BEGIN
    IF errDist >= minErrDist THEN BEGIN
      LangS.Error(errNo, LangS.line, LangS.col, LangS.pos);
    END;
    errDist := 0;
  END;

PROCEDURE  SynError (errNo: INTEGER);
  BEGIN
    IF errDist >= minErrDist THEN BEGIN
      LangS.Error(errNo, LangS.nextLine, LangS.nextCol, LangS.nextPos);
    END;
    errDist := 0;
  END;

PROCEDURE  Get;
  VAR
    s: STRING;
  BEGIN
    REPEAT
      LangS.Get(sym);
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
    LangS.GetName(LangS.pos, LangS.len, Lex)
  END;

PROCEDURE LexString (VAR Lex : STRING);
  BEGIN
    LangS.GetString(LangS.pos, LangS.len, Lex)
  END;

PROCEDURE LookAheadName (VAR Lex : STRING);
  BEGIN
    LangS.GetName(LangS.nextPos, LangS.nextLen, Lex)
  END;

PROCEDURE LookAheadString (VAR Lex : STRING);
  BEGIN
    LangS.GetString(LangS.nextPos, LangS.nextLen, Lex)
  END;

FUNCTION Successful : BOOLEAN;
  BEGIN
    Successful := LangS.errors = 0
  END;

PROCEDURE _variable; FORWARD;
PROCEDURE _MulOperator; FORWARD;
PROCEDURE _factor; FORWARD;
PROCEDURE _AddOperator; FORWARD;
PROCEDURE _term; FORWARD;
PROCEDURE _relation; FORWARD;
PROCEDURE _SimpleExpression; FORWARD;
PROCEDURE _expression; FORWARD;
PROCEDURE _Lang; FORWARD;

PROCEDURE _variable;
  BEGIN
    Expect(1);
  END;

PROCEDURE _MulOperator;
  BEGIN
    IF (sym = 6) THEN BEGIN
      Get;
    END ELSE IF (sym = 7) THEN BEGIN
      Get;
    END ELSE IF (sym = 8) THEN BEGIN
      Get;
    END ELSE IF (sym = 9) THEN BEGIN
      Get;
    END ELSE IF (sym = 10) THEN BEGIN
      Get;
    END ELSE BEGIN SynError(23);
    END;
  END;

PROCEDURE _factor;
  BEGIN
    IF (sym = 1) THEN BEGIN
      _variable;
    END ELSE IF (sym = 3) THEN BEGIN
      Get;
      _expression;
      Expect(4);
    END ELSE IF (sym = 5) THEN BEGIN
      Get;
      _factor;
    END ELSE BEGIN SynError(24);
    END;
  END;

PROCEDURE _AddOperator;
  BEGIN
    IF (sym = 11) THEN BEGIN
      Get;
    END ELSE IF (sym = 12) THEN BEGIN
      Get;
    END ELSE IF (sym = 13) THEN BEGIN
      Get;
    END ELSE BEGIN SynError(25);
    END;
  END;

PROCEDURE _term;
  BEGIN
    _factor;
    WHILE (sym = 6) OR (sym = 7) OR (sym = 8) OR (sym = 9) OR (sym = 10) DO BEGIN
      _MulOperator;
      _factor;
    END;
  END;

PROCEDURE _relation;
  BEGIN
    CASE sym OF
      14 : BEGIN
        Get;
        END;
      15 : BEGIN
        Get;
        END;
      16 : BEGIN
        Get;
        END;
      17 : BEGIN
        Get;
        END;
      18 : BEGIN
        Get;
        END;
      19 : BEGIN
        Get;
        END;
      20 : BEGIN
        Get;
        END;
      21 : BEGIN
        Get;
        END;
    ELSE BEGIN SynError(26);
        END;
    END;
  END;

PROCEDURE _SimpleExpression;
  BEGIN
    _term;
    WHILE (sym = 11) OR (sym = 12) OR (sym = 13) DO BEGIN
      _AddOperator;
      _term;
    END;
  END;

PROCEDURE _expression;
  BEGIN
    _SimpleExpression;
    IF _In(symSet[1], sym) THEN BEGIN
      _relation;
      _SimpleExpression;
    END;
  END;

PROCEDURE _Lang;
  BEGIN
    _expression;
    WHILE (sym = 1) OR (sym = 3) OR (sym = 5) DO BEGIN
      _expression;
    END;
  END;



PROCEDURE  Parse;
  BEGIN
    _Reset; Get;
    _Lang;

  END;

BEGIN
  errDist := minErrDist;
  symSet[ 0, 0] := [0];
  symSet[ 0, 1] := [];
  symSet[ 1, 0] := [14, 15];
  symSet[ 1, 1] := [0, 1, 2, 3, 4, 5];
END. (* LangP *)
