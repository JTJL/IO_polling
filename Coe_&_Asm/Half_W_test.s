.text 

	addi	$s2,	$zero,	-256					# Switch address
	addi 	$s1, 	$zero, 	-512 					# Seven_seg address
	la 		$s0,	Data4Test 					
Start:
	lw 		$t0,	0($s0)
	lui		$t3,	0xf
Loop_write_1:
	sw 		$t0,	0($s1) 							# 0x12345678
	addi 	$t3,	$t3,	-1
	bne 	$t3,	$zero,	 Loop_write_1

	lh		$t1,	0($s0)
	lui		$t3,	0xf
Loop_write_2:
	sw 		$t1,	0($s1)							# 0x00001234
	addi 	$t3,	$t3,	-1
	bne 	$t3,	$zero,	 Loop_write_2

	sh 		$zero,	6($s0)							# 0x00001234

	lh		$t1,	6($s0)
	lui		$t3,	0xf
Loop_write_3:
	sw 		$t1,	0($s1)							# 0x00000000
	addi 	$t3,	$t3,	-1
	bne 	$t3,	$zero,	 Loop_write_3

	lh		$t1,	4($s0)
	lui		$t3,	0xf
Loop_write_4:
	sw 		$t1,	0($s1)							# 0x000090ab
	addi 	$t3,	$t3,	-1
	bne 	$t3,	$zero,	 Loop_write_4

	j 		Start


.data 
Data4Test:
	.word 0x12345678
	.word 0x90abcdef