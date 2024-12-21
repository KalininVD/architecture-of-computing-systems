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


# macro for sleeping for the specified time
# %time parameter is the time to sleep in milliseconds (immediate integer value)
.macro sleep(%time)
	stack_push_int(a0) # save the value in a0 register to the program stack as it will be overwritten
	stack_push_int(a7) # save the value in a7 register to the program stack as it will be overwritten

	li a0 %time # load the time to sleep to a0 register
    li a7 32 # set command code to 32 (sleep command)
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