#baseAddr 0000
	add  	$zero, 	$zero, 	$zero
	addi 	$s0, 	$zero, 	d000			# Ps2_addr
	addi 	$s1, 	$zero, 	fe00			# Sev_seg_addr
	lui		$s2, 	c  						# VRam_addr
	addi 	$s2,	$s2, 	140
	addi  	$t0,	$zero, 	41				# 'A' ascii 
	addi  	$t1,	$zero, 	42				# 'B' ascii 

	sw 		$t0,	0($s2)				# Write 'A' and 'B'
	add 	$zero,	$zero, 	$zero
	sw 		$t1,	4($s2)
	add 	$zero,	$zero, 	$zero

Polling:
	lw 	 	$t0, 	0($s0)
	andi 	$t1,	$t0, 	100
	beq  	$t1, 	$zero,  Polling	
	sw 	 	$t0, 	0($s1)					# Write Seven-Seg
	addi 	$s2,	$s2, 	8
	sw 		$t0, 	0($s2)					# Write Screen
	add 	$zero,	$zero, 	$zero
	
	j Polling
		 