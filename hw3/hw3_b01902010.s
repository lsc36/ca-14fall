.data
n:
	.word	0
c:
	.word	0
comma:
	.word	0
output:
	.word	0
file_in:
	.asciiz	"/home/lsc36/103-1/ca/hw3/in.txt"
file_out:
	.asciiz	"/home/lsc36/103-1/ca/hw3/b01902010_out.txt"

# the following data is only for sample demonstration
output_ascii:
	.word	0

.text
main:    #start of your program

# STEP1: open input file
# ($s0: fd_in)

	li	$v0, 13			# 13 = open file
	la	$a0, file_in		# $a2 <= filepath
	li	$a1, 0x0		# $a1 <= flags = 0x0 (O_RDONLY)
	li	$a2, 0			# $a2 <= mode = 0
	syscall				# $v0 <= $s0 = fd
	move	$s0, $v0		# store fd_in in $s0, fd_in is the file descriptor just returned by syscall

# STEP2: read inputs (chars) from file to registers
# ($s1: n, $s2: c)

# 2 bytes for n
	li	$v0, 14			# 14 = read from file
	move	$a0, $s0		# $a0 <= fd_in
	la	$a1, n			# $a1 <= n
	li	$a2, 2			# read 2 byte to the address given by n
	syscall

#   1 byte for the comma
	li	$v0, 14			# 14 = read from file
	move	$a0, $s0		# $a0 <= fd_in
	la	$a1, comma		# $a1 <= comma
	li	$a2, 1			# read 1 bytes to the address given by comma
	syscall

#   2 bytes for c
	li	$v0, 14			# 14 = read from file
	move	$a0, $s0		# $a0 <= fd_in
	la	$a1, c			# $a1 <= c
	li	$a2, 2			# read 2 byte to the address given by c
	syscall

# STEP3: turn the chars into integers
	la	$a0, n
	bal	atoi
	move	$s1, $v0		# $s1 <= atoi(n)

	la	$a0, c
	bal	atoi
	move	$s2, $v0		# $s2 <= atoi(c)

################################ write your code below ################################
# Inputs are ($s1: n, $s2: c)
# Output is $s3 (in integer)


# STEP4: implement recursive function to solve the equation
	move	$a0, $s1
	bal	calc
	move	$s3, $v0
	j	result

# calc($a0: n) = 2 * calc(n / 2) + n * c, n > 1
#	       | c, n = 1
calc:
	li	$t0, 1
	beq	$a0, $t0, .basecase	# goto base case if n = 1
	srl	$a0, $a0, 1		# n = n / 2 (as argument for recursion)
	addiu	$sp, $sp, -4		# allocate stack for return address
	sw	$ra, 0($sp)
	bal	calc			# result = calc(n / 2)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4		# free stack
	sll	$v0, $v0, 1		# result = result * 2
	sll	$a0, $a0, 1		# n = n * 2 (original n)
	mult	$a0, $s2
	mflo	$t0			# $t0 = n * c
	add	$v0, $v0, $t0		# result = result + n * c
	jr	$ra
.basecase:
	move	$v0, $s2
	jr	$ra





# STEP5: turn the integer into printable char
# transferred ASCII should be put into "output_ascii"(see definition in the beginning of the file)
result:
	sw	$s3, output	# output <= $s3
	move	$a0, $s3
	bal	itoa		# itoa($s3)
	sw	$v0, output_ascii	# output_ascii <= itoa($3)
	jr	ret

itoa:
	# Input: ($a0 = input integer)
	# Output: ( output_ascii )
	li	$v0, 0		# reset $v0
	div	$a0, $a0, 10
	mfhi	$t0		# 4th digit
	addi	$t0, $t0, 48
	sll	$t0, $t0, 24	# shift 3 bytes
	or	$v0, $v0, $t0
	div	$a0, $a0, 10
	mfhi	$t0		# 3rd digit
	addi	$t0, $t0, 48
	sll	$t0, $t0, 16	# shift 2 bytes
	or	$v0, $v0, $t0
	div	$a0, $a0, 10
	mfhi	$t0		# 2nd digit
	addi	$t0, $t0, 48
	sll	$t0, $t0, 8	# shift 1 byte
	or	$v0, $v0, $t0
	div	$a0, $a0, 10
	mfhi	$t0		# 1st digit
	addi	$t0, $t0, 48
	or	$v0, $v0, $t0

	jr	$ra		# return

################################ write your code above ################################

ret:

# STEP6: write result (output_ascii) to file_out
# ($s4 = fd_out)

	li	$v0, 13			# 13 = open file
	la	$a0, file_out		# $a2 <= filepath
	li	$a1, 0x41		# $a1 <= flags = 0x41 (O_WRONLY | O_CREAT)
	li	$a2, 0x1a4		# $a2 <= mode = 0644
	syscall				# $v0 <= $s0 = fd_out
	move	$s4, $v0		# store fd_out in $s4

	li	$v0, 15			# 15 = write file
	move	$a0, $s4		# $a0 <= $s4 = fd_out
	la	$a1, output_ascii
	li	$a2, 4
	syscall				# $v0 <= $s0 = fd

# STEP7: this is for you to debug your calculation on console
	li	$v0, 1			# 1 = print int
	lw	$a0, output		# $a0 <= $s1
	syscall				# print output


# STEP8: close file_in and file_out

	li	$v0, 16			# 16 = close file
	move	$a0, $s0		# $a0 <= $s0 = fd_in
	syscall				# close file

	li	$v0, 16			# 16 = close file
	move	$a0, $s4		# $a0 <= $s4 = fd_out
	syscall				# close file


# exit

	li	$v0, 10
	syscall



#######################################################################################
#
#  int atoi ( const char *str );
#
#  Parse the cstring str into an integral value
#
#  Author: http://stackoverflow.com/questions/9649761/mips-store-integer-data-into-array-from-file
atoi:
	or      $v0, $zero, $zero   	# num = 0
	or      $t1, $zero, $zero   	# isNegative = false
	lb      $t0, 0($a0)
	bne     $t0, '+', .isp      	# consume a positive symbol
	addi    $a0, $a0, 1
.isp:
	lb      $t0, 0($a0)
	bne     $t0, '-', .num
	addi    $t1, $zero, 1       	# isNegative = true
	addi    $a0, $a0, 1
.num:
	lb      $t0, 0($a0)
	slti    $t2, $t0, 58        	# *str <= '9'
	slti    $t3, $t0, '0'       	# *str < '0'
	beq     $t2, $zero, .done
	bne     $t3, $zero, .done
	sll     $t2, $v0, 1
	sll     $v0, $v0, 3
	add     $v0, $v0, $t2       	# num *= 10, using: num = (num << 3) + (num << 1)
	addi    $t0, $t0, -48
	add     $v0, $v0, $t0       	# num += (*str - '0')
	addi    $a0, $a0, 1         	# ++num
	j   .num
.done:
	beq     $t1, $zero, .out    	# if (isNegative) num = -num
	sub     $v0, $zero, $v0
.out:
	jr      $ra         		# return

