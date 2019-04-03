.section .text
.type add_add1, @function
add_add1:
pushl %ebp;
movl %esp,%ebp;
movl 8(%ebp), %edx
addl 12(%ebp), %edx
movl %edx,%eax;
movl %ebp,%esp;
popl %ebp;
ret
