
m.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	48 83 ec 10          	sub    $0x10,%rsp
   8:	c7 45 f8 17 00 00 00 	movl   $0x17,-0x8(%rbp)
   f:	c7 45 fc 2a 00 00 00 	movl   $0x2a,-0x4(%rbp)
  16:	8b 55 fc             	mov    -0x4(%rbp),%edx
  19:	8b 45 f8             	mov    -0x8(%rbp),%eax
  1c:	89 d6                	mov    %edx,%esi
  1e:	89 c7                	mov    %eax,%edi
  20:	e8 00 00 00 00       	callq  25 <main+0x25>
  25:	89 45 f8             	mov    %eax,-0x8(%rbp)
  28:	8b 45 f8             	mov    -0x8(%rbp),%eax
  2b:	c9                   	leaveq 
  2c:	c3                   	retq   
