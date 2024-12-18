# simple macro for saving the value in register %reg to the stack
# the value is taken from register %reg as a 32-bit integer
.macro stack_push_int(%reg)
	addi sp sp -4 # move stack pointer 1 word down
	sw %reg (sp) # save integer value to the stack
.end_macro

# simple macro for restoring the last value in the stack to the register %reg
# the value is taken from stack as a 32-bit integer
.macro stack_pop_int(%reg)
	lw %reg (sp) # copy the value on the top of the stack to %reg
	addi sp sp 4 # move stack pointer 1 word up
.end_macro


# simple macro for performing the environment call to print an integer value in a0 register to the console
.macro print_int_a0
	stack_push_int(a7) # save the value in a7 register to the program stack as it will be overwritten
	
	li a7 1 # set command code to 1 (print integer in a0 to console)
	ecall # make the env call
	
	stack_pop_int(a7) # restore the value of a7 register from the stack
.end_macro

# macro for printing an integer value from any register to the console
# parameter %reg must be an integer register
.macro print_int(%reg)
	stack_push_int(a0) # save the value in a0 register to the program stack as it will be overwritten
	
	mv a0 %reg # copy the value in %reg to a0
	print_int_a0 # print the value in a0 to the console
	
	stack_pop_int(a0) # restore the value of a0 register from the stack
.end_macro


# macro for printing a string to the console
# parameter %out_string must be a string in ""
.macro print_string(%out_string)
.data
	output_string: .asciz %out_string # load the string to a temporary label for the convenience of making env call
.text
	stack_push_int(a0) # save the value in a0 register to the program stack as it will be overwritten
	stack_push_int(a7) # save the value in a7 register to the program stack as it will be overwritten
	
	la a0 output_string # load the address of temporary label to a0 register
	li a7 4 # set command code to 4 (print string by address in a0 to the console)
	ecall # make the env call
	
	stack_pop_int(a7) # restore the value of a7 register from the stack
	stack_pop_int(a0) # restore the value of a0 register from the stack
.end_macro

# simple macro to start a new line of text in the console (print the '\n' symbol)
.macro print_newline
	print_string("\n") # print the '\n' symbol to the console via print_string macro
.end_macro


# macro for printing a string from a label to the console
# parameter %label must be a string label in .data
.macro print_string_label(%label)
	stack_push_int(a0) # save the value in a0 register to the program stack as it will be overwritten
	stack_push_int(a7) # save the value in a7 register to the program stack as it will be overwritten
	
	la a0 %label # load the address of the label to a0 register
	li a7 4 # set command code to 4 (print string by address in a0 to the console)
	ecall # make the env call
	
	stack_pop_int(a7) # restore the value of a7 register from the stack
	stack_pop_int(a0) # restore the value of a0 register from the stack
.end_macro


# special macro for finishing the program execution with the specified error code
# parameter %exit_code must be an integer value (immediate)
.macro exit_with_code(%exit_code)
	li a0 %exit_code # load the provided error code to a0 register
	li a7 93 # set command code to 93 (exit with the error code stored in a0 register)
	ecall # make the env call
.end_macro

# simple macro for exiting the program with the default error code 0 (no errors)
.macro exit
	exit_with_code(0) # call the exit_with_code macro
.end_macro


# Macro for reading a string from the console
# Parameter %string must be a string label in .data
# Parameter %length must be a 32-bit integer register
# Parameter %max_length must be a 32-bit integer immediate
.macro read_string(%string, %length, %max_length)
	stack_push_int(a0) # save the value in a0 register to the program stack as it will be overwritten
	stack_push_int(a1) # save the value in a1 register to the program stack as it will be overwritten
	stack_push_int(a7) # save the value in a7 register to the program stack as it will be overwritten

	la a0 %string # load the address of the string into a0 register
	li a1 %max_length # load the maximum length of the string into a1 register
	li a7 8 # set command code to 8 (read string from the console)
	ecall # make the env call

	mv t0 zero # Set string length to 0
	la t1 %string # Load the address of the string into t1 register
	li t2 '\n' # Save the newline character into t2 register

read_string_loop:
	lb t3 (t1) # Load a character from the string into t3 register
	beq t2 t3 read_string_replace_newline # If the character is a newline, replace it with a zero
	addi t0 t0 1 # Increment the string length
	addi t1 t1 1 # Move to the next character in the string
	j read_string_loop # Loop until the end of the string is reached

read_string_replace_newline:
	sb zero (t1) # Replace the newline character with a zero
	sw t0 %length t4 # Store the string length at the length label

	stack_pop_int(a7) # restore the value of a7 register from the stack
	stack_pop_int(a1) # restore the value of a1 register from the stack
	stack_pop_int(a0) # restore the value of a0 register from the stack
.end_macro


# Macro for adding the trailing zero to the string
# Parameter %string must be a string label in .data
# Parameter %length must be a 32-bit integer register
.macro add_trailing_zero(%string, %length)
	# If the length of the string is less than 0, finish the macro
	lw t0 %length
	bltz t0 add_trailing_zero_end

	# Add the trailing zero to the string
	la t1 %string
	lw t2 %length
	add t1 t1 t2 # Move to the end of the string
	sb zero (t1) # Add the trailing zero

add_trailing_zero_end:
.end_macro


# Macro for using the strncpy subroutine
# Adds the trailing zero to the destination string
.macro strncpy_macro(%destination_str, %source_str, %length)
	la a0 %destination_str
	la a1 %source_str # Load the subroutine parameters into registers a0-a2
	lw a2 %length
	jal strncpy # Call the strncpy subroutine
	add_trailing_zero(%destination_str, %length) # Add the trailing zero to the destination string
.end_macro