
* update ATG EBNF grammar to introduce global variables.
  global VAR section.
   var_name : type (we have only one type now - INTEGER)

* update grammar to introduce assignments.
  only numerical constants can be assigned to variables yet.

  for example, if we declared global variable
    i : INTEGER;
	then after BEGIN section we can do:
	i := 42;

  correct program which should parse:

```
PROGRAM testPrg;

VAR
    i: INTEGER;
	j: INTEGER;
	k: INTEGER;

BEGIN
  i := 42;
  j := 23;
  RETURN i;
END testPrg;


```
*  add generator module.
   it creates output assembler file with '.s' extension.
   it has section for program exit and startup.
   hint for startup: '.globl _start'
   hint for exit:    'exit syscall'
   hint for declaration:
   ```
   .section .bss
   .lcomm i, 4
   .lcomm j, 4
   ```
   hint for assignment:

   ```
     movl $42, i

   ```


assignment link: https://classroom.github.com/a/oKkfo9iF

deadline: 02/20/2019 23:59 +040

* make sure ATG is correct

* be able to compile a compiler. (main file may be necessary)

* make sure the compiled compiler finds mistakes in example source. otherwise change ATG and generate compiler sources again.

* add generator module.
















