.data
 
.text
 
    addi $t1,$zero,1
    addi $sp,$zero,268505084
    addi  $s0, $zero, 3 
    add $s1, $zero, 0x10010000     
    sll $t7, $s0, 2
    add $s2, $t7, $s1  
    add $s3, $s2, $t7
    add $t6, $s0,$zero
    for:
        sw   $t6, 0($s1)
        add  $s1, $s1, 4
        addi $t6, $t6, -1
        bne  $t6, $zero, for
    add $s4,$s0,$zero
    jal hanoiTower
j end

hanoiTower:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    bne  $s4, $t1, else
    addi $s1, $s1, -4
    sw   $s4, 0($s3)
    addi $s3, $s3, 4
    sw   $zero, 0($s1)
    lw   $ra, 0($sp)
    addi $sp, $sp,4
    addi  $s4, $s4, 1
    jr   $ra 
else:
    add $t3, $zero, $s2  
    add $s2, $zero, $s3
    add $s3, $zero, $t3
    addi $s4, $s4, -1  
    jal hanoiTower
    addi $s1, $s1, -4
    sw   $s4, 0($s2)
    addi $s2,$s2, 4
    sw   $zero, 0($s1)
    add $t0, $zero, $s1    
    add $s1, $zero, $s3
    add $s3,$zero, $s2
    add $s2, $zero, $t0
    sub $s4, $s4, 1  
    jal hanoiTower
    add $t5, $zero, $s1    
    add $s1, $zero, $s2
    add $s2, $zero, $t5
    lw   $ra, 0($sp)
    addi $sp, $sp,4
    addi $s4, $s4, 1
    jr $ra 


end:
    
