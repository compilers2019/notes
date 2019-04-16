	.file	"test.cpp"
	.text
	.section	.rodata
	.type	_ZStL19piecewise_construct, @object
	.size	_ZStL19piecewise_construct, 1
_ZStL19piecewise_construct:
	.zero	1
.LC0:
	.string	"aaa"
	.section	.text._Z1fi,"axG",@progbits,_Z1fi,comdat
	.weak	_Z1fi
	.type	_Z1fi, @function
_Z1fi:
.LFB984:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA984
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r12
	pushq	%rbx
	subq	$16, %rsp
	.cfi_offset 12, -24
	.cfi_offset 3, -32
	movl	%edi, -20(%rbp)
	cmpl	$2, -20(%rbp)
	jne	.L2
	movl	$16, %edi
	call	__cxa_allocate_exception@PLT
	movq	%rax, %rbx
	leaq	.LC0(%rip), %rsi
	movq	%rbx, %rdi
.LEHB0:
	call	_ZNSt12out_of_rangeC1EPKc@PLT
.LEHE0:
	movq	_ZNSt12out_of_rangeD1Ev@GOTPCREL(%rip), %rax
	movq	%rax, %rdx
	leaq	_ZTISt12out_of_range(%rip), %rsi
	movq	%rbx, %rdi
.LEHB1:
	call	__cxa_throw@PLT
.L2:
	movl	-20(%rbp), %eax
	imull	-20(%rbp), %eax
	jmp	.L6
.L5:
	movq	%rax, %r12
	movq	%rbx, %rdi
	call	__cxa_free_exception@PLT
	movq	%r12, %rax
	movq	%rax, %rdi
	call	_Unwind_Resume@PLT
.LEHE1:
.L6:
	addq	$16, %rsp
	popq	%rbx
	popq	%r12
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE984:
	.globl	__gxx_personality_v0
	.section	.gcc_except_table._Z1fi,"aG",@progbits,_Z1fi,comdat
.LLSDA984:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE984-.LLSDACSB984
.LLSDACSB984:
	.uleb128 .LEHB0-.LFB984
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L5-.LFB984
	.uleb128 0
	.uleb128 .LEHB1-.LFB984
	.uleb128 .LEHE1-.LEHB1
	.uleb128 0
	.uleb128 0
.LLSDACSE984:
	.section	.text._Z1fi,"axG",@progbits,_Z1fi,comdat
	.size	_Z1fi, .-_Z1fi
	.text
	.globl	_Z2f2i
	.type	_Z2f2i, @function
_Z2f2i:
.LFB988:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	movl	-4(%rbp), %eax
	imull	-4(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE988:
	.size	_Z2f2i, .-_Z2f2i
	.local	_ZZ5maintvE1x
	.comm	_ZZ5maintvE1x,4,4
	.local	_ZGVZ5maintvE1x
	.comm	_ZGVZ5maintvE1x,8,8
	.local	_ZZ5maintvE1y
	.comm	_ZZ5maintvE1y,4,4
	.local	_ZGVZ5maintvE1y
	.comm	_ZGVZ5maintvE1y,8,8
	.globl	_Z5maintv
	.type	_Z5maintv, @function
_Z5maintv:
.LFB989:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA989
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r12
	pushq	%rbx
	.cfi_offset 12, -24
	.cfi_offset 3, -32
	movzbl	_ZGVZ5maintvE1x(%rip), %eax
	testb	%al, %al
	sete	%al
	testb	%al, %al
	je	.L10
	leaq	_ZGVZ5maintvE1x(%rip), %rdi
	call	__cxa_guard_acquire@PLT
	testl	%eax, %eax
	setne	%al
	testb	%al, %al
	je	.L10
	movl	$0, %r12d
	movl	$2, %edi
.LEHB2:
	call	_Z1fi
.LEHE2:
	movl	%eax, _ZZ5maintvE1x(%rip)
	leaq	_ZGVZ5maintvE1x(%rip), %rdi
	call	__cxa_guard_release@PLT
.L10:
	movzbl	_ZGVZ5maintvE1y(%rip), %eax
	testb	%al, %al
	sete	%al
	testb	%al, %al
	je	.L11
	leaq	_ZGVZ5maintvE1y(%rip), %rdi
	call	__cxa_guard_acquire@PLT
	testl	%eax, %eax
	setne	%al
	testb	%al, %al
	je	.L11
	movl	$6, %edi
	call	_Z2f2i
	movl	%eax, _ZZ5maintvE1y(%rip)
	leaq	_ZGVZ5maintvE1y(%rip), %rdi
	call	__cxa_guard_release@PLT
.L11:
	jmp	.L15
.L14:
	movq	%rax, %rbx
	testb	%r12b, %r12b
	jne	.L13
	leaq	_ZGVZ5maintvE1x(%rip), %rdi
	call	__cxa_guard_abort@PLT
.L13:
	movq	%rbx, %rax
	movq	%rax, %rdi
.LEHB3:
	call	_Unwind_Resume@PLT
.LEHE3:
.L15:
	popq	%rbx
	popq	%r12
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE989:
	.section	.gcc_except_table,"a",@progbits
.LLSDA989:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE989-.LLSDACSB989
.LLSDACSB989:
	.uleb128 .LEHB2-.LFB989
	.uleb128 .LEHE2-.LEHB2
	.uleb128 .L14-.LFB989
	.uleb128 0
	.uleb128 .LEHB3-.LFB989
	.uleb128 .LEHE3-.LEHB3
	.uleb128 0
	.uleb128 0
.LLSDACSE989:
	.text
	.size	_Z5maintv, .-_Z5maintv
	.hidden	DW.ref.__gxx_personality_v0
	.weak	DW.ref.__gxx_personality_v0
	.section	.data.rel.local.DW.ref.__gxx_personality_v0,"awG",@progbits,DW.ref.__gxx_personality_v0,comdat
	.align 8
	.type	DW.ref.__gxx_personality_v0, @object
	.size	DW.ref.__gxx_personality_v0, 8
DW.ref.__gxx_personality_v0:
	.quad	__gxx_personality_v0
	.ident	"GCC: (Funtoo 7.4.1-r6) 7.4.1 20181207"
	.section	.note.GNU-stack,"",@progbits
