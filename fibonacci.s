.data

msg0: .asciiz "  _____._____.                                     .__\
_/ ____\__\_ |__   ____   ____ _____    ____  ____ |__|
\   __\|  || __ \ /  _ \ /    \\__  \ _/ ___\/ ___\|  |
 |  |  |  || \_\ (  <_> )   |  \/ __ \\  \__\  \___|  |
 |__|  |__||___  /\____/|___|  (____  /\___  >___  >__|
               \/            \/     \/     \/    \/    \n\n"
               
msg1: .asciiz "\nenter a number: "

msg2: .asciiz "The fibonacci number for the entered number is = "

msg3: .asciiz "Would you like to do another number?\n\nEnter 1 to go again\nEnter 2 to exit\n\nenter here: "

msg4: .asciiz "\ngood bye\n\n"

nl: .asciiz "\n"

.text

.globl main

main: 	

# print out "a cool title"

    li $v0, 4
    la $a0, msg0
    syscall


program_loop:



    # print out "enter a number: "
    li $v0, 4
    la $a0, msg1
    syscall
    
    # system call to get input from the user
    li $v0, 5 
    syscall
    
    # call fib with user input
    add $a0, $v0, $zero
    jal fib
    add $s0, $v0, $zero

    # print out a new line
    li $v0, 4
    la $a0, nl
    syscall

    #print out "he fibonacci number for the entered number is = "
    li $v0, 4
    la $a0, msg2
    syscall

    li $v0, 1
    add $a0, $s0, $zero
    syscall

    # print out a new line
    li $v0, 4
    la $a0, nl
    syscall

    # print out a new line
    li $v0, 4
    la $a0, nl
    syscall

    #print out "would you like to enter another numebr?"
    li $v0, 4
    la $a0, msg3
    syscall

    # system call to get input from the user
    li $v0, 5 
    syscall

    addi $t0, $zero, 1
    beq $v0, $t0, program_loop

    #print out "good bye"
    li $v0, 4
    la $a0, msg4
    syscall

    li $v0, 10    # return 0;
    syscall


fib:

#
#   STEP 1:
#
#   1.) adjust the call stack for 3 words
#
#   2.) save current data to the call stack
#
#       return_address gets offset 0 (position 0)
#
#       current_n gets offset 4 (position 1)
#
#       calculated (n - 1) gets offset 8 (position 2)
#

    addi $sp, $sp, -12            # adjusts the stack 3 words (3 * word_size = 12)
    addi $t0, $zero, 0
    sw $ra, 0($sp)                # save return address with in stack position 0 (offset 0)
    sw $a0, 4($sp)                # save the current value of n in stack position 1 (offset 4)
    sw $t0, 8($sp)                # initialize the calculated value of fib(n - 1) to zero in stack position 2 (offset 8)

#
#   STEP 2:
#
#   figure out if our number is (n == 0) or (n == 1) or (n > 1)
#
#   if (n == 0)
#       go_to case_zero;
#   else if (n == 1)
#       go_to case_one;
#   else
#       go_to case_general; (just under the if statements in the code block)
#

    addi $t1, $zero, 1           # set temp 1 to 1 for comparisons
    beq $a0, $zero, case_zero    # if (n == 0) go_to case_zero;
    beq $a0, $t1, case_one       # if (n == 1) go_to case_one;

#
#   STEP 3:
#   (this is case_general meaning that the current n is greater than 1)
#   
#   1.) call fib with (n - 1)
#
#   2.) store the result of fib(n - 1) in the stack at position 2 (offset 8)
#
#   3.) restore the origional n by retrieving it from the stack at posiiton 1 (offset 4)
#
#   4.) call fib with n - 2
#
#   5.) restore the result of fib(n - 1) from the stack
#
#   6.) add together the results from (n - 1) and (n - 2)
#
#   7.) store the result of fib(n - 1) + fib(n - 2) in the return register
#
#   8.) restore the return register from the stack at position 0 (offset 0)
#
#   9.) return to the caller function
#

    add $a0, $a0, -1             # put the current n - 1 into the argument register 0
    jal fib                      # call fibonacci with n - 1

    sw $v0, 8($sp)               # save the calculated n - 1 inside the stack at position 02 (offset 8)
    lw $a0, 4($sp)               # restore the origional n from the call stack
    addi $a0, $a0, -2            # set the temp register 0 to n - 2
    jal fib                      # call fibonacci with n - 1

    lw $t1, 8($sp)               # load the resuly from fib(n - 1) inside temp register 1
    add $v0, $t1, $v0            # add together the results from fib(n - 1) and fib(n - 2)
    lw $ra, 0($sp)               # load the return address into the return address register
    addi $sp, $sp, 12            # pop three items off of the stack
    jr $ra                       # return

#
#   case_zero:
#
#   1.) load stuff from the call stack
#
#   2.) pop three items from the call stack
#
#   3.) load zero into the return register
#
#   4.) return to parent caller
#

case_zero:

    addi $v0, $zero, 0          # put zero into the return register
    addi $sp, $sp, 12           # pop three items off of the stack
    jr $ra                      # return to the caller

#
#   case_zero:
#
#   1.) load stuff from the call stack
#
#   2.) pop three items from the call stack
#
#   3.) load one into the return register
#
#   4.) return to parent caller
#

case_one:

    addi $v0, $zero, 1         # put one into the return register
    addi $sp, $sp, 12          # pop three items from the stack
    jr $ra                     # return to the caller