.data
 	
desc: 	.asciiz		"\n This program takes either a decimal, a hexdecmial or a binary digits and asks\nthe user to choose one of them to convert the value entered to the other two\n\n"
menu:	.asciiz		"\n\n1)\t\tEnter a Binary Number\n\n2)\t\tEnter a Decimal Number\n\n3)\t\tEnter a Hexadeimal Number\n\n4)\t\tQuit\n\n"
choiceTxt: .asciiz	"Enter your choice -->  "
errMsg1: .asciiz	"\nError: Inavlid input.\n\n"
binTxt: .asciiz	"\nEnter a binary number  (less than 33 digits) -->  "
decTxt: .asciiz	"\nEnter a decimal number (less than 4294967295d) --> "
hexTxt: .asciiz	"\nEnter a hexadecimal number (less than 0FFFFFFFFh) -->  "
tooLarge: .asciiz "\nError: Input too large. Try again please.\n\n"
bin: .asciiz "\nBinary = "
dec: .asciiz "\tDecimal = "
hex: .asciiz "\tHexadecimal = "
userInput:  .space 5
binBuffer:  .space 100
hexBuffer:  .space 100 #with leading zero if starts with letter
userChoiceB: .space 40

      	# start of instruction section
      	.text
      	.globl main
      	
      	# ============================================
      	# MAIN ENTERANCE OF THE PROGRAM
      	# ============================================
      	
      	main:
      
	la   $a0, desc        # load program description to reg a0
      	li   $v0, 4           # service number 4 is to do a print operation
      	syscall
      	
      	loopMain:
      	
      	la   $a0, menu        # load program menu to reg a0
      	li   $v0, 4           # we also load service 4 to print the menu
      	syscall
      	
      	loopChoice:
      	
      	# ===============================================
      	# RESET USED REGISTERS
      	# =============================================
      	xor $t0, $t0, $t0
      	xor $t0, $t0, $t0
      	xor $t1, $t1, $t1
      	xor $t2, $t2, $t2
      	xor $t3, $t3, $t3
      	xor $t4, $t4, $t4
      	xor $t5, $t5, $t5
      	xor $t6, $t6, $t6
      	xor $t7, $t7, $t7
      	xor $t8, $t8, $t8
      	xor $t9, $t9, $t9
      	
      	la   $a0, choiceTxt        # load program menu to reg a0
      	li   $v0, 4           # we also load service 4 to print the menu
      	syscall
      	
      	li $v0, 8
	la $a0, userChoiceB
	li $a1, 100
	syscall		# get the user's choice
	
	
	# =====================================================
      	# HANDLE ERRORS RELATED TO USER CHOICE
      	# =====================================================
      	
      	choice_search:

	lbu $t8, userChoiceB($t9)
	# size counter
	addiu $t2, $t2, 1
	addiu $t9, $t9, 1

	bne $t8, '\n', choice_search

	subiu $t2, $t2, 1
	
	bgt $t2, 1, checkMenuGreater
	xor $t2, $t2, $t2
      	xor $t9, $t9, $t9
      	xor $t8, $t8, $t8
      	
      	lbu $t0, userChoiceB($zero)      # store the user's choice
      	
      	#addi $t1, $zero, 4
      	bgt $t0, '4', checkMenuGreater	# check if the user's choice is correct and print error if not
      	
      	#addi $t1, $zero, 0
      	ble $t0, '0', checkMenuLess	# check if the user's choice is correct and print error if not
   
   
      	beq $t0, '4', exit		# end the program if user choose 4
      	
      	beq $t0, '2', intMenu		# branch to binary menu
      	
      	beq $t0, '1', binMenu
      	
      	beq $t0, '3', hexMenu		# call hex procedure
      	
      	
      	checkMenuGreater:
      		la   $a0, errMsg1
      		li   $v0, 4
      		syscall
      		
      		b loopChoice
      		
      	checkMenuLess:
      		la   $a0, errMsg1
      		li   $v0, 4
      		syscall
      		
      		b loopChoice
      		
      	exit: 
      		li $v0, 10 		# end of the program
      		syscall
      		
      	# ==============================================
      	# MAIN START FOR EACH CONVERSION PROCESS
      	# ===============================================	
    	
      	intMenu:
      	jal intMenuProc
      	jal calAllConversionProc
      	b loopMain
      	
      	binMenu:
      	jal binMenuProc
      	jal calAllConversionProc
      	b loopMain
      	
      	hexMenu:
      	jal hexMenuProc
      	jal calAllConversionProc
      	b loopMain
      	
      	# =====================================================
      	# STARR OF THE HEX PREPROCESSING PROCEDURE
      	# =====================================================
      	
      	hexMenuProc:  	
      	la $a0, hexTxt
      	li $v0, 4
      	syscall
      		
      	li $v0, 8
	la $a0, userInput
	li $a1, 100
	syscall
	
	la $t1, userInput
	
	xor $a1, $a1, $a1
	xor $a2, $a2, $a2
	xor $t2, $t2, $t2
	
	
	hex_search:
	
	# print input
	lbu $a0, userInput($a1)

	addiu $a1, $a1, 1
	
	# size counter
	addiu $t2, $t2, 1
	beq $a0, '\n', finishLengthHex
	
	blt $a0, '0', checkMenuLess
	bgt $a0, '9', lengthHex1
	b continLS
	
	lengthHex1:
	blt $a0, 'A', checkMenuLess
	bgt $a0, 'F', lengthHex2
	b continLS
	
	lengthHex2:
	blt $a0, 'a', checkMenuLess
	bgt $a0, 'f', checkMenuLess
	
	continLS:
	bne $a0, '\n', hex_search

	finishLengthHex:
	subiu $t2, $t2, 1
	
	bgt $t2, 9, hexTooLarge
	
	b continueHex
	hexTooLarge :
	
	la   $a0, tooLarge        # load program description to reg a0
      	li   $v0, 4           # service number 4 is to do a print operation
      	syscall
      	
      	b loopChoice

	continueHex:
	
	addiu $t3, $t3, 2
	addiu $t5, $t5, 0
	addiu $t6, $t6, 1 # the result integer
	
	xor $a3, $a3, $a3
	
	move $t4, $t2
	
	hex_firstround:
	# subtract t4 by 1
	#100
	subiu $t4, $t4, 1
	
	# move t4 to t5
	move $t5, $t4
	
	# get char at t5 to a1
	lbu $a1, userInput($a3)
	addi $a3, $a3, 1
	
	beq $a1, '\n', hex_last
	
	# if grearter than or equal to 49
	bge $a1, '0', hex_checkSecond
	# to do : exist to error unknown char
	
	hex_checkSecond:
	ble $a1, '9', hex_calpower
	
	# for letters from a to f
	bge $a1, 'a', hex_checkthird
	# to do : exist to error unknown char
	
	hex_checkthird:
	ble $a1, 'f', hex_calpower
	
	hex_back:
	# add result of t6 to t7
	sub $a1, $a1, 48
	bgt $a1, 9, hex_bmore
	b hex_orig
	hex_bmore:
	sub $a1, $a1, 7
	bgt $a1, 15, hex_bmore2
	b hex_orig
	hex_bmore2:
	sub $a1, $a1, 32
	
	hex_orig:
	mul $t6, $t6, $a1
	addu $t7, $t7, $t6
	
	# make t6 zero
	xor $t6, $t6, $t6
	add $t6, $t6, 1

	# loop again for next value
	bgez $t4, hex_firstround
	
	b hex_last
	
	hex_calpower: #cal power of 16^x
	beq $t5, 0, hex_back
	mul $t6, $t6, 16
	subiu $t5, $t5, 1
	blez $t5, hex_back
	b hex_calpower
	
	hex_last:

	jr $ra


	# =================================================
	# START OF THE BINARY PREPROCESSING PROCEDURE
	# =================================================
      		
      	binMenuProc:
      	la $a0, binTxt
      	li $v0, 4
      	syscall
      		
      	li $v0, 8
	la $a0, userInput
	li $a1, 100
	syscall
	
	la $t1, userInput
	
	xor $a1, $a1, $a1
	xor $a2, $a2, $a2
	xor $t2, $t2, $t2
	
	
	bin_search:
	
	# get input
	lbu $a0, userInput($a1)
	
	# string counter
	addiu $a1, $a1, 1
	
	# size counter
	addiu $t2, $t2, 1
	beq $a0, '\n', finishLengthBin
	blt $a0, '0', checkMenuLess
	bgt $a0, '1', checkMenuLess
	bne $a0, '\n', bin_search
	
	finishLengthBin:

	subiu $t2, $t2, 1
	
	bgt $t2, 33, binTooLarge
	
	b continueBin
	binTooLarge :
	
	la   $a0, tooLarge        # load program description to reg a0
      	li   $v0, 4           # service number 4 is to do a print operation
      	syscall
      	
      	b loopChoice

	continueBin:
	
	addiu $t3, $t3, 2
	addiu $t5, $t5, 0
	addiu $t6, $t6, 1 # the result integer
	
	xor $a3, $a3, $a3
	
	move $t4, $t2

	bin_firstround:
	
	# subtract t4 by 1
	subiu $t4, $t4, 1
	
	# move t4 to t5
	move $t5, $t4
	
	# get char at t5 to a1
	lbu $a1, userInput($a3)
	addi $a3, $a3, 1
	
	# if a1 = '1' cal power
	beq $a1, '1', bin_calpower
	
	beq $a1, '0', bin_firstround
	
	beq $a1, '\n', bin_last
	
	bin_back:
	
	# add result of t6 to t7
	add $t7, $t7, $t6
	
	# make t6 zero
	xor $t6, $t6, $t6
	add $t6, $t6, 1

	# loop again for next value
	bgez $t4, bin_firstround
	
	b bin_last
	
	bin_calpower: #cal power of 2^x
	beq $t5, 0, bin_back
	mul $t6, $t6, 2
	subiu $t5, $t5, 1
	blez $t5, bin_back
	b bin_calpower

	bin_last:
	
	jr $ra
	
      	# ==============================================================
      	# START OF THE DECIMAL PREPROCESSING PROCEDURE
      	# ===============================================================	
      	intMenuProc:
      	la   $a0, decTxt
      	li   $v0, 4
      	syscall
      		
      	li $v0, 8
	la $a0, userInput
	li $a1, 40
	syscall
	
	la $t1, userInput
	
	xor $a1, $a1, $a1
	xor $a2, $a2, $a2
	xor $t2, $t2, $t2
	
	addi $sp, $sp, -4

	sw $ra, 0($sp)
	
	# get the length of the input value
	jal get_input_length
	
	lw $ra, 0($sp)
	
	addi $sp, $sp, 4
	
	#reset registers
	xor $t9, $t9, $t9
	xor $t7, $t7, $t7
	xor $t6, $t6, $t6
	addiu $t6, $t6, 1
	
	firstround:
	# subtract t4 by 1
	#100
	subiu $t4, $t4, 1 # 1- 
	
	# move t4 to t5
	move $t5, $t4
	
	# get char at t5 to a1
	lbu $a1, userInput($a3)# start ??a3 counter  
	addi $a3, $a3, 1# i  +1 
	
	beq $a1, '\n', calBinary
	
	# if grearter than or equal to 48
	bge $a1, '0', checkSecond
	# to do : exist to error unknown char
	
	checkSecond:
	bleu $a1, '9', calpower
		
	
	back:
	# add result of t6 to t7
	sub $a1, $a1, 48
	
	mulu $t6, $t6, $a1
	addu $t7, $t7, $t6
	bltu $t7, $t9, hexTooLarge
	
	addu $t9, $t9, $t6 #  to check for overflow
	
	# make t6 zero
	xor $t6, $t6, $t6
	add $t6, $t6, 1

	# loop again for next value
	bgez $t4, firstround

	# TODO: fix this if theres an error
	b calBinary
	
	calpower:
	 #cal power of 10^x  # int check
	 #34 ---> 3*10 ^1 + 10^0*4  $t5
	beq $t5, 0, back
	mulu $t6, $t6, 10
	subiu $t5, $t5, 1
	blez $t5, back
	b calpower
	
	calBinary:
	jr $ra
	
	# ========================================================
	# START OF THE CONVERSION PROCEDURE FOR DEC, BIN AND HEX
	# ========================================================
	
	calAllConversionProc:
	# zero t3 as a counter fomr buffer
	xor $t3, $t3, $t3
	xor $t6, $t6, $t6
	move $t6, $t7 #for bin
	move $t5, $t7 #for hex
	move $t8, $t7 #for dec
	findNumOfDiv:
	
	#t1 to store quetient
	xor $t1, $t1, $t1
	
	# t2 to store remainder
	xor $t2, $t2, $t2
	
	divu $t6, $t6, 2
	mflo $t1	# store value of low register which containt the quetient
	mfhi $t2	# store value of high register which contain the remainder
	
	addi $t3, $t3, 1
	beqz $t1, temBin
	bgtz $t1, findNumOfDiv
	
	temBin:
	move $t6, $t3
	subi $t3, $t3, 1

	b binCovLoop
	
	binCovLoop:
	# begin convertion to bin
	
	#t1 to store quetient
	xor $t1, $t1, $t1
	
	# t2 to store remainder
	xor $t2, $t2, $t2
	
	divu $t7, $t7, 2
	mflo $t1	# store value of low register which containt the quetient
	mfhi $t2	# store value of high register which contain the remainder
	
	beq $t2, 0, isZero
	beq $t2, 1, isOne
	
	isZero:
	xor $t4, $t4, $t4
	addi $t4, $t4, '0'
	sb $t4, binBuffer($t3)
	
	b cont
	
	isOne:
	xor $t4, $t4, $t4
	addi $t4, $t4, '1'
	sb $t4, binBuffer($t3)
	
	cont:
	subi $t3, $t3, 1
	beqz $t1, finishDecToBin
	bgtz $t1, binCovLoop
	
	finishDecToBin:
	xor $t1, $t1, $t1
	addi $t1, $t1, 0
	sb $t1, binBuffer($t6)
	xor $t6, $t6, $t6
	
	calHex:
	# zero t3 as a counter fomr buffer
	xor $t3, $t3, $t3
	xor $t6, $t6, $t6
	move $t6, $t5
	move $t4, $t5
	HfindNumOfDiv:
	
	#t1 to store quetient
	xor $t1, $t1, $t1
	
	# t2 to store remainder
	xor $t2, $t2, $t2
	
	divu $t6, $t6, 16
	mflo $t1	# store value of low register which containt the quetient
	mfhi $t2	# store value of high register which contain the remainder
	
	addi $t3, $t3, 1
	beqz $t1, HtemBin
	bgtz $t1, HfindNumOfDiv
	
	HtemBin:
	xor $t6, $t6, $t6
	move $t6, $t3
	subi $t3, $t3, 1
	#check last remainder if hex
	
	addi $t2, $t2, 55
	
	bge $t2, 'a', hexLeadingS1
	bge $t2, 'A', hexLeadingC1
	
	b hexCovLoop
	
	hexLeadingS1:
	ble $t2, 'f', hexLeading
	b hexCovLoop
	
	hexLeadingC1:
	ble $t2, 'F', hexLeading
	b hexCovLoop
	
	hexLeading: 
	addi $t3, $t3, 1
	xor $t1, $t1, $t1
	addi $t1, $t1, 48
	sb $t1, hexBuffer($zero)
	xor $t9, $t9, $t9
	addi $t9, $t9, 1 #flag for a leading zero
	
	
	b hexCovLoop
	
	hexCovLoop:
	# begin convertion to hex
	
	#t1 to store quetient
	xor $t1, $t1, $t1
	
	# t2 to store remainder
	xor $t2, $t2, $t2
	
	divu $t5, $t5, 16
	mflo $t1	# store value of low register which containt the quetient
	mfhi $t2	# store value of high register which contain the remainder
	
	ble $t2, 9, HisZeroToNine
	bge $t2, 10, HisTenToFifteen
	
	HisZeroToNine:
	addi $t2, $t2, 48
	sb $t2, hexBuffer($t3)
	
	b Hcont
	
	HisTenToFifteen:
	addi $t2, $t2, 55
	sb $t2, hexBuffer($t3)
	
	Hcont:
	subi $t3, $t3, 1
	beqz $t1, finishDecToHex
	bgtz $t1, hexCovLoop
	
	finishDecToHex:
	xor $t1, $t1, $t1
	addi $t1, $t1, 0
	beq $t9, 1, flagForLeadingZero
	b noFlagForLeadingZero
	
	flagForLeadingZero:
		addi $t6, $t6, 1 #increaser the buffer null char
	
	noFlagForLeadingZero: ## add 0  --> 0at beging of abcd
	sb $t1, hexBuffer($t6)
	xor $t6, $t6, $t6
	
	# print binary
	la   $a0, bin        # load program description to reg a0
      	li   $v0, 4           # service number 4 is to do a print operation
      	syscall
      	    	
      	
	li $v0, 4
	la $a0, binBuffer
	syscall
	
	# print decimal
      	la   $a0, dec        # load program description to reg a0
      	li   $v0, 4           # service number 4 is to do a print operation
      	syscall
      	
      	xor $a0, $a0, $a0
      	move $a0, $t8
	li $v0, 36
	syscall
      	
      	# print hexadecimal
      	la   $a0, hex        # load program description to reg a0
      	li   $v0, 4           # service number 4 is to do a print operation
      	syscall
      	
      		
	li $v0, 4
	la $a0, hexBuffer
	syscall	
	
	jr $ra

	
	# ===========================================
	# SEARCH PROCEDURE
	# ===========================================
	
	get_input_length:
	
	# load byte from buffer to register a
	lbu $a0, userInput($a1)
	
	
	addiu $a1, $a1, 1  #increasing the index  by one  i = i + 1 
	
	# size counter
	addiu $t2, $t2, 1
	beq $a0, '\n', finishLength
	blt $a0, '0', checkMenuLess
	bgt $a0, '9', checkMenuLess
	
	bne $a0, '\n', get_input_length# recuriusion +  1 Enter : ==

	finishLength:
	
	subiu $t2, $t2, 1 #1- char

	addiu $t3, $t3, 2 # 
	addiu $t5, $t5, 0
	# addiu $t6, $t6, 1 # the result integer #|||
	
	xor $a3, $a3, $a3
	
	move $t4  ,  $t2
	jr $ra
