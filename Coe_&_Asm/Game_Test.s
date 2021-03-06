#############################################################
##	Function Name: 	TERIS_GAME
##
## 	Description	: 	The entrance of the game 
##
##	Status 	: 		Under Test
##
##############################################################
TERIS_GAME:
	addi 	$sp,	$sp,	-40
	sw 		$s2,	0x24($sp)
	sw 		$s1,	0x20($sp)
	sw 		$s3,	0x1c($sp)
	sw		$t4,	0x18($sp)	
	sw		$t3,	0x14($sp)	
	sw		$t2,	0x10($sp)
	sw		$t1,	0xc($sp)
	sw 		$t0,	0x8($sp)
	sw 		$s0,	0x4($sp)
	sw 		$ra,	0x0($sp)



 	la 		$s1,	Win_Line_U
 	add 	$s2,	$zero,	$zero
 	addi	$s3,	$zero, 	512
 Loop_Clr_Win:
 	sw 		$zero, 	0($s1)
 	addi	$s1,	$s1,	4
 	addi	$s2,	$s2,	1
 	bne 	$s2,	$s3, 	Loop_Clr_Win 	

	lui		$s1,	0x1							# Counter Init
	lui		$s3,	0xc
	addi	$s3,	$s3,	0xe1f

	la		$t0,	Block_Pattern
	lw		$a0,	0($t0)
	addi	$a0,	$zero, 	0x0 					# Starting from 	#
	sw 		$a0,	0($t0)											    ###
	la 		$t0,	Block_Addr 						# Relative address
	lw 		$a1,	0($t0)
	addi	$a1,	$zero,	0x08
	sw 		$a1,	0($t0)
	and 	$zero,	$zero,	$zero
	add 	$a1,	$a1,	$s3
	jal		Draw_Block
	sub 	$a1,	$a1,	$s3

GAME_ON:
	addi 	$s1,	$s1,	-1 						# Counter - 1
	#lw 	$t0, 	0($s0)
	#andi 	$t1,	$t0, 	0x100
	#beq 	$t1,	$zero,	N_key					# If no key pressed, then branch
	jal		Key_Respond								# Ps2_ready, one key pressed
N_key:
	bne 	$zero,	$s1,	N_Fall
	jal 	Block_Fall
	beq		$v0,	$zero,	N_NEXT_BLOCK
	ori		$t1,	$zero,	0x1f							
	and		$t2,	$a0,	$t1							# Get current pattern and rotation
	ori		$t1,	$zero,	0x13
	bne 	$t2,	$t1,	INGAME_NONE_ZERO_STATUS
	and 	$a0,	$zero,	$zero	
INGAME_NONE_ZERO_STATUS:
	addi 	$a0,	$a0,	1						
	ori	 	$a1,	$zero,	0x08
	add 	$a1,	$a1,	$s3
	jal		Draw_Block
	sub 	$a1,	$a1,	$s3
	jal 	Block_Fall
	bne 	$v0,	$zero,	GAME_OVER
N_NEXT_BLOCK:
	la		$t0,	Block_Pattern
	sw		$a0,	0($t0)

	la 		$t0,	Block_Addr 						# Relative address
	sw 		$a1,	0($t0)
	lui		$s1,	0x1
N_Fall:
 	bne	    $zero,	$zero,	GAME_OVER
 	add 	$zero,	$zero,	$zero
	j  		GAME_ON

GAME_OVER:
	
	lw 		$ra,	0x0($sp)
	lw 		$s0,	0x4($sp)
	lw 		$t0,	0x8($sp)
	lw		$t1,	0xc($sp)
	lw		$t2,	0x10($sp)	
	lw		$t3,	0x14($sp)	
	lw		$t4,	0x18($sp)
	lw 		$s3,	0x1c($sp)
	lw 		$s1,	0x20($sp)
	lw 		$s2,	0x24($sp)
	addi 	$sp,	$sp,	40
	jr 		$ra


#####################################################
##	Function Name:	Key_Respond
##
##	Parameter: 	$a0 [ 8: 8] [ 4: 2] [ 1: 0] for Clr, Patterns(5) and Rotation(4)
##					$a0[8] 1 for clr, 0 for display
##				$a1 [13: 8] [ 7: 0] for address Y(32) and X(15) 
##	Description:Coping with keyboard control during the game
##	Return:		No return
#####################################################
Key_Respond:

	addi	$sp,	$sp,	-32
	sw		$t3,	0x1c($sp)
	sw		$t2,	0x18($sp)
	sw		$t1,	0x14($sp)
	sw		$t0,	0x10($sp)		
	sw		$s3,	0x0c($sp)
	sw		$s2,	0x08($sp)
	sw 		$s0,	0x04($sp)
	sw	 	$ra,	0x00($sp)	

	addi 	$s0, 	$zero, 	-12288				# Ps2_addr		Radix: DEC_FORMAT
	lw 	 	$t0, 	0($s0)
	andi 	$t1,	$t0, 	0x100
	beq 	$t1,	$zero,	KEY_RESPOND_RETURN

	la 		$s3,	Ascii_code	
	lui		$s2,	0xc 								# Window addr
	addi	$s2,	$s2,	0xe1f

	ori 	$t2,	$zero,	0xf0
	andi 	$t1, 	$t0,	0xff
	bne		$t1,	$t2,	KEY_RESPOND_Load_Data		# 0xF0 Detection 
KEY_RESPOND_Read_Bk_Code:
	lw	 	$t0, 	0($s0)								# Read Break Code
	andi 	$t1,	$t0, 	0x100
	beq  	$t1, 	$zero,  KEY_RESPOND_Read_Bk_Code	# No Ps2_ready
	j 		KEY_RESPOND_RETURN 							# Return after f0

KEY_RESPOND_Load_Data:
	add 	$t3, 	$t1,	$t1
	add 	$t3, 	$t3,	$t3 						# Shift Scan Code left 2 bits
	add 	$t3, 	$s3,	$t3							# Cal Addr with Scan Code as an offset 	
	lw		$t2,	0($t3)								# Load the ascii code from decode table
	# Detect if key in need 
	addi 	$t1, 	$t2,	-282 						# SPACE Judge
	bne 	$t1, 	$zero, 	KEY_RESPOND_N_SPACE	
	ori		$t1,	$zero,	0x3							
	and		$t2,	$a0,	$t1							# Get current rotation
	ori	 	$a0,	$a0,	0x100
	add 	$a1,	$a1,	$s2 						# Add 000c_0000 plus window offset
	jal	 	Draw_Block 		
	sub		$a1,	$a1,	$s2							# Clr the old one 
	andi	$a0,	$a0,	0xff
	bne 	$t2,	$t1,	KEY_RESPOND_N_MINUS_Four
	addi	$a0,	$a0,	-4
KEY_RESPOND_N_MINUS_Four:
	add 	$zero,	$zero, 	$zero
	addi	$a0,	$a0,	1
	add  	$zero, 	$zero,	$zero
	add 	$a1,	$a1,	$s2 						# Add 000c_0000 plus window offset
	jal	 	Draw_Block 		
	sub		$a1,	$a1,	$s2						
	j 		KEY_RESPOND_RETURN

KEY_RESPOND_N_SPACE:
	addi	$t1,	$t2,	-65 						# Key 'A', move block left 
	bne 	$t1, 	$zero,	KEY_RESPOND_N_A
	andi	$t0,	$a1,	0x7f	
	beq		$t0,	$zero,	KEY_RESPOND_RETURN
	ori	 	$a0,	$a0,	0x100
	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
	addi	$a1,	$a1,	-1							# Addr X - 1
	jal	 	Draw_Block
	sub		$a1,	$a1,	$s2
	j 		KEY_RESPOND_RETURN

KEY_RESPOND_N_A:
	addi	$t1,	$t2,	-68 						# Key 'D', move block left 
	bne 	$t1, 	$zero,	KEY_RESPOND_RETURN
	andi	$t0,	$a0,	0x1c						# Get current pattern
	

	beq		$t0,	$zero,	KEY_RESPOND_LINE			# Pattern  ####          	Pattern_No = 000_00
														
	addi	$t3,	$zero,	0x4 													
	beq 	$t0,	$t3,	KEY_RESPOND_ARROW			# Pattern   #				Pattern_No = 001_00
														           ###
	addi	$t3,	$zero,	0x8 													
	beq 	$t0,	$t3,  	KEY_RESPOND_SQUARE			# Pattern  ##				Pattern_No = 010_00
														           ##
    addi	$t3,	$zero,	0xc
    beq 	$t0,	$t3,  	KEY_RESPOND_RIGHTL			# Pattern  #				Pattern_No = 011_00
    													           ###
    addi	$t3,	$zero,	0x10
	beq 	$t0,	$t3,  	KEY_RESPOND_LEFTL			# Pattern    #				Pattern_No = 100_00
														  		   ###
KEY_RESPOND_LINE:	
   	andi	$t1,	$a0,	0x1 						# Get current rotation
   	beq 	$t1,	$zero,	KEY_RESPOND_Horizontal
   	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-14
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_Horizontal:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-11
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_ARROW:
	andi	$t1,	$a0,	0x3							# Get current rotation
	add 	$t1,	$t1,	$t1
	add 	$t1,	$t1,	$t1
	la		$t2,	KEY_RESPOND_ARROW_Rotation
	add 	$t2,	$t2,	$t1							# Add $t1 as offset
	jr 		$t2
KEY_RESPOND_ARROW_Rotation:
	beq 	$zero,	$zero, 	KEY_RESPOND_ARROW_D			
	beq		$zero,	$zero,  KEY_RESPOND_ARROW_L
	beq		$zero,	$zero,  KEY_RESPOND_ARROW_U
	beq		$zero,	$zero,  KEY_RESPOND_ARROW_R

KEY_RESPOND_ARROW_D:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_ARROW_L:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100						# Clr
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_ARROW_U:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_ARROW_R:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_SQUARE:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_RIGHTL:
	la		$t2,	KEY_RESPOND_RIGHTL_Rotation
	andi	$t1,	$a0,	0x3							# Get current rotation
	add 	$t1,	$t1,	$t1
	add 	$t1,	$t1,	$t1
	add 	$t2,	$t2,	$t1							# Add $t1 as offset
	jr 		$t2

KEY_RESPOND_RIGHTL_Rotation: 							
	beq 	$zero,	$zero,	KEY_RESPOND_RL_R
	beq 	$zero,	$zero,	KEY_RESPOND_RL_D
	beq 	$zero,	$zero,	KEY_RESPOND_RL_L
	beq 	$zero,	$zero,	KEY_RESPOND_RL_U

KEY_RESPOND_RL_R:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_RL_D:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_RL_L:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_RL_U:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_LEFTL:
	la		$t2,	KEY_RESPOND_LEFTL_Rotation
	andi	$t1,	$a0,	0x3							# Get current rotation
	add 	$t1,	$t1,	$t1
	add 	$t1,	$t1,	$t1
	add 	$t2,	$t2,	$t1							# Add $t1 as offset
	jr 		$t2

KEY_RESPOND_LEFTL_Rotation: 							
	beq 	$zero,	$zero,	KEY_RESPOND_LL_L
	beq 	$zero,	$zero,	KEY_RESPOND_LL_U
	beq 	$zero,	$zero,	KEY_RESPOND_LL_R
	beq 	$zero,	$zero,	KEY_RESPOND_LL_D

KEY_RESPOND_LL_L:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_LL_U:
	andi	$t1,	$a1,	0x7f
	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_LL_R:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_LL_D:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	KEY_RESPOND_RETURN
   	ori	 	$a0,	$a0,	0x100
   	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
   	addi	$a1,	$a1,	1
   	jal	 	Draw_Block
   	sub		$a1,	$a1,	$s2
   	j 		KEY_RESPOND_RETURN

KEY_RESPOND_RETURN:
	
	add 	$zero,	$zero,	$zero

	lw	 	$ra,	0x00($sp)
	lw		$s0,	0x04($sp)
	lw		$s2,	0x08($sp)
	lw	 	$s3,	0x0c($sp)
	lw		$t0,	0x10($sp)
	lw		$t1,	0x14($sp)
	lw		$t2,	0x18($sp)
	lw		$t3,	0x1c($sp)	

	addi	$sp,	$sp,	32

	jr 		$ra


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
