##############
# 	Function: Clear Screen
#
# 	Return	: None
##############
Clr_Screen:			
	addi 	$sp,	$sp, 	-28						# DEC_FORMAT
	sw		$t0,	0x0($sp)
	sw		$t2,	0x4($sp)
	sw		$t3,	0x8($sp)
	sw		$t4,	0xc($sp)
	sw 		$t5,	0x10($sp)	
	sw		$t6,	0x14($sp)
	sw 		$ra,	0x18($sp)

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

	lw 		$ra,	0x18($sp)
	lw		$t6,	0x14($sp)
	lw		$t5,	0x10($sp)
	lw		$t4,	0xc($sp)
	lw		$t3,	0x8($sp)
	lw		$t2,	0x4($sp)
	lw		$t0,	0x0($sp)
	addi 	$sp,	$sp, 	28
	add 	$zero, 	$zero,	$zero
	jr		$ra