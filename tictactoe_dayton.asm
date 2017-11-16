#Patrick Dayton
#CS 3340.003 - Computer Architecture - F17
#Karen Mazidi
#Course Project
#TIC TAC TOE

#Add in Tie functionality
#Scoreboard Functionality?

###################################################################################################################################################	
	
		.data
	
instruc1:		.asciiz "\n\nLets play some Tic Tac Toe!\n\nTo make a move, enter the square number and hit return.\nSquare numbers are shown below:\n\n"
xTurnPrompt:	.asciiz "\n\nX's Turn!\n\nChoose your next move: "
oTurnPrompt:	.asciiz "\n\nO's Turn!\n\nChoose your next move: "
xWins:		.asciiz "\n\nX Wins!\n\n"
oWins:		.asciiz "\n\nO Wins!\n\n"
ws:		.asciiz "\n\n"
markErr:		.asciiz "\nThis is not a valid move.\nPlease enter an integer from 1 to 9.\n"
x:		.asciiz "X"
o:		.asciiz "O"
go:		.asciiz "GO!:"
winner:		.asciiz "\n\nWinner!\n\n"
invalidMovePrompt:	.asciiz "That spot has already been used.\nPlease use another\n\n"
resetPrompt:	.asciiz "Do you want to play again? (y/n) "
invalidResetPrompt:	.asciiz "\nInvalid Response. Please enter 'y' or 'n'\n"
thanks:		.asciiz "\n\nThanks for playing!\n\nGAME OVER\n\n"
dash:		.byte '-'
y:		.byte 'y'
n:		.byte 'n'

instrucArr:		.byte '1','|','2','|','3','\n','4','|','5','|','6','\n','7','|','8','|','9'
		.space 100
	
moveArr:		.byte '-','|','-','|','-','\n','-','|','-','|','-','\n','-','|','-','|','-'
		.space 100

turn:		.word 0 # 0--> O 1-->X

###################################################################################################################################################
		.text
main:		li $v0, 4	#print initial instructions
  		la $a0, instruc1
  		syscall
  	
		la $a1, instrucArr #print instruction board
		jal printBoard
  	
  		li $v0, 4	#print white space
  		la $a0, ws
  		syscall
 
		jal game
###################################################################################################################################################	
exit:		li $v0, 4	
  		la $a0, thanks
  		syscall
		
		li $v0, 10
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
	
###################################################################################################################################################
		
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

###################################################################################################################################################
																						
		#a1=move array
		#a2=move space
markBoard:		add $t2, $a1, $a2 #t2 = moveArray[i]
		
		#check if board spot is already taken
		la $t4, dash
		lb $t4, ($t4) #so we can check if '-'
		lb $t6, ($t2)
		bne $t4, $t6, invalidMove
		
		lw $t7, turn
		beq $t7, $zero, markO  #if o's turn, mark o and vice versa
		lb $s0, x
		sb $s0, ($t2)
		sw $zero, turn #switch to Os turn
		jr $ra
markO:		lb $s0, o
		li $s2, 1	#switch to Xs turn
		sw $s2, turn
		sb $s0, ($t2)
		jr $ra
		
invalidMove:	li $v0, 4	
  		la $a0, invalidMovePrompt
  		syscall	
  		jr $ra	

###################################################################################################################################################

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
		jal checkForWinner
		
continueGame:	
		j loop2
			
###################################################################################################################################################

		#after each move we check for one of the 8 winning combos
		#winning combos must be either all X or all O and CANNOT have any dashes
checkForWinner:	la $a1, moveArr
		jal check123
		jal check456
		jal check789
		jal check147
		jal check258
		jal check369
		jal check159
		jal check357
		j continueGame
					
check123:		lb $t1, 0($a1)
		lb $t2, 2($a1)
		lb $t3, 4($a1)
		j checkForDashes
		
check456:		lb $t1, 6($a1)
		lb $t2, 8($a1)
		lb $t3, 10($a1)
		j checkForDashes		
		
check789:		lb $t1, 12($a1)
		lb $t2, 14($a1)
		lb $t3, 16($a1)
		j checkForDashes		
		
check147:		lb $t1, 0($a1)
		lb $t2, 6($a1)
		lb $t3, 12($a1)
		j checkForDashes
		
check258:		lb $t1, 2($a1)
		lb $t2, 8($a1)
		lb $t3, 14($a1)
		j checkForDashes						

check369:		lb $t1, 4($a1)
		lb $t2, 10($a1)
		lb $t3, 16($a1)
		j checkForDashes	
		
check159:		lb $t1, 0($a1)
		lb $t2, 8($a1)
		lb $t3, 16($a1)
		j checkForDashes

check357:		lb $t1, 4($a1)
		lb $t2, 8($a1)
		lb $t3, 12($a1)
		j checkForDashes																													
		
checkForDashes:	#Check for a winner after every move.
		#A dash in a winning combination means it's not a winner																																
		la $t4, dash
		lb $t4, ($t4) #so we can check if '-'
		
		beq $t1, $t4, noWin #see if any are equal to '-'
		beq $t2, $t4, noWin
		beq $t3, $t4, noWin
		
		bne $t1, $t2, noWin #see if we have three of same kind in a row
		bne $t1, $t3, noWin 
		
		li $v0, 4 #We've found a winner!
  		la $a0, winner
  		jal clearBoard
  		syscall
		j reset
		
noWin:		jr $ra

###################################################################################################################################################

reset:		li $v0, 4	#print initial instructions
  		la $a0, resetPrompt
  		syscall
  		
  		li $v0, 12	#read in the y/n character
  		syscall
  		
  		lb $t6, y
  		lb $t5, n
  		
  		#user does NOT want to play again
  		move $t7, $v0
  		beq $t5, $t7, exit 
  		
  		#user DOES want to play again
  		move $t7, $v0
  		beq $t6, $t7, game 
  		
  		#user enters an invalid response
  		li $v0, 4	
  		la $a0, invalidResetPrompt
  		syscall
  		j reset 
  		
##################################################################################################################################################

clearBoard:   	la $t4, dash
		lb $t4, ($t4)
		sb $t4, 0($a1)
		sb $t4, 2($a1)
		sb $t4, 4($a1)
		sb $t4, 6($a1)
		sb $t4, 8($a1)
		sb $t4, 10($a1)
		sb $t4, 12($a1)
		sb $t4, 14($a1)
		sb $t4, 16($a1)
		jr $ra
