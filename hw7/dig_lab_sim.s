.data
	.global display_digit
	.global clear_indicator
	.global display_dot

	# Digits lookup table:
	#  0 -> digit 0 for the display
	#  1 -> digit 1 for the display
	#  ...
	#  15 -> digit F for the display
	digits_lookup_table:
		.byte 0x3f # '0' digit
		.byte 0x06 # '1' digit
		.byte 0x5b # '2' digit
		.byte 0x4f # '3' digit
		.byte 0x66 # '4' digit
		.byte 0x6d # '5' digit
		.byte 0x7d # '6' digit
		.byte 0x07 # '7' digit
		.byte 0x7f # '8' digit
		.byte 0x6f # '9' digit
		.byte 0x77 # 'A' digit
		.byte 0x7c # 'B' digit
		.byte 0x39 # 'C' digit
		.byte 0x5e # 'D' digit
		.byte 0x79 # 'E' digit
		.byte 0x71 # 'F' digit


.text

# Subroutine to display a digit to the RARS Digital Lab Sim
# The digit is represented with 4 lowest bits of the a0 register
# If the value in a0 is greater than 16, dot will be displayed
# Indicator index is passed in the a1 (1 for left indicator, 0 for right indicator)
display_digit:
	la t0 digits_lookup_table # load the address of the lookup table
	andi t1 a0 0xF # save 4 lowest bits of a0 to t1
	add t0 t0 t1 # now t0 contains the address of the digit in lookup table
	lbu t2 (t0) # t2 is the representation of the digit

	srli t3 a0 4 # t3 = a0 >> 4
	snez t3 t3 # if t3 > 0 then a0 >= 16, so need to display the dot
	slli t3 t3 7 # now t3 is the mask for the dot symbol
	or t4 t3 t2 # add 7-th bit for the dot symbol if needed

	lui t5 0xFFFF0 # load MMIO address base (0xFFFF0000)
	add t6 t5 a1 # move to the left or right indicator
	sb t4 0x10(t6) # write the digit to the address 0xFFFF0010 + a1
	ret # return to the main program


# Subroutine for clearing the specified (left or right) indicator of the Digital Lab Sim
# Indicator index is passed in the a0 register (1 for left indicator, 0 for right indicator)
clear_indicator:
	lui t0 0xFFFF0 # load MMIO address base (0xFFFF0000)
	add t1 t0 a0 # move to the left or right indicator
	sb zero 0x10(t1) # clear the indicator at 0xFFFF0010 + a0
	ret # return to the main program


# Subroutine for printing the dot '.' symbol on the right indicator of the Digital Lab Sim
# Firstly clears the left indicator
display_dot:
	lui t0 0xFFFF0 # load MMIO address base (0xFFFF0000)
	sb zero 0x11(t0) # clear the left indicator
	li t1 0x80 # load the dot representation to t1
	sb t1 0x10(t0) # write the dot to the right indicator
	ret # return to the main program