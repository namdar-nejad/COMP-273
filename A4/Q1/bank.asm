




# Program Info:
# All oporations are being done on the MMIO
# To test:
# 1- Compile the code
# 2- Open MMIO, from the Tools tab
# 3- Connect MMIO
# 4- Run the code



#####################       Attention       #####################
# I have written and tested this code on a mac machine. 	#
# The Newline ascii code for my machine is 10 			#
# however it might be 13 for some other OSs. 			#
# Please check what the ascii code is on your machine, 		#
# and if it is not 10 change the values on lines 322 & 432. 	#
# Here is a reference you can check: 				#
# https://en.wikipedia.org/wiki/Newline 			#
#################################################################













#/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/#
#					      	#
#  Do not change any thing from this point on. 	#
#					      	#
#/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/#


.data

bank_array: .word 0, 0, 0, 0, 0
command_array: .space 200
command: .space 30
arg1: .space 1000
arg2: .space 1000
arg3:.space 1000
arg4: .space 1000
arg1_int:
	.align 2
	.space 100
arg2_int:
	.align 2
	.space 100
arg3_int:
	.align 2
	.space 100
arg4_int:
	.align 2
	.space 100
	
history_array:
	.align 2
	.space 300
history_it:
	.align 2
	.space 4
temp: .space 100
intro: .asciiz " ####################       Attention       #################### \n I have written and tested this code on a mac machine. \n The “Newline” ascii code for my machine is 10 \n however it might be 13 for some other OS’s. \n Please check what the ascii code is on your machine, \n and if it is not 10 change the values on lines 322 & 432. \n Here is a reference you can check: \n https://en.wikipedia.org/wiki/Newline \n ############################################################## \n\n"
error_message:	.asciiz "That is an invalid banking transaction. Please enter a valid one.\n" 
error_open_account: .asciiz "The account entered already exists.\n"
error_dep_account: .asciiz "The account entered doesn’t exist.\n"
error_dep_amount: .asciiz "The deposit amount should be more than zero.\n"
loan_error: .asciiz "Loan can’t be more than 50% of the total credit.\n"
enter_command: 	.asciiz "\nPlease enter command:\n"
history_order: .asciiz "Printed from most recent to oldest command:\n"
insufficient_funds: .asciiz "Insufficient Funds.\n"
terminate: .asciiz "Terminating Program.\n"
loan_surplus_msg: .asciiz "The amount of transfer is more than the loan taken.\n"
command_msg: .asciiz "Command Given: "
bank_msg: .asciiz "Latest Bank Info: "
history_msg: .asciiz "History out of bound.\n"
open_bracket: .asciiz "[ "
open_bracket_dollar: .asciiz "[ $"
close_bracket: .asciiz " ]\n"
partition: .asciiz ", "
newline: .asciiz "\n"

	.text
	.globl main

main:	
	la $a1, intro
	jal print_string
	jal prompt
	
exit:	li $v0,10
	syscall

prompt:
	jal reset_arrays
	la $a1, enter_command
	jal print_string
	jal get_command
	
	la $a1, command_msg
	jal print_string
	la $a1, command_array
	jal print_string
	
	jal parse_array
	jal process_arrays
	jal execute_command
	
update_history:
	la $a0, history_array
	la $a1, bank_array
	addi $s0, $a0, 76
	li $t0, 20
	li $t1, 5
	shift_history:
	beqz $t0, add_history
	lw $t2, 0($s0)
	sw $t2, 20($s0)
	addi $s0, $s0, -4
	addi $t0, $t0, -1
	j shift_history
	add_history:
	beqz $t1, done_history
	lw $t0, 0($a1)
	sw $t0, 0($a0)
	addi $a1, $a1, 4
	addi $a0, $a0, 4
	addi $t1, $t1, -1
	j add_history
	done_history:
	la $t1, history_it
	lw $t0, 0($t1)
	addi $t0, $t0, 1
	sw $t0, 0($t1)
	jr $ra
	
# compute_number: subrotine to compute the int number from an array of ints. $a0 is the address of the int array and $a1, is the address of the sorrosponding char array.
compute_number:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $s4, 0		# sum
	move $s1, $a0		# address of int array in $s1 and $a0
	move $a0, $a1		# address of char array in $a1
	jal length_char_array
	move $s2, $v0		# length in $v0 compy to $s2
	move $a0, $s1
	
	compute_digit:
	beq $s2, $zero, done_compute
	lw $s3, 0($s1)
	j get_power
	add_to_sum:
	add $s4, $s4, $s3
	addi $s2, $s2, -1
	addi $s1, $s1, 4
	j compute_digit
	
	get_power:
	addi $t0, $s2, -1
	power_loop:
	beqz $t0, add_to_sum
	mul $s3, $s3, 10
	addi $t0, $t0, -1
	j power_loop
	
	done_compute:
	sw $s4, 0($a0) 
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

# length_char_array: subrotine to compute the length of a char array. Address of array in $a0, return length in $v0.
length_char_array:
	li $t0, 0
	length_loop:
	lb $t1, 0($a0)
	beq $t1, 0, done_length
	addi $t0, $t0, 1
	addi $a0, $a0, 1
	j length_loop
	done_length:
	move $v0, $t0
	jr $ra

execute_command:
	la $a0, command
	lb $t0, 0($a0)
	lb $t1, 1($a0)
	lb $t2, 2($a0)
	bne $t2, $zero,command_error		# if the command is more than 2 chars
	
	beq $t1, 76, ends_l
	beq $t1, 72, ends_h
	beq $t1, 86, ends_v
	beq $t1, 69, ends_e
	beq $t1, 78, ends_n
	beq $t1, 82, ends_r
	beq $t1, 84, ends_t
	j command_error
	
	ends_l:
	beq $t0, 67, close_account
	beq $t0, 66, get_balance
	j command_error
	ends_h:
	beq $t0, 81, history
	beq $t0, 67, open_account_ch
	j command_error	
	ends_v:
	beq $t0, 83, open_account_sv
	j command_error
	ends_e:
	beq $t0, 68, deposit
	j command_error
	ends_n:
	beq $t0, 76, get_loan
	j command_error
	ends_r:
	beq $t0, 84, transfer
	j command_error
	ends_t:
	beq $t0, 81, quit
	beq $t0, 87, withdraw
	j command_error
	command_error:
	la $a1, error_message
	jal print_string
	j prompt
	
test2:
	la $a1, command_array
	li $a3, 20
	jal print_char_array

	lb $a0, newline
	li $v0, 11
	syscall

	la $a1, command
	li $a3, 2
	jal print_char_array
	
	lb $a0, newline
	li $v0, 11
	syscall
	
	la $a1, arg1
	li $a3, 5
	jal print_char_array
	
	lb $a0, newline
	li $v0, 11
	syscall
	
	la $a1, arg2
	li $a3, 5
	jal print_char_array
	
	lb $a0, newline
	li $v0, 11
	syscall
	
	la $a1, arg3
	li $a3, 5
	jal print_char_array
	
	j exit
	
# process_arrays: subrotine that stores the int values of the arg arrays in the arg_int arrays.
process_arrays:
	# byte_int
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a1, arg1
	la $a0, arg1_int
	jal byte_int
	la $a1, arg2
	la $a0, arg2_int
	jal byte_int
	la $a1, arg3
	la $a0, arg3_int
	jal byte_int
	la $a1, arg4
	la $a0, arg4_int
	jal byte_int
	
	# compute_number
	la $a1, arg1
	la $a0, arg1_int
	jal compute_number
	la $a1, arg2
	la $a0, arg2_int
	jal compute_number
	la $a1, arg3
	la $a0, arg3_int
	jal compute_number
	la $a1, arg4
	la $a0, arg4_int
	jal compute_number
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
# byte_int: subrotine that takes an array with chars at $a1 and stores the int values of the chars in $a0.
byte_int:
	#la $a1, temp
	#move $s0, $a0
	#jal copy_byte
	#la $a1, temp
	#move $a0, $s0
	byte_int_loop:
	lb $t0, 0($a1)
	beq $t0, 0, done_byte_int
	addi $t0, $t0, -48
	sw $t0, 0($a0)
	addi $a0, $a0, 4
	addi $a1, $a1, 1
	j byte_int_loop
	done_byte_int:
	#sw $ra, 0($sp)
	#addi $sp, $sp, 4
	jr $ra
	
# copy_byte: subrotine that copyes the bytes in $a0 to $a1, until it hits a null char.
copy_byte:
	copyb_loop:
	lb $t0, 0($a0)
	beq $t0, 0, done_copyb
	sb $t0, 0($a1)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	j copyb_loop
	done_copyb:
	jr $ra
	
# parse_command: subroutine to parse the command given. No input, fills arrays command, arg1, arg2, arg3, arg4.
parse_array:
	la $a0, command_array	# $a0 hold the address of command_array, with byte values of the command
	la $t1, command		# $t1 hold the address of the arrays to put values in
	#---------#
	li $t2, 10		# ascii of return key <CR> --> it might be 13 if you are on windows
	#---------#
	li $t4, 0		# counter, to count the number of arrays filled
	
	parse_loop:
	lb $t0, 0($a0)			# $t0 hold the char value at $a0
	beq $t0, 32, next_array		# if space --> go to filling next array
	beq $t0, $t2, done_parse	# if return key --> done with parsing
	sb $t0, 0($t1)			# put value at $a0 in $t1
	addi $t1, $t1, 1		# increment
	addi $a0, $a0, 1
	j parse_loop
	
	next_array:
	addi $t4, $t4, 1
	beq $t4, 1, parse_arg1
	beq $t4, 2, parse_arg2
	beq $t4, 3, parse_arg3
	beq $t4, 4, parse_arg4

	parse_arg1:
	la $t1, arg1
	j check_for_space
	parse_arg2:
	la $t1, arg2
	j check_for_space
	parse_arg3:
	la $t1, arg3
	j check_for_space
	parse_arg4:
	la $t1, arg4
	j check_for_space
	
	check_for_space:
	lb $t0, 0($a0)
	bne $t0, 32, parse_loop
	addi $a0, $a0, 1
	j check_for_space
	
	done_parse:
	jr $ra


# print_char_array: subrotine to print array with char values, $a1 is the address of the array, $a3 the number of chars to print
print_char_array:
	lb $a0, 0($a1)
	li $v0, 11    # print_character
	syscall
	
	addi $a3, $a3, -1
	beq $a3, $zero, done_PCA
	
	addi $a1, $a1, 1
	j print_char_array
	
	done_PCA:
	jr $ra
	
# test1: test the get_char and put_char
test1:
	jal get_char
	move $a0, $v0
	jal put_char
	j test1
	
reset_arrays:
	addi $sp, $sp, -4	# storing return address to main in stack
	sw $ra, 0($sp)
	la $a0, arg1_int
	li $a1, 10
	jal reset_int_array
	la $a0, arg2_int
	li $a1, 10
	jal reset_int_array
	la $a0, arg3_int
	li $a1, 10
	jal reset_int_array
	la $a0, arg4_int
	li $a1, 10
	jal reset_int_array
	
	la $a0, command
	jal reset_char_array
	la $a0, command_array
	jal reset_char_array
	la $a0, arg1
	jal reset_char_array
	la $a0, arg2
	jal reset_char_array
	la $a0, arg3
	jal reset_char_array
	la $a0, arg4
	jal reset_char_array
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# get_input: subrotine to get the command from the user and put in the command buffer	
# return byte values of the command in command_array, until and including the return key at the end of the command
get_command:
	la $a1, command_array	# command_array in $a1
	addi $sp, $sp, -4	# storing return address to main in stack
	sw $ra, 0($sp)
	
	get_command_l:
	jal get_char		# char in $v0
	sb $v0, 0($a1)		# take char from user and put in command_array
	addi $a1, $a1, 1	# going to next byte
	#-----------------#
	addi $t0, $zero,10	# check if the value is return key --> the ascii code of <CR> might be 13 if you are on a windows machine
	#-----------------#
	bne $v0,$t0,get_command_l# if not reached return key, continue reading
	
	lw $ra, 0($sp)		# if have reached the return key, go back
	add $sp, $sp, 4
	jr $ra
	
	
# get_char: subrotine to get the input char from MMIO
get_char:
	lui $t0, 0xffff 	# $t0 = 0xffff0000
	get_char_l:
	lw $t1, 0($t0) 		# check control
	andi $t1,$t1,0x0001
	beq $t1,$zero,get_char_l
	lw $v0, 4($t0) 		# put data in $v0	
	jr $ra

# put_char: subrotine to put the input char in MMIO
put_char: 
	lui $t0, 0xffff 	# $t0 = 0xffff0000
	put_char_l:
	lw $t1, 8($t0) 		# check control
	andi $t1, $t1, 0x0001
	beq $t1, $zero, put_char
	sw $a0, 12($t0) 	# print data
	jr $ra

# print_string: subrotine to print string to MMIO, address in $a1
print_string:
	addi $sp, $sp, -4	# storing return address to main in stack
	sw $ra, 0($sp)
	print_string_l:
	lb $a0, 0($a1)
	beqz $a0,done_print_string # if not reached null, continue reading
	jal put_char
	addi $a1, $a1, 1	# going to next char
	j print_string_l
	done_print_string:
	lw $ra, 0($sp)		# if have reached the null, go back
	add $sp, $sp, 4
	jr $ra

print_bank:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $s7, $a0		# $s0 --> the address
	move $s6, $a1		# $s1 --> counter
	la $a1, open_bracket
	jal print_string
	print_bank_l:
	move $a0, $s7
	jal int_to_asc
	jal print_bank_asc
	addi $s7, $s7, 4	# going to next char
	addi $s6, $s6, -1
	beqz $s6, done_print_bank
	la $a1, partition
	jal print_string
	j print_bank_l
	done_print_bank:
	la $a1, close_bracket
	jal print_string
	lw $ra, 0($sp)		# if have reached the null, go back
	add $sp, $sp, 4
	jr $ra
	print_bank_asc:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $s2, $v0
	print_bank_asc_l:
	lb $t0, 0($s2)
	beq $t0, 22, done_print_asc # if not reached null, continue reading
	move $a0, $t0
	jal put_char
	addi $s2, $s2, -1	# going to next char
	j print_bank_asc_l
	done_print_asc:
	lw $ra, 0($sp)		# if have reached the null, go back
	add $sp, $sp, 4
	jr $ra

print_int:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $s7, $a0
	la $a1, open_bracket_dollar
	jal print_string
	move $a0, $s7
	jal int_to_asc
	jal print_bank_asc
	la $a1, close_bracket
	jal print_string
	lw $ra, 0($sp)		# if have reached the null, go back
	add $sp, $sp, 4
	jr $ra

print_bank_console:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $s0, $a0		# $s0 --> the addrres
	move $s1, $a1		# $s1 --> counter
	
	li  $v0, 4
    	la $a0, open_bracket
    	syscall
	print_bank_console_l:
	lw $a0, 0($s0)
	li  $v0, 1
    	syscall
    	addi $s0, $s0, 4	# going to next char
	addi $s1, $s1, -1
	beqz $s1, done_print_bank_c
	li  $v0, 4
    	la $a0, partition
    	syscall
	j print_bank_console_l
	done_print_bank_c:
	li  $v0, 4
    	la $a0, close_bracket
    	syscall
	lw $ra, 0($sp)		# if have reached the null, go back
	add $sp, $sp, 4
	jr $ra

reset_int_array:
	reset_int_loop:
	lw $t0, 0($a0)
	beq $a1, 0, done_reset_int
	sw $zero, 0($a0)
	addi $a0, $a0, 4
	addi $a1, $a1, -1
	j reset_int_loop
	done_reset_int:
	jr $ra
	
reset_char_array:
	reset_char_loop:
	lb $t0, 0($a0)
	beq $t0, 0, done_reset_char
	li $t1, 0
	sb $t1, 0($a0)
	addi $a0, $a0, 1
	j reset_char_loop
	done_reset_char:
	jr $ra

open_account:
	open_account_ch:		# checking account number is in slot 1 of bank_array
	jal check_open_account
	la $s0, bank_array		# $s0 --> the account address
	lw $t1, 0($s0)			# $t1 --> ch account number
	bnez $t1, open_account_error	# if ch exsits --> error
	la $t0, arg1_int		# else, create account
	lw $t1, 0($t0)			# $t1 --> ch account number input
	sw $t1, 0($s0)			# store ch account number
	la $t0, arg2_int
	lw $t1, 0($t0)			# $t1 --> ch account balance input
	sw $t1, 8($s0)			# store ch account balance
	j open_account_done
	
	open_account_sv:		# savings account number is in slot 2 of bank_array
	jal check_open_account
	la $s0, bank_array		# $s0 --> the account address
	lw $t1, 4($s0)			# $t1 --> sv account number
	bnez $t1, open_account_error	# if sv exsits --> error
	la $t0, arg1_int		# else, create account
	lw $t1, 0($t0)			# $t1 --> sv account number input
	sw $t1, 4($s0)			# store sv account number
	la $t0, arg2_int
	lw $t1, 0($t0)			# $t1 --> sv account balance input
	sw $t1, 12($s0)			# store ch account balance
	j open_account_done
	
	open_account_done:
	j done_op
	
	check_open_account:
	la $t0, arg1_int
	lw $t0, 0($t0)
	beqz $t0, command_error
	la $t0, arg2_int
	lw $t0, 0($t0)
	beqz $t0, command_error
	la $t0, arg3_int
	lw $t0, 0($t0)
	bnez $t0, command_error
	jr $ra
	
	open_account_error:
	la $a1, error_open_account
	jal print_string
	j prompt
	
deposit:
	jal check_deposit
	la $a0, bank_array
	la $t0, arg1_int
	lw $t0, 0($t0)		# $t0 --> account number input
	lw $t1, 0($a0)		# $t1 --> cheking account number
	lw $t2, 4($a0)		# $t2 --> savings account number
	beq $t0, $t1, deposit_checking
	beq $t0, $t2, deposit_savings
	j error_deposit_account
	
	deposit_savings:
	la $t0, arg2_int
	lw $t0, 0($t0)
	lw $t1, 12($a0)
	add $t2, $t0, $t1
	sw $t2, 12($a0)
	j done_op
	
	deposit_checking:
	la $t0, arg2_int
	lw $t0, 0($t0)
	lw $t1, 8($a0)
	add $t2, $t0, $t1
	sw $t2, 8($a0)
	j done_op
	
	error_deposit_account:
	la $a1, error_dep_account
	jal print_string
	j prompt
	
	check_deposit:
	la $t0, arg1_int
	lw $t0, 0($t0)
	beqz $t0, command_error
	la $t0, arg2_int
	lw $t0, 0($t0)
	beqz $t0, command_error
	la $t0, arg3_int
	lw $t0, 0($t0)
	bnez $t0, command_error
	jr $ra


withdraw:
	jal check_withdraw
	la $a0, bank_array
	la $t0, arg1_int
	lw $t0, 0($t0)		# $t0 --> account number input
	lw $t1, 0($a0)		# $t1 --> cheking account number
	lw $t2, 4($a0)		# $t2 --> savings account number
	beq $t0, $t1, withdraw_checking
	beq $t0, $t2, withdraw_savings
	j error_deposit_account
	
	withdraw_savings:
	la $t0, arg2_int
	lw $t0, 0($t0)
	mul $t3, $t0, 5
	div $t3, $t3, 100
	lw $t1, 12($a0)
	sub $t2, $t1, $t0
	blez $t2, withdraw_error
	sub $t2, $t2, $t3
	sw $t2, 12($a0)
	j done_op
	
	withdraw_checking:
	la $t0, arg2_int
	lw $t0, 0($t0)
	lw $t1, 8($a0)
	sub $t2, $t1, $t0
	blez $t2, withdraw_error
	sub $t2, $t1, $t0
	sw $t2, 8($a0)
	j done_op
	
	withdraw_error:
	la $a1, insufficient_funds
	jal print_string
	j prompt
	
	check_withdraw:
	la $t0, arg1_int
	lw $t0, 0($t0)
	beqz $t0, command_error
	la $t0, arg2_int
	lw $t0, 0($t0)
	beqz $t0, command_error
	la $t0, arg3_int
	lw $t0, 0($t0)
	bnez $t0, command_error
	jr $ra

int_to_asc:
	lw $s0, 0($a0)
	la $s1, temp
	
	li $t0, 22	# storing 21 in the first slot to avoid reversint array later on, print from tail and strop when reached 21 or !
	sb $t0, 0($s1)
	addi $s1, $s1, 1
	
	int_asc_loop:
	li $t0, 10
	div $s0, $t0
	mflo $s0	# $s0 --> number in int (quotient after deviding by 10)
	mfhi $t1	# $t1 --> digit % 10
	addi $t1, $t1, 48
	sb $t1, 0($s1)	# store $t1 + 48 in $s1 (temp array)
	beqz $s0, int_asc_done
	addi $s1, $s1, 1
	j int_asc_loop
	int_asc_done:
	move $v0, $s1
	jr $ra
	
get_loan:
	jal check_loan
	la $a0, bank_array
	check_loan_balance:
	lw $t0, 8($a0)
	lw $t1, 12($a0)
	add $t0, $t0, $t1
	ble $t0, 10000, loan_fund_error
	div $t1, $t0, 2		# $t0 --> total balance, $t1 --> 50% total balance
	la $t2, arg1_int
	
	lw $t2, 0($t2)
	lw $t3, 16($a0)
	add $t2, $t2, $t3	# total loan taken untill now
	
	bgt $t2, $t1, loan_per_error
	
	sw $t2, 16($a0)			# give lone
	
	j done_op
	
	loan_per_error:
	la $a1, loan_error
	jal print_string
	j prompt
	
	loan_fund_error:
	la $a1, insufficient_funds
	jal print_string
	j prompt

	check_loan:
	la $t0, arg1_int
	lw $t0, 0($t0)
	beqz $t0, command_error
	la $t0, arg2_int
	lw $t0, 0($t0)
	bnez $t0, command_error
	jr $ra
	
transfer:
	jal check_transfer
	loan_transfer:
	la $a0, bank_array
	la $t0, arg1_int
	lw $t0, 0($t0)		# $t0 --> account number input
	lw $t1, 0($a0)		# $t1 --> cheking account number
	lw $t2, 4($a0)		# $t2 --> savings account number
	beq $t0, $t1, loan_from_ch
	beq $t0, $t2, loan_from_sv
	j error_deposit_account
	
	loan_from_ch:
	la $a0, bank_array
	la $t0, arg2_int
	lw $t0, 0($t0)		# $t0 --> amount of money to transfer
	lw $t1, 8($a0)		# $t1 --> the amount of money in checking
	sub $t1, $t1, $t0	# $t1 --> money left in cheking after transfer
	blt $t1, $zero, loan_fund_error
	
	lw $t2, 16($a0)		# $t2 --> loan amount
	sub $t2, $t2, $t0	# $t2 --> money left from loan after transfer
	blt $t2, $zero, loan_surplus_error
	sw $t1, 8($a0)
	sw $t2, 16($a0)
	j done_op
	
	loan_from_sv:
	la $a0, bank_array
	la $t0, arg2_int
	lw $t0, 0($t0)		# $t0 --> amount of money to transfer
	lw $t1, 12($a0)		# $t1 --> the amount of money in savings
	sub $t1, $t1, $t0	# $t1 --> money left in savings after transfer
	blt $t1, $zero, loan_fund_error
	
	lw $t2, 16($a0)		# $t2 --> loan amount
	sub $t2, $t2, $t0	# $t2 --> money left from loan after transfer
	blt $t2, $zero, loan_surplus_error
	sw $t1, 12($a0)
	sw $t2, 16($a0)
	j done_op
	
	account_transfer:
	la $a0, bank_array
	la $t0, arg1_int
	lw $t0, 0($t0)		# $t0 --> account number input
	lw $t1, 0($a0)		# $t1 --> cheking account number
	lw $t2, 4($a0)		# $t2 --> savings account number
	beq $t0, $t1, ch_to_sv
	beq $t0, $t2, sv_to_ch
	j error_deposit_account
	
	ch_to_sv:
	la $a0, bank_array
	la $t0, arg2_int
	lw $t0, 0($t0)		# $t0 --> account number input
	lw $t1, 4($a0)		# $t1 --> savings account number
	bne $t0, $t1, error_deposit_account
	
	la $t0, arg3_int
	lw $t0, 0($t0)		# $t0 --> amount of money to transfer
	lw $t1, 8($a0)		# $t1 --> the amount of money in checking
	sub $t1, $t1, $t0	# $t1 --> money left in cheking after transfer
	blt $t1, $zero, loan_fund_error
	sw $t1, 8($a0)
	lw $t2, 12($a0)		# $t2 --> money in savings
	add $t2, $t2, $t0
	sw $t2, 12($a0)
	j done_op
	
	sv_to_ch:
	la $a0, bank_array
	la $t0, arg2_int
	lw $t0, 0($t0)		# $t0 --> account number input
	lw $t1, 0($a0)		# $t1 --> cheking account number
	bne $t0, $t1, error_deposit_account
	
	la $t0, arg3_int
	lw $t0, 0($t0)		# $t0 --> amount of money to transfer
	lw $t1, 12($a0)		# $t1 --> the amount of money in savings
	sub $t1, $t1, $t0	# $t1 --> money left in savings after transfer
	blt $t1, $zero, loan_fund_error
	sw $t1, 12($a0)
	lw $t2, 8($a0)		# $t2 --> money in cheking
	add $t2, $t2, $t0
	sw $t2, 8($a0)
	j done_op
	
	loan_surplus_error:
	la $a1, loan_surplus_msg
	jal print_string
	j prompt
	
	check_transfer:
	la $t0, arg1_int
	lw $t0, 0($t0)
	beqz $t0, command_error
	la $t0, arg2_int
	lw $t0, 0($t0)
	beqz $t0, command_error
	la $t0, arg4_int
	lw $t0, 0($t0)
	bnez $t0, command_error
	la $t0, arg3_int
	lw $t0, 0($t0)
	beqz $t0, loan_transfer
	bnez $t0, account_transfer
	
close_account:
	jal check_close
	la $a0, bank_array
	la $t0, arg1_int
	lw $t0, 0($t0)		# $t0 --> account number input
	lw $t1, 0($a0)		# $t1 --> cheking account number
	lw $t2, 4($a0)		# $t2 --> savings account number
	beq $t0, $t1, close_checking
	beq $t0, $t2, close_savings
	j error_deposit_account
	
	close_checking:
	lw $t0, 8($a0)
	lw $t1, 12($a0)
	lw $t2, 4($a0)
	bne $t2, $zero, add_to_saving
	lw $t1, 16($a0)
	sub $t1, $t1, $t0
	blez $t1, loan_zero_check
	sw $t1, 16($a0)
	sw $zero, 0($a0)
	sw $zero, 8($a0)
	j done_op
	
	loan_zero_check:
	sw $zero, 16($a0)
	sw $zero, 0($a0)
	sw $zero, 8($a0)
	j done_op
	
	add_to_saving:
	add $t1, $t1, $t0
	sw $t1, 12($a0)
	sw $zero, 0($a0)
	sw $zero, 8($a0)
	j done_op
	
	close_savings:
	lw $t0, 12($a0)
	lw $t1, 8($a0)
	lw $t2, 0($a0)
	bne $t2, $zero, add_to_cheking
	lw $t1, 16($a0)
	sub $t1, $t1, $t0
	blez $t1, loan_zero_save
	sw $t1, 16($a0)
	sw $zero, 4($a0)
	sw $zero, 12($a0)
	j done_op
	
	loan_zero_save:
	sw $zero, 16($a0)
	sw $zero, 4($a0)
	sw $zero, 12($a0)
	j done_op
	
	add_to_cheking:
	add $t1, $t1, $t0
	sw $t1, 8($a0)
	sw $zero, 4($a0)
	sw $zero, 12($a0)
	j done_op
	
	check_close:
	la $t0, arg1_int
	lw $t0, 0($t0)
	beqz $t0, command_error
	la $t0, arg2_int
	lw $t0, 0($t0)
	bnez $t0, command_error
	jr $ra
	

get_balance:
	jal check_balance
	la $a0, bank_array
	la $t0, arg1_int
	lw $t0, 0($t0)		# $t0 --> account number input
	lw $t1, 0($a0)		# $t1 --> cheking account number
	lw $t2, 4($a0)		# $t2 --> savings account number
	beq $t0, $t1, balance_checking
	beq $t0, $t2, balance_savings
	j error_deposit_account
	
	
	balance_savings:
	addi $a0, $a0, 12
	jal print_int
	j prompt
	balance_checking:
	addi $a0, $a0, 8
	jal print_int
	j prompt
	
	check_balance:
	la $t0, arg1_int
	lw $t0, 0($t0)
	beqz $t0, command_error
	la $t0, arg2_int
	lw $t0, 0($t0)
	bnez $t0, command_error
	jr $ra


history:
	jal check_history
	la $t0, arg1_int
	lw $t0, 0($t0)			# $t0 --> number or history input
	blez $t0, history_error
	bgt $t0, 5, history_error
	
	la $t1, history_it
	lw $t1, 0($t1)
	bgt $t0, $t1, history_error
	move $s4, $t0
	
	la $a1, history_order
	jal print_string
	
	la $s5, history_array
	history_print:
	beqz $s4, done_hitory
	li $a1, 5
	move $a0, $s5
	jal print_bank
	addi $s5, $s5, 20
	addi $s4, $s4, -1
	j history_print
	
	history_error:
	la $a1, history_msg
	jal print_string
	j prompt
	
	check_history:
	la $t0, arg1_int
	lw $t0, 0($t0)
	beqz $t0, command_error
	la $t0, arg2_int
	lw $t0, 0($t0)
	bnez $t0, command_error
	jr $ra
	
	done_hitory:
	j prompt

quit:
	la $a1, terminate
	jal print_string
	j exit
	
done_op:
	jal update_history
	
	la $a1, bank_msg
	jal print_string

	la $a0, bank_array
	la $a1, 5
	jal print_bank_console
	
	la $a0, bank_array
	la $a1, 5
	jal print_bank
	
	j prompt
