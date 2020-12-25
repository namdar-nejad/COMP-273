# This program manipulates an array by inserting and deleting at specified index and sorting the contents of the array.
# The program should also be able to print the current content of the array.
# The program should not terminate unless the 'quit' subroutine is called
# You can add more subroutines and variables as you wish.
# Remember to use the stack when calling subroutines.
# You can change the values and length of the beginarray as you wish for testing.
# You will submit 5 .asm files for this quesion, Q1a.asm, Q1b.asm, Q1c.asm, Q1d.asm and Q1e.asm.
# Each file will be implementing the functionalities specified in the assignment.
# Use this file to build the helper functions that you will need for the rest of the question.


.data

beginarray: .word 2, 3, 77, 5, -999			#’beginarray' with some contents	 DO NOT CHANGE THE NAME "beginarray"
array: .space 4000					#allocated space for ‘array'

# strings
space: .asciiz " "
newLine: .asciiz "\n"
str_command:	.asciiz "Enter a command (i, d, s or q): " # command to execute
array_l: .asciiz "Current array: "
length_l: .asciiz "Length: "
invalid: .asciiz "[Error] invalid input"
index: .asciiz "Enter Index: "
int_input: .asciiz "Enter Int: "
i:     .asciiz "i"
s:     .asciiz "s"
q:     .asciiz "q"
d:     .asciiz "d"


	.text
	.globl main



main:	
	# Initilizing the array and doing some tests
	
	# copy test
	la $a0,beginarray	# loading address of test array in a0
	la $a1,array		# loading address of empty array in a1
	jal copyarray		# copying from a0 to a1
	
	# print test
	la $a0, array		# loading address of array in a0
	jal printarray		# printing values of array
	
	# length test
	la $a0, array		# loading address of array in a0
	jal length		# calculating length
	move $s0, $v0		# moving length to s0

		
	li $v0, 4		# printing label
	la $a0, length_l
	syscall
	
	li $v0, 1		# printing length
	move $a0, $s0
	syscall
	
	li $v0,4		# going to a new line
	la $a0,newLine
	syscall
	
	j get_input 		# getting user input
	
get_input:
	li $v0,4		# printing string
	la $a0, str_command
	syscall
	
	li $v0,12		# reading char input
	syscall
	
	add $s0,$v0,$zero	# s0 holds the entered value
	
	li $v0, 4		# going to a new line
	la $a0, newLine
	syscall
	
	j isValid		# jumping to a subroutine called isValid
				# the rest of the opurations are handled from isValid
		
	# main code ends here
Exit:	li $v0,10
	syscall
	
isValid:

	add $t0,$s0,$zero	# t0 holds the entered value
	
	la $t3,d		# pointer to "d"
	lb $t3,0($t3)		# ascii value of "d" in $t1
	
	beq $t0,$t3,delete	# go to delete subrotine

	li $v0, 4		# printing this if the input is invalid
	la $a0, invalid
	syscall	
	
	li $v0, 4		# going to a new line
	la $a0, newLine
	syscall
	
	j get_input		# if input is invalid, prompt for another input


# length subroutine
length: add $v0,$zero,$zero	# use $v0 as the counter and initialize it
	
lenLoop:
	lw $t0, 0($a0)		# load the value of the pointer to t0
	
	addi $t0,$t0, 999	# add 999 to t0, if t0 is pointing to -999 then the result will be 0
	beq $t0,$zero,doneLen	# reached the last int (-999) character so we are done
	
	addi $v0,$v0,1		# increment count
	addi $a0,$a0,4		# advance pointer by 4
	j lenLoop		# continue loop
	
doneLen:jr $ra			# length in v0


# copyarray subroutine
copyarray:
	lw $t0, 0($a0)		# copying from a0 to a1
    	sw $t0, 0($a1)
	
	addi $t0, $t0, 999	# add 999 to t0, if t0 is pointing to -999 then the result will be 0
	beq $t0,$zero,doneCopy	# reached the last int (-999) character so we are done
	
	addi $a0, $a0, 4	# incrementing both pointers
	addi $a1, $a1, 4
	
	j copyarray
	
doneCopy:
	jr $ra

# printarray subroutine	
printarray:
	move $a1,$a0		# copying where a0 is pointing at in a1
	
	li $v0,4		# syscal to print string
	la $a0,array_l	# printing "Current Array: "
	syscall

printLoop:	
	lw $t0, 0($a1)		# copying from a1 to t0
	
	addi $t0, $t0, 999	# add 999 to t0, if t0 is pointing to -999 then the result will be 0
	beq $t0,$zero,donePrint	# reached the last int (-999) character so we are done
	
	li $v0,1		# system call code for print_int
	lw $a0, 0($a1)
	syscall
	
	li $v0, 4		# system call code for string
	la $a0, space		# printing a space between the array values
	syscall
	
	addi $a1, $a1, 4
	
	j printLoop
	
donePrint:
	li $v0,4		# syscal to print string
	la $a0,newLine		# going to new line
	syscall
	
	jr $ra
	
# delete subroutine	
delete:
	li $v0, 4		# printing index prompt
	la $a0, index
	syscall
	
	li $v0,5		# system call code for read_int
	syscall
	
	add $s0, $v0, $zero	# s0 holding the index entered
	
	la $a0, array
	jal length		# calculating length
	add $s1, $v0, $zero	# s1 holding the length
	
	
	bltz $s0,inval_index_d	# if input index < 0
	
	sub $t0, $s0, $s1	# t0 = s0 - s1 / t0 = index - length (has to be nagative)
	slt $t0, $t0, $zero	# if s0 - s1 < 0
	beq $t0, $zero, inval_index_d
	
	j remove		# index is correct and we go to remove
	
inval_index_d:
	li $v0, 4		# print error prompt
	la $a0, invalid
	syscall
	
	li $v0,4		# syscal to print string
	la $a0,newLine		# going to new line
	syscall
	
	j delete
	
remove:
	la $a1,array
	sll $s0, $s0, 2		# multiply the value of s0 by 4
	add $a1, $a1, $s0	# a1 points to the correct slot to delete
	addi $a0, $a1, 4	# a0 points to the slot after the one that we want to delete
	
	jal copyarray		# copyback the values
	
	la $a0, array
	jal printarray
	
	j get_input
