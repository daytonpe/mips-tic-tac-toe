		.data
	
instruc1:		.asciiz "\n\nLets play some Tic Tac Toe!\n\nTo make a move, enter the square number and hit return.\nSquare numbers are shown below:\n\n"
xTurnPrompt:	.asciiz "\n\nX's Turn!\n\nChoose your next move: "
oTurnPrompt:	.asciiz "\n\nO's Turn!\n\nChoose your next move: "
xWins:		.asciiz "\n\nX Wins!\n\n"
oWins:		.asciiz "\n\nO Wins!\n\n"
ws:		.asciiz "\n\n"
markErr:		.asciiz "\nThis is not a valid move.\nPlease enter an integer from 1 to 9.\n"
pickle:		.asciiz "\nPICKLE RICK!"
dubdub:		.asciiz "\nRUBALUBADUBDUB!"
x:		.asciiz "X"
o:		.asciiz "O"
y:		.byte 'y'
n:		.byte 'n'
go:		.asciiz "GO!:"
winner:		.asciiz "\n\nWinner!\n\n"
invalidMovePrompt:	.asciiz "That spot has already been used.\nPlease use another\n\n"
resetPrompt:	.asciiz "Do you want to play again? (y/n) "
invalidResetPrompt:	.asciiz "\nInvalid Response. Please enter 'y' or 'n'\n"
thanks:		.asciiz "\n\nThanks for playing!\n\nGAME OVER\n\n"
dash:		.byte '-'

instrucArr:		.byte '1','|','2','|','3','\n','4','|','5','|','6','\n','7','|','8','|','9'
		.space 100
	
moveArr:		.byte 'X','|','O','|','X','\n','0','|','-','|','-','\n','-','|','-','|','X'
		.space 100

turn:		.word 0 # 0--> O 1-->X


		.text
		
		la $a1, moveArr
		jal clear
		jal printBoard
		
		li $v0, 10
		syscall
		
############################################################################
		
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
		
############################################################################		

clear:   		la $t4, dash
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
		
		#move $t0, $zero	#i=0
		#la $t4, dash
		#lb $t4, ($t4)
		#li $t3, 0
	
#clearLoop:		#sll $t1, $t0, 2	#t1 = i * 4
		#add $t2, $a1, $t1	#$t2 = &array[i] $t2 is now the element pointer
		
		#sb $t4, 0($t2)	#array[i] = '-'
		#addi $t0, $t0, 1	#i = i + 1
		#slt $t3, $t0, $a1	#$t3 = (i < size)
		
		#bne $t3, $zero, clearLoop   # if (...) goto loop
  		#jr $ra	
