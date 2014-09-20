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
	andi 	$t1,	$a0, 	0x3	 				# To get rotation

	la 		$t2,	Case_Pattern_Begin
	add 	$t2,	$t2,	$t0 				# Add $t0 as offset
	jr 		$t2						

Case_Pattern_Begin: 				
	beq		$zero,	$zero,	P_LINE				# Pattern  ####          	Pattern_No = 000
												#

	beq 	$zero,	$zero,	P_ARROW				# Pattern   #				Pattern_No = 001
												#          ###

	beq 	$zero,	$zero,  P_SQUARE			# Pattern  ##				Pattern_No = 010
												#          ##

    beq 	$zero,	$zero,  P_RIGHTL			# Pattern  #				Pattern_No = 011
    											#          ###

	beq 	$zero,	$zero,  P_LEFTL				# Pattern    #				Pattern_No = 100
												# 		   ###
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
	slti	$t3,	$t2,	0x2d				
	beq		$t3,	$zero, 	RETURN
	and 	$v0,	$zero,	$zero
	sw 		$s0,	0($a1)
	sw 		$s0,	2($a1)
	sw 		$s0,	3($a1)
	sw 		$s0,	4($a1)
	j 		RETURN

LINE_VERTICAL:
	andi 	$t2,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	0x300 				# Judge y + 3
	slti	$t3,	$t2,	0x2d00
	beq		$t3,	$zero, 	RETURN
	and 	$v0,	$zero,	$zero
	sw		$s0,	0($a1)
	sw		$s0,	0x100($a1)
	sw		$s0,	0x200($a1)
	sw		$s0,	0x300($a1)
	j 		RETURN

P_ARROW:
	la		$t2,	Case_ARROW_Rotation
	add 	$t2,	$t2,	$t1					# Add $t1 as offset
	jr 		$t2
Case_ARROW_Rotation:
	beq 	$zero,	$zero, 	ARROW_DOWN			
	beq		$zero,	$zero,  ARROW_RIGHT
	beq		$zero,	$zero,  ARROW_UP
	beq		$zero,	$zero,  ARROW_LEFT

ARROW_DOWN:										# ARROW: 	###
															 #

    andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y															 
	addi 	$t2,	$t2,	3					# Judge x + 2
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x2($a1)
	sw 		$s0,	0x101($a1)
	j 		RETURN
	
ARROW_RIGHT:									# ARROW: 	#
															##
															#

    andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y															
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x200				# Judge y + 2
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x200($a1)
	j 		RETURN

ARROW_UP:										# ARROW: 	 #
															###

    andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y															
	addi 	$t2,	$t2,	2					# Judge x + 2
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x102($a1)
	j 		RETURN

ARROW_LEFT:										# ARROW: 	 #
															##
															 #
	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x200				# Judge y + 2
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x201($a1)
	j 		RETURN

P_SQUARE:										# Square    ##
															##
	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x101($a1)
	j 		RETURN

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
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x102($a1)
	j 		RETURN

RIGHTL_D:										# Right_L D	##
															#
															#

	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x200				# Judge y + 2
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x200($a1)
	j 		RETURN

RIGHTL_L:										# Right_L L	###
															  #
															
	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	2					# Judge x + 2
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x2($a1)
	sw 		$s0,	0x102($a1)
	j 		RETURN														

RIGHTL_U:										# Right_L L	 #
															 #
															##

	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x200				# Judge y + 2
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x200($a1)
	sw 		$s0,	0x201($a1)
	j 		RETURN													

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
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x2($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x102($a1)
	j 		RETURN

LEFTL_U:										# Left_L U	#
															#
															##

	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x200				# Judge y + 2
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x100($a1)
	sw 		$s0,	0x200($a1)
	sw 		$s0,	0x201($a1)
	j 		RETURN

LEFTL_R:										# Left_L U	###
															#

	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	2					# Judge x + 2
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x100				# Judge y + 1
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x2($a1)
	sw 		$s0,	0x100($a1)
	j 		RETURN

LEFTL_D:										# Left_L U	##
															 #
															 #

	andi	$t2,	$a1, 	0x7f 				# Get addr X
	andi 	$t3,	$a1, 	0x3f00				# Get addr Y
	addi 	$t2,	$t2,	1					# Judge x + 1
	slti	$t4,	$t2,	0x2d			
	addi 	$t3,	$t3,	0x200				# Judge y + 2
	slti	$t5,	$t2,	0x2d00
	and		$t4,	$t4,	$t5
	beq 	$t4,	$zero,	RETURN
	and 	$v0,	$zero,	$zero 				# Draw Succeeded
	sw 		$s0,	0x0($a1)
	sw 		$s0,	0x1($a1)
	sw 		$s0,	0x101($a1)
	sw 		$s0,	0x201($a1)
	j 		RETURN


RETURN:
	lw 		$ra,	0x0($sp)
	lw 		$s0,	0x4($sp)
	lw 		$t0,	0x8($sp)
	lw		$t1,	0xc($sp)
	lw		$t2,	0x10($sp)	
	lw		$t3,	0x14($sp)	
	lw		$t4,	0x18($sp)
	addi 	$sp,	$sp,	123
	jr 		$ra