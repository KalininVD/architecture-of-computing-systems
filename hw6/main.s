.include "tools.i"

.eqv STRING_SIZE 256

.data
	.global main

	source_string: .space STRING_SIZE
	destination_string: .space STRING_SIZE
	string_length: .word 0

	test_str_1: .asciz "test string"
	test_str_1_length: .word 11

	test_str_2: .asciz "Lorem ipsum dolor sit amet, consectetuer adipiscing elit."
	test_str_2_length: .word 57

	test_str_3: .asciz "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Proin pharetra nonummy pede. Mauris et orci."
	test_str_3_length: .word 138

.text

main:
	print_string("Enter a string no longer than 255 characters: ")
	read_string(source_string, string_length, STRING_SIZE)

	la a0 destination_string
	la a1 source_string
	lw a2 string_length
	jal strncpy
	add_trailing_zero(destination_string, string_length)

	print_string("Original string: ")
	print_string_label(source_string)
	print_newline

	print_string("Copied string: ")
	print_string_label(destination_string)
	print_newline

	print_string("Testing predefined strings...")
	print_newline

	print_string("Test string #1: ")
	print_string_label(test_str_1)
	print_newline

	strncpy_macro(destination_string, test_str_1, test_str_1_length)

	print_string("Copied version: ")
	print_string_label(destination_string)
	print_newline

	print_string("Test string #2: ")
	print_string_label(test_str_2)
	print_newline

	strncpy_macro(destination_string, test_str_2, test_str_2_length)

	print_string("Copied version: ")
	print_string_label(destination_string)
	print_newline

	print_string("Test string #3: ")
	print_string_label(test_str_3)
	print_newline

	strncpy_macro(destination_string, test_str_3, test_str_3_length)

	print_string("Copied version: ")
	print_string_label(destination_string)
	print_newline

	print_string("Testing finished! Exiting...")
	exit