Draw_Win:
	addi 	$sp,	$sp,	-16
	sw 		$t0,	0x0($sp)
	sw 		$t1,	0x4($sp)
	sw 		$t2,	0x8($sp)
	sw 		$t3,	0xc($sp)
	sw 		$ra,	0x10($sp)

	lui		$t0,	0xc
	lui		$t1,	0xc
	lui		$t3,	0xc
	ori		$t0,	$t0,	0x0d1e				# UpRow Addr
	ori		$t1,	$t1,	0x2e1e				# DownRow Addr
	ori		$t2,	$zero,	0x12d				# Char '-'
	ori		$t3,	$t3,	0x0d2f				# Row Limit
Loop_Draw_Row:
	and 	$zero,	$zero,	$zero
	sw		$t2,	0($t0)
	and 	$zero,	$zero,	$zero
	sw		$t2,	0($t1)

	addi	$t0,	$t0,	1
	addi	$t1,	$t1,	1
	bne 	$t0,	$t3,	Loop_Draw_Row
	
	lui		$t0,	0xc
	lui		$t1,	0xc
	lui 	$t3,	0xc
	ori		$t0,	$t0,	0x0e1e				# RightColAddr
	ori		$t1,	$t1,	0x0e2e				# LeftCol Addr 
	ori		$t2,	$zero,	0x17c				# Char '|'
	ori		$t3,	$t3, 	0x2e1e				# Col_Limit
Loop_Draw_Col:
	and 	$zero,	$zero,	$zero
	sw		$t2,	0($t0)
	and 	$zero,	$zero,	$zero
	sw		$t2,	0($t1)
	addi	$t0,	$t0,	0x100
	addi	$t1,	$t1,	0x100
	bne 	$t0,	$t3, 	Loop_Draw_Col

	lw 		$ra,	0x10($sp)
	lw 		$t3,	0xc($sp)
	lw 		$t2,	0x8($sp)
	lw 		$t1,	0x4($sp)
	lw 		$t0,	0x0($sp)
	addi	$sp,	$sp,	16
	jr 		$ra