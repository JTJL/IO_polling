
	add  $zero, $zero, 	$zero
	addi $s0, 	$zero, 	0xd000			// Ps2_addr
	addi $s1, 	$zero, 	0xfe00			// Sev_seg_addr
Polling:
	lw 	 $t0, 	0($s0)
	andi $t1,	$t0, 	0x100
	beq  $t1, 	$zero,  Polling	
	sw 	 $t0, 	0($s1)
	j Polling
		 

