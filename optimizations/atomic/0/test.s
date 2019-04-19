	.file	"test.cpp"
	.text
	.type	_ZL3fooi, @function
_ZL3fooi:
.LFB248:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	movl	-4(%rbp), %eax
	addl	%eax, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE248:
	.size	_ZL3fooi, .-_ZL3fooi
	.globl	_Z4fredi
	.type	_Z4fredi, @function
_Z4fredi:
.LFB249:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movl	%edi, -36(%rbp)
	call	_ZNSt6chrono3_V212system_clock3nowEv@PLT
	movq	%rax, -16(%rbp)
	movl	-36(%rbp), %eax
	movl	%eax, %edi
	call	_ZL3fooi
	movl	%eax, -20(%rbp)
	call	_ZNSt6chrono3_V212system_clock3nowEv@PLT
	movq	%rax, -8(%rbp)
	movl	-20(%rbp), %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE249:
	.size	_Z4fredi, .-_Z4fredi
	.ident	"GCC: (Funtoo 7.4.1-r6) 7.4.1 20181207"
	.section	.note.GNU-stack,"",@progbits
