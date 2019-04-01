PROGRAM Oberon;
(* This is an example of a rudimentary main module for use with COCO/R (Pascal)
   The auxiliary modules <Grammar>S (scanner) and <Grammar>P (parser)
   are assumed to have been constructed with COCO/R compiler generator. *)

USES OberonS, (* lst, src, errors, Error, CharAt *)
     OberonP;  (* Parse, Successful *)

PROCEDURE AppendExtension (OldName, Ext : STRING; VAR NewName : STRING);
  VAR
    i : INTEGER;
  BEGIN
    i := System.Length(OldName);
    WHILE (i > 0) AND (OldName[i] <> '.') AND (OldName[i] <> '\') DO DEC(i);
    IF (i > 0) AND (OldName[i] = '.') THEN System.Delete(OldName, i, 255);
    IF System.Pos('.', Ext) = 1 THEN System.Delete(Ext, 1, 1);
    NewName := OldName + '.' + Ext
  END;

(* ------------------- Source Listing and Error handler -------------- *)

  TYPE
    CHARSET = SET OF CHAR;
    Err = ^ErrDesc;
    ErrDesc = RECORD
      nr, line, col: INTEGER;
      next: Err
    END;

  CONST
    TAB  = #09;
    _LF  = #10;
    _CR  = #13;
    _EF  = #0;
    LineEnds : CHARSET = [_CR, _LF, _EF];

  VAR
    firstErr, lastErr: Err;
    Extra : INTEGER;

  PROCEDURE StoreError (nr, line, col: INTEGER; pos: LONGINT); FAR;
  (* Store an error message for later printing *)
    VAR
      nextErr: Err;
    BEGIN
      NEW(nextErr);
      nextErr^.nr := nr; nextErr^.line := line; nextErr^.col := col;
      nextErr^.next := NIL;
      IF firstErr = NIL
        THEN firstErr := nextErr
        ELSE lastErr^.next := nextErr;
      lastErr := nextErr;
      INC(errors)
    END;

  PROCEDURE GetLine (VAR pos  : LONGINT;
                     VAR line : STRING;
                     VAR eof  : BOOLEAN);
  (* Read a source line. Return empty line if eof *)
    VAR
      ch: CHAR;
      i:  INTEGER;
    BEGIN
      i := 1; eof := FALSE; ch := CharAt(pos); INC(pos);
      WHILE NOT (ch IN LineEnds) DO BEGIN
        line[i] := ch; INC(i); ch := CharAt(pos); INC(pos);
      END;
      line[0] := Chr(i-1);
      eof := (i = 1) AND (ch = _EF);
      IF ch = _CR THEN BEGIN (* check for MsDos *)
        ch := CharAt(pos);
        IF ch = _LF THEN BEGIN INC(pos); Extra := 0 END
      END
    END;

  PROCEDURE PrintErr (line : STRING; nr, col: INTEGER);
  (* Print an error message *)

    PROCEDURE Msg (s: STRING);
      BEGIN
        Write(lst, s)
      END;

    PROCEDURE Pointer;
      VAR
        i : INTEGER;
      BEGIN
        Write(lst, '*****  ');
        i := 0;
        WHILE i < col + Extra - 2 DO BEGIN
          IF line[i] = TAB
            THEN Write(lst, TAB)
            ELSE Write(lst, ' ');
          INC(i)
        END;
        Write(lst, '^ ')
      END;

    BEGIN
      Pointer;
      CASE nr OF
         0 : Msg('EOF expected');
         1 : Msg('ident expected');
         2 : Msg('integer expected');
         3 : Msg('real expected');
         4 : Msg('CharConstant expected');
         5 : Msg('string expected');
         6 : Msg('"." expected');
         7 : Msg('"BEGIN" expected');
         8 : Msg('"END" expected');
         9 : Msg('"MODULE" expected');
        10 : Msg('";" expected');
        11 : Msg('"*" expected');
        12 : Msg('"=" expected');
        13 : Msg('"RECORD" expected');
        14 : Msg('":" expected');
        15 : Msg('"," expected');
        16 : Msg('"POINTER" expected');
        17 : Msg('"TO" expected');
        18 : Msg('"PROCEDURE" expected');
        19 : Msg('"[" expected');
        20 : Msg('"]" expected');
        21 : Msg('"^" expected');
        22 : Msg('"#" expected');
        23 : Msg('"<" expected');
        24 : Msg('"<=" expected');
        25 : Msg('">" expected');
        26 : Msg('">=" expected');
        27 : Msg('"IN" expected');
        28 : Msg('"IS" expected');
        29 : Msg('"+" expected');
        30 : Msg('"-" expected');
        31 : Msg('"/" expected');
        32 : Msg('"(" expected');
        33 : Msg('")" expected');
        34 : Msg('"&" expected');
        35 : Msg('"DIV" expected');
        36 : Msg('"MOD" expected');
        37 : Msg('"NIL" expected');
        38 : Msg('"OR" expected');
        39 : Msg('":=" expected');
        40 : Msg('"~" expected');
        41 : Msg('"{" expected');
        42 : Msg('"}" expected');
        43 : Msg('".." expected');
        44 : Msg('"EXIT" expected');
        45 : Msg('"RETURN" expected');
        46 : Msg('"IF" expected');
        47 : Msg('"THEN" expected');
        48 : Msg('"ELSIF" expected');
        49 : Msg('"ELSE" expected');
        50 : Msg('"CASE" expected');
        51 : Msg('"OF" expected');
        52 : Msg('"|" expected');
        53 : Msg('"WHILE" expected');
        54 : Msg('"DO" expected');
        55 : Msg('"REPEAT" expected');
        56 : Msg('"UNTIL" expected');
        57 : Msg('"LOOP" expected');
        58 : Msg('"WITH" expected');
        59 : Msg('"CONST" expected');
        60 : Msg('"TYPE" expected');
        61 : Msg('"VAR" expected');
        62 : Msg('"ARRAY" expected');
        63 : Msg('"IMPORT" expected');
        64 : Msg('not expected');
        65 : Msg('invalid FormalType');
        66 : Msg('invalid MulOperator');
        67 : Msg('invalid factor');
        68 : Msg('invalid AddOperator');
        69 : Msg('invalid relation');
        70 : Msg('invalid type');
        71 : Msg('invalid number');
      
      (* add your customized cases here *)
      ELSE BEGIN Msg('Error: '); Write(lst, nr); END
      END;
      WriteLn(lst)
    END;

  PROCEDURE PrintListing;
  (* Print a source listing with error messages *)
    VAR
      nextErr:   Err;
      eof:       BOOLEAN;
      lnr, errC: INTEGER;
      srcPos:    LONGINT;
      line:      STRING;
    BEGIN
      WriteLn(lst, 'Listing:');
      WriteLn(lst);
      srcPos := 0; nextErr := firstErr;
      GetLine(srcPos, line, eof); lnr := 1; errC := 0;
      WHILE NOT eof DO BEGIN
        WriteLn(lst, lnr:5, '  ', line);
        WHILE (nextErr <> NIL) AND (nextErr^.line = lnr) DO BEGIN
          PrintErr(line, nextErr^.nr, nextErr^.col); INC(errC);
          nextErr := nextErr^.next
        END;
        GetLine(srcPos, line, eof); INC(lnr);
      END;
      IF nextErr <> NIL THEN BEGIN
        WriteLn(lst, lnr:5);
        WHILE nextErr <> NIL DO BEGIN
          PrintErr(line, nextErr^.nr, nextErr^.col); INC(errC);
          nextErr := nextErr^.next
        END
      END;
      WriteLn(lst);
      Write(lst, errC:5, ' error');
      IF errC <> 1 THEN Write(lst, 's');
      WriteLn(lst); WriteLn(lst); WriteLn(lst);
    END;

(* --------------------------- main module ------------------------------- *)

VAR
  sourceName, listName : STRING;

BEGIN
   firstErr := NIL; Extra := 1;

  (* check on correct parameter usage *)
   IF ParamCount < 1 THEN BEGIN
     WriteLn('No input file specified');
     HALT;
   END;
   sourceName := ParamStr(1);

  (* open the source file Scanner.src *)
  Assign(src, sourceName);
  {$I-} Reset(src, 1); {$I+}
  IF IOResult <> 0 THEN BEGIN
    WriteLn('Could not open input file');
    HALT;
  END;

  (* open the output file for the source listing Scanner.lst *)
  AppendExtension(sourceName, 'lst', listName);
  Assign(lst, listName);
  {$I-} Rewrite(lst); {$I+}
  IF IOResult <> 0 THEN BEGIN
    Close(lst);
    WriteLn('Could not open listing file');
    (* default Scanner.lst to screen *)
    Assign(lst, ''); Rewrite(lst);
  END;

  (* install error reporting procedure *)
  OberonS.Error := StoreError;

  (* instigate the compilation *)
  WriteLn('Parsing');
  Parse; 

  (* generate the source listing on Scanner.lst *)
  PrintListing; Close(lst);

  (* examine the outcome from Scanner.errors *)
  IF NOT Successful
    THEN
      Write('Incorrect source - see ', listName)
    ELSE BEGIN
      Write('Parsed correctly');
      (* ++++++++ Add further activities if required ++++++++++ *)
  END;
END. (* Oberon *)
