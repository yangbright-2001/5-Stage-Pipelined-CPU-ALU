.text
# To test the MEM_to_EX hazard
# To test the WB_to_EX hazard
# If the hazard is handled correctly, $a2 should be 8. Otherwise, it may be -1 or something else
      rt    rs
addi $v0, $zero, 1      #v0(2)=1  
addiu $v1, $zero, 2     #v1(3)=2
addiu $a0, $zero, 20    #a0(4)=20
addiu $a1, $zero, 16    #a1(5)=16
addi $t1, $zero, 1 # t1(9) meaningless instruction, just to avoid other hazards
addi $t1, $zero, 1 # meaningless instruction, just to avoid other hazards 
addi $t1, $zero, 1 # meaningless instruction, just to avoid other hazards 
sub $v0, $a0, $a1 # 4 in $v0  #v0(2)=4
sub $v1, $a1, $a0 # -4 in $v1   #v1(3)=-4
#下面的语句，$v0,$v1各有一个hazard
sub $a2, $v1, $v0 # -8 in $a2(6) (if the forward succeeds, $a2 should be 8)
sw $a2, 0($zero) # store $a2, which should be -8, in DATA_MEM[0]
    rt             # We only need to care about the value in $a2, so we just store $a2