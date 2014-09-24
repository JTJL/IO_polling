################################################
## 	Function Name: Block_Fall
##
##	Parameters: $a0 [ 8: 8] [ 4: 2] [ 1: 0] for Clr, Patterns(5) and Rotation(4)
##					$a0[8] 1 for clr, 0 for display
##				$a1 [13: 8] [ 7: 0] for address Y(32) and X(15) 
##
## 	Return:		$v0 to show if block is at the bottom
##
################################################

Block_Fall:
	addi	$sp,	$sp,	-32

	sw		$t0,	0x1c($sp)
	sw		$t1,	0x18($sp)
	sw		$t2,	0x14($sp)
	sw		$t3,	0x10($sp)
	sw		$t4,	0x0c($sp)
	sw		$s2,	0x08($sp)
	sw		$s5,	0x04($sp)
	sw		$ra,	0x00($sp)

	andi	$t0,	$a1,	0x3f00				# Get current Y addr (relatively)
	andi	$t4,	$a1,	0x7f				# Get current X addr (relatively)
	la		$s5,	Win_Line_U 					# Point reg
	beq		$t0,	$zero,	FIRST_LINE
Loop_line:
	addi	$t0,	$t0, 	-256				# Minus 0x100
	addi	$s5,	$s5,	0x40				# Next line
	bne		$t0,	$zero,	Loop_line
FIRST_LINE:
	beq		$t4,	$zero,	FIRST_POINT
Loop_point:
	addi	$t4,	$t4,	-1
	addi	$s5,	$s5,	0x4
	bne		$t4,	$zero,	Loop_point	
FIRST_POINT:									# Here we reach the left-top point of the block, stored in $s5
	
	lui		$s2,	0xc
	addi	$s2,	$s2,	0xe1f
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
   	beq 	$t1,	$zero,	Block_Fall_Line_Horizontal
   	lw 		$t1,	0x100($s5) 	
   	bne 	$t1,	$zero,	N_FALL_Line_V	
   	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							 
	sub 	$a1,	$a1,	$s2
	addi	$a1,	$a1,	-256
   	bne		$v0,	$zero,	N_FALL_Line_V		# Draw_Failed
   	ori		$a0,	$a0,	0x100
	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_Line_V:
	ori		$v0,	$zero, 	1
	sw		$v0,	0x00($s5)
	sw		$v0,	0x40($s5)
	sw		$v0,	0x80($s5)
	sw		$v0,	0xc0($s5)
	add 	$zero,	$zero,	$zero	
	j 		Block_Fall_RETURN

Block_Fall_Line_Horizontal:
	lw		$t1,	0x40($s5)
	lw		$t2,	0x44($s5)
	or 		$t1,	$t1,	$t2
	lw		$t2,	0x48($s5)
	or 		$t1,	$t1,	$t2
	lw		$t2,	0x4c($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_Line_H
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block			
	sub  	$a1,	$a1,	$s2
	addi	$a1,	$a1,	-256				
   	bne		$v0,	$zero,	N_FALL_Line_H		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_Line_H:
	ori		$v0,	$zero, 1
	sw		$v0,	0x00($s5)
	sw		$v0,	0x04($s5)
	sw		$v0,	0x08($s5)
	sw		$v0,	0x0c($s5)
	add 	$zero,	$zero,	$zero	
	j 		Block_Fall_RETURN

Block_Fall_ARROW:
	andi	$t1,	$a0,	0x3					# Get current rotation
	add 	$t1,	$t1,	$t1
	add 	$t1,	$t1,	$t1	
	la		$t2,	Block_Fall_ARROW_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2
Block_Fall_ARROW_Rotation:
	beq 	$zero,	$zero, 	Block_Fall_ARROW_D			
	beq		$zero,	$zero,  Block_Fall_ARROW_L
	beq		$zero,	$zero,  Block_Fall_ARROW_U
	beq		$zero,	$zero,  Block_Fall_ARROW_R

Block_Fall_ARROW_D:
	lw		$t1,	0x40($s5)
	lw		$t2,	0x84($s5)
	or 		$t1,	$t1,	$t2
	lw		$t2,	0x48($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_ARROW_D
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							
	sub  	$a1,	$a1,	$s2	
	addi	$a1,	$a1,	-256
   	bne		$v0,	$zero,	N_FALL_ARROW_D		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block							# Clr the former one 
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_ARROW_D:
	ori		$v0,	$zero,	1
	sw		$v0,	0x00($s5)
	sw		$v0,	0x04($s5)
	sw		$v0,	0x08($s5)
	sw		$v0,	0x44($s5)
	add 	$zero,	$zero,	$zero	
	j 		Block_Fall_RETURN

Block_Fall_ARROW_L:
	lw		$t1,	0x80($s5)
	lw		$t2,	0xc4($s5)
	or 		$t1,	$t1,	$t2
	add 	$zero,	$zero,	$zero
	addi	$t2,	$zero,  -512
	sw 		$t1,	0($t2)
	add 	$zero,	$zero,	$zero
	bne 	$t1,	$zero,	N_FALL_ARROW_L
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block		
	sub  	$a1,	$a1,	$s2	
   	addi	$a1,	$a1,	-256					 
   	bne		$v0,	$zero,	N_FALL_ARROW_L		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_ARROW_L:
	ori		$v0,	$zero,	1
	sw		$v0,	0x04($s5)
	sw		$v0,	0x40($s5)
	sw		$v0,	0x44($s5)
	sw		$v0,	0x84($s5)
	add 	$zero,	$zero,	$zero	
	j 		Block_Fall_RETURN

Block_Fall_ARROW_U:
	lw		$t1,	0x80($s5)
	lw		$t2,	0x84($s5)
	or 		$t1,	$t1,	$t2
	lw		$t2,	0x88($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_ARROW_U
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							
	sub  	$a1,	$a1,	$s2	
	addi	$a1,	$a1,	-256
   	bne		$v0,	$zero,	N_FALL_ARROW_U		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_ARROW_U:
	ori		$v0,	$zero,	1
	sw		$v0,	0x04($s5)
	sw		$v0,	0x40($s5)
	sw		$v0,	0x44($s5)
	sw		$v0,	0x48($s5)
	add 	$zero,	$zero,	$zero	
	j 		Block_Fall_RETURN

Block_Fall_ARROW_R:
	lw		$t1,	0xc0($s5)
	lw		$t2,	0x84($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_ARROW_R
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block			
	sub  	$a1,	$a1,	$s2	
   	addi	$a1,	$a1,	-256				
   	bne		$v0,	$zero,	N_FALL_ARROW_R		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_ARROW_R:
	ori 	$v0,	$zero,	1
	sw 		$v0,	0x00($s5)
	sw		$v0,	0x40($s5)
	sw		$v0,	0x44($s5)
	sw		$v0,	0x80($s5)
	add 	$zero,	$zero,	$zero	
	j 		Block_Fall_RETURN	
	


Block_Fall_SQUARE:
	lw		$t1,	0x80($s5)
	lw		$t2,	0x84($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_SQUARE
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block			
	sub  	$a1,	$a1,	$s2					
   	addi	$a1,	$a1,	-256   	
   	bne		$v0,	$zero,	N_FALL_SQUARE		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_SQUARE:
	ori 	$v0,	$zero,	1
	sw 		$v0,	0x00($s5)
	sw		$v0,	0x04($s5)
	sw		$v0,	0x40($s5)
	sw		$v0,	0x44($s5)
	add 	$zero,	$zero,	$zero	
	j 		Block_Fall_RETURN	

Block_Fall_RIGHTL:
	andi	$t1,	$a0,	0x3 				# Get current rotation
	add 	$t1,	$t1,	$t1
	add 	$t1,	$t1,	$t1	
	la		$t2,	Block_Fall_RIGHTL_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2

Block_Fall_RIGHTL_Rotation: 							
	beq 	$zero,	$zero,	Block_Fall_RL_R
	beq 	$zero,	$zero,	Block_Fall_RL_D
	beq 	$zero,	$zero,	Block_Fall_RL_L
	beq 	$zero,	$zero,	Block_Fall_RL_U

Block_Fall_RL_R:
	lw		$t1,	0x80($s5)
	lw		$t2,	0x84($s5)
	or 		$t1,	$t1,	$t2
	lw		$t2,	0x88($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_RL_R
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# See if inside the window 
	sub  	$a1,	$a1,	$s2	
	addi	$a1,	$a1,	-256
   	bne		$v0,	$zero,	N_FALL_RL_R			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 					 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_RL_R:
	ori		$v0,	$zero,	1
	sw 		$v0,	0x00($s5)
	sw		$v0,	0x40($s5)
	sw		$v0,	0x44($s5)
	sw		$v0,	0x48($s5)
	add 	$zero,	$zero,	$zero		
	j 		Block_Fall_RETURN

Block_Fall_RL_D:
	lw		$t1,	0xc0($s5)
	lw		$t2,	0x44($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_RL_D
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# See if inside the window 
	sub  	$a1,	$a1,	$s2	
	addi	$a1,	$a1,	-256
   	bne		$v0,	$zero,	N_FALL_RL_D			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_RL_D:
	ori		$v0,	$zero,	1
	sw 		$v0,	0x00($s5)
	sw		$v0,	0x04($s5)
	sw		$v0,	0x40($s5)
	sw		$v0,	0x80($s5)
	add 	$zero,	$zero,	$zero		
	j 		Block_Fall_RETURN

Block_Fall_RL_L:
	lw		$t1,	0x40($s5)
	lw		$t2,	0x44($s5)
	or 		$t1,	$t1,	$t2
	lw		$t2,	0x88($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_RL_L
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# See if inside the window 
	sub  	$a1,	$a1,	$s2	
   	addi	$a1,	$a1,	-256
   	bne		$v0,	$zero,	N_FALL_RL_L			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_RL_L:
	ori		$v0,	$zero,	1
	sw 		$v0,	0x00($s5)
	sw		$v0,	0x04($s5)
	sw		$v0,	0x08($s5)
	sw		$v0,	0x48($s5)
	add 	$zero,	$zero,	$zero		
	j 		Block_Fall_RETURN


Block_Fall_RL_U:
	lw		$t1,	0xc0($s5)
	lw		$t2,	0xc4($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_RL_U
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# See if inside the window 
	sub  	$a1,	$a1,	$s2	 
   	addi	$a1,	$a1,	-256
   	bne		$v0,	$zero,	N_FALL_RL_U			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_RL_U:
	ori		$v0,	$zero,	1
	sw 		$v0,	0x04($s5)
	sw		$v0,	0x44($s5)
	sw		$v0,	0x80($s5)
	sw		$v0,	0x84($s5)	
	add 	$zero,	$zero,	$zero
	j 		Block_Fall_RETURN

Block_Fall_LEFTL:
	andi	$t1,	$a0,	0x3 				# Get current rotation
	add 	$t1,	$t1,	$t1
	add 	$t1,	$t1,	$t1	
	la		$t2,	Block_Fall_LEFTL_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2

Block_Fall_LEFTL_Rotation: 							
	beq 	$zero,	$zero,	Block_Fall_LL_L
	beq 	$zero,	$zero,	Block_Fall_LL_U
	beq 	$zero,	$zero,	Block_Fall_LL_R
	beq 	$zero,	$zero,	Block_Fall_LL_D

Block_Fall_LL_L:
	lw		$t1,	0x80($s5)
	lw		$t2,	0x84($s5)
	or 		$t1,	$t1,	$t2
	lw		$t2,	0x8c($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_LL_L
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	sub  	$a1,	$a1,	$s2	
   	addi	$a1,	$a1,	-256
   	bne		$v0,	$zero,	N_FALL_LL_L			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_LL_L:
	ori		$v0,	$zero,	1
	sw 		$v0,	0x08($s5)
	sw		$v0,	0x40($s5)
	sw		$v0,	0x44($s5)
	sw		$v0,	0x48($s5)
	add 	$zero,	$zero,	$zero		
	j 		Block_Fall_RETURN

Block_Fall_LL_U:
	lw		$t1,	0xc0($s5)
	lw		$t2,	0xc4($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_LL_U
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	sub  	$a1,	$a1,	$s2	
	addi	$a1,	$a1,	-256
   	bne		$v0,	$zero,	N_FALL_LL_U			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_LL_U:
	ori		$v0,	$zero,	1
	sw 		$v0,	0x00($s5)
	sw		$v0,	0x40($s5)
	sw		$v0,	0x80($s5)
	sw		$v0,	0x84($s5)	
	add 	$zero,	$zero,	$zero	
	j 		Block_Fall_RETURN

Block_Fall_LL_R:
	lw		$t1,	0x80($s5)
	lw		$t2,	0x44($s5)
	or 		$t1,	$t1,	$t2
	lw		$t2,	0x48($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_LL_R
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	sub 	$a1,	$a1,	$s2	
   	addi	$a1,	$a1,	-256
   	bne		$v0,	$zero,	N_FALL_LL_R			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_LL_R:
	ori		$v0,	$zero,	1
	sw 		$v0,	0x00($s5)
	sw		$v0,	0x04($s5)
	sw		$v0,	0x08($s5)
	sw		$v0,	0x40($s5)
	add 	$zero,	$zero,	$zero		
	j 		Block_Fall_RETURN

Block_Fall_LL_D:
	lw		$t1,	0x40($s5)
	lw		$t2,	0xc4($s5)
	or 		$t1,	$t1,	$t2
	bne 	$t1,	$zero,	N_FALL_LL_D
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	sub  	$a1,	$a1,	$s2	
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
   	bne		$v0,	$zero,	N_FALL_LL_D			# Draw_Failed
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							# Clr the former one 
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	0x100
	jal 	Draw_Block
	sub 	$a1,	$a1,	$s2
   	j 		Block_Fall_RETURN

N_FALL_LL_D:
	ori		$v0,	$zero,	1
	sw 		$v0,	0x00($s5)
	sw		$v0,	0x04($s5)
	sw		$v0,	0x44($s5)
	sw		$v0,	0x84($s5)	
	add 	$zero,	$zero,	$zero
	j 		Block_Fall_RETURN

Block_Fall_RETURN:

	lw		$ra,	0x00($sp)
	lw		$s5,	0x04($sp)
	lw		$s2,	0x08($sp)
	lw		$t4,	0x0c($sp)
	lw		$t3,	0x10($sp)
	lw		$t2,	0x14($sp)
	lw		$t1,	0x18($sp)
	lw		$t0,	0x1c($sp)
	addi	$sp,	$sp,	32

	jr		$ra