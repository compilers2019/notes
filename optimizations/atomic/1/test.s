	.file	"test.cpp"
	.text
	.p2align 4,,15
	.globl	_Z4fredi
	.type	_Z4fredi, @function
_Z4fredi:
.LFB262:
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	movl	%edi, %ebx
	call	_ZNSt6chrono3_V212system_clock3nowEv@PLT
	movl	%ebx, %edi
	call	_Z3fooi@PLT
	movl	%eax, %ebx
	call	_ZNSt6chrono3_V212system_clock3nowEv@PLT
	movl	%ebx, %eax
	popq	%rbx
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE262:
	.size	_Z4fredi, .-_Z4fredi
	.ident	"GCC: (Funtoo 7.4.1-r6) 7.4.1 20181207"
	.section	.note.GNU-stack,"",@progbits
