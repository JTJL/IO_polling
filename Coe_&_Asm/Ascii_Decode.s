#############################################################################
##
##	Numbase is assumed to be Hex except specially declared
##		
##	Updated Date 	: Sept 16th
##
##	Author 			: S.k.a.r.
##	
##	Last revision	: Draw_Win added and Block display Tested
##	
#############################################################################

.text                           # code segment
	la 		$s3,	Ascii_code					# Ascii_Data_BaseAddr, Actually implemented by lui and ori
	addi 	$s0, 	$zero, 	-12288				# Ps2_addr		Radix: DEC_FORMAT
	addi 	$s1, 	$zero, 	-512				# Sev_seg_addr	Radix: DEC_FORMAT
	lui		$s2, 	0xc  						# VRam_addr
	ori 	$s2,	$s2, 	0x101
	ori 	$sp,	$zero,	0x4000				# Stack from 0x0000_4000 to 0x0000_0000
	ori  	$t0,	$zero, 	0x27f				# 'A' ascii 
	ori  	$t1,	$zero, 	0x27f				# 'B' ascii 

	sw 		$t0,	-1($s2)						# Write 'A' and 'B'
	add 	$zero,	$zero, 	$zero
	sw 		$t1,	0($s2)
	add 	$zero,	$zero, 	$zero
	
Polling:
	lw 	 	$t0, 	0($s0)
	andi 	$t1,	$t0, 	0x100
	beq  	$t1, 	$zero,  Polling				# Ps2_ready
	jal 	Scan2Ascii
	sw 	 	$t0, 	0($s1)						# Write Seven-Seg
	#addi 	$t0,	$zero, 	1
	#beq 	$v0,	$t0, 	TERIS_GAME			# Enter the game
	j 		Polling

Scan2Ascii:

	sw 		$ra, 	0($sp)						## You gotta store something, say ra
	ori 	$t2,	$zero,	0xf0
	andi 	$t1, 	$t0,	0xff
	bne		$t1,	$t2,	Load_Data			# 0xF0 Detection 
Read_Bk_Code:
	lw	 	$t0, 	0($s0)						# Read Break Code
	andi 	$t1,	$t0, 	0x100
	beq  	$t1, 	$zero,  Read_Bk_Code		# Ps2_ready
	sw		$t0, 	0($s1)						# Write Seven-Seg
	add 	$zero,	$zero, 	$zero
	lw 		$ra, 	0($sp)						# load back $ra
	jr 		$ra

Load_Data:
	add 	$t3, 	$t1,	$t1
	add 	$t3, 	$t3,	$t3 				# Shift Scan Code left 2 bits
	add 	$a0, 	$s3,	$t3					# Cal Addr with Scan Code as an offset 	
	lw		$t2,	0($a0)
	andi 	$t1, 	$t2,	0x100				# Op_key has eighth bit high
	beq  	$t1, 	$zero,	Print_Ascii			# Not an Op_key

	addi 	$t1, 	$t2,	-282 				# SPACE Judge
	bne 	$t1, 	$zero, 	N_SPACE
 	add 	$t2,	$zero,	$zero
 	j  		Print_Ascii
N_SPACE:
	addi 	$t1, 	$t2, 	-283				# ENTER Judge 
	bne		$t1, 	$zero,  N_ENTER  	
	addi 	$t6, 	$zero,	-128 				# Set ffff_ff80
	#andi 	$t5, 	$s2,	0x7f
	and 	$s2, 	$s2,	$t6					# Enter
	ori		$s2,	$s2,	0x4f 				# Set X at 79 (DEC_FORMAT)
	#addi 	$s2, 	$s2,	0x100 				# Y + 1 	
	addi 	$t2, 	$zero,	0x42d				# Write 2d RED'-' to the beginning of the line
	j Print_Ascii								# We do not enter the next line, do it with "writing '-'"

N_ENTER:
	addi 	$t1, 	$t2, 	-285 				# BACKSPACE Judge
	bne		$t1, 	$zero,  N_BKSP 
	sw 		$zero,	0($s2)						# store blank
	#beq 	$s2, 	$zero,	
	addi 	$s2,	$s2,	-1 					# Addr X - 1 
											
N_BKSP:	
	lw 		$ra, 	0($sp)						# load back $ra
	add 	$zero,	$zero, 	$zero
	jr 		$ra

Print_Ascii:
	addi 	$s2,	$s2, 	1
	addi 	$t4, 	$zero, 	0x50 				# Judge if X reach 80(DEC_FORMAT) 
	addi 	$t6,	$zero,	0x7f				# Get addr x 
	and 	$t5, 	$s2,	$t6
	bne		$t4,	$t5,	Write_Screen 		# No need for Y + 1 
	addi 	$t6, 	$zero,	-128				# Set ffff_ff80, 127 (DEC_FORMAT)
	and 	$s2, 	$s2,	$t6					# keep the Vram Y addr, Clr X
	addi 	$s2,	$s2, 	0x100  				# Addr Y + 1 
	lui		$t4,	0xc
	ori 	$t4,	$t4,	0x3c00
	bne		$s2,	$t4,	Write_Screen 		# No need for Clr_S
	add 	$zero,	$zero, 	$zero	
	jal 	Clr_Screen

	############################################ 	This is only for Test
	##	and 	$a0,	$zero,	$zero
	##	lui		$a1,	0xc
	##	ori 	$a1,	$a1,	0xf20
	##	jal 	Draw_Block
	##	add 	$zero,	$zero,	$zero
	##	addi 	$a0,	$a0,	5
	##	addi 	$a1,	$a1,	0x302
	##	jal 	Draw_Block
	##	addi 	$a0,	$a0,	5
	##	addi 	$a1,	$a1,	0x302
	##	jal 	Draw_Block
	##	addi 	$a0,	$a0,	5
	##	addi 	$a1,	$a1,	0x302
	##	jal 	Draw_Block
	##	addi 	$a0,	$a0,	1
	##	addi 	$a1,	$a1,	0x302
	##	jal 	Draw_Block
	##	addi 	$a0,	$a0,	0x100
	##	jal 	Draw_Block
	#######################################################################

	add 	$zero,	$zero, 	$zero	
	jal 	TERIS_GAME
Write_Screen:
	sw 		$t2, 	0($s2)						# Write Screen
	add 	$zero,	$zero, 	$zero
	lw 		$ra, 	0($sp)						# load back $ra
	jr 		$ra


##############
## 	Function: 	Clear Screen
##
## 	Parameter: 	None
##
## 	Return	: 	None
##############
Clr_Screen:			
	addi 	$sp,	$sp, 	-28						# DEC_FORMAT
	sw 		$ra,	0x18($sp)
	sw		$t6,	0x14($sp)
	sw 		$t5,	0x10($sp)
	sw		$t4,	0xc($sp)
	sw		$t3,	0x8($sp)
	sw		$t2,	0x4($sp)
	sw		$t0,	0x0($sp)

	ori		$t0,	$zero, 	0x12c0					# Condition: 4800 DEC_FORMAT
	and 	$t2, 	$zero,	$zero 					# Counter 
	lui 	$t3,	0xc
	
Loop_Clr_S:
	addi 	$t3,	$t3,	1						# Addr X + 1
	ori 	$t4, 	$zero, 	0x50 					# Judge if X reach 80(DEC_FORMAT) 
	ori 	$t6,	$zero,	0x7f					# Get addr x 
	and 	$t5, 	$t3,	$t6
	bne		$t4,	$t5, 	N_CLR_Y_Inc
	addi 	$t6, 	$zero,	-128					# Set ffff_ff80, 127 (DEC_FORMAT)
	and 	$t3, 	$t3,	$t6						# keep the Vram Y addr, Clr X
	addi 	$t3,	$t3, 	0x100  					# Addr Y + 1 
N_CLR_Y_Inc:
	sw 		$zero,	0($t3)							# Clr this point
	addi 	$t2,	$t2,	1 						# Counter = Counter + 1 
	bne 	$t2, 	$t0,	Loop_Clr_S				# Judgment if $t2(Counter) equals $t0(Limit)


	lui 	$s2,	0xc

	jal 	Draw_Win


	lw		$t0,	0x0($sp)
	lw		$t2,	0x4($sp)
	lw		$t3,	0x8($sp)
	lw		$t4,	0xc($sp)
	lw		$t5,	0x10($sp)
	lw		$t6,	0x14($sp)
	lw 		$ra,	0x18($sp)
	addi 	$sp,	$sp, 	28
	add 	$zero, 	$zero,	$zero
	jr		$ra

Draw_Win:  											# Window limit X in [1F:2D], Y in [0E:2D]
	addi 	$sp,	$sp,	-16
	sw 		$ra,	0x10($sp)
	sw 		$t3,	0xc($sp)
	sw 		$t2,	0x8($sp)
	sw 		$t1,	0x4($sp)
	sw 		$t0,	0x0($sp)

	lui		$t0,	0xc
	lui		$t1,	0xc
	lui		$t3,	0xc
	ori		$t0,	$t0,	0x0d1e					# UpRow Addr
	ori		$t1,	$t1,	0x2e1e					# DownRow Addr
	ori		$t2,	$zero,	0x12d					# Char '-'
	ori		$t3,	$t3,	0x0d2f					# Row Limit
Loop_Draw_Row:
	sw		$t2,	0($t0)
	sw		$t2,	0($t1)

	addi	$t0,	$t0,	1
	addi	$t1,	$t1,	1
	bne 	$t0,	$t3,	Loop_Draw_Row
	
	lui		$t0,	0xc
	lui		$t1,	0xc
	lui 	$t3,	0xc
	ori		$t0,	$t0,	0x0e1e					# RightColAddr
	ori		$t1,	$t1,	0x0e2e					# LeftCol Addr 
	ori		$t2,	$zero,	0x17c					# Char '|'	
	ori		$t3,	$t3, 	0x2e1e					# Col_Limit
Loop_Draw_Col:
	sw		$t2,	0($t0)
	sw		$t2,	0($t1)
	addi	$t0,	$t0,	0x100
	addi	$t1,	$t1,	0x100
	bne 	$t0,	$t3, 	Loop_Draw_Col

	lw 		$t0,	0x0($sp)
	lw 		$t1,	0x4($sp)
	lw 		$t2,	0x8($sp)
	lw 		$t3,	0xc($sp)
	lw 		$ra,	0x10($sp)
	addi	$sp,	$sp,	16
	jr 		$ra




#########################################
##
##	Function: Draw_Block
##	
##	Parameters: $a0 [ 8: 8] [ 4: 2] [ 1: 0] for Clr, Patterns(5) and Rotation(4)
##					$a0[8] 1 for clr, 0 for display
##				$a1 [13: 8] [ 7: 0] for address Y(60) and X(80) 
##				
##  Return 	:	$v0 Zero for Draw-Succeed otherwise Draw-Failure
##
#########################################


Draw_Block:
	addi 	$sp, 	$sp,	-123
	sw		$t4,	0x18($sp)	
	sw		$t3,	0x14($sp)	
	sw		$t2,	0x10($sp)
	sw		$t1,	0xc($sp)
	sw 		$t0,	0x8($sp)
	sw 		$s0,	0x4($sp)
	sw 		$ra,	0x0($sp)

	andi 	$s0,	$a0,	0x100 
	bne		$s0,	$zero, 	CLR_BLOCK 			# Clr block when a0[8] == 1, i.e. $s0(result of 'andi') != 0
	ori 	$s0,	$zero,	0x27f				# Block(Green) to display
CLR_BLOCK:
	ori 	$v0,	$zero,	0x1 				# Set return number to 1 <==> Failure
	andi	$t0,	$a0, 	0x1c 				# To get pattern
#	srl 	$t0,	$t0,	2
	andi 	$t1,	$a0, 	0x3	 				# To get rotation
	add 	$t1,	$t1,	$t1	
	add 	$t1,	$t1,	$t1

#	la 		$t2,	Case_Pattern_Begin
#	add 	$t2,	$t2,	$t0 				# Add $t0 as offset
#	jr 		$t2						

Case_Pattern_Begin: 				
	beq		$t0,	$zero,	P_LINE				# Pattern  ####          	Pattern_No = 000_00
												
	addi	$t3,	$zero,	0x4 											
	beq 	$t0,	$t3,	P_ARROW				# Pattern   #				Pattern_No = 001_00
												           ###
	addi	$t3,	$zero,	0x8 											
	beq 	$t0,	$t3,  P_SQUARE				# Pattern  ##				Pattern_No = 010_00
												           ##
    addi	$t3,	$zero,	0xc
    beq 	$t0,	$t3,  P_RIGHTL				# Pattern  #				Pattern_No = 011_00
    											           ###
    addi	$t3,	$zero,	0x10
	beq 	$t0,	$t3,  P_LEFTL				# Pattern    #				Pattern_No = 100_00
												  		   ###
P_LINE:
	la		$t2,	Case_LINE_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2

Case_LINE_Rotation:	
	beq 	$zero,	$zero, 	LINE_HORIZONTAL
	beq		$zero,	$zero,  LINE_VERTICAL

LINE_HORIZONTAL:
	andi	$t2,	$a1, 	0x7f 				# Get addr X
	addi 	$t2,	$t2,	3					# Judge x + 3
	slti	$t3,	$t2,	0x2e				
	andi	$t2,	$a1,	0x3f00				# Get addr Y
	slti	$t4,	$t2,	0x2e00				# Judge if Y < 32(Indirectly)
	and 	$t3,	$t3,	$t4
	beq		$t3,	$zero, 	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero
	sw 		$s0,	0($a1)
	sw 		$s0,	1($a1)
	sw 		$s0,	2($a1)
	sw 		$s0,	3($a1)
	j 		DRAW_BLOCK_RETURN

LINE_VERTICAL:
	andi 	$t2,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	0x300 				# Judge y + 3
	slti	$t3,	$t2,	0x2e00
	andi	$t2,	$a1,	0x7f
	slti	$t4,	$t2,	0x2e
	and 	$t3,	$t3,	$t4
	beq		$t3,	$zero, 	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero
	sw		$s0,	0($a1)
	sw		$s0,	0x100($a1)
	sw		$s0,	0x200($a1)
	sw		$s0,	0x300($a1)
	j 		DRAW_BLOCK_RETURN

P_ARROW:
	la		$t2,	Case_ARROW_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2
Case_ARROW_Rotation:
	beq 	$zero,	$zero, 	ARROW_DOWN			
	beq		$zero,	$zero,  ARROW_LEFT
	beq		$zero,	$zero,  ARROW_UP
	beq		$zero,	$zero,  ARROW_RIGHT

ARROW_DOWN:										# ARROW: 	###
															 #

    andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y															 
	addi 	$t2,	$t2,	3					# Judge x + 2
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x2($a1)
	sw 		$s0,	0x101($a1)
	j 		DRAW_BLOCK_RETURN
	
ARROW_RIGHT:									# ARROW: 	#
															##
															#

    andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y															
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x200				# Judge y + 2
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x200($a1)
	j 		DRAW_BLOCK_RETURN

ARROW_UP:										# ARROW: 	 #
															###

    andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y															
	addi 	$t2,	$t2,	2					# Judge x + 2
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x102($a1)
	j 		DRAW_BLOCK_RETURN

ARROW_LEFT:										# ARROW: 	 #
															##
															 #
	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x200				# Judge y + 2
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x201($a1)
	j 		DRAW_BLOCK_RETURN

P_SQUARE:										# Square    ##
															##
	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x101($a1)
	j 		DRAW_BLOCK_RETURN

P_RIGHTL:  										# Actually we can use jumptable to implement the case
	la		$t2,	Case_RIGHTL_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2

Case_RIGHTL_Rotation: 							
	beq 	$zero,	$zero,	RIGHTL_R
	beq 	$zero,	$zero,	RIGHTL_D
	beq 	$zero,	$zero,	RIGHTL_L
	beq 	$zero,	$zero,	RIGHTL_U

RIGHTL_R:										# Right_L R	#
															###

	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	2					# Judge x + 2
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x102($a1)
	j 		DRAW_BLOCK_RETURN

RIGHTL_D:										# Right_L D	##
															#
															#

	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x200				# Judge y + 2
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x200($a1)
	j 		DRAW_BLOCK_RETURN

RIGHTL_L:										# Right_L L	###
															  #
															
	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	2					# Judge x + 2
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x2($a1)
	sw 		$s0,	0x102($a1)
	j 		DRAW_BLOCK_RETURN														

RIGHTL_U:										# Right_L L	 #
															 #
															##

	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x200				# Judge y + 2
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x200($a1)
	sw 		$s0,	0x201($a1)
	j 		DRAW_BLOCK_RETURN													

P_LEFTL:
	la		$t2,	Case_LEFTL_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2

Case_LEFTL_Rotation: 							
	beq 	$zero,	$zero,	LEFTL_L
	beq 	$zero,	$zero,	LEFTL_U
	beq 	$zero,	$zero,	LEFTL_R
	beq 	$zero,	$zero,	LEFTL_D

LEFTL_L:										# Left_L L	  #
															###

	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	2					# Judge x + 2
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x2($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x102($a1)
	j 		DRAW_BLOCK_RETURN

LEFTL_U:										# Left_L U	#
															#
															##

	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x200				# Judge y + 2
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x200($a1)
	sw 		$s0,	0x201($a1)
	j 		DRAW_BLOCK_RETURN

LEFTL_R:										# Left_L U	###
															#

	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	2					# Judge x + 2
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x2($a1)
	sw 		$s0,	0x100($a1)
	j 		DRAW_BLOCK_RETURN

LEFTL_D:										# Left_L U	##
															 #
															 #

	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2e			
	addi 	$t3,	$t3,	0x200				# Judge y + 2
	slti	$t5,	$t2,	0x2e00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	DRAW_BLOCK_RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x201($a1)
	j 		DRAW_BLOCK_RETURN


DRAW_BLOCK_RETURN:
	lw 		$ra,	0x0($sp)
	lw 		$s0,	0x4($sp)
	lw 		$t0,	0x8($sp)
	lw		$t1,	0xc($sp)
	lw		$t2,	0x10($sp)	
	lw		$t3,	0x14($sp)	
	lw		$t4,	0x18($sp)
	addi 	$sp,	$sp,	123
	jr 		$ra

#############################################################
##	Function Name: 	TERIS_GAME
##
## 	Description	: 	The entrance of the game 
##
##	Status 	: 		Under Test
##
##############################################################

TERIS_GAME:
	addi 	$sp,	$sp,	-32
	sw 		$s3,	0x1c($s0)
	sw		$t4,	0x18($sp)	
	sw		$t3,	0x14($sp)	
	sw		$t2,	0x10($sp)
	sw		$t1,	0xc($sp)
	sw 		$t0,	0x8($sp)
	sw 		$s0,	0x4($sp)
	sw 		$ra,	0x0($sp)

	lui		$s1,	0x7							# Counter Init
	lui		$s3,	0xc
	addi	$s3,	$s3,	0xe1f

	la		$t0,	Block_Pattern
	lw		$a0,	0($t0)
	add		$a0,	$zero, 	$zero
	sw 		$a0,	0($t0)
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
	lw 	 	$t0, 	0($s0)
	andi 	$t1,	$t0, 	0x100
	beq 	$t1,	$zero,	N_key					# If no key pressed, then branch
	jal		Key_Respond								# Ps2_ready, one key pressed
N_key:
	bne 	$zero,	$s1,	N_Fall
	jal 	Block_Fall
	beq		$v0,	$zero,	N_NEXT_BLOCK
	addi 	$a0,	$a0,	5						# Actually 5 is not that reasonable
	ori	 	$a1,	$zero,	0x08
	add 	$a1,	$a1,	$s3
	jal		Draw_Block
	sub 	$a1,	$a1,	$s3
N_NEXT_BLOCK:
	la		$t0,	Block_Pattern
	sw		$a0,	0($t0)

	la 		$t0,	Block_Addr 						# Relative address
	sw 		$a1,	0($t0)
	lui		$s1,	0x7
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
	lw 		$s3,	0x1c($s0)
	addi 	$sp,	$sp,	32
	jr 		$ra

Key_Respond:
	add 	$zero,	$zero, 	$zero
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
   	beq 	$t1,	$zero,	Block_Fall_Horizontal
   	lw 		$t1,	0xc0($s5) 	
   	bne 	$t1,	$zero,	N_FALL_Line_V	
   	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block							 
	sub 	$a1,	$a1,	$s2
   	bne		$v0,	$zero,	N_FALL_Line_V		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block			
	sub  	$a1,	$a1,	$s2				
   	bne		$v0,	$zero,	N_FALL_Line_H		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	bne		$v0,	$zero,	N_FALL_ARROW_D		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
	bne 	$t1,	$zero,	N_FALL_ARROW_L
	addi 	$a1,	$a1,	0x100				# Addr Y + 1
   	add 	$a1,	$a1,	$s2
	jal 	Draw_Block		
	sub  	$a1,	$a1,	$s2						 
   	bne		$v0,	$zero,	N_FALL_ARROW_L		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	bne		$v0,	$zero,	N_FALL_ARROW_U		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	bne		$v0,	$zero,	N_FALL_ARROW_R		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	bne		$v0,	$zero,	N_FALL_SQUARE		# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	bne		$v0,	$zero,	N_FALL_RL_R			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	bne		$v0,	$zero,	N_FALL_RL_D			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	bne		$v0,	$zero,	N_FALL_RL_L			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	bne		$v0,	$zero,	N_FALL_RL_U			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	bne		$v0,	$zero,	N_FALL_LL_L			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	bne		$v0,	$zero,	N_FALL_LL_U			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	bne		$v0,	$zero,	N_FALL_LL_R			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
   	bne		$v0,	$zero,	N_FALL_LL_D			# Draw_Failed
   	ori		$a0,	$a0,	0x100
   	addi	$a1,	$a1,	-256
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
	
.data
Ascii_code:
	.word 	0x00000000
	.word	0x00000108
	.word	0x00000020
	.word	0x00000104
	.word	0x00000102
	.word	0x00000100
	.word	0x00000101
	.word	0x0000010b
	.word	0x00000020
	.word	0x00000109
	.word	0x00000107
	.word	0x00000105
	.word	0x00000103
	.word	0x00000112
	.word	0x00000060
	.word	0x00000020
	.word	0x00000020
	.word	0x00000121
	.word	0x00000115
	.word	0x00000020
	.word	0x00000116
	.word	0x00000051
	.word	0x00000031
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x0000005a
	.word	0x00000053
	.word	0x00000041
	.word	0x00000057
	.word	0x00000032
	.word	0x00000117
	.word	0x00000020
	.word	0x00000043
	.word	0x00000058
	.word	0x00000044
	.word	0x00000045
	.word	0x00000034
	.word	0x00000033
	.word	0x00000117
	.word	0x00000020
	.word	0x0000011a
	.word	0x00000056
	.word	0x00000046
	.word	0x00000054
	.word	0x00000052
	.word	0x00000035
	.word	0x00000114
	.word	0x00000020
	.word	0x0000004e
	.word	0x00000042
	.word	0x00000048
	.word	0x00000047
	.word	0x00000059
	.word	0x00000036
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x0000004d
	.word	0x0000004a
	.word	0x00000055
	.word	0x00000037
	.word	0x00000038
	.word	0x00000020
	.word	0x00000020
	.word	0x0000002c
	.word	0x0000004b
	.word	0x00000049
	.word	0x0000004f
	.word	0x00000030
	.word	0x00000039
	.word	0x00000020
	.word	0x00000020
	.word	0x0000002e
	.word	0x0000002f
	.word	0x0000004c
	.word	0x0000003b
	.word	0x00000050
	.word	0x0000002d
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x0000005b
	.word	0x0000003d
	.word	0x00000020
	.word	0x00000020
	.word	0x00000113
	.word	0x00000115
	.word	0x0000011b
	.word	0x0000005d
	.word	0x00000020
	.word	0x0000005c
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x0000011d
	.word	0x00000020
	.word	0x00000020
	.word	0x00000119
	.word	0x00000020
	.word	0x0000010e
	.word	0x00000118
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x0000011c
	.word	0x0000002e
	.word	0x0000010d
	.word	0x0000010f
	.word	0x00000020
	.word	0x0000010c
	.word	0x0000011f
	.word	0x00000120
	.word	0x0000010a
	.word	0x0000002b
	.word	0x00000111
	.word	0x0000002d
	.word	0x0000002a
	.word	0x00000110
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x00000020
	.word	0x00000106
Block_Pattern:
	.word 0x00000000
Block_Addr:
	.word 0x00000000
Win_Line_U:
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000

.end