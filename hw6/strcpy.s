.data
	.global strncpy

.text

# Strncpy subroutine
#  Parameters: a0 - destination string, a1 - source string, a2 - number of characters to copy
strncpy:
	mv t0 a0
	mv t1 a1
	mv t2 a2

strncpy_loop:
	# If the number of characters to copy is less than 1, finish the loop
	blez t2 strncpy_end

	# Copy a character from the source string to the destination string
	lb t3 (t1)
	sb t3 (t0)

	# Move to the next character to copy
	addi t0 t0 1
	addi t1 t1 1
	addi t2 t2 -1

	j strncpy_loop

strncpy_end:
	# Return to the main program
	ret