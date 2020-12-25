# This program calculates the slope and midpoint between two points in a plane

	.data
str_x1:
	.asciiz "Enter x1: "
str_y1:
	.asciiz "Enter y1: "
str_x2:
	.asciiz "Enter x2: "
str_y2:
	.asciiz "Enter y2: "
out_midpoint:
	.asciiz "The midpoint is: "
out_slope:
	.asciiz "The slope is: "
space:
	.asciiz ","
newline:
	.asciiz "\n"

	.text	
main:
# Prompt user to enter the values
# Saving x1 in $t1
li $v0, 4
la $a0, str_x1
syscall

li $v0, 5
syscall

move $t1, $v0

# Saving x2 in $t2
li $v0, 4
la $a0, str_x2
syscall

li $v0, 5
syscall

move $t2, $v0

# Saving x2 in $t3
li $v0, 4
la $a0, str_y1
syscall

li $v0, 5
syscall

move $t3, $v0

# Saving x2 in $t4
li $v0, 4
la $a0, str_y2 
syscall

li $v0, 5
syscall

move $t4, $v0

# Calculating Midpoint
add $t5,$t1,$t2 #$s1 is the x-midpoint
srl $s1,$t5,1

add $t6,$t3,$t4 #$s2 is the y-midpoint
srl $s2,$t6,1

# Calculating Slope
sub $t5,$t4,$t3
sub $t6,$t2,$t1
div $t5,$t6
mflo $s3

# Printing the computed values
# Printing the values of midpoint
li $v0,4
la $a0, out_midpoint
syscall

li $v0,1
move $a0,$s1
syscall
li $v0,4
la $a0, space
syscall
li $v0,1
move $a0,$s2
syscall

li $v0,4
la $a0, newline
syscall


# Printing the values of slope
li $v0,4
la $a0, out_slope
syscall

li $v0, 1
add $a0,$zero,$s3
syscall



# EXIT PROGRAM
li $v0,10		#system call code for exit = 10
syscall			#call operating sys : EXIT
