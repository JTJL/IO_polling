Key_Respond:
	ori 	$t2,	$zero,	0xf0
	andi 	$t1, 	$t0,	0xff
	bne		$t1,	$t2,	Load_Data_Ingame			# 0xF0 Detection 
Read_Bk_Code_Ingame:
	lw	 	$t0, 	0($s0)						# Read Break Code
	andi 	$t1,	$t0, 	0x100
	beq  	$t1, 	$zero,  Read_Bk_Code_Ingame		# No Ps2_ready
	jr 		$ra

Load_Data_Ingame:
	add 	$t3, 	$t1,	$t1
	add 	$t3, 	$t3,	$t3 				# Shift Scan Code left 2 bits
	add 	$t3, 	$s3,	$t3					# Cal Addr with Scan Code as an offset 	
	lw		$t2,	0($t3)						# Load the ascii code from decode table
	# Detect if key in need 
	addi 	$t1, 	$t2,	-282 				# SPACE Judge
	bne 	$t1, 	$zero, 	N_SPACE_Ingame	
	ori		$t1,	$zero	0x3					# Get current rotation
	and		$t2,	$a0,	$t1
	bne 	$t2,	$t1,	N_MINUS_4
	addi	$a0,	$a0,	-4
N_MINUS_0x4:
	addi	$a0,	$a0,	1
N_SPACE_Ingame:
	addi	$t1,	$t2,	-65 				# Key 'A', move block left 
	bne 	$t1, 	$zero,	N_A
	andi	$t0,	$a1,	0x7f	
	beq		$t0,	$zero,	N_A
	addi	$a1,	$a1,	-1					# Addr X - 1
N_A:
	addi	$t1,	$t2,	-68 				# Key 'D', move block left 
	bne 	$t1, 	$zero,	N_D
	andi	$t0,	$a0,	0x1c				# Get current pattern
	

	beq		$t0,	$zero,	LINE				# Pattern  ####          	Pattern_No = 000_00
												
	addi	$t3,	$zero,	0x4 											
	beq 	$t0,	$t3,	ARROW				# Pattern   #				Pattern_No = 001_00
												           ###
	addi	$t3,	$zero,	0x8 											
	beq 	$t0,	$t3,  	SQUARE				# Pattern  ##				Pattern_No = 010_00
												           ##
    addi	$t3,	$zero,	0xc
    beq 	$t0,	$t3,  	RIGHTL				# Pattern  #				Pattern_No = 011_00
    											           ###
    addi	$t3,	$zero,	0x10
	beq 	$t0,	$t3,  	LEFTL				# Pattern    #				Pattern_No = 100_00
												  		   ###
LINE:	
   	andi	$t1,	$a0,	0x1 				# Get current rotation
   	beq 	$t1,	$zero,	Horizontal
   	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-14
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra
Horizontal:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-11
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

ARROW:
	andi	$t1,	$a0,	0x3					# Get current rotation
	la		$t2,	ARROW_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2
ARROW_Rotation:
	beq 	$zero,	$zero, 	ARROW_D			
	beq		$zero,	$zero,  ARROW_L
	beq		$zero,	$zero,  ARROW_U
	beq		$zero,	$zero,  ARROW_R

ARROW_D:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

ARROW_L:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

ARROW_U:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

ARROW_R:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

SQUARE:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

RIGHTL:
	la		$t2,	RIGHTL_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2

RIGHTL_Rotation: 							
	beq 	$zero,	$zero,	RL_R
	beq 	$zero,	$zero,	RL_D
	beq 	$zero,	$zero,	RL_L
	beq 	$zero,	$zero,	RL_U

RL_R:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

RL_D:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

RL_L:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

RL_U:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

LEFTL：
	la		$t2,	LEFTL_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2

LEFTL_Rotation: 							
	beq 	$zero,	$zero,	LL_L
	beq 	$zero,	$zero,	LL_U
	beq 	$zero,	$zero,	LL_R
	beq 	$zero,	$zero,	LL_D

LL_L:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

LL_U:
	andi	$t1,	$a1,	0x7f
	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

LL_R:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-12
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

LL_D:
	andi	$t1,	$a1,	0x7f
   	addi	$t1,	$t1,	-13
   	beq 	$t1,	$zero,	N_PLUS_1
   	addi	$a1,	$a1,	1
   	jr		$ra

N_PLUS_1:
	add 	$zero,	$zero,	$zero
	jr 		$ra
