.include "miniprojectUtils.asm"
#TODO: see at end of file
#TODO: document
#TODO: User IO

main:
.data
	string: .space 100
	solved_string: .space 100
	length: .word 0      	# len(str)
	loop_limit: .word 0 	# limit on looping
	isOdd: .word 0  		# Flag if length%2 == 1
	i: .word 0				# counter for string
	i1: .word 0				# counter for solved_string
	immediate: .word 0		# for wordy purpose
	validMessage: .asciiz " is a cyclone phrase"
	invalidMessage: .asciiz " is not a cyclone phrase"

.text

#Step 1: get a cyclone string (solved_string)

#Initialize
	getStringDialog(string)
	getLengthLabel(string)
	sw $v0, length 			# v0 = len(str)

	div $t0,$v0, 2 
	sw $t0, loop_limit  
	                   
	rem $t0,$v0, 2
	sw $t0, isOdd
	

#For-ing

.macro init_1
	sw $zero, i
.end_macro

.macro cond_1
	pushRegister($t0)
	pushRegister($t1)

	lw $t0, i
	lw $t1, loop_limit

	slt $v0, $t0, $t1

	popRegister($t1)
	popRegister($t0)
.end_macro

.macro increment_1
	increaseBy1(i)
.end_macro


.macro body_1
	pushRegister($a0)
	pushRegister($a1)
	pushRegister($t0)
	pushRegister($t1)

	getAddressAtIndex(string, i)
	move $a1,$a0   						   #a1 = string[i]

	getAddressAtIndex(solved_string, i1)   #a0 = & solved[i1]

	copyChar($a0, $a1)

	increaseBy1(i1)

	#Get reflect of i
	
	lw $t0, i
	mul $t0,$t0,-1

	lw $t1, length
	addi $t1, $t1, -1

	add $t0, $t1, $t0  						#t0 = len(str) - 1 - i
	sw $t0, immediate

	getAddressAtIndex(string, immediate)
	move $a1,$a0   

	getAddressAtIndex(solved_string, i1)    #a0 = & solved[i1]

	copyChar($a0, $a1)

	increaseBy1(i1)

	popRegister($t1)
	popRegister($t0)
	popRegister($a1)
	popRegister($a0)
	
	
.end_macro

	forLoop(init_1, cond_1, increment_1, body_1)

	lw $t0, isOdd
	beqz $t0, okay

	#Copy middle char
	getAddressAtIndex(string, i)
	move $a1,$a0

	getAddressAtIndex(solved_string, i1)
	copyChar( $a0, $a1)

okay:
	#Print

# Step 2: Check condition ( ord(i) > ord(i+1) )

.data
	isOkay: .word 1
.text

# for loop from 0--> len(str) - 2
.macro init_2
	sw $zero, i
.end_macro

.macro cond_2
	# i < len(str) - 1?
	pushRegister($t0)
	pushRegister($t1)

	lw $t0, i  		# t0 = i
	lw $t1, length 	
	addi $t1, $t1, -1 # t1 = length - 1

	slt $v0, $t0, $t1    #i < len(str) - 1?
	popRegister($t1)
	popRegister($t0)
.end_macro


.macro increment_2
	increaseBy1(i)
.end_macro


.macro body_2

	pushRegister($t0) # t0 = index
	pushRegister($t1) # t1 = condition

	lw $t0, i
	get_str_index(solved_string, $t0)
	move $v1,$v0     # v1 = solved_string[i]

	addi $t0, $t0, 1
	get_str_index(solved_string, $t0)   # v0 = solved_string[i+1]

	sgt $t1, $v1, $v0    # v0 > v1?
	beqz $t1, Okay

not_okay:
	sw $zero, isOkay
	j end
Okay:
	j end

end:
	popRegister($t1)
	popRegister($t0)
.end_macro

forLoop(init_2, cond_2, increment_2, body_2)
#End for loop

	lw $a0, isOkay
	beqz $a0, invalidMes
	printStringLabel(string)
	printStringLabel(validMessage)
	j ending
invalidMes:
	printStringLabel(string)
	printStringLabel(invalidMessage)
	
ending:
	li $v0, 10
	syscall