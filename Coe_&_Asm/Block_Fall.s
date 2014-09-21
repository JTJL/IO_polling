Block_Fall:
	
	andi	$t0,	$a1,	0x3f00				# Get current Y addr
	andi	$t1,	$a1,	0x7f				# Get current X addr
	la		$s5,	Win_Line_U 					# Point reg
	beq		$t0,	$zero,	FIRST_LINE
Loop_line:
	addi	$t0,	$t0, 	-256				# Minus 0x100
	addi	$s5,	$s5,	0x40				# Next line
	bne		$t0,	$zero,	Loop_line
FIRST_LINE:
	beq		$t1,	$zero,	FIRST_POINT
Loop_point:
	addi	$t1,	$t1,	-1
	addi	$s5,	$s5,	0x4
	bne		$t1,	$zero,	Loop_line	
FIRST_POINT:									# Here we reach the left-top point of the block, stored in $s5

	andi	$t0,	$a0,	0x1c				# Get current pattern
	

	beq		$t0,	$zero,	Block_Fall_LINE		# Pattern  ####          	Pattern_No = 000_00
												
	addi	$t3,	$zero,	0x4 											
	beq 	$t0,	$t3,	Block_Fall_ARROW	# Pattern   #				Pattern_No = 001_00
												           ###
	addi	$t3,	$zero,	0x8 											
	beq 	$t0,	$t3,  	Block_Fall_SQUARE	# Pattern  ##				Pattern_No = 010_00
												           ##
    addi	$t3,	$zero,	0xc
    beq 	$t0,	$t3,  	Block_Fall_RIGHTL	# Pattern  #				Pattern_No = 011_00
    											           ###
    addi	$t3,	$zero,	0x10
	beq 	$t0,	$t3,  	Block_Fall_LEFTL	# Pattern    #				Pattern_No = 100_00
												  		   ###
Block_Fall_LINE:	
   	andi	$t1,	$a0,	0x1 				# Get current rotation
   	beq 	$t1,	$zero,	Block_Fall_Horizontal
   	lw 		$t1,	0xc0($s5) 	
   	bne 	$t1,	$zero,	N_FALL_Line_V	
   	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	jal		Draw_Block
   	bne		$v0,	$zero,	N_FALL_Line_V		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
   	j 		Block_Fall_RETURN
N_FALL_Line_V:
	ori		$v0,	$zero, 	1
	sw		$v0,	0($s5)
	sw		$v0,	0x40($s5)
	sw		$v0,	0x80($s5)
	sw		$v0,	0xc0($s5)
	j 		Block_Fall_RETURN

Block_Fall_Horizontal:
	lw		$t1,	0x40($s5)
	lw		$t2,	0x44($s5)
	or 		$t1,	$t1,	$t2
	lw		$t2,	0x48($s5)
	or 		$t1,	$t1,	$t2
	lw		$t2,	0x4c($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_Line_H
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	jal		Draw_Block
   	bne		$v0,	$zero,	N_FALL_Line_H		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
   	j 		Block_Fall_RETURN

N_FALL_Line_H:
	ori		$v0,	$zero, 1
	sw		$v0,	0x0($s5)
	sw		$v0,	0x04($s5)
	sw		$v0,	0x08($s5)
	sw		$v0,	0x0c($s5)
	j 		Block_Fall_RETURN

Block_Fall_ARROW:
	andi	$t1,	$a0,	0x3					# Get current rotation
	la		$t2,	Block_Fall_ARROW_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2
Block_Fall_ARROW_Rotation:
	beq 	$zero,	$zero, 	Block_Fall_ARROW_D			
	beq		$zero,	$zero,  Block_Fall_ARROW_L
	beq		$zero,	$zero,  Block_Fall_ARROW_U
	beq		$zero,	$zero,  Block_Fall_ARROW_R

Block_Fall_ARROW_D:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

Block_Fall_ARROW_L:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

Block_Fall_ARROW_U:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

Block_Fall_ARROW_R:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

Block_Fall_SQUARE:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

Block_Fall_RIGHTL:
	la		$t2,	Block_Fall_RIGHTL_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2

Block_Fall_RIGHTL_Rotation: 							
	beq 	$zero,	$zero,	Block_Fall_RL_R
	beq 	$zero,	$zero,	Block_Fall_RL_D
	beq 	$zero,	$zero,	Block_Fall_RL_L
	beq 	$zero,	$zero,	Block_Fall_RL_U

Block_Fall_RL_R:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

Block_Fall_RL_D:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

Block_Fall_RL_L:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

Block_Fall_RL_U:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

Block_Fall_LEFTL：
	la		$t2,	Block_Fall_LEFTL_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2

Block_Fall_LEFTL_Rotation: 							
	beq 	$zero,	$zero,	Block_Fall_LL_L
	beq 	$zero,	$zero,	Block_Fall_LL_U
	beq 	$zero,	$zero,	Block_Fall_LL_R
	beq 	$zero,	$zero,	Block_Fall_LL_D

Block_Fall_LL_L:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

Block_Fall_LL_U:
	andi	$t1,	$a1,	0x7f
	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

Block_Fall_LL_R:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

Block_Fall_LL_D:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra








Block_Fall_RETURN:
	jr		$ra