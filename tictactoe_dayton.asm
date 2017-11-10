#Patrick Dayton
#CS 3340.003 - Computer Architecture - F17
#Karen Mazidi
#Course Project
#TIC TAC TOE
###################################################################################################################################################	
	
	.data
	
instruc1:	.asciiz "Lets play some Tic Tac Toe!\n\nTo make a move, enter the square number and hit return.\nSquare numbers are shown below:\n\n\n"
xTurn:	.asciiz "\n\nX's Turn!\n\nChoose your next move: "
oTurn:	.asciiz "\n\nO's Turn!\n\nChoose your next move: "
xWins:	.asciiz "\n\nX Wins!\n\n"
oWins:	.asciiz "\n\nO Wins!\n\n"
ws:	.asciiz "\n\n\n"
pickle:	.asciiz "PICKLE RICK!"
dubdub:	.asciiz "RUBALUBADUBDUB!"

instrucArr:	.word '1','|','2','|','3','\n','4','|','5','|','6','\n','7','|','8','|','9'
	.space 100
	
moveArr:	.word '-','|','-','|','-','\n','-','|','-','|','-','\n','-','|','-','|','-'
	.space 100

turn:	.word 0 # 0--> O 1-->X

###################################################################################################################################################
	.text
main:	li $v0, 4	#print initial instructions
  	la $a0, instruc1
  	syscall
  	
	la $a1, instrucArr #print instruction board
	li $a2, 17
	jal printBoard
  	
  	li $v0, 4	#print white space
  	la $a0, ws
  	syscall
  		
	la $a1, moveArr #print the actual board
	li $a2, 17
	jal printBoard
	
	li $v0, 4	#print white space
  	la $a0, ws
  	syscall
  	
  	li $v0, 4	
  	la $a0, xTurn
  	syscall
  	
  	lw $s6, turn
  	jal switchTurn
  	
###################################################################################################################################################	
exit:	li $v0, 10
	syscall
###################################################################################################################################################

switchTurn:	li $t7, 1 #t7 = 1
	beq $s6, $t7, oGoes 	#if turn==1 (X just went) branch
	sw $t7, turn	#else set turn to 1 (O just went)
	
	li $v0, 4	
  	la $a0, dubdub
  	syscall
	
	jr $ra	
		 
oGoes:	li $t7, 0
	sw $t7, turn	  #set turn to 0 (X just went)
	
	li $v0, 4	
  	la $a0, pickle
  	syscall
  	
	jr $ra
	
printBoard:	move $t0, $zero #i=0
loop1:	sll $t1, $t0, 2 #bits = i*4
	add $t2, $a1, $t1 #t2 = moveArray[i]
	#sw $zero, ($t2) #moveArray[i]=0
	
	li $v0, 4
  	la $a0, ($t2) #print each of the numbers in the loop
  	syscall
  	
	addi $t0, $t0, 1 #i++
	
	#jal divByThree
	
	slt $t3, $t0, $a2 #loop until we get to end
	bne $t3, $zero, loop1
	jr $ra
	
	
