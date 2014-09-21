TERIS_GAME:
	addi 	$sp,	$sp,	-123
	sw		$t4,	0x18($sp)	
	sw		$t3,	0x14($sp)	
	sw		$t2,	0x10($sp)
	sw		$t1,	0xc($sp)
	sw 		$t0,	0x8($sp)
	sw 		$s0,	0x4($sp)
	sw 		$ra,	0x0($sp)

	lui		$s1,	0x3ff							# Counter Init

	la		$t0,	Block_Pattern
	lw		$a0,	0($t0)

	la 		$t0,	Block_Addr 						# Relative address
	lw 		$a1,	0($t0)

GAME_ON:
	addi 	$s1,	$s1,	-1 						# Counter - 1
	lw 	 	$t0, 	0($s0)
	andi 	$t1,	$t0, 	0x100
	beq 	$t1,	$zero,	N_Key					# If no key pressed, then branch
	jal		Key_Respond								# Ps2_ready, one key pressed
N_key:
	bne 	$zero,	$s1,	N_Fall
	jal 	Block_Fall
	lui		$s1,	0x3ff
N_Fall:
 	bne	    $zero,	$zero,	GAME_OVER
	j  		GAME_ON

GAME_OVER:
	
	lw 		$ra,	0x0($sp)
	lw 		$s0,	0x4($sp)
	lw 		$t0,	0x8($sp)
	lw		$t1,	0xc($sp)
	lw		$t2,	0x10($sp)	
	lw		$t3,	0x14($sp)	
	lw		$t4,	0x18($sp)
	addi 	$sp,	$sp,	123
	jr 		$ra

Key_Respond:
	add 	$zero,	$zero, 	$zero
	jr 		$ra


.data
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

