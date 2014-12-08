addi	$a0, $zero, 0
addi	$t0, $zero, 0
addi	$t1, $zero, 1
addi	$s1, $zero, 0
addi	$s2, $zero, 1
lw	$s0, 0($a0)
addi	$s4, $s0, 0

loop:
sub	$s0, $s0, $t1
add	$s1, $s1, $s2
addi	$s3, $s2, 0
addi	$s2, $s1, 0
addi	$s1, $s3, 0
beq	$s0, $t0, finish
j	loop

finish:
sw	$s1, 4($a0)
and	$t2, $s1, $zero
or	$t3, $s1, $zero
add	$t4, $s1, $t4
sub	$t5, $s1, $t4
mul	$t6, $s1, $t4
sw	$t2, 8($a0)
sw	$t3, 12($a0)
sw	$t4, 16($a0)
sw	$t5, 20($a0)
sw	$t6, 24($a0)
