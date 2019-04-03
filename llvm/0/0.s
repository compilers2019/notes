	.text
	.file	"0.c"
	.globl	add1                    # -- Begin function add1
	.p2align	4, 0x90
	.type	add1,@function
add1:                                   # @add1
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	%edi, -4(%rbp)
	movl	%esi, -8(%rbp)
	movl	-4(%rbp), %esi
	addl	-8(%rbp), %esi
	movl	%esi, %eax
	popq	%rbp
	retq
.Lfunc_end0:
	.size	add1, .Lfunc_end0-add1
	.cfi_endproc
                                        # -- End function

	.ident	"clang version 6.0.0 (tags/RELEASE_600/final)"
	.section	".note.GNU-stack","",@progbits
