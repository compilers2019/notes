UNIT OberonP;
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

USES OberonS, OberonG, Unix;




CONST
  maxT = 64;
  minErrDist  =  2;  (* minimal distance (good tokens) between two errors *)
  setsize     = 16;  (* sets are stored in 16 bits *)

TYPE
  BITSET = SET OF 0 .. 15;
  SymbolSet = ARRAY [0 .. maxT DIV setsize] OF BITSET;

VAR
  symSet:  ARRAY [0 ..   3] OF SymbolSet; (*symSet[0] = allSyncSyms*)
  errDist: INTEGER;   (* number of symbols recognized since last error *)
  sym:     INTEGER;   (* current input symbol *)

PROCEDURE  SemError (errNo: INTEGER);
  BEGIN
    IF errDist >= minErrDist THEN BEGIN
      OberonS.Error(errNo, OberonS.line, OberonS.col, OberonS.pos);
    END;
    errDist := 0;
  END;

PROCEDURE  SynError (errNo: INTEGER);
  BEGIN
    IF errDist >= minErrDist THEN BEGIN
      OberonS.Error(errNo, OberonS.nextLine, OberonS.nextCol, OberonS.nextPos);
    END;
    errDist := 0;
  END;

PROCEDURE  Get;
  VAR
    s: STRING;
  BEGIN
    REPEAT
      OberonS.Get(sym);
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
    OberonS.GetName(OberonS.pos, OberonS.len, Lex)
  END;

PROCEDURE LexString (VAR Lex : STRING);
  BEGIN
    OberonS.GetString(OberonS.pos, OberonS.len, Lex)
  END;

PROCEDURE LookAheadName (VAR Lex : STRING);
  BEGIN
    OberonS.GetName(OberonS.nextPos, OberonS.nextLen, Lex)
  END;

PROCEDURE LookAheadString (VAR Lex : STRING);
  BEGIN
    OberonS.GetString(OberonS.nextPos, OberonS.nextLen, Lex)
  END;

FUNCTION Successful : BOOLEAN;
  BEGIN
    Successful := OberonS.errors = 0
  END;

PROCEDURE _import; FORWARD;
PROCEDURE _FormalType; FORWARD;
PROCEDURE _FPSection; FORWARD;
PROCEDURE _ProcedureBody; FORWARD;
PROCEDURE _ProcedureHeading; FORWARD;
PROCEDURE _ProcedureDeclaration; FORWARD;
PROCEDURE _CaseLabels; FORWARD;
PROCEDURE _CaseLabelList; FORWARD;
PROCEDURE _case; FORWARD;
PROCEDURE _WithStatement; FORWARD;
PROCEDURE _LoopStatement; FORWARD;
PROCEDURE _RepeatStatement; FORWARD;
PROCEDURE _WhileStatement; FORWARD;
PROCEDURE _CaseStatement; FORWARD;
PROCEDURE _IfStatement; FORWARD;
PROCEDURE _assignment; FORWARD;
PROCEDURE _statement; FORWARD;
PROCEDURE _element; FORWARD;
PROCEDURE _ActualParameters; FORWARD;
PROCEDURE _set; FORWARD;
PROCEDURE _MulOperator; FORWARD;
PROCEDURE _factor; FORWARD;
PROCEDURE _assign; FORWARD;
PROCEDURE _nil; FORWARD;
PROCEDURE _mod; FORWARD;
PROCEDURE _div; FORWARD;
PROCEDURE _and; FORWARD;
PROCEDURE _mul; FORWARD;
PROCEDURE _divide; FORWARD;
PROCEDURE _or; FORWARD;
PROCEDURE _AddOperator; FORWARD;
PROCEDURE _term; FORWARD;
PROCEDURE _minus; FORWARD;
PROCEDURE _plus; FORWARD;
PROCEDURE _relation; FORWARD;
PROCEDURE _SimpleExpression; FORWARD;
PROCEDURE _ExpList; FORWARD;
PROCEDURE _designator; FORWARD;
PROCEDURE _VariableDeclaration; FORWARD;
PROCEDURE _FormalParameters; FORWARD;
PROCEDURE _IdentList; FORWARD;
PROCEDURE _FieldList; FORWARD;
PROCEDURE _FieldListSequence; FORWARD;
PROCEDURE _parCl; FORWARD;
PROCEDURE _BaseType; FORWARD;
PROCEDURE _parOp; FORWARD;
PROCEDURE _ProcedureType; FORWARD;
PROCEDURE _PointerType; FORWARD;
PROCEDURE _RecordType; FORWARD;
PROCEDURE _type; FORWARD;
PROCEDURE _TypeDeclaration; FORWARD;
PROCEDURE _expression; FORWARD;
PROCEDURE _ConstExpression; FORWARD;
PROCEDURE _ConstantDeclaration; FORWARD;
PROCEDURE _qualident; FORWARD;
PROCEDURE _identdef; FORWARD;
PROCEDURE _number; FORWARD;
PROCEDURE _end; FORWARD;
PROCEDURE _StatementSequence; FORWARD;
PROCEDURE _begin; FORWARD;
PROCEDURE _DeclarationSequence; FORWARD;
PROCEDURE _ImportList; FORWARD;
PROCEDURE _semicolon; FORWARD;
PROCEDURE _module; FORWARD;
PROCEDURE _Oberon; FORWARD;

PROCEDURE _import;
  BEGIN
    Expect(1);
    IF (sym = 39) THEN BEGIN
      _assign;
      Expect(1);
    END;
  END;

PROCEDURE _FormalType;
  BEGIN
    WHILE (sym = 62) DO BEGIN
      Get;
      Expect(51);
    END;
    IF (sym = 1) THEN BEGIN
      _qualident;
    END ELSE IF (sym = 18) THEN BEGIN
      _ProcedureType;
    END ELSE BEGIN SynError(65);
    END;
  END;

PROCEDURE _FPSection;
  BEGIN
    IF (sym = 61) THEN BEGIN
      Get;
    END;
    Expect(1);
    WHILE (sym = 15) DO BEGIN
      Get;
      Expect(1);
    END;
    Expect(14);
    _FormalType;
  END;

PROCEDURE _ProcedureBody;
  BEGIN
    _DeclarationSequence;
    IF (sym = 7) THEN BEGIN
      Get;
      _StatementSequence;
    END;
    Expect(8);
  END;

PROCEDURE _ProcedureHeading;
  BEGIN
    Expect(18);
    IF (sym = 11) THEN BEGIN
      Get;
    END;
    _identdef;
    IF (sym = 32) THEN BEGIN
      _FormalParameters;
    END;
  END;

PROCEDURE _ProcedureDeclaration;
  BEGIN
    _ProcedureHeading;
    Expect(10);
    _ProcedureBody;
    Expect(1);
  END;

PROCEDURE _CaseLabels;
  BEGIN
    _ConstExpression;
    IF (sym = 43) THEN BEGIN
      Get;
      _ConstExpression;
    END;
  END;

PROCEDURE _CaseLabelList;
  BEGIN
    _CaseLabels;
    WHILE (sym = 15) DO BEGIN
      Get;
      _CaseLabels;
    END;
  END;

PROCEDURE _case;
  BEGIN
    IF _In(symSet[1], sym) THEN BEGIN
      _CaseLabelList;
      Expect(14);
      _StatementSequence;
    END;
  END;

PROCEDURE _WithStatement;
  BEGIN
    Expect(58);
    _qualident;
    Expect(14);
    _qualident;
    Expect(54);
    _StatementSequence;
    Expect(8);
  END;

PROCEDURE _LoopStatement;
  BEGIN
    Expect(57);
    _StatementSequence;
    Expect(8);
  END;

PROCEDURE _RepeatStatement;
  BEGIN
    Expect(55);
    _StatementSequence;
    Expect(56);
    _expression;
  END;

PROCEDURE _WhileStatement;
  BEGIN
    Expect(53);
    _expression;
    Expect(54);
    _StatementSequence;
    Expect(8);
  END;

PROCEDURE _CaseStatement;
  BEGIN
    Expect(50);
    _expression;
    Expect(51);
    _case;
    WHILE (sym = 52) DO BEGIN
      Get;
      _case;
    END;
    IF (sym = 49) THEN BEGIN
      Get;
      _StatementSequence;
    END;
    Expect(8);
  END;

PROCEDURE _IfStatement;
  BEGIN
    Expect(46);
    _expression;
    Expect(47);
    _StatementSequence;
    WHILE (sym = 48) DO BEGIN
      Get;
      _expression;
      Expect(47);
      _StatementSequence;
    END;
    IF (sym = 49) THEN BEGIN
      Get;
      _StatementSequence;
    END;
    Expect(8);
  END;

PROCEDURE _assignment;
  BEGIN
    _designator;
    _assign;
    _expression;
  END;

PROCEDURE _statement;
  BEGIN
    IF _In(symSet[2], sym) THEN BEGIN
      CASE sym OF
        1 : BEGIN
          _assignment;
          END;
        46 : BEGIN
          _IfStatement;
          END;
        50 : BEGIN
          _CaseStatement;
          END;
        53 : BEGIN
          _WhileStatement;
          END;
        55 : BEGIN
          _RepeatStatement;
          END;
        57 : BEGIN
          _LoopStatement;
          END;
        58 : BEGIN
          _WithStatement;
          END;
        44 : BEGIN
          Get;
          END;
        45 : BEGIN
          Get;
          IF _In(symSet[1], sym) THEN BEGIN
            _expression;
          END;
          END;
      END;
    END;
  END;

PROCEDURE _element;
  BEGIN
    _expression;
    IF (sym = 43) THEN BEGIN
      Get;
      _expression;
    END;
  END;

PROCEDURE _ActualParameters;
  BEGIN
    _parOp;
    IF _In(symSet[1], sym) THEN BEGIN
      _ExpList;
    END;
    _parCl;
  END;

PROCEDURE _set;
  BEGIN
    Expect(41);
    IF _In(symSet[1], sym) THEN BEGIN
      _element;
      WHILE (sym = 15) DO BEGIN
        Get;
        _element;
      END;
    END;
    Expect(42);
  END;

PROCEDURE _MulOperator;
  BEGIN
    IF (sym = 11) THEN BEGIN
      _mul;
    END ELSE IF (sym = 31) THEN BEGIN
      _divide;
    END ELSE IF (sym = 35) THEN BEGIN
      _div;
    END ELSE IF (sym = 36) THEN BEGIN
      _mod;
    END ELSE IF (sym = 34) THEN BEGIN
      _and;
    END ELSE BEGIN SynError(66);
    END;
  END;

PROCEDURE _factor;
  BEGIN
    CASE sym OF
      2, 3 : BEGIN
        _number;
        END;
      4 : BEGIN
        Get;
        END;
      5 : BEGIN
        Get;
        END;
      37 : BEGIN
        _nil;
        END;
      41 : BEGIN
        _set;
        END;
      1 : BEGIN
        _designator;
        IF (sym = 32) THEN BEGIN
          _ActualParameters;
        END;
        END;
      32 : BEGIN
        _parOp;
        _expression;
        _parCl;
        END;
      40 : BEGIN
        Get;
        _factor;
        END;
    ELSE BEGIN SynError(67);
        END;
    END;
  END;

PROCEDURE _assign;
  BEGIN
    Expect(39);
  END;

PROCEDURE _nil;
  BEGIN
    Expect(37);
  END;

PROCEDURE _mod;
  BEGIN
    Expect(36);
  END;

PROCEDURE _div;
  BEGIN
    Expect(35);
  END;

PROCEDURE _and;
  BEGIN
    Expect(34);
  END;

PROCEDURE _mul;
  BEGIN
    Expect(11);
  END;

PROCEDURE _divide;
  BEGIN
    Expect(31);
  END;

PROCEDURE _or;
  BEGIN
    Expect(38);
  END;

PROCEDURE _AddOperator;
  BEGIN
    IF (sym = 29) THEN BEGIN
      _plus;
    END ELSE IF (sym = 30) THEN BEGIN
      _minus;
    END ELSE IF (sym = 38) THEN BEGIN
      _or;
    END ELSE BEGIN SynError(68);
    END;
  END;

PROCEDURE _term;
  BEGIN
    _factor;
    WHILE (sym = 11) OR (sym = 31) OR (sym = 34) OR (sym = 35) OR (sym = 36) DO BEGIN
      _MulOperator;
      _factor;
    END;
  END;

PROCEDURE _minus;
  BEGIN
    Expect(30);
  END;

PROCEDURE _plus;
  BEGIN
    Expect(29);
  END;

PROCEDURE _relation;
  BEGIN
    CASE sym OF
      12 : BEGIN
        Get;
        END;
      22 : BEGIN
        Get;
        END;
      23 : BEGIN
        Get;
        END;
      24 : BEGIN
        Get;
        END;
      25 : BEGIN
        Get;
        END;
      26 : BEGIN
        Get;
        END;
      27 : BEGIN
        Get;
        END;
      28 : BEGIN
        Get;
        END;
    ELSE BEGIN SynError(69);
        END;
    END;
  END;

PROCEDURE _SimpleExpression;
  BEGIN
    IF (sym = 29) OR (sym = 30) THEN BEGIN
      IF (sym = 29) THEN BEGIN
        _plus;
      END ELSE BEGIN
        _minus;
      END;
    END;
    _term;
    WHILE (sym = 29) OR (sym = 30) OR (sym = 38) DO BEGIN
      _AddOperator;
      _term;
    END;
  END;

PROCEDURE _ExpList;
  BEGIN
    _expression;
    WHILE (sym = 15) DO BEGIN
      Get;
      _expression;
    END;
  END;

PROCEDURE _designator;
  BEGIN
    _qualident;
    WHILE (sym = 6) OR (sym = 19) OR (sym = 21) OR (sym = 32) DO BEGIN
      IF (sym = 6) THEN BEGIN
        Get;
        Expect(1);
      END ELSE IF (sym = 19) THEN BEGIN
        Get;
        _ExpList;
        Expect(20);
      END ELSE IF (sym = 32) THEN BEGIN
        _parOp;
        _qualident;
        _parCl;
      END ELSE BEGIN
        Get;
      END;
    END;
  END;

PROCEDURE _VariableDeclaration;
  BEGIN
    _IdentList;
    Expect(14);
    _type;
  END;

PROCEDURE _FormalParameters;
  BEGIN
    _parOp;
    IF (sym = 1) OR (sym = 61) THEN BEGIN
      _FPSection;
      WHILE (sym = 10) DO BEGIN
        Get;
        _FPSection;
      END;
    END;
    _parCl;
    IF (sym = 14) THEN BEGIN
      Get;
      _qualident;
    END;
  END;

PROCEDURE _IdentList;
  BEGIN
    _identdef;
    WHILE (sym = 15) DO BEGIN
      Get;
      _identdef;
    END;
  END;

PROCEDURE _FieldList;
  BEGIN
    IF (sym = 1) THEN BEGIN
      _IdentList;
      Expect(14);
      _type;
    END;
  END;

PROCEDURE _FieldListSequence;
  BEGIN
    _FieldList;
    WHILE (sym = 10) DO BEGIN
      Get;
      _FieldList;
    END;
  END;

PROCEDURE _parCl;
  BEGIN
    Expect(33);
  END;

PROCEDURE _BaseType;
  BEGIN
    _qualident;
  END;

PROCEDURE _parOp;
  BEGIN
    Expect(32);
  END;

PROCEDURE _ProcedureType;
  BEGIN
    Expect(18);
    IF (sym = 32) THEN BEGIN
      _FormalParameters;
    END;
  END;

PROCEDURE _PointerType;
  BEGIN
    Expect(16);
    Expect(17);
    _type;
  END;

PROCEDURE _RecordType;
  BEGIN
    Expect(13);
    IF (sym = 32) THEN BEGIN
      _parOp;
      _BaseType;
      _parCl;
    END;
    _FieldListSequence;
    Expect(8);
  END;

PROCEDURE _type;
  BEGIN
    IF (sym = 1) THEN BEGIN
      _qualident;
    END ELSE IF (sym = 13) THEN BEGIN
      _RecordType;
    END ELSE IF (sym = 16) THEN BEGIN
      _PointerType;
    END ELSE IF (sym = 18) THEN BEGIN
      _ProcedureType;
    END ELSE BEGIN SynError(70);
    END;
  END;

PROCEDURE _TypeDeclaration;
  BEGIN
    _identdef;
    Expect(12);
    _type;
  END;

PROCEDURE _expression;
  BEGIN
    _SimpleExpression;
    IF _In(symSet[3], sym) THEN BEGIN
      _relation;
      _SimpleExpression;
    END;
  END;

PROCEDURE _ConstExpression;
  BEGIN
    _expression;
  END;

PROCEDURE _ConstantDeclaration;
  BEGIN
    _identdef;
    Expect(12);
    _ConstExpression;
  END;

PROCEDURE _qualident;
  BEGIN
    IF (sym = 1) THEN BEGIN
      Get;
      Expect(6);
    END;
    Expect(1);
  END;

PROCEDURE _identdef;
  BEGIN
    Expect(1);
    IF (sym = 11) THEN BEGIN
      Get;
    END;
  END;

PROCEDURE _number;
  BEGIN
    IF (sym = 2) THEN BEGIN
      Get;
    END ELSE IF (sym = 3) THEN BEGIN
      Get;
    END ELSE BEGIN SynError(71);
    END;
  END;

PROCEDURE _end;
  BEGIN
    Expect(8);
  END;

PROCEDURE _StatementSequence;
  BEGIN
    _statement;
    WHILE (sym = 10) DO BEGIN
      Get;
      _statement;
    END;
  END;

PROCEDURE _begin;
  BEGIN
    Expect(7);
  END;

PROCEDURE _DeclarationSequence;
  BEGIN
    WHILE (sym = 59) OR (sym = 60) OR (sym = 61) DO BEGIN
      IF (sym = 59) THEN BEGIN
        Get;
        WHILE (sym = 1) DO BEGIN
          _ConstantDeclaration;
          Expect(10);
        END;
      END ELSE IF (sym = 60) THEN BEGIN
        Get;
        WHILE (sym = 1) DO BEGIN
          _TypeDeclaration;
          Expect(10);
        END;
      END ELSE BEGIN
        Get;
        WHILE (sym = 1) DO BEGIN
          _VariableDeclaration;
          Expect(10);
        END;
      END;
    END;
    WHILE (sym = 18) DO BEGIN
      _ProcedureDeclaration;
      Expect(10);
      Expect(10);
    END;
  END;

PROCEDURE _ImportList;
  BEGIN
    Expect(63);
    _import;
    WHILE (sym = 15) DO BEGIN
      Get;
      _import;
    END;
    Expect(10);
  END;

PROCEDURE _semicolon;
  BEGIN
    Expect(10);
  END;

PROCEDURE _module;
  BEGIN
    Expect(9);
  END;

PROCEDURE _Oberon;
  VAR
    modName: string;
  BEGIN
    _module;
    Expect(1);
	LexString(modName);
	OberonG.NewFile(modName);
    _semicolon;
    IF (sym = 63) THEN BEGIN
      _ImportList;
    END;
    _DeclarationSequence;
    IF (sym = 7) THEN BEGIN
      _begin;
	     OberonG.GenMain;
      _StatementSequence;
    END;
    _end;
	OberonG.CloseFile;

    Expect(1);
    Expect(6);
	Unix.fpsystem('as -o ' + modName + '.o ' + modName + '.s');
	Unix.fpsystem('ld -o ' + modName + ' ' + modName + '.o');
  END;



PROCEDURE  Parse;
  BEGIN
    _Reset; Get;
    _Oberon;

  END;

BEGIN
  errDist := minErrDist;
  symSet[ 0, 0] := [0];
  symSet[ 0, 1] := [];
  symSet[ 0, 2] := [];
  symSet[ 0, 3] := [];
  symSet[ 0, 4] := [];
  symSet[ 1, 0] := [1, 2, 3, 4, 5];
  symSet[ 1, 1] := [13, 14];
  symSet[ 1, 2] := [0, 5, 8, 9];
  symSet[ 1, 3] := [];
  symSet[ 1, 4] := [];
  symSet[ 2, 0] := [1];
  symSet[ 2, 1] := [];
  symSet[ 2, 2] := [12, 13, 14];
  symSet[ 2, 3] := [2, 5, 7, 9, 10];
  symSet[ 2, 4] := [];
  symSet[ 3, 0] := [12];
  symSet[ 3, 1] := [6, 7, 8, 9, 10, 11, 12];
  symSet[ 3, 2] := [];
  symSet[ 3, 3] := [];
  symSet[ 3, 4] := [];
END. (* OberonP *)
