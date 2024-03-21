.data
.text
main:
j test1
j test2
j test3
j test4
j test5
j test6
j test7
j test8
j test9
j testa
j testb
j testc
j testd
j teste
j testf
j testg

test1:
	
	lw $v0,0X00003FFF($0)
	addi $s1,$0,1
	beq $v0,$s1,yes1
	addi $s1,$0,2
	beq $v0,$s1,yes1
	addi $s1,$0,4
	beq $v0,$s1,yes1
	addi $s1,$0,8
	beq $v0,$s1,yes1
	addi $s1,$0,16
	beq $v0,$s1,yes1
	addi $s1,$0,32
	beq $v0,$s1,yes1
	addi $s1,$0,64
	beq $v0,$s1,yes1
	addi $s1,$0,128
	beq $v0,$s1,yes1
	addi $s1,$0,256
	beq $v0,$s1,yes1
	add $a1,$zero,$zero
	add $a0,$a0,$v0
	j exit
	yes1:
	add $a0,$a0,$v0
	addi $a1,$a1,1
	j exit


test2:
	add $a1,$zero,$zero
	lw $v0,0X00003FFF($0)
	addi $a0,$v0,0
	loop1:
	addi $s1,$zero,0
	beq $v0,$s1,even
	addi $s1,$zero,1
	beq $v0,$s1,odd
	addi $s1,$zero,2
	beq $v0,$s1,even
	addi $s1,$zero,3
	beq $v0,$s1,odd
	addi $s1,$zero,4
	beq $v0,$s1,even
	addi $s1,$zero,5
	beq $v0,$s1,odd
	addi $s1,$zero,6
	beq $v0,$s1,even
	addi $s1,$zero,7
	beq $v0,$s1,odd
	addi $v0,$v0,-8
	j loop1
	even:
	add $a1,$zero,$zero
	j exit
	odd:
	addi $a1,$zero,1
	j exit

test3:
	lw $v0,0X00003FFF($0)
	addi $a0,$v0,0
	lw $v0,0X00003FFB($0)
	addi $a1,$v0,0
	or $a2,$a1,$a0
	j exit

test4:
	lw $v0,0X00003FFF($0)
	addi $a0,$v0,0
	lw $v0,0X00003FFB($0)
	addi $a1,$v0,0
	nor $a2,$a1,$a0
	j exit

test5:
	lw $v0,0X00003FFF($0)
	addi $a0,$v0,0
	lw $v0,0X00003FFB($0)
	addi $a1,$v0,0
	xor $a2,$a1,$a0
	j exit

test6:
	lw $v0,0X00003FFF($0)
	addi $a0,$v0,0
	lw $v0,0X00003FFB($0)
	addi $a1,$v0,0
	slt $a2,$a0,$a1
	j exit

test7:
	lw $v0,0X00003FFF($0)
	addi $a0,$v0,0
	lw $v0,0X00003FFB($0)
	addi $a1,$v0,0
	addi $a1,$v0,0
	sltu $a2,$a0,$a1
	j exit

test8:
	lw $v0,0X00003FFF($0)
	addi $a0,$v0,0
	lw $v0,0X00003FFB($0)
	addi $a1,$v0,0
	j exit

test9:
#、�?�bug
	lw $t0,0X00003FFF($0)
	slti $t6,$t0,0
	bne $t6,$0,NegativeCalculateSum
	calculateSum:
		add $t1,$t0,$t1
		addi $t0,$t0,-1
		bne $t0,$0,calculateSum
		add $a0,$t1,$zero
	j exit
	NegativeCalculateSum:
		add $t1,$t0,$t1
		addi $t0,$t0,1
		bne $t0,$0,NegativeCalculateSum
		add $a0,$t1,$zero
	j exit
	
testa:
	li $sp,0x00003FF8
	lw $t2,0x00003FFF
	addi $t0,$t2,0
	j L1
	fact1:
		addi $sp,$sp,-8
		sw $ra,4($sp)
		addi $a0,$a0,2
		addi $a1,$a1,2
		addi $a2,$a2,2
		sw $t3,0($sp)
		bne $t3,$t0,L1
		jr $ra
	L1:	
		addi $t3,$t3,1
		jal fact1	
	Y:  	
		lw $t4,0($sp)
		lw $t4,0($sp)
		addi $a0,$a0,2
		addi $a1,$a1,2
		addi $a2,$a2,2
		lw $ra,4($sp)
		lw $ra,4($sp)
		add $t5,$t4,$t5
		addi $sp,$sp,8
		beq $ra,0,Y1_2
		jr $ra
	Y1_2:	
		move $a2,$t5
		addi $a0,$a0,-2
		addi $a1,$a1,-2
	j exit		


testb:
	li $sp,0x00003FF8
	li $s0,0
	li $s1,10000000
	lw $t2,0x00003FFF
	addi $t0,$t2,0
	li $a0,0
	j L2
	fact2:
		addi $sp,$sp,-8
		sw $ra,4($sp)
		sw $a0,0($sp)
		bne $a0,$t0,L2
		jr $ra
	L2:	
		addi $a0,$a0,1
		addi $a1,$a1,1
		addi $a2,$a2,1
		jal cycle2_2
		
		jal fact2	
	Y2:  	
		lw $s2,0($sp)
		lw $s2,0($sp)
		add $s3,$s2,$s3
		lw $ra,4($sp)
		lw $ra,4($sp)
		addi $sp,$sp,8
		beq $ra,0,Y2_2
		jr $ra
	Y2_2:	
		move $a0,$s3
		move $a1,$s3
		move $a2,$s3
		
		
	j exit	
	
	cycle2_2:
		addi $s0,$s0,1
		addi $s5,$s5,0
		addi $s5,$s5,0
		bne $s0,$s1,cycle2_2
		li $s0,0
		jr $ra

	
testc:
	
	li $sp,0x00003FF8
	li $s0,0
	li $s1,10000000
	lw $t2,0x00003FFF
	addi $t0,$t2,0
	li $a0,0
	j L3
	fact3:
		addi $sp,$sp,-8
		sw $ra,4($sp)
		sw $s4,0($sp)
		bne $s4,$t0,L3
		jr $ra
	L3:	
		addi $s4,$s4,1
		jal fact3
	Y3:  	
		lw $a0,0($sp)
		lw $a0,0($sp)
		lw $a1,0($sp)
		lw $a1,0($sp)
		lw $a2,0($sp)
		lw $a2,0($sp)
		jal cycle3_2
		add $s3,$a0,$s3
		lw $ra,4($sp)
		lw $ra,4($sp)
		addi $sp,$sp,8
		beq $ra,0,Y3_2
		jr $ra
	Y3_2:
		move $a0,$s3
		move $a1,$s3
		move $a2,$s3
	j exit	
	
	cycle3_2:
		addi $s0,$s0,1
		addi $s5,$s5,0
		addi $s5,$s5,0
		bne $s0,$s1,cycle3_2
		li $s0,0
		jr $ra

	
testd:
	lw $t0,0X00003FFF($0)
	lw $t1,0X00003FFB($0)
	add $t2,$t1,$t0
	addi $t4,$0,255
	addi $t5,$0,128
	and $t3,$t2,$t4
	and $s0,$t0,$t5
	and $s1,$t1,$t5
	and $s2,$t2,$t5
	beq $s0,$s1,overFlowDeter
	j end5
	overFlowDeter:
	bne $s2,$s1,overFlow
	j end5
	overFlow:
	addi $s7,$0,1
	j end5
	end5:
	add $a0,$t3,$zero
	add $a1,$s7,$zero
	j exit
	
teste:
	lw $t0,0X00003FFF($0)
	lw $t1,0X00003FFB($0)
	addi $s5,$zero,255
	sub $s6,$s5,$t1
	addi $t1,$s6,1
	add $t2,$t1,$t0
	addi $t4,$0,255
	addi $t5,$0,128
	and $t3,$t2,$t4
	and $s0,$t0,$t5
	and $s1,$t1,$t5
	and $s2,$t2,$t5
	beq $s0,$s1,overFlowDeter2
	j end6
	overFlowDeter2:
	bne $s2,$s1,overFlow2
	j end6
	overFlow2:
	addi $s7,$zero,1
	j end6
	end6:
	add $a0,$t3,$zero
	add $a1,$s7,$zero
	j exit
	
testf:
	lw $t0,0X00003FFF($0)
	lw $t1,0X00003FFB($0)

	slti $s3,$t0,0
	addi $s4,$0,1
	beq $s3,$s4,f1
	back1:
	slti $s3,$t1,0
	beq $s3,$s4,f2
	back2:
	
	addi $a0,$zero,0
	add $t2,$0,$0
	loop:
	addi $s1,$zero,1
	and $s2,$s1,$t1 #to determine the lowest bit of $s1
	beq $s2, $0, jumpAdd
	add $t2, $t0, $t2
	jumpAdd:
	sll $t0,$t0,1
	srl $t1,$t1,1
	addi $a0,$a0,1
	addi $a1,$0,8 #4 is the length of 9 in binary
	slt $s1,$a0,$a1
	beq $s1,$s4,loop
	add $a0,$0,$t2
	
	bne $t8,$t9,change
	back3:
	j end
	f1:
	addi $t0,$t0,-1
	addi $t3,$zero,1
	nor $t0,$t0,$zero
	addi $t8,$zero,1
	j back1
	f2:
	addi $t1,$t1,-1
	addi $t3,$zero,1
	nor $t1,$t1,$zero
	addi $t9,$zero,1
	j back2
	change:
	nor $a0,$a0,$zero
	addi $a0,$a0,1
	j back3
	end:
	j exit

testg:	

	lw $t1,0X00003FFF($0)
	lw $t2,0X00003FFB($0)
	
	#lw $t1,dividend # t1 : diviend
	#lw $t2,divisor
	beq $t2,$0,error1
	addi $s3,$0,0x00000080
	slt $s1,$t1,$s3
	addi $s2,$0,1
	bne $s1,$s2,f3
	back4:
	slt $s1,$t2,$s3
	bne $s1,$s2,f4
	back5:
	addi $a0,$zero,0
	sll $t2,$t2,8 # t2 : dividor
	add $t3,$t1,$zero # t3 store the remainder
	add $t4,$0,$0 # t4 Quot
	addi $a0,$zero,0x80000000 #a0 used to get the higest bit of rem
	add $t0,$0,$0 # t0: loop cnt
	addi $v0,$zero,9 #v0: looptimes
	loopb: #MIPS piece2/3
	# $t1: dividend, $t2: divisor, $t3: remainder, $t4: quot
	# $a0: 0x8000, $v0: 5
	sub $t3,$t3,$t2 #dividend - dividor
	and $s0,$t3,$a0 # get the higest bit of rem to check if rem<0
	sll $t4,$t4,1 # shift left quot with 1bit
	beq $s0,$0, SdrUq # if rem>=0, shift Div right
	add $t3,$t3,$t2 # if rem<0, rem=rem+div
	srl $t2,$t2,1
	addi $t4,$t4,0
	j loope
	SdrUq:
	srl $t2,$t2,1
	addi $t4,$t4,1
	loope:
	addi $t0,$t0,1
	bne $t0,$v0,loopb
	addi $v0,$0,1 #MIPS piece3/3
	bne $t8,$t9,change1
	back6:
	beq $t8,$s2,change2
	back7:
	add $a0,$0,$t4 #print quot
	add $a1,$0,$t3 #print remainder
	j end2
	f3:
	addi $t1,$t1,-1
	nor $t1,$t1,$0
	addi $t8,$0,1
	andi $t1,$t1,0x000000ff
	j back4
	f4:
	addi $t2,$t2,-1
	nor $t2,$t2,$0
	addi $t9,$0,1
	andi $t2,$t2,0x000000ff
	j back5
	change1:
	nor $t4,$t4,$0
	addi $t4,$t4,1
	j back6
	change2:
	nor $t3,$t3,$0
	addi $t3,$t3,1
	j back7
	error1:
	addi $a0,$0,-1
	end2:
	
	j exit
exit:
	or $a1,$a1,$0
