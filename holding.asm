pushLoop:
		
		lw $t1, ($s1) #; address of subarray1 address 
		lw $t2, ($s3) #; address of subarray2 address 
		blt $t1, $t2, pushOnStack1
		j pushOnStack2

		pushOnStack1:
		subu $sp, $sp, 4
		sw $t1, ($sp)
		subu $t3, $t3, 1
		beqz $t3, pushOnStack2
		addu $s1, $s1, 4
		j pushLoop

		pushOnStack2:
		subu $sp, $sp, 4
		sw $t2, ($sp)
		subu $t4, $t4, 1
		beqz $t3, pushOnStack1
		addu $s3, $s3, 4 
		j pushLoop

		moveOn:
		
		li $t4, 0
		j pushLoop

	popLoop:

		addu $sp, $sp, 4
		lw $s1, ($sp)
		add $t4, $t4, 1
		sw $s1, numbers
		add $t5, $s0, $s2
		bne $t4, $t5, popLoop