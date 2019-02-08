.section .data
.section .bss       # VAR
.lcomm  a, 4        # a : INTEGER;
.lcomm  b, 4        # b : INTEGER;
.lcomm  i, 4        # i : INTEGER;



.section .text      # BEGIN

.globl _start



_start:
  movl $5, a        # a := 5

  movl $1, %eax   # number of exit() syscall
  movl a, %ebx      # RETURN A 
  int $0x80         # END, interrupt, execute the code.
