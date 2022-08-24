#;	Assignment #12
#; 	Author: Keith Beauvais
#; 	Section: 1001
#; 	Date Last Modified: 11/24/2021
#; 	Program Description: This program will implement a mergeSort.

.data
#;	System service constants
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_STRING = 4
	SYSTEM_PRINT_CHARACTER = 11
	SYSTEM_READ_INTEGER = 5
	SYSTEM_EXIT = 10
	
#;	Random Number Generator Values
	M = 0x00010001
	A = 75
	C = 74
	previousRandomNumber: .word  1
	
	MINIMUM_VALUE = 1
	MAXIMUM_VALUE = 100
	ARRAY_SIZE = 100

	numbers: .space ARRAY_SIZE*4


#;	Labels
	unsortedArrayLabel: .asciiz "Unsorted:\n"
	sortedArrayLabeL: .asciiz "\nSorted:\n"
	mergesLabel: .asciiz "\nMerges: "
	space: .asciiz "  "
	newLine: .asciiz "\n"

.text
.globl main
.ent main
main:
	#;  Uses the random number function to initialize the array to random values
	li $v0, SYSTEM_PRINT_STRING
	la $a0, unsortedArrayLabel
	syscall

	
	la $s1, numbers #; saves the address
	li $s2, ARRAY_SIZE #; saves the array size

	#;	intializes the 2D array with random numbers from generator
	initializeLoop:
		li $a0, 1
		li $a1, 100
		jal getRandomNumber
		sw $v0, ($s1)
		add $s1, $s1, 4
		sub $s2, $s2, 1 
		bnez $s2, initializeLoop
	
	#;	Prints the unsorted array of random values
	la $a0, numbers
	li $a1, 10
	jal printArray

	#;	Sort using mergeSort
	la $a0, numbers
	li $a1, ARRAY_SIZE
	jal mergeSort
	move $t6, $v0
	
	#;	Print the sorted array
	li $v0, SYSTEM_PRINT_STRING
	la $a0, sortedArrayLabeL
	syscall
		
	#;	Print the number of merges used
	la $a0, numbers
	li $a1, 10
	jal printArray

	#;	Prints out the amount of merges from the returned function
	li $v0, SYSTEM_PRINT_STRING
	la $a0, mergesLabel
	syscall

	li $v0, SYSTEM_PRINT_INTEGER
	move $a0, $t6
	syscall
	
	li $v0, SYSTEM_EXIT
	syscall
	
.end main

#; Sorts an array using the merge sort algorithm:
#;	Split array into two halves
#;	Call mergeSort on each half
#;	Merge each half of the array
#;    Compare the front of each array
#;		Push the lower valued element and increment its pointer
#;		Continue until both sub-arrays are empty
#;		Pop the values back into the array (in reverse)
#;	Base Case: Array Size = 1 just return (do not count as a merge)
#;	Arguments:
#;		$a0 - &array (signed word integers)
#;		$a1 - array size (signed word integer)
#;	Return a count of the number of merges
.globl mergeSort
.ent mergeSort
mergeSort:

	subu $sp, $sp, 32
	sw $s0, 0($sp) 	#; subarray1 size 
	sw $s1, 4($sp)	#; subarray1 address 
	sw $s2, 8($sp)	#; subarray2 size 
	sw $s3, 12($sp) #; subarray2 address 
	sw $s4, 16($sp)	#; original address
	sw $s5, 20($sp) #; original size
	sw $s6, 24($sp)
    sw $ra, 28($sp)

	move $s4, $a0 #; original address
	move $s5, $a1 #; original size

	li $s6, 0 

	li $v0, 1
	#; Base Case
	beq $a1, 1, mergeSortDone
	#; Setting up the splits for subarrays
	divu $s0, $a1, 2 #; subarray1 size 
	subu $s2, $a1, $s0 #; subarray2 size 
	move $s1, $a0 #; subarray1 address 
	move $t0, $s0
	mulou $t0, $t0, 4
	addu $s3, $a0, $t0 #; subarray2 address 

	#; recursive call (merge left)
	move $a0, $s1
	move $a1, $s0
	jal mergeSort

	#; recursive call (merge right)
	move $a0, $s3
	move $a1, $s2
	jal mergeSort

	#; responsible for merges
	move $t0, $s0 #; size of subarray1
	move $t1, $s2 #; size of subarray2
	li $t2, 0 #; left
	li $t3, 0 #; right
	li $t4, 0 #; total

	pushLoop:
		bgeu $t2, $t0, remainingRightLoop #; if the left side is greater or equal to the leftSize of the subarray then push the remaining right side
		bgeu $t3, $t1, remainingLeftLoop #; if the right side is greater or equal to the rightSize of the subarray then push the remaining left side
		lw $t5, ($s1) #; address of subarray1 address 
		lw $t6, ($s3) #; address of subarray2 address
		bgt $t5, $t6, elseStatement  #; if the left side is greater than the right then push right integer if not push left and increase left count by 1
		subu $sp, $sp, 4
		sw $t5, ($sp)
		addu $t2, $t2, 1
		addu $s1, $s1, 4
		j incrementTotal
		elseStatement:
		subu $sp, $sp, 4
		sw $t6, ($sp)
		addu $t3, $t3, 1
		addu $s3, $s3, 4
		incrementTotal:
		addu $t4, $t4, 1 #; increments total (used to push later)
		j pushLoop

	remainingLeftLoop:
		#; while the left count is less than the leftSize subarray size, push integers increase total count and left count, once it hits then goes to pop in reverse order.   
		bgeu $t2, $t0, popTime
		lw $t5, ($s1)
		subu $sp, $sp, 4
		sw $t5, ($sp)
		addu $t2, $t2, 1
		addu $t4, $t4, 1
		addu $s1, $s1, 4
		j remainingLeftLoop

	remainingRightLoop:
		#; while the right count is less than the rightSize subarray size, push integers increase total count and left count, once it hits then goes to pop in reverse order.  
		bgeu $t3, $t1, popTime
		lw $t6, ($s3)
		subu $sp, $sp, 4
		sw $t6, ($sp)
		addu $t3, $t3, 1
		addu $t4, $t4, 1
		addu $s3, $s3, 4
		j remainingRightLoop
	
	popTime:
	#; moves pointer to the back of the original array to start popping 
	move $t7, $s5
	subu $t7, $t7, 1
	mulou $t7, $t7, 4
	move $t0, $s4
	addu $t0, $t7, $t0

	popLoop:
		#; pops the integers on the stack in reverse order using the total counts. 
		lw $t5, ($sp)
		sw $t5, ($t0)
		subu $t0, $t0, 4
		addu $sp, $sp, 4
		subu $t4, $t4, 1
		move $v0, $s6
		addu $s6, $s6, 1
		bnez $t4, popLoop

	mergeSortDone:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $ra, 28($sp)
		addu $sp, $sp, 32
	jr $ra
.end mergeSort

#; Gets a random non-negative number between a specified range
#; Uses a linear congruential generator
#;	m = 2^16+1
#;	a = 75
#;	c = 74
#;	newRandom = (previous*a+c)%m
#; Arguments:
#;	$a0 - Minimum Value
#;	$a1 - Maximum Value
#; Global Variables/Constants Used
#;	previousRandom - Used to generate the next value, must be updated each time
#;	m, a, c
#; Returns a random signed integer number
.globl getRandomNumber
.ent getRandomNumber
getRandomNumber:
	#; Multiply the previous random number by A
	#; Add C
	#; Get the remainder by M
	#; Set the previousRandomNumber to this new random value
	#; Use the new random value to generate a random number within the specified range
	#; return randomNumber = newRandom%(maximum-minimum+1)+minimum

	lw $t0, previousRandomNumber
	li $t1, M
	li $t2, A
	li $t3, C 

	mul $t0, $t0, $t2
	add $t0, $t0, $t3
	rem $t0, $t0, $t1
	sw $t0, previousRandomNumber

	move $t0, $a0 # min
	move $t1, $a1 # max

	lw $t2, previousRandomNumber
	sub $t0, $t1, $t0
	add $t0, $t0, 1
	rem $t0, $t2, $t0
	add $t0, $t0, 1

	move $v0, $t0 

	jr $ra
.end getRandomNumber

#; Prints an array to the console with a new line every 10 elements
#; Arguments:
#;	$a0 - &array
#;	$a1 - elements
.globl printArray
.ent printArray
printArray:
	move $t0, $a0
	move $t1, $a1
	li $t4, 0 # counter

	 mul $t3, $t1, $t1 # array size 

	printMatrixLoop:
		#; prints out the integer 
        li $v0, SYSTEM_PRINT_INTEGER
        lw $a0, ($t0)
        syscall
		#; prints out the a space
        li $v0, SYSTEM_PRINT_STRING
        la $a0, space
        syscall
		#; moves the index over, increases count by 1 and subtracts one from the total array size
        addu $t0, $t0, 4
        subu $t3, $t3, 1
        addu $t4, $t4, 1
		#; checks the column size to the count to end the line or not 
        bne $t4, $t1, printMatrixLoop

    endLine:
		#; ends the line 
        li $v0, SYSTEM_PRINT_STRING
        la $a0, newLine
        syscall
		#; resets the count
        li $t4, 0 
        bnez $t3, printMatrixLoop

        li $v0, SYSTEM_PRINT_STRING
        la $a0, newLine
        syscall
	jr $ra
.end printArray


