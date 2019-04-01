unit OberonG;


interface
VAR f : textfile;

PROCEDURE NewFile(VAR n: string);
PROCEDURE GenMain;
PROCEDURE CloseFile;
PROCEDURE emitLn(VAR s : string);

implementation

PROCEDURE emitLn(VAR s : string);
BEGIN
  writeln (f, s)
END; //emitLn

PROCEDURE GenMain;
BEGIN
  writeln (f, '.section .text');
  writeln (f, '.globl _start');
  writeln (f, '_start:');
END; //GenMain;


PROCEDURE NewFile(VAR n: string);
var fn: string;
BEGIN
  fn := n + '.s';
  assign(f, fn);
  rewrite(f);

END; //NewFile


PROCEDURE CloseFile;
BEGIN
 writeln (f, ' movl $1, %eax');
 writeln (f, ' movl $0, %ebx');
 writeln (f, ' int $0x80');
 Close(f);
END; //CloseFile;

END.
