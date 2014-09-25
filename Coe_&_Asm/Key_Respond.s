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
	ori		$t1,	$zero,	0x3							# Get current rotation
	and		$t2,	$a0,	$t1
	ori	 	$a0,	$a0,	0x100
	add 	$a1,	$a1,	$s2
	jal	 	Draw_Block
	andi	$a0,	$a0,	0xff
	bne 	$t2,	$t1,	KEY_RESPOND_N_MINUS_0x4
	addi	$a0,	$a0,	-4
KEY_RESPOND_N_MINUS_0x4:
	addi	$a0,	$a0,	1
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
   	ori	 	$a0,	$a0,	0x100
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