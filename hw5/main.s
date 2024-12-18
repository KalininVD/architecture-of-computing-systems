.include "tools.i"

.data
    .global main

.text

main:
    # Initialize argument to 0
    li s1 0

# Factorial calculation loop
loop:
    # Calculate factorial of current argument
    mv a0 s1
    jal factorial

    # Save factorial to s2
    mv s2 a0

    # Print factorial to the console
    print_int(s1)
    print_string("! = ")
    print_int(s2)
    print_newline

    # If the next factorial is greater than 32-bit integer, finish the loop
    addi t0 s1 1
    mulh t1 s2 t0
    bnez t1 end

    # Increase argument
    addi s1 s1 1
    j loop # Start the loop again

end:
    # Print maximum factorial argument to the console
    print_string("Maximum factorial argument is ")
    print_int(s1)
    print_string(", ")
    print_int(s1)
    print_string("! = ")
    print_int(s2)

    exit # Finish the program

# Factorial calculation subroutine
#  Input: a0 - n
#  Output: a0 - n!
factorial:
    # Save ra and s0 registers to the stack
    stack_push_int(ra)
    stack_push_int(s0)

    # If n <= 1, return 1
    li t0 1
    li s0 1
    ble a0 t0 factorial_finish

    # Multiply n by (n - 1)!
    mv s0 a0
    addi a0 s0 -1
    jal factorial # Calculate (n - 1)!
    mul s0 s0 a0 # Multiply by n

factorial_finish:
    # Save the result to a0
    mv a0 s0

    # Restore ra and s0 registers from the stack
    stack_pop_int(s0)
    stack_pop_int(ra)

    # Return
    ret