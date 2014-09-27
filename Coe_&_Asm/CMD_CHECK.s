######################################################
##	Function Name: CMD_CHECK
##
##	Only TETRIS added.
##
##
################################################
CMD_CHECK:
	addi 	$sp,	$sp,	-12
	sw 		$ra,	0x00($sp)
	sw	 	$t0,	0x04($sp)
	sw	 	$t1,	0x08($sp)

	la 		$gp,	CMD_STR
	addi	$gp,	$gp, 	4
	lw 		$t1,	0x0($gp)

	addi	$t0,	$zero,	0x54 								# T
	bne 	$t1,	$t0,	CMD_CHECK_RETURN
	sw 	 	$zero, 	0x0($gp)
	addi	$gp,	$gp,	0x4
	lw 		$t1,	0x0($gp)
	addi	$t0,	$zero,	0x45 								# E
	bne 	$t1,	$t0,	CMD_CHECK_RETURN
	sw 	 	$zero, 	0x0($gp)
	addi	$gp,	$gp,	0x4
	lw 		$t1,	0x0($gp)
	addi	$t0,	$zero,	0x54								# T
	bne 	$t1,	$t0,	CMD_CHECK_RETURN
	sw 	 	$zero, 	0x0($gp)
	addi	$gp,	$gp,	0x4
	lw 		$t1,	0x0($gp)
	addi	$t0,	$zero,	0x52								# R
	bne 	$t1,	$t0,	CMD_CHECK_RETURN
	sw 	 	$zero, 	0x0($gp)
	addi	$gp,	$gp,	0x4
	lw 		$t1,	0x0($gp)
	addi	$t0,	$zero,	0x49								# I
	bne 	$t1,	$t0,	CMD_CHECK_RETURN
	sw 	 	$zero, 	0x0($gp)
	addi	$gp,	$gp,	0x4
	lw 		$t1,	0x0($gp)
	addi	$t0,	$zero,	0x53								# S
	bne 	$t1,	$t0,	CMD_CHECK_RETURN
	sw 	 	$zero, 	0x0($gp)

	jal 	Clr_Screen
	add 	$zero,	$zero,	$zero
	jal 	Draw_Win 
	add 	$zero,	$zero,	$zero
	jal 	TERIS_GAME
	add 	$zero,	$zero,	$zero

CMD_CHECK_RETURN:

	lw 		$t1,	0x08($sp)
	lw 		$t0,	0x04($sp)
	lw 		$ra,	0x00($sp)
	addi 	$sp,	$sp,	12
	jr	 	$ra



