
add.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <add>:
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	89 7d fc             	mov    %edi,-0x4(%rbp)
   7:	89 75 f8             	mov    %esi,-0x8(%rbp)
   a:	89 55 f4             	mov    %edx,-0xc(%rbp)
   d:	8b 55 fc             	mov    -0x4(%rbp),%edx
  10:	8b 45 f8             	mov    -0x8(%rbp),%eax
  13:	01 d0                	add    %edx,%eax
  15:	2b 45 f4             	sub    -0xc(%rbp),%eax
  18:	5d                   	pop    %rbp
  19:	c3                   	retq   
