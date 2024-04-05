.data

    test_array: .space 40      # this allocates 40 bytes (10 integers) in memory
    test_array_size: .word 10  # this is just going to save the size of the array 

    new_line: .asciiz "\n"

    msg0: .asciiz "__________.__                               _________                           .__     
\______   \__| ____ _____ _______ ___.__.  /   _____/ ____ _____ _______   ____ |  |__  
 |    |  _/  |/    \\__  \\_  __ <   |  |  \_____  \_/ __ \\__  \\_  __ \_/ ___\|  |  \ 
 |    |   \  |   |  \/ __ \|  | \/\___  |  /        \  ___/ / __ \|  | \/\  \___|   Y  \
 |______  /__|___|  (____  /__|   / ____| /_______  /\___  >____  /__|    \___  >___|  /
        \/        \/     \/       \/              \/     \/     \/            \/     \/ \n\n"
    msg1: .asciiz "Enter value for array index ["
    msg2: .asciiz "]: "
    msg3: .asciiz "\nEnter a number you would like to search for: "
    msg4: .asciiz "\nTHE NUMBER YOU ENTERED WAS NOT FOUND IN THE ARRAY"
    msg5: .asciiz "\nTHE NUMBER YOU ENTERED WAS FOUND!\n   Here is the index it was found at: "
    msg6: .asciiz "\n\nWould you like to search for another number in your array?\n     Enter 0 to exit\n     Enter 1 to search again\n\nEnter here:"
    msg7: .asciiz "\n\ngood bye"



.text

.globl main

main:
 
    # print out the super cool title
    li $v0, 4
    la $a0, msg0
    syscall

    jal user_load_array              # this will populate all 10 indexes of the input array in the ram

    program_loop:

    jal get_search_key               # get the number that we would like to search for
    add $a0, $v0, $zero              # copy that number to the argument register
    lw $a1, test_array_size          # copy the size of the array to the second argument register

    jal binary_search                # call the binary search
    add $t0, $v0, $zero              # store the result of the search inside temp 0
    addi $t1, $zero, -1              # store -1 in temp 1 for comparison

    beq $t0, $t1, not_found          # if the thing wasnt found than handle it accordingly
    j found                          # it was found

    not_found:

    li $v0, 4
    la $a0, msg4
    syscall
    j go_again

    found:

    li $v0, 4
    la $a0, msg5
    syscall
    add $a0, $t0, $zero         # store the contents
    li $v0, 1
    syscall

    go_again:

    # print out "go again?"
    li $v0, 4
    la $a0, msg6
    syscall

    # system call to get input from the user
    li $v0, 5 
    syscall

    beq $v0, $zero, done_with_everything
    j program_loop

    done_with_everything:

    # print out "good bye"
    li $v0, 4
    la $a0, msg7
    syscall



    li $v0, 10    # return 0;
    syscall


user_load_array:
#################################################

    add $s0, $zero, $zero             # int i = 0, like a for loop
    addi $s1 $zero, 9                 # set the cap of the loop to be 9     10 iterations

    load_loop:

    # print out "Enter value for array index ["
    li $v0, 4
    la $a0, msg1
    syscall

    # print out i
    li $v0, 1
    add $a0, $s0, $zero
    syscall

    # print out "]: "
    li $v0, 4
    la $a0, msg2
    syscall

    # system call to get input from the user
    li $v0, 5 
    syscall

    # print out "\n"
    #li $v0, 4
    #la $a0, new_line
    #syscall

    sll $t0, $s0, 2                   # this multiplies the array index by 4 to align it in memory
    sw $v0, test_array($t0)           # this saves the word in memory

    beq $s0, $s1, population_done     # i == 9 ? then done
    addi, $s0, $s0, 1                 # i++
    j load_loop                       # begin another iteration

    population_done:

    jr $ra                                # return to the funciton caller
#################################################

get_search_key:
#################################################

    # print out "\nEnter a number you would like to search for: "
    li $v0, 4
    la $a0, msg3
    syscall

    # system call to get input from the user
    li $v0, 5 
    syscall

    jr $ra
#################################################

binary_search:
#################################################
    #
    #   $s0 --> left_index
    #   $s1 --> right_index
    #   $s2 --> middle_index
    #   $s3 --> search key
    #
    
    addi $s0, $zero, 0                      # set the left index to zero
    addi $s1, $a1, -1                       # set the right index to size - 1
    addi $s3, $a0, 0                        # put the search key inside of S3
                                            # now calculate the index of the middle index
    sub $t0, $s1, $s0                       # (right_index - left_index) {put in T0}
    srl $t0, $t0, 1                         # (right_index - left_index) / 2 {put in $t0}
    add $s2, $s0, $t0                       # ((right_index - left_index) / 2) + left_index {put in $s2}

    search_loop:                            # main_search_of_the_loop

    ############################################# check if the indexes are valid while (left_index <= right_index)


#        beq $s0, $s1, keep_going_00         # it is okay of the indexes are equal
#        slt $t0, $s0, $s1                   # T0 = (left < right)
#        beq $t0, $zero, search_fail         # if T0 is false, fail
#       j keep_going_00                     # if T0 is true, keep going

        slt $t0, $s1, $s0                   # is (right < left)
        bne $t0, $zero, search_fail         # if this is true, FAIL
        j keep_going_00

    #############################################

    keep_going_00:

    ############################################# check if the thing was found

        sll $t0, $s2 2                      # multiply the middle index by 4 to get its adjusted memory address
        lw $t0, test_array($t0)             # load the contents of the array at index middle_index
        beq $s3, $t0, search_pass           # if these are equal than we have found the item at index middle_index

    #############################################
    #############################################
    
    # we still have the active value in $T0

    slt $t0, $s3, $t0                       # is the search key less than the active value?
    beq $t0, $zero, greater_than            # if the above condition was false, go to greater_than
    j less_than                             # else: go to less than

    greater_than:

        addi $s0, $s2, 1                    # set the left_index to middle_index + 1
        j keep_going_01

    less_than:

        addi $s1, $s2, -1                   # set the right_index to middle - 1
        j keep_going_01

    keep_going_01:

        sub $t0, $s1, $s0                   # T0 = (right_index - left_index)
        div $t0, $t0, 2                     # T0 = (right_index - left_index) / 2                   
        add $s2, $t0, $s0                   # middle_index = ((right_index - left_index) / 2) + left_index

    #############################################
    j search_loop

    search_fail:

        addi $v0, $zero, -1
        jr $ra

    search_pass:

        add $v0, $s2, $zero                 # set the return register to the middle index
        jr $ra

#################################################


load_test:
#################################################

    addi $t0, $zero, 0
    addi $t1, $zero, 0
    sw $t0, test_array($t1)

    addi $t0, $zero, 1
    addi $t1, $zero, 4
    sw $t0, test_array($t1)

    addi $t0, $zero, 2
    addi $t1, $zero, 8
    sw $t0, test_array($t1)

    addi $t0, $zero, 3
    addi $t1, $zero, 12
    sw $t0, test_array($t1)

    addi $t0, $zero, 4
    addi $t1, $zero, 16
    sw $t0, test_array($t1)
                            # this saves vals 1 - 9 in the array
    addi $t0, $zero, 5
    addi $t1, $zero, 20
    sw $t0, test_array($t1)

    addi $t0, $zero, 6
    addi $t1, $zero, 24
    sw $t0, test_array($t1)

    addi $t0, $zero, 7
    addi $t1, $zero, 28
    sw $t0, test_array($t1)

    addi $t0, $zero, 8
    addi $t1, $zero, 32
    sw $t0, test_array($t1)

    addi $t0, $zero, 9
    addi $t1, $zero, 36
    sw $t0, test_array($t1)
 #################################################


