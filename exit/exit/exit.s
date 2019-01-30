
.section .data
.section .bss
.lcomm  a, 4
.lcomm  b, 4
.lcomm  i, 4



.section .text

.globl _start



_start:
  movl $5, a

  movl $1, %eax   # number of exit() syscall
  movl a, %ebx   # return
  int $0x80       # interrupt, execute the code.
