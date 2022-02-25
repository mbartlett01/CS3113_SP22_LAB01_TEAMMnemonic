.section .data
# This example does not make use of the data section
# Creation of a temp list to run bubble sort on -> no nodes created 
data_items:
     .quad 13,167,5,1,200,4,-1
#Initialize the addresses to zero
addresses:
     .quad 0,0,0,0,0,0,0,0,0,0
.section .text
# The .text section is our executable code.

# We need to make the symbol _start available to the loader (ld) and we do this
# with .globl	
.globl _start
_start:

	# Fill in the addresses array
	call _fill_in_addesses

	#Sort the linked list
	leaq addresses, %rcx
	call _insertion_sort

	#Load all variable into %rab to check if it is sorted
	#Start index variable at 0
	movq $0, %rdi
	_test_loop:
		#Move each element into %rax
		movq addresses(,%rdi,8), %rax
		movq (%rax), %rbx
		#Exit loop if last element is -1
		cmpq $-1, %rbx
		je _end_test_loop
		#Increment the index variable
		incq %rdi
		jmp _test_loop
	_end_test_loop:

	jmp _exit_x86_64bit


# take two params (a,b) in %rdi and %rsi, multiply
# them and return the result in rax
.type _fill_in_addresses, @function
_fill_in_addesses:
	# standard function stuff for call
	# 1. put the old base pointer register on the stack
	pushq	%rbp
	# 2. move the old stack pointer register
	#    to the base pointer register
	movq	%rsp, %rbp

	#Initialize the index variable
	movq $0x0, %rdi

	#Create a loop
	_start_loop:
		#Load the current value into rax
		movq data_items(,%rdi,8), %rax

		#Load the corresponding address into the addresses array
		leaq data_items(,%rdi,8), %rbx
		movq %rbx, addresses(,%rdi,8)

		#Increment the counter
		incq %rdi

		#Check to see if the current value is -1 and if so, jump to the end of the loop
		cmpq $-1, %rax
		je _end_of_loop

		#Loop 
		jmp _start_loop

	_end_of_loop:
	
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

#Swap Function used in bubble sort that swaps addresses stored in %rax and %rbx
.type _swap, @function
_swap:
	# standard function stuff for call
	# 1. put the old base pointer register on the stack
	pushq	%rbp
	# 2. move the old stack pointer register
	#    to the base pointer register
	movq	%rsp, %rbp

	#swap the addresses in the addresses array
	movq %rax, addresses(,%rdi,8)
	decq %rdi
	movq %rbx, addresses(,%rdi,8)
	incq %rdi

	# Standard function callee stuff
	# 1. set the stack pointer to the base pointer value.
	#    This is where the caller believe the top of the
	#    stack is located.
	movq %rbp, %rsp
	# 2. restore the base pointer
	popq %rbp

	# return 
	ret

#Uses bubble sort to sort a linked list
#Passes the addresses of linked list in %rcx
.type _bubble_sort, @function
_bubble_sort:
	# standard function stuff for call
	# 1. put the old base pointer register on the stack
	pushq	%rbp
	# 2. move the old stack pointer register
	#    to the base pointer register
	movq	%rsp, %rbp

	# Start bubble sort
	#%rax first element
	#%rbx second element
	#%rdx flag saying if we have swapped (0 = no swap, 1 = swap)
	_start_outer_bubble_loop:
		#Start index variable at 0
		movq $0, %rdi
		movq $0, %rdx
		_start_inner_bubble_loop:
			#Load the address of the first two values into %rax and %rbx
			movq (%rcx,%rdi,8), %rax
			incq %rdi
			movq (%rcx,%rdi,8), %rbx
			#Exit loop if last element is -1
			cmpq $-1, (%rbx)
			je _end_inner_bubble_loop
			#Compare the values and swap if necessary
			#Push the addresses to reduce register use
			pushq %rax
			pushq %rbx
			pushq (%rax)
			pushq (%rbx)
			#Get the actual values at the addresses
			popq %rbx
			popq %rax
			#Compare the value of the two elements
			cmpq %rbx, %rax
			#Return the addresses to the registers
			popq %rbx
			popq %rax
			#Decide to swap or not
			jle _no_swap
			call _swap
			#Set the swap flag to true
			movq $1, %rdx
			_no_swap:
			jmp _start_inner_bubble_loop
		_end_inner_bubble_loop:
		#Check to see if no swaps occurred
		cmpq $0, %rdx
		je _end_outer_bubble_loop
		jmp _start_outer_bubble_loop
	_end_outer_bubble_loop:

	# Standard function callee stuff
	# 1. set the stack pointer to the base pointer value.
	#    This is where the caller believe the top of the
	#    stack is located.
	movq %rbp, %rsp
	# 2. restore the base pointer
	popq %rbp

	# return 
	ret

#Uses Insertion sort to sort a linked list
#Passes the addresses of linked list in %rcx
.type _insertion_sort, @function
_insertion_sort:
	# standard function stuff for call
	# 1. put the old base pointer register on the stack
	pushq	%rbp
	# 2. move the old stack pointer register
	#    to the base pointer register
	movq	%rsp, %rbp

	#%rdi outer loop index
	#%rsi inner loop index
	#Start insertion sort
	#Initialize the index variables
	movq $1, %rdi
	_start_outer_insertion_loop:
		#Load the value we are currently moving into %rax
		movq (%rcx,%rdi,8), %rax
		#Break out of the loop if the value is -1
		cmpq $-1, (%rax)
		je _end_outer_insertion_loop
		#Reset the inner loop index
		movq %rdi, %rsi
		decq %rsi
		#Start inner loop
		_start_inner_insertion_loop:
			#Load the next value to compare into %rbx
			movq (%rcx,%rsi,8), %rbx
			#Compare the values and shift if necessary
			#Push the addresses to reduce register use
			pushq %rax
			pushq %rbx
			pushq (%rax)
			pushq (%rbx)
			#Get the actual values at the addresses
			popq %rbx
			popq %rax
			#Compare the value of the two elements
			cmpq %rbx, %rax
			#Return the addresses to the registers
			popq %rbx
			popq %rax
			#Determine if wee need to shift or not
			jge _no_shift
			#shift the value in %rbx to the right by one
			incq %rsi
			movq %rbx, (%rcx,%rsi,8)
			decq %rsi
			_no_shift:
			#Check to see if we need to break out of the loop
			decq %rsi
			cmpq $-1, %rsi
			je _end_inner_insertion_loop
			#Jump back to start of the inner loop
			jmp _start_inner_insertion_loop
		_end_inner_insertion_loop:
		#Jump back to the start of the outer loop
		incq %rdi
		jmp _start_outer_insertion_loop
	_end_outer_insertion_loop:

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
	
	
