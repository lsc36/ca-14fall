lw   $s0, 0($0)
addi $t1, $0, 1
Begin:
nop
beq  $s0, $0, End
add  $t2, $t0, $t1
add  $t0, $t1, $0
add  $t1, $t2, $0
addi $s0, $s0, -1
j    Begin
End:
sw   $t0, 4($0)
