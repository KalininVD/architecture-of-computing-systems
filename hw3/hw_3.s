.data
    .global main
    .global divide

    prompt_dividend: .asciz "Enter dividend: "
    prompt_divisor: .asciz "Enter divisor: "
    quotient_msg: .asciz "Quotient = "
    remainder_msg: .asciz "Remainder = "
    newline: .asciz "\n"
    div_by_zero_msg: .asciz "Cannot divide by zero!"

.text

main:
    # Ask user to enter dividend
    la a0 prompt_dividend
    li a7 4
    ecall

    # Read the dividend
    li a7 5
    ecall

    # Save the dividend to s0
    mv s0 a0

    # Ask user to enter divisor
    la a0 prompt_divisor
    li a7 4
    ecall

    # Read the divisor
    li a7 5
    ecall

    # Save the divisor to s1
    mv s1 a0

    # Check if divisor is zero
    beqz s1 division_by_zero_error
    # If divisor equals zero, then jump to error handling

    # Divide dividend by divisor
    mv a0 s0 # Move dividend to a0
    mv a1 s1 # Move divisor to a1
    jal divide # Call divide subroutine
    # Now quotient is in a2 and remainder is in a3

    # Save the quotient to s2
    mv s2 a2

    # Save the remainder to s3
    mv s3 a3

    # Print the quotient
    la a0 quotient_msg
    li a7 4
    ecall

    mv a0 s2
    li a7 1
    ecall

    # Print newline after the quotient
    la a0 newline
    li a7 4
    ecall

    # Print the remainder
    la a0 remainder_msg
    li a7 4
    ecall

    mv a0 s3
    li a7 1
    ecall

    # Exit from the program
    li a7 10
    ecall

division_by_zero_error:
    # Print error message
    la a0 div_by_zero_msg
    li a7 4
    ecall

    # Finish the program after error
    li a0 1
    li a7 93
    ecall

# __Division subroutine__
#  Input parameters:  a0 = dividend, a1 = divisor
#  Output perameters: a2 = quotient, a3 = remainder
divide:
    # Handle negative values
    mv t0 a0
    mv t1 a1
    mv t2 zero # Flag to swap the sign of the quotient
    mv t3 zero # Flag to swap the sign of the remainder

    # Check if dividend is negative
    bltz t0 neg_dividend
    j check_divisor

neg_dividend:
    sub t0 zero t0 # Make dividend positive
    li t2 1 # Toggle the sign flag for the quotient
    li t3 1 # Toggle the sign flag for the remainder

check_divisor:
    # Check if divisor is negative
    bltz t1 neg_divisor
    j divide_positive

neg_divisor:
    sub t1 zero t1 # Make divisor positive
    sub t2 zero t2 # If the divident is positive
    addi t2 t2 1 # Then toggle the sign flag for the quotient

# Now perform the division with positive dividend and divisor
divide_positive:
    mv a2 zero # Initialize the quotient to 0
    mv a3 t0 # Initialize the remainder to the dividend

div_loop:
    # If the remainder is less than the divisor, then finish the loop
    blt a3 t1 division_done

    # Subtract divisor from the remainder
    sub a3 a3 t1 # remainder -= divisor

    # Increment the quotient
    addi a2 a2 1 # ++quotient

    j div_loop

division_done:
    bnez t2 negate_quotient # Swap the quotient sign if necessary
    bnez t3 negate_remainder # Swap the remainder sign if necessary
    j division_finished

negate_quotient:
    sub a2 zero a2 # Negate the quotient
    mv t2 zero
    j division_done

negate_remainder:
    sub a3 zero a3 # Negate the remainder
    mv t3 zero
    j division_done

division_finished:
    ret