.include "tools.i"

.data
	.global main

	# Spaces to save registers inside the keyboard interrupt handler
	reg_space_1: .space 4
	reg_space_2: .space 4

	# Trailing zeros lookup table
	zeros_lookup_table:
		.byte 0
		.byte 0
		.byte 1
		.byte 0
		.byte 2
		.byte 0
		.byte 1
		.byte 0
		.byte 3

.text

main:
	mv s1 zero # starting with digit 0
	li s2 32 # number of digits to display (currently 32)

print_loop:
	li a0 1 # clear the right indicator
	jal clear_indicator

	mv a0 s1 # move the digit to the a0 register
	li a1 0 # print the digit to the left indicator
	jal display_digit

	sleep(1000) # sleep for 1 second

	li a0 0 # clear the left indicator
	jal clear_indicator

	mv a0 s1 # move the digit to the a0 register
	li a1 1 # print the digit to the right indicator
	jal display_digit

	sleep(1000) # sleep for 1 second

	addi s1 s1 1 # increase the digit
	bne s1 s2 print_loop # finish the loop when all digits are printed

	# clear left indicator and print the dot '.' symbol on the right indicator
	jal display_dot

keyboard_waiter:
	lui s0 0xFFFF0 # load base MMIO address 0xFFFF0000 to s0
	la t0 kb_handler # register keyboard interrupt handler
	csrw t0 utvec # save keyboard_handler address to utvec
	csrsi ustatus 1 # enable exceptions
	csrsi uie 0x100 # enable handling of this specific interrupt

	li t0 0x8F
	sb t0 0x12(s0) # set the 7-th bit of 0xFFFF0012 to 1 to enable interrupts in Digital Lab Sim

	li s1 0 # keyboard buttons pressed counter
	li s2 16 # max keyboard buttons pressed (currently 16)

wait_loop:
	wfi # wait for the next keyboard button pressed
	addi s1 s1 1 # increase the counter after handling interrupt
	bne s1 s2 wait_loop # if the counter is less than max button number, wait for the next button

	exit # exit with error code 0


kb_handler:
	csrw a0 uscratch # save a0 register
	sw a1 reg_space_1 a0 # save a1 register
	sw ra reg_space_2 a1 # save ra register

	# scan row #1
	li a0 1
	sb a0 0x12(s0)
	lbu a1 0x14(s0)
	bnez a1 key_detected

	# scan row #2
	li a0 2
	sb a0 0x12(s0)
	lbu a1 0x14(s0)
	bnez a1 key_detected

	# scan row #3
	li a0 4
	sb a0 0x12(s0)
	lbu a1 0x14(s0)
	bnez a1 key_detected

	# scan row #4
	li a0 8
	sb a0 0x12(s0)
	lbu a1 0x14(s0)
	bnez a1 key_detected

	# if no key is pressed, print dot symbol '.'
	jal display_dot
	j kb_handler_epilogue # end exit the keyboard interrupt handler

key_detected:
	# get row and column indexes from a0 and a1 registers
	la ra zeros_lookup_table
	add a0 ra a0
	lbu a0 (a0)
	srli a1 a1 4
	add a1 ra a1
	lbu a1 (a1)

	# now a0 is row index (i) and a1 is column index (j)
	slli a0 a0 2
	or a0 a0 a1 # digit = 4 * i + j
	li a1 0 # print the digit to the right indicator
	jal display_digit

kb_handler_epilogue:
	li a0 0x8F # set the 7-th bit of 0xFFFF0012 to 1 to enable interrupts in Digital Lab Sim
	sb a0 0x12(s0)
	lw ra reg_space_2 # restore ra register
	lw a1 reg_space_1 # restore a1 register
	csrr a0 uscratch # restore a0 register
	uret # return from the interrupt handler