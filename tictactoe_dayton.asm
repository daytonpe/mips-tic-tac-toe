#Patrick Dayton
#CS 3340.003 - Computer Architecture - F17
#Karen Mazidi
#Course Project
#TIC TAC TOE
###################################################################################################################################################	
	
	.data
	
instruc1:		.asciiz "Lets play some Tic Tac Toe!\n\nTo make a move, enter the square number and hit return.\nSquare numbers are shown below:\n\n"
xTurnPrompt:	.asciiz "\n\nX's Turn!\n\nChoose your next move: "
oTurnPrompt:	.asciiz "\n\nO's Turn!\n\nChoose your next move: "
xWins:		.asciiz "\n\nX Wins!\n\n"
oWins:		.asciiz "\n\nO Wins!\n\n"
ws:		.asciiz "\n\n"
markErr:		.asciiz "\nThis is not a valid input.\nPlease enter an integer from 1 to 9.\n"
pickle:		.asciiz "PICKLE RICK!"
dubdub:		.asciiz "RUBALUBADUBDUB!"
x:		.asciiz "X"
o:		.asciiz "O"
go:		.asciiz "GO!:"

instrucArr:		.byte '1','|','2','|','3','\n','4','|','5','|','6','\n','7','|','8','|','9'
		.space 100
	
moveArr:		.byte '-','|','-','|','-','\n','-','|','-','|','-','\n','-','|','-','|','-'
		.space 100

turn:		.word 0 # 0--> O 1-->X

###################################################################################################################################################
		.text
main:		#li $v0, 4	#print initial instructions
  		#la $a0, instruc1
  		#syscall
  	
		#la $a1, instrucArr #print instruction board
		#jal printBoard
  	
  		#li $v0, 4	#print white space
  		#la $a0, ws
  		#syscall
 
		#jal game
		jal check123
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
		
transformMark:	#based on value passed in via a0, this function:
		#1)transform variable input so that it matches correct board position 1>>0, 8>>15
		#2)marks the board in the correct position
		#3)with the correct team (X/O)

		#TRANSFORM INPUT
		li $t6, 1  #if 1 is input, transform it to 0 on board
		bne $a2, $t6, mark2
		li $a2, 0
		j markBoard

mark2:		li $t6, 2  #2>>2
		bne $a2, $t6, mark3
		j markBoard
		
mark3:		li $t6, 3  #3>>4
		bne $a2, $t6, mark4
		li $a2, 4
		j markBoard

mark4:		li $t6, 4  #4>>6
		bne $a2, $t6, mark5
		li $a2, 6
		j markBoard	
		
mark5:		li $t6, 5  #5>>8
		bne $a2, $t6, mark6
		li $a2, 8
		j markBoard					
			
mark6:		li $t6, 6  #6>>10
		bne $a2, $t6, mark7
		li $a2, 10
		j markBoard	
		
mark7:		li $t6, 7  #7>>12
		bne $a2, $t6, mark8
		li $a2, 12
		j markBoard	
		
mark8:		li $t6, 8  #8>>14
		bne $a2, $t6, mark9
		li $a2, 14
		j markBoard	

mark9:		li $t6, 9  #9>>16
		bne $a2, $t6, markError
		li $a2, 16
		j markBoard					

markError:		#print error prompt
		li $v0, 4	#print white space
  		la $a0, markErr
  		syscall
		jr $ra																												
											
		#a1=moveArray
markBoard:		add $t2, $a1, $a2 #t2 = moveArray[i]
		lw $t7, turn
		beq $t7, $zero, markO  #if o's turn, mark o and vice versa
		lb $s0, x
		sb $s0, ($t2)
		sw $zero, turn #switch to Xs turn
		jr $ra
markO:		lb $s0, o
		li $s2, 1	#switch to Xs turn
		sw $s2, turn
		sb $s0, ($t2)
		jr $ra

game:		#1)Check turn
		#2)Prompt correct user for input
		#3)Mark Board 
		#4)Check for Winner
		#5)Notify Winner when Necessary
		#6)Prompt for Reset
		#7)Reset
		
		li $s7, 0 #turn counter
		
loop2:		lw $s0, turn
		beq $s0, $zero, oTurn		
		li $v0, 4	
  		la $a0, xTurnPrompt
  		syscall
  		j continueMove
				
oTurn:		li $v0, 4	
  		la $a0, oTurnPrompt
  		syscall	
  		
continueMove:	li $v0, 5	#read an integer
  		syscall
  	  	move $a2, $v0
  	  	
  	  	li $v0, 4	
  		la $a0, ws
  		syscall
  	  	
  		la $a1, moveArr #print the actual board
  		jal transformMark
		jal printBoard
		
		addi $s7, $s7, 1
		li $s6, 9
		beq $s7, $s6, exit #if you get to nine moves, exit!
		j loop2	

				
check123:		#check if someone has one via the 123 pattern (Really 0,2,4)
		la $a1, moveArr
		
		lb $t1, 0($a1)
		lb $t2, 2($a1)
		lb $t3, 4($a1)
		
		
		beq $t1, $t2, bigpickle
		j exit
		#when checking if same also need to check that they aren't dashes
		
bigpickle:		li $v0, 4
  		la $a0, pickle
  		syscall	
  			