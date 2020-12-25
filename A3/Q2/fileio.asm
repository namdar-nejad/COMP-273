# fileio.asm

.data

buffer:  .space 4096		# buffer for upto 4096 bytes (increase size if necessary)


str1:	.asciiz ".test1.txt"		#provide full path
str2:	.asciiz "./test2.txt"
str3:	.asciiz "./test2.pbm"		#used as output
error_msg: .asciiz "code: "
error_open: .asciiz "\nError when opening file, "
error_close: .asciiz "\nError when closing file, "
error_read: .asciiz "\nError when reading from file, "
error_write: .asciiz "\nError when writing ro file, "
header: .asciiz "P1\n50 50\n"

	.text
	.globl main
	
main:	la $a0,str2		#readfile takes $a0 as input
	jal readfile

	la $a0, str3		#writefile will take $a0 as file location
	la $a1, buffer		#$a1 takes location of what we wish to write.
	jal writefile

Exit:	li $v0,10		# exit
	syscall

readfile:
	#open a file for reading
	li $v0, 13		# system call for open file
	# reads from a0
	li $a1, 0		# Open for reading
	li $a2, 0
	syscall			# open a file (file descriptor returned in $v0)
	move $s0, $v0		# save the file descriptor 
	
	la $v1, error_open
	bltz $v0, error
	
	#read from file
	li $v0, 14       	# system call for read from file
	move $a0, $s0      	# file descriptor 
	la $a1, buffer   	# address of buffer to which to read
	li $a2, 4096    	# hardcoded buffer length
	syscall           	# read from file
	
	la $v1, error_read
	bltz $v0, error		# cheking for errors

	li $v0, 4		# printing the value in the buffer
	la $a0, buffer
	syscall	
	

	# Close the file 
	li $v0, 16       	# system call for close file
	move $a0, $s0      	# file descriptor to close
	syscall            	# close file
	
	la $v1, error_close
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

	la $v1, error_open
	bltz $v0, error		# checking for errors

	# Write to file just opened
	# write the header
	li   $v0, 15      	# system call for write to file
	move $a0, $s0      	# file descriptor
  	la   $a1, header	# writing the value of the header from the handout
  	li   $a2, 4096       	# hardcoded buffer length
  	syscall            	# write to file
  	
  	la $v1, error_write
  	bltz $v0, error		# checking for errors
  	
  	# write the header
	li   $v0, 15      	# system call for write to file
	move $a0, $s0      	# file descriptor
  	move $a1, $s1		# writing the value of the header from the handout
  	li   $a2, 4096       	# hardcoded buffer length
  	syscall            	# write to file

	la $v1, error_write
	bltz $v0, error		# checking for errors

  	# Close the file 
  	li   $v0, 16       	# system call for close file
  	move $a0, $s0      	# file descriptor to close
  	syscall            	# close file
  	
  	la $v1, error_close
  	bltz $v0, error		# checking for errors
  	
  	jr $ra
  	
error:	move $t0, $v0		# printing out error
	
	li $v0, 4
	move $a0, $v1
	syscall
	
	li $v0, 4
	la $a0, error_msg
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	j Exit			# jumping to exit if error
