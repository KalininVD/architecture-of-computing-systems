.data
    .global main

    prompt_length: .asciz "Enter array length (1 to 10): "
    prompt_element: .asciz "Enter array element: "
    prompt_contents: .asciz "Here are the array elements: "
    prompt_sum: .asciz "Accumulated sum of array elements: "
    prompt_count: .asciz "Number of summed elements of array up to overflow: "
    prompt_odd: .asciz "Number of odd elements of array: "
    prompt_even: .asciz "Number of even elements of array: "

    newline: .asciz "\n"
    space: .asciz " "

    overflow_error: .asciz "Overflow reached!"
    length_error: .asciz "Only arrays of length 1 to 10 are supported!"

    .align 2
    n: .word 0
    n_min: .word 1
    n_max: .word 10
    array: .space 40

.text

main:
    # Ask user to enter the array length
    la a0 prompt_length
    li a7 4
    ecall

    # Read array length
    li a7 5
    ecall

    # Save array length
    la t0 n
    sw a0 (t0)

    # Check array length
    lw t1 n
    lw t2 n_min
    lw t3 n_max
    blt t1 t2 length_check_failed
    bgt t1 t3 length_check_failed

    # Fill the array
    la s0 array
    lw t4 n

fill_array:
    # Ask user to enter next array element
    la a0 prompt_element
    li a7 4
    ecall

    # Read new array element
    li a7 5
    ecall

    # Save new array element
    sw a0 (s0)

    # Move to next array element
    addi s0 s0 4
    addi t4 t4 -1

    # If the array is full, then move to the array printing
    beqz t4 print_array

    # Otherwise, read the next array element
    j fill_array

print_array:
    # Print the array
    la a0 prompt_contents
    li a7 4
    ecall

    lw t5 n
    la s0 array

print_array_elements:
    # Print the array element
    lw a0 (s0)
    li a7 1
    ecall

    # Print the space
    la a0 space
    li a7 4
    ecall

    # Move to the next array element
    addi s0 s0 4
    addi t5 t5 -1

    # If the array is not full, then print the next array element
    bnez t5 print_array_elements

    # Print the newline
    la a0 newline
    li a7 4
    ecall

sum_calculation:
    lw t6 n
    la s0 array
    mv s1 zero

sum_calculation_loop:
    # Add the current array element to the sum
    lw s2 (s0)
    add s3 s1 s2

    # Check for the overflow
    sltz t1 s1
    sltz t2 s2
    sub t2 t2 t1
    # If the signs of the operands are different, no overflow possible
    bnez t2 save_sum
    
    # If the operands have the same sign, check the sign of the sum
    sltz t4 s3
    bne t1 t4 overflow_fail

save_sum:
    # If the sum is correct, then save the new sum
    mv s1 s3

    # Move to the next array element
    addi s0 s0 4
    addi t6 t6 -1

    # If the array is not fully handled, then continue summing
    bnez t6 sum_calculation_loop

    # Otherwise, print the sum
    j print_sum

overflow_fail:
    # Print the message to the user
    la a0 overflow_error
    li a7 4
    ecall

    la a0 newline
    li a7 4
    ecall

    # Inform the user about the number of elements summed
    la a0 prompt_count
    li a7 4
    ecall

    # Print the number of elements summed
    lw a0 n
    sub a0 a0 t6
    li a7 1
    ecall

    la a0 newline
    li a7 4
    ecall
    
    # Save the last correct sum
    mv s3 s1

print_sum:
    # Print the message to the user
    la a0 prompt_sum
    li a7 4
    ecall

    # Print the sum
    li a7 1
    mv a0 s3
    ecall

    # Exit the program
    li a7 10  
    ecall

length_check_failed:
    # Print the error message to the user
    la a0 length_error
    li a7 4
    ecall

    # Exit the program with error code 1
    li a0 1
    li a7 93
    ecall
