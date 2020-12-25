
.data

#You must use accurate an file path.
#These file paths are EXAMPLES,
#These will not work for you!

# do not change
buffer:  .space 50000
newbuff: .space 50000
stackbuff: .space 50000
rtnbuff: .space 50000

zero: .asciiz "0"
one: .asciiz "1"
newline: .ascii "\n"
str1:		.asciiz "./test2.txt"				# provide full path
str3:		.asciiz "./test2_2.pbm"	#used as output
error_msg:	.asciiz "Error code: "
header:		.asciiz "P1\n50 50\n"
# do not change

	.text
	.globl main

main:	
	# reading file (at str1) and putting values in buffer
	la $a0,str1		
	jal readfile
	
	# fill contour
	# filling the specified area in buffer and returning the filled array in rtnbuff
	la $a0, buffer		# buffer with 1,0 chars writen from the file
	# x, y values of the region to be filled. Assume a 2D array where the indices start from 1.
	li $a2, 2		# x value
	li $a3, 2		# y value
	jal fillregion
	
	# writing from filled rtnbuff to file (at str3)
	la $a0, str3
	la $a1, rtnbuff
	jal writefile
	
	
Exit:	li $v0,10		# exit
	syscall
	
# copy_array function
# hgetting int values and saving them as chars of 1 or 0, with a \n after each 50 chars
copy_array:
	#la $a0,newbuff		done at input in main
	#la $a1,rtnbuff
	li $s0, 0		# counter
	li $s1, 2500		# hardcorded array length
	li $s3, 0
	li $s4, 50
	lb $s5, zero
	lb $s6, one
copy_loop:
	beq $s1, $s0, done_copy	# if we have reach the end of the array
	lw $t0, 0($a0)		# take the int value
	blez $t0, add_zero
	beq $s3, $s4, add_nl
	
add_one:
	sb $s6, 0($a1)
	addi $a0,$a0,4		# increment pointer
	addi $a1,$a1,1		# increment pointer
	addi $s0,$s0,1		# increment counter
	addi $s3, $s3,1
	j copy_loop

add_zero:
	sb $s5, 0($a1)
	addi $a0,$a0,4		# increment pointer
	addi $a1,$a1,1		# increment pointer
	addi $s0,$s0,1		# increment counter
	addi $s3, $s3,1
	j copy_loop
add_nl:
	lb $t0, newline
	sb $t0, 0($a1)		# put value in new array slot
	addi $a1,$a1,1		# increment pointer
	li $s3, 0
	j copy_loop
done_copy:
	jr $s7

# load_array subroutine
# takes a array of chars and returns a pointer to the first element of the same array with the int values
# a0 --> buffer with char, a1 --> newbuffer with int
load_array:
	#la $a0,buffer		done at input in fillregion
	la $a1,newbuff
	li $s0, 0		# counter
	li $s1, 2500		# hardcorded array length
load_loop:
	beq $s1, $s0, done_load	# if we have reach the end of the array
	lb $t0, 0($a0)		# take the ascii value
	addi $t0,$t0,-48	# subtract 48 (ascii value of 0) --> get int value
	bltz $t0, increment	# if the value is a new line char
	sw $t0, 0($a1)		# put value in new array slot
	addi $a0,$a0,1		# increment pointer
	addi $a1,$a1,4		# increment pointer
	addi $s0,$s0,1		# increment counter
	j load_loop
	
increment:
	addi $a0,$a0,1		# increment pointer
	j load_loop
done_load:
	jr $ra
	
fillregion:
	# a0 --> pointer to newBuff
	# a2 --> x
	# a3 --> y
	
	la $s5, stackbuff		# pointing to the start of the stackbuff
	move $s7, $ra
	
	# create array of (1,0) ints
	sw $ra, 0($s5)
	addi $s5, $s5, 4
	
	jal load_array			# now newbuff has the int values
	
	la $a0,newbuff			# a0 points to newbuff with int values
	
	# Calculating the address using the given x y
	addi $s0, $a2, -1		# s0 = x' = 4*(x-1)
	sll $s0, $s0, 2
	
	addi $s1, $a3, -1		# s1 = y' = a0 + (50*4)(y-1)
	li $t0, 200
	mult $s1, $t0
	mflo $s1
	
	add $s0, $s0, $s1		# s0 = pointer to slot = s0 + s1
	add $s0, $s0, $a0		# s0 --> pointer to the point on plane
					
	sw $s0, 0($s5)
	addi $s5, $s5, 4
	
fill_loop:
	addi $s5, $s5, -4		# s0 --> pointer to slot in array
	lw $s0, 0($s5)			# poping the coordinate stored in stack
	
	beq $s7, $s0, rtn		# cheking if we have emptied stack and reach the ra to main
	
	lw $s1, 0($s0)			# loading the value stored in array slot
	blez $s1, push			# s1 --> value of slot, if 0 --> goto push
	
	j fill_loop

rtn:	# converted all bits --> converd bits from int to char and save to rtnbuff
	la $a0,newbuff
	la $a1,rtnbuff
	j copy_array
		
push:	
	addi $t0, $zero, 1
	sw $t0, 0($s0)			# the value was 0 --> set to 1
	
load_n:	# call function with the North slot
	addi $t0, $s0, -200
	lw $t1, 0($t0)
	bgtz $t1, load_s
	sw $t0, 0($s5)
	addi $s5, $s5, 4
	
	# call function with the South slot
load_s:	addi $t0, $s0, 200
	lw $t1, 0($t0)
	bgtz $t1, load_e
	sw $t0, 0($s5)
	addi $s5, $s5, 4
	
	# call function with the East slot
load_e:	addi $t0, $s0, 4
	lw $t1, 0($t0)
	bgtz $t1, load_w
	sw $t0, 0($s5)
	addi $s5, $s5, 4
	
	# call function with the West slot
load_w:	addi $t0, $s0, -4
	lw $t1, 0($t0)
	bgtz $t1, load_ne
	sw $t0, 0($s5)
	addi $s5, $s5, 4
	
	# call function with the NE slot
load_ne:addi $t0, $s0, -196
	lw $t1, 0($t0)
	bgtz $t1, load_nw
	sw $t0, 0($s5)
	addi $s5, $s5, 4
	
	# call function with the NW slot
load_nw:addi $t0, $s0, -204
	lw $t1, 0($t0)
	bgtz $t1, load_se
	sw $t0, 0($s5)
	addi $s5, $s5, 4
	
	# call function with the SE slot
load_se:addi $t0, $s0, 204
	lw $t1, 0($t0)
	bgtz $t1, load_sw
	sw $t0, 0($s5)
	addi $s5, $s5, 4
	
	# call function with the SW slot
load_sw:addi $t0, $s0, 196
	lw $t1, 0($t0)
	bgtz $t1, fill_loop
	sw $t0, 0($s5)
	addi $s5, $s5, 4
	
	j fill_loop
	
# readfile subroutine
readfile:
	#open a file for reading
	li $v0, 13		# system call for open file
	# reads from a0
	li $a1, 0		# Open for reading
	li $a2, 0
	syscall			# open a file (file descriptor returned in $v0)
	move $s0, $v0		# save the file descriptor 
	
	bltz $v0, error
	
	#read from file
	li $v0, 14       	# system call for read from file
	move $a0, $s0      	# file descriptor 
	la $a1, buffer   	# address of buffer to which to read
	li $a2, 4096    	# hardcoded buffer length
	syscall           	# read from file
	
	bltz $v0, error		# cheking for errors

	li $v0, 4		# printing the value in the buffer
	la $a0, buffer
	syscall	

	# Close the file 
	li $v0, 16       	# system call for close file
	move $a0, $s0      	# file descriptor to close
	syscall            	# close file
	
	bltz $v0, error		# cheking for errors
	
	jr $ra

writefile:
	move $s1, $a1		# saving address of what we want to write in s1
	
	#open a file for writing
	li $v0, 13		# system call for open file
	# adress of file already in a0
	li $a1, 1		# Open for writing
	li $a2, 0
	syscall			# open a file (file descriptor returned in $v0)
	move $s0, $v0		# save the file descriptor 

	bltz $v0, error		# checking for errors

	# Write to file just opened
	# write the header
	li   $v0, 15      	# system call for write to file
	move $a0, $s0      	# file descriptor
  	la   $a1, header	# writing the value of the header from the handout
  	li   $a2, 10000       	# hardcoded buffer length
  	syscall            	# write to file
  	
  	bltz $v0, error		# checking for errors
  	
  	# write the header
	li   $v0, 15      	# system call for write to file
	move $a0, $s0      	# file descriptor
  	move $a1, $s1		# writing the value of the buffer
  	li   $a2, 4096       	# hardcoded buffer length
  	syscall            	# write to file

	bltz $v0, error		# checking for errors

  	# Close the file 
  	li   $v0, 16       	# system call for close file
  	move $a0, $s0      	# file descriptor to close
  	syscall            	# close file
  	
  	bltz $v0, error		# checking for errors
  	
  	jr $ra
  	
error:	move $t0, $v0
	li $v0, 4
	la $a0, error_msg
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	j Exit
