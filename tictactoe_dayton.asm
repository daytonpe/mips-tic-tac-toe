#Patrick Dayton
#CS 3340.003 - Computer Architecture - F17
#Karen Mazidi
#Course Project
#TIC TAC TOE

#Program lets a user play Tic Tac Toe against a random number generator powered AI. 

###################################################################################################################################################	
	
		.data
	
instruc1:		.asciiz "\n*************************************\n*******LET'S PLAY TIC TAC TOE!*******\n*************************************\n\nTo make a move, enter a keypad number.\n\nYou will be Team X.\nThe computer is Team O.\n\nSquare numbers are shown below.\n\nGood Luck!\n\n"
xTurnPrompt:	.asciiz "\n\nX's Turn!\n\nChoose your next move: "
compTurnPrompt:	.asciiz "\n\nYour robo-adversary is contemplating... "
xWinsPrompt:	.asciiz "\n\nYou have Won! Go Team X!\n************************\n\n"
oWinsPrompt:	.asciiz "\n\nThe Robot Wins! Go Team O!\n**************************\n\n"
ws:		.asciiz "\n"
markErr:		.asciiz "\nThis is not a valid move.\nPlease enter an integer from 1 to 9.\n\n"
x:		.asciiz "X"
o:		.asciiz "O"
tiePrompt:		.asciiz "\n\nYou have tied!\n\n"
invalidMovePrompt:	.asciiz "\nThat spot has already been used.\nPlease use another\n\n"
resetPrompt:	.asciiz "Do you want to play again? (y/n) "
invalidResetPrompt:	.asciiz "\nInvalid Response. Please enter 'y' or 'n'\n"
thanks:		.asciiz "\n\nThanks for playing!\n\n*************************************\n**************GAME OVER**************\n*************************************\n"

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
main:		jal game

###################################################################################################################################################

game:		#1)Check turn
		#2)Prompt correct user for input
		#3)Mark Board 
		#4)Check for Winner
		#5)Notify Winner when Necessary
		#6)Prompt for Reset
		#7)Reset if necessary
		
		#Print Game Instruction
		li $v0, 4	#print initial instructions
  		la $a0, instruc1
  		syscall
  		
  		#print instruction board
		la $a1, instrucArr 
		jal printBoard
  	
  		li $v0, 4	#print white space
  		la $a0, ws
  		syscall
		
		#clear Board for New Game
		la $a1, moveArr
		jal clearBoard
		
		move $s5, $zero #initialize the move counter to 0. Use this for tie checking
		move $s7, $zero #marker initializes to 0
		
gameLoop:		#Main loop for the series of actions in one game
		
		li $t1, 9	#if counter is at eight and no winner was declared. We have a tie!
		beq $s5, $t1, tie
		
		lw $s0, turn
		beq $s0, $zero, computerTurn	
		
		################BOARD REPRINT AFTER COMPUTER TURN##############
		#Have to keep this section out of computerTurn loop so that board doesn't get reprinted
		#...each time the random number generator chooses a number that's already been picked
		
		#Sleep for 2 seconds before making move if computer to simulate thinking
  		beq $s7, $zero, userTurn
  		li $a0, 1000
  		li $v0, 32
  		syscall
  		
  		#Print the board after the computer's turn
		li $v0, 4	
  		la $a0, ws
  		syscall
		la $a1, moveArr
		jal printBoard
		
  		################USER'S TURN######################
		#Prompt the user to enter a value 1-9
userTurn:		li $v0, 4	
  		la $a0, xTurnPrompt
  		syscall
  		
  		#Read an integer from the Player
  		li $v0, 12	
  		syscall
  		subi $a2, $v0, 48
  		
  		li $v0, 4	
  		la $a0, ws
  		syscall
  		
  		move $s7, $zero #computer 'thinking-marker' set to 0
  			    #used to see if we need to print computer thinking prompt or not
  		
  		#Use subroutines to mark the transform the input, mark the board, and check for a winner
  		la $a1, moveArr 
		jal transformMark
		jal printBoard
		jal checkForWinner
		
		j gameLoop
				
computerTurn:	################COMPUTER'S TURN##################

		li $t1, 1 #see below for $s7 explanation 
		beq $s7, $t1, skipCompPrompt 
		
		#Print cute computer prompt
		li $v0, 4	
  		la $a0, compTurnPrompt
  		syscall
	  		
  		#Use s7 as our marker that the computer is currently trying to find a move
  		#Set marker to 1 after first printing compTurnPrompt
  		#if s7 = 1, don't reprint the board and the prompt each time
  		li $s7, 1
  		
skipCompPrompt:	#Random Number Generator	
		li $v0, 42		#Service 42, random int
		li $a1, 10		#Set max to 9 (min is 1)
		xor $a0, $a0, $a0	#Select random generator 0
		syscall		#Generate random int (returns in $a0)
		move $a2, $a0
  		
  		la $a1, moveArr 
		jal transformMark
		jal checkForWinner
		
continueGame:	j gameLoop
		

###################################################################################################################################################

printBoard:		move $t0, $zero #i=0

		li $v0, 4	
  		la $a0, ws
  		syscall	

printLoop:		sll $t1, $t0, 8 #convert i value to bytes
		add $t2, $a1, $t1 #t2 = moveArray[i]
	
		li $v0, 4
  		la $a0, ($t2) #print each of the numbers in the loop
  		syscall
  	
		addi $t0, $t0, 1 #i++
	
		li $t5, 17 #array won't be longer than 17
		slt $t3, $t0, $t5 #loop until we get to end
		bne $t3, $zero, printLoop
		jr $ra
	
###################################################################################################################################################
		
transformMark:	#based on value passed in via a0, this function transforms 
		#variable input so that it matches correct board position 1>>0, 8>>15

		#if 1 is input, transform it to 0 on board
		li $t6, 1  
		bne $a2, $t6, mark2
		li $a2, 0
		j markBoard

mark2:		#2>>2
		li $t6, 2  
		bne $a2, $t6, mark3
		j markBoard
		
mark3:		#3>>4
		li $t6, 3  
		bne $a2, $t6, mark4
		li $a2, 4
		j markBoard

mark4:		#4>>6
		li $t6, 4  
		bne $a2, $t6, mark5
		li $a2, 6
		j markBoard	
		
mark5:		#5>>8
		li $t6, 5  
		bne $a2, $t6, mark6
		li $a2, 8
		j markBoard					
			
mark6:		#6>>10
		li $t6, 6  
		bne $a2, $t6, mark7
		li $a2, 10
		j markBoard	
		
mark7:		#7>>12
		li $t6, 7  
		bne $a2, $t6, mark8
		li $a2, 12
		j markBoard	
		
mark8:		#8>>14
		li $t6, 8  
		bne $a2, $t6, mark9
		li $a2, 14
		j markBoard	

mark9:		#9>>16
		li $t6, 9  
		bne $a2, $t6, markError
		li $a2, 16
		j markBoard					

markError:		#Show Prompt: This is not a valid move.\nPlease enter an integer from 1 to 9
		lw $t1, turn
		beq $t1, $zero, markReturn1 #if computer somehow makes an invalid move, don't prompt
		li $v0, 4	
  		la $a0, markErr
  		syscall		
markReturn1:	jr $ra																												

###################################################################################################################################################

		#This section actually markes the board to be displayed
																																														
		#a1=move array
		#a2=move space
markBoard:		add $t2, $a1, $a2 #t2 = moveArray[i]
		
		#Test if board spot is already taken
		la $t4, dash
		lb $t4, ($t4) #so we can check if '-'
		lb $t6, ($t2)
		bne $t4, $t6, invalidMove
		
		lw $t7, turn
		beq $t7, $zero, markO  #if o's turn, mark o and vice versa
		lb $s0, x
		sb $s0, ($t2)
		sw $zero, turn #switch to Os turn
		addi $s5, $s5, 1 #Increment tie tracker
		jr $ra
		
markO:		lb $s0, o
		li $s2, 1	#switch to Xs turn
		sw $s2, turn
		sb $s0, ($t2)
		addi $s5, $s5, 1 #Increment tie tracker	
		jr $ra
		
invalidMove:	#Prompt that spot was already used
		lw $t1, turn
		beq $t1, $zero, markReturn2 #if computer makes an invalid move, don't prompt
		li $v0, 4	
  		la $a0, invalidMovePrompt
  		syscall	
  					
markReturn2:  	jr $ra	
			
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
					
check123:		#test top horizontal
		lb $t1, 0($a1)
		lb $t2, 2($a1)
		lb $t3, 4($a1)
		j checkForDashes
		
check456:		#test middle horizontal
		lb $t1, 6($a1)
		lb $t2, 8($a1)
		lb $t3, 10($a1)
		j checkForDashes		
		
check789:		#test bottom horizontal
		lb $t1, 12($a1)
		lb $t2, 14($a1)
		lb $t3, 16($a1)
		j checkForDashes		
		
check147:		#test left vertical
		lb $t1, 0($a1)
		lb $t2, 6($a1)
		lb $t3, 12($a1)
		j checkForDashes
		
check258:		#test middle vertical
		lb $t1, 2($a1)
		lb $t2, 8($a1)
		lb $t3, 14($a1)
		j checkForDashes						

check369:		#test right vertical
		lb $t1, 4($a1)
		lb $t2, 10($a1)
		lb $t3, 16($a1)
		j checkForDashes	
		
check159:		#check top left to bottom right diagonal
		lb $t1, 0($a1)
		lb $t2, 8($a1)
		lb $t3, 16($a1)
		j checkForDashes

check357:		#check top right to bottom left diagonal
		lb $t1, 4($a1)
		lb $t2, 8($a1)
		lb $t3, 12($a1)
		j checkForDashes																													
		
checkForDashes:	#Check for a winner after every move.
		#A dash in a winning combination means it's not a winner																																
		la $t4, dash
		lb $t4, ($t4) #so we can check if '-'
		
		#test if any are equal to '-'
		beq $t1, $t4, noWin 
		beq $t2, $t4, noWin
		beq $t3, $t4, noWin
		
		#test if we have three of same kind in a row
		bne $t1, $t2, noWin 
		bne $t1, $t3, noWin 
		
		#We've found a winner!
		li $v0, 4 
  		la $t1, turn #actually need it to be the opposite of turn
  		lw $t1, ($t1)
  		beq $t1, $zero, xWins
  		
  		#Format with White Space
  		li $v0, 4	
  		la $a0, ws
  		syscall
  		
  		#Sleep for 2 seconds before making move if computer to simulate thinking
  		li $a0, 1000
  		li $v0, 32
  		syscall
  		
  		#Reprint the board and print that the computer has one the game!
		la $a1, moveArr
		jal printBoard	
  		
  		#Print that the computer has won this game
  		la $a0, oWinsPrompt
  		j printWinner
  		
xWins:		la $a0, xWinsPrompt
			
printWinner:	syscall
  		
  		#if someone wins, we ask the user if they want to play again
		j reset
		
noWin:		#no one has won. Continue game
		jr $ra

####################################################################################################################################################

tie:		#Tie functionality changes based on who forces the tie
		lw $s0, turn
		beq $s0, $zero, announceTie
		
		#Format with white Space
		li $v0, 4	
  		la $a0, ws
  		syscall
  		
  		#Due to way we generate computer move, we need to reprint board here only for the computer
		la $a1, moveArr 
		jal printBoard
		
		#print tie announcement
announceTie:	li $v0, 4	
  		la $a0, tiePrompt
  		syscall
  		j reset

####################################################################################################################################################

reset:		#print reset prompt
		li $v0, 4	
  		la $a0, resetPrompt
  		syscall
  		
  		#read in the y/n character
  		li $v0, 12	
  		syscall
  		
  		#load in yes and no bytes
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

clearBoard:   	#clear board of all Xs and Os after a game
		#actually shorter to do it manually than with a loop
		la $t4, dash
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
		
###################################################################################################################################################	

exit:		#thank user for playing
		li $v0, 4	
  		la $a0, thanks
  		syscall
		
		#clean exit
		li $v0, 10
		syscall
