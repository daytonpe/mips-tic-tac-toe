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
x:	.asciiz "X"
o:	.asciiz "O"

instrucArr:	.byte '1','|','2','|','3','\n','4','|','5','|','6','\n','7','|','8','|','9'
	.space 100
	
moveArr:	.byte '-','|','-','|','-','\n','-','|','-','|','-','\n','-','|','-','|','-'
	.space 100

turn:	.word 0 # 0--> O 1-->X

###################################################################################################################################################
	.text
main:	#li $v0, 4	#print initial instructions
  	#la $a0, instruc1
  	#syscall
  	
	#la $a1, instrucArr #print instruction board
	#jal printBoard
  	
  	#li $v0, 4	#print white space
  	#la $a0, ws
  	#syscall
  		
	#la $a1, moveArr #print the actual board
	#jal printBoard
	
	#li $v0, 4	#print white space
  	#la $a0, ws
  	#syscall
  	
  	#li $v0, 4	
  	#la $a0, xTurn
  	#syscall
  	
  	#lw $s6, turn
  	#jal switchTurn
  	#lw $s6, turn
  	#jal switchTurn
  	
  		li $v0, 4	#print white space
  		la $a0, ws
  		syscall
  	
  		li $a2, 1 #mark top left box
  		la $a1, moveArr #print the actual board
  		jal markBoard
		jal printBoard
###################################################################################################################################################	
exit:		li $v0, 10
		syscall
###################################################################################################################################################

switchTurn:		li $t7, 1 #t7 = 1
		beq $s6, $t7, oGoes  #if turn==1 (X just went) branch
		sw $t7, turn  #else set turn to 1 (O just went)
		jr $ra		 
oGoes:		li $t7, 0
		sw $t7, turn  #set turn to 0 (X just went)  	
		jr $ra
	
printBoard:		move $t0, $zero #i=0
loop1:		sll $t1, $t0, 8 #convert i value to bytes
		add $t2, $a1, $t1 #t2 = moveArray[i]
		#sw $zero, ($t2) #moveArray[i]=0
	
		li $v0, 4
  		la $a0, ($t2) #print each of the numbers in the loop
  		syscall
  	
		addi $t0, $t0, 1 #i++
	
		li $t5, 17 #array won't be longer than 17
		slt $t3, $t0, $t5 #loop until we get to end
		bne $t3, $zero, loop1
		jr $ra
	
makeMove: 		#based on the value that is passed in a2 this function: 
		#1)prompts user for move based on who's turn it is
		#2)takes in an integer value from 1-9
		#4)calls the mark function
		
markBoard:		#based on value passed in via a0, this function:
		#1)transform variable input so that it matches correct board position 1>>0, 8>>15
		#2)marks the board in the correct position
		#3)with the correct team (X/O)
		
		#a2=1
		#a1=moveArray
		#sll $t1, $a2, 3 #i=a2*4, remember that a2 will be our transformed input
		add $t2, $a1, $a2 #t2 = moveArray[i]
		lb $s0, x
		sb $s0, ($t2)
		jr $ra
