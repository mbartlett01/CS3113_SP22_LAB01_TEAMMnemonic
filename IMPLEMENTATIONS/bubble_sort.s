.section .data
# This example does not make use of the data section
# Creation of a temp list to run bubble sort on -> no nodes created 
data_items:
	.quad 3,1,4,6,2,5,-1
#Initialize the addresses to zero
next_address:
	.quad 0,0,0,0,0,0,0,0,0,0
previous_address:
	.quad -1,0,0,0,0,0,0,0,0,0
head:
	.quad 0

.section .text
# The .text section is our executable code.

# We need to make the symbol _start available to the loader (ld) and we do this
# with .globl	
.globl _start
_start:
	# Fill in the addresses array
	leaq data_items, %rcx
	movq %rcx, (head)
	leaq next_address, %rdx
	call _fill_in_addresses

	_break_point:

	#Sort the linked list
	leaq next_address, %rcx
	leaq head, %rdx
	call _bubble_sort

	#Load all variable into %rab to check if it is sorted
	#Start index variable at 0
	movq (head), %rax
	movq (%rax), %rbx
	movq $0, %rdi
	_test_loop:
		#Move each element into %rax
		movq (%rcx,%rdi,8), %rax
		movq (%rax), %rbx
		#Exit loop if last element is -1
		cmpq $-1, %rbx
		je _end_test_loop
		#Increment the index variable
		incq %rdi
		jmp _test_loop
	_end_test_loop:

	jmp _exit_x86_64bit

#fill in the next address array
#pass the data array in %rcx and the address array in %rdx
.type _fill_in_addresses, @function
_fill_in_addresses:
	# standard function stuff for call
	# 1. put the old base pointer register on the stack
	pushq	%rbp
	# 2. move the old stack pointer register
	#    to the base pointer register
	movq	%rsp, %rbp

	#Initialize the index variable
	movq $1, %rdi

	#Create a loop
	_start_address_loop:
		#Load the current value into rax
		movq (%rcx,%rdi,8), %rax
		#Load the corresponding address into the addresses array
		leaq (%rcx,%rdi,8), %rbx
		decq %rdi
		movq %rbx, (%rdx,%rdi,8)
		incq %rdi
		#Increment the counter
		incq %rdi
		#Check to see if the current value is -1 and if so, jump to the end of the loop
		cmpq $-1, %rax
		je _end_address_loop
		#Loop 
		jmp _start_address_loop
	_end_address_loop:
	
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

#fill in the previous address array
#pass the data array in %rcx and the address array in %rdx
.type _fill_in_previous_addresses, @function
_fill_in_previous_addresses:
	# standard function stuff for call
	# 1. put the old base pointer register on the stack
	pushq	%rbp
	# 2. move the old stack pointer register
	#    to the base pointer register
	movq	%rsp, %rbp

	#Initialize the index variable
	movq $0x0, %rdi

	#Create a loop
	_start_prev_address_loop:
		#Load the current value into rax
		movq (%rcx,%rdi,8), %rax
		#Load the corresponding address into the addresses array
		leaq (%rcx,%rdi,8), %rbx
		incq %rdi
		movq %rbx, (%rdx,%rdi,8)
		#Check to see if the current value is -1 and if so, jump to the end of the loop
		cmpq $-1, %rax
		je _end_prev_address_loop
		#Loop 
		jmp _start_prev_address_loop
	_end_prev_address_loop:
	
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

	#Check to see if we are dealing with the head of the array
	cmpq $0, %rdi
	je _head_swap

	#swap the addresses in the addresses array
	movq %rax, (%rcx,%rdi,8)
	decq %rdi
	movq %rbx, (%rcx,%rdi,8)
	incq %rdi
	jmp _end_head_swap

	#Swap the value for the one in the head of the array
	_head_swap:
	movq %rax, (%rcx,%rdi,8)
	movq %rbx, (%rdx)
	_end_head_swap:

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
#Passes the addresses of linked list in %rcx amd the head of the linked list in %rdx
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
	#%rsi flag saying if we have swapped (0 = no swap, 1 = swap)
	_start_outer_bubble_loop:
		#Start index variable at 0
		movq $0, %rdi
		movq $0, %rsi
		#load the head of the list into %rax to start
		movq (%rdx), %rax
		_start_inner_bubble_loop:
			#Load the address of the next value into %rbx
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
			movq $1, %rsi
			_no_swap:
			#Load the new values into %rax
			movq (%rcx,%rdi,8), %rax
			incq %rdi
			jmp _start_inner_bubble_loop
		_end_inner_bubble_loop:
		#Check to see if no swaps occurred
		cmpq $0, %rsi
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
#Uses %rax, %rbx, %rdi, %rsi
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
			#Determine if we need to shift or insert
			jge _end_inner_insertion_loop
			#Shift the value by 1 if you are not inserting it
			#shift the value in %rbx to the right by one
			incq %rsi
			movq %rbx, (%rcx,%rsi,8)
			decq %rsi
			#Check to see if we need to break out of the loop
			decq %rsi
			cmpq $-1, %rsi
			je _end_inner_insertion_loop
			#Jump back to start of the inner loop
			jmp _start_inner_insertion_loop
		_end_inner_insertion_loop:
		#insert the value into the correct position
		incq %rsi
		movq %rax, (%rcx,%rsi,8)
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
	
	
