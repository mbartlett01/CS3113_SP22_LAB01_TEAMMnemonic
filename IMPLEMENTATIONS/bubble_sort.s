# This is a set of examples in a series of using x86 (32bit) and x86_64 (64bit) assembly
# instructions. Assemble and link these files and trace through the executable with the
# debugger. The idea is to get a sense of how to use these instructions, so you can rip
# this and use it in your own code
#
# If you have any questions, comments, concerns, or find bugs, then just send me an email.
# 
# - richard.m.veras@ou.edu

# Resources to check out:
# https://www.cs.princeton.edu/courses/archive/spr18/cos217/lectures/15_AssemblyFunctions.pdf
# https://www.cs.uaf.edu/2015/fall/cs301/lecture/09_14_call.html
# http://6.s081.scripts.mit.edu/sp18/x86-64-architecture-guide.html
# https://cs61.seas.harvard.edu/site/2018/Asm2/
# https://cs.lmu.edu/~ray/notes/gasexamples/
# https://flint.cs.yale.edu/cs421/papers/x86-asm/asm.html#calling	
# https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf

	
.section .data
# This example does not make use of the data section
# Creation of a temp list to run bubble sort on -> no nodes created 
data_items
     .long 13,167,4,200,5,75,10,14,1,60,2,111,66,55,0
.section .text
# The .text section is our executable code.

# We need to make the symbol _start available to the loader (ld) and we do this
# with .globl	
.globl _start
_start:

	# Caller side of the function
	# If we are using any of the caller saved registers, then we
	# need to save them to the stack before making the function call.
	# After the function call we will restore them.
	#
	# the caller saved registers are:
	# %rax, %rcx, %rdx, %rdi, %rsi, %r8, %r9, %r10, %r11
	#
	# In general before and after the function call we will do the following:
	#
	#
	# pushq %rax # Note: Also the return value
	# pushq %rcx # Note: Also fourth parameter
	# pushq %rdx # Note: Also third parameter
	# pushq %rdi # Note: Also first parameter
	# pushq %rsi # Note: Also second parameter
	# pushq %r8  # Note: Also fifth parameter
	# pushq %r9  # Note: Also sixth parameter
	# pushq %r10
	# pushq %r11
	#
	# ... Move the values for the first six parameters to %rdi, %rsi, %rdx, %rcx, %r8, %r9
	# ... Everything after that is stored on the stack: (towards_bottom), param8,..., paramN, (stack_top)
	#
	# call some_function 
	#
	# ... Grab and do something with the return value in %rax
	#
	# popq %r11
	# popq %r10
	# popq %r9
	# popq %r8
	# popq %rsi
	# popq %rdi
	# popq %rdx
	# popq %rcx
	# popq %rax
	#
	# Note: that some of these registers are used in the function call
	#       so we can get clever in how we use them. For example if we
	#       are not using a particular register, then we do not need to
	#       save it's value.



	# Let's call our function. We haven't used any of the caller saved
	# registers, so we don't need to deal with them.

	# TEST: Examine the stack in gdb before, during and after the function call.
	#   The following command will show us the first 8 quadwords (64bit) at the
	#   top of the stack.
	#
	#   (gdb) x/8gx $rsp
	#
	
	# We want to multiply 3 by 7
	movq $3, %rdi
	movq $7, %rsi
	call _my_mul_2_params

	# the return value should be in %rax
	

	jmp _exit_x86_64bit


# take two params (a,b) in %rdi and %rsi, multiply
# them and return the result in rax
.type _my_mul_2_params, @function
_my_mul_2_params:
	# standard function stuff for callee
	# 1. put the old base pointer register on the stack
	pushq	%rbp
	# 2. move the old stack pointer register
	#    to the base pointer register
	movq	%rsp, %rbp

	# TEST: Examine the stack in gdb before, during and after the function call.
	#   The following command will show us the first 8 quadwords (64bit) at the
	#   top of the stack.
	#
	#   (gdb) x/8gx $rsp
	#

	# callee saved registers: If the callee needs to use these registers
	#   then it is is the callee's responsibility to first save the value
	#   of these registers on the stack before using these register, then
	#   restore the value of these registers before returning. We see this
	#   every time with %rbp, and sort of %rsp... and indirectly with %rip
	#
	# The callee saved registers are:
	# %rbp, %rbx, %r12, %r13, %r14 and %r15
	#


	# The first six parameters are stored in:
	# %rdi, %rsi, %rdx, %rcx, %r8, %r9
	# All parameters after that are pushed on the stack by the
	# caller function


	# Here is the actual work performed by the function.
	movq %rdi, %rax
	imulq %rsi, %rax

	# the return value is in %rax

	
	# callee saved registers: if we used any of the callee saved
	#   we need to make sure to restore them before returning.
	
	# Standard function callee stuff
	# 1. set the stack pointer to the base pointer value.
	#    This is where the caller believe the top of the
	#    stack is located.
	movq %rbp, %rsp
	# 2. restore the base pointer
	popq %rbp

	# return 
	ret
	
_exit_x86_64bit:
	# This is slightly different because in x86_64 (64bit) we get the
	# syscall instruction, which provides more flexibility than int (interrupt)
	# so it is the defacto way for making system calls in 64bit binaries, in linux,
	# on systems with the x86_64 instruction set architecture.
	movq $60, %rax  # call number 60 -> exit
	movq $0x0, %rdi # return 0
	syscall #run kernel
	
	
