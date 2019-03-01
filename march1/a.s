.section .bss

.lcomm i, 4
.lcomm j, 4


.section .text
.globl _start
_start:
movl $23, i
pushl i

movl i, %ebx
movl $1, %eax
int $0x80
