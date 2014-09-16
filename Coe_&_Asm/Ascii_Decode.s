#############################################################################
#
#	Numbase is assumed to be Hex except specially declared
#		
#	Updated Date 	: Sept 16th
#
#	Author 			: S.k.a.r.
#	
#	Last revision	: Comment added
#	
#############################################################################

.text                           # code segment
	la 		$s3,	Ascii_code				# Ascii_Data_BaseAddr, Actually implemented by lui and ori
	add  	$zero, 	$zero, 	$zero
	addi 	$s0, 	$zero, 	-12288			# Ps2_addr		Radix: DEC_FORMAT
	addi 	$s1, 	$zero, 	-512			# Sev_seg_addr	Radix: DEC_FORMAT
	lui		$s2, 	0xc  					# VRam_addr
	addi 	$s2,	$s2, 	0x101
	addi 	$sp,	$zero,	0x4000			# Stack from 0x0000_4000 to 0x0000_0000
	addi  	$t0,	$zero, 	0x141			# 'A' ascii 
	addi  	$t1,	$zero, 	0x242			# 'B' ascii 

	sw 		$t0,	-1($s2)					# Write 'A' and 'B'
	add 	$zero,	$zero, 	$zero
	sw 		$t1,	0($s2)
	add 	$zero,	$zero, 	$zero
	
Polling:
	lw 	 	$t0, 	0($s0)
	andi 	$t1,	$t0, 	0x100
	beq  	$t1, 	$zero,  Polling			# Ps2_ready
	jal 	Scan2Ascii
	sw 	 	$t0, 	0($s1)					# Write Seven-Seg
	#addi 	$t0,	$zero, 	1
	#beq 	$v0,	$t0, 	TERIS_GAME		# Enter the game
	j 		Polling

Scan2Ascii:

	sw 		$ra, 	0($sp)					## You gotta store something, say ra
	ori 	$t2,	$zero,	0xf0
	andi 	$t1, 	$t0,	0xff
	bne		$t1,	$t2,	Load_Data		# 0xF0 Detection 
Read_Bk_Code:
	lw	 	$t0, 	0($s0)					# Read Break Code
	andi 	$t1,	$t0, 	0x100
	beq  	$t1, 	$zero,  Read_Bk_Code	# Ps2_ready
	sw		$t0, 	0($s1)					# Write Seven-Seg
	add 	$zero,	$zero, 	$zero
	lw 		$ra, 	0($sp)					# load back $ra
	jr 		$ra

Load_Data:
	add 	$t3, 	$t1,	$t1
	add 	$t3, 	$t3,	$t3 			# Shift Scan Code left 2 bits
	add 	$a0, 	$s3,	$t3				# Cal Addr with Scan Code as an offset 	
	lw		$t2,	0($a0)
	andi 	$t1, 	$t2,	0x100			# Op_key has eighth bit high
	beq  	$t1, 	$zero,	Print_Ascii		# Not an Op_key

	addi 	$t1, 	$t2,	-282 			# SPACE Judge
	bne 	$t1, 	$zero, 	N_SPACE
	addi 	$s2,	$s2, 	1
	addi 	$t4, 	$zero, 	0x50 			# Judge if X reach 80(Dec) 
	addi 	$t6,	$zero,	0x7f			# Get addr x 
	and 	$t5, 	$s2,	$t6
	bne		$t4,	$t5,	N_Vram_Y_Inc_1
	addi 	$t6, 	$zero,	-128			# Set ffff_ff80, 127 (DEC_FORMAT)
	and 	$s2, 	$s2,	$t6				# keep the Vram Y addr
	addi 	$s2,	$s2, 	0x100  			# Addr Y + 1 
N_Vram_Y_Inc_1:
	sw 		$zero,	0($s2)					# store blank
	add 	$zero,	$zero, 	$zero
	lw 		$ra, 	0($sp)					# load back $ra
	jr 		$ra
N_SPACE:
	addi 	$t1, 	$t2, 	-283			# ENTER Judge 
	bne		$t1, 	$zero,  N_ENTER  
	addi 	$t6, 	$zero,	-128 			# Set ffff_ff80
	#andi 	$t5, 	$s2,	0x7f
	and 	$s2, 	$s2,	$t6				# Enter
	ori		$s2,	$s2,	0x4f 			# Set X at 79 (DEC_FORMAT)
	#addi 	$s2, 	$s2,	0x100 			# Y + 1 	
	addi 	$t2, 	$zero,	0x42d			# Write 2d RED'-' to the beginning of the line
	j Print_Ascii
	#sw 	$t0, 	0($s2)					# Write 2d '-' to the beginning of the line
	#add 	$zero,	$zero, 	$zero
	#lw 	$ra,	0($sp)
	#jr 		$ra
N_ENTER:
	addi 	$t1, 	$t2, 	-285 			# BACKSPACE Judge
	bne		$t1, 	$zero,  N_BKSP 
	sw 		$zero,	0($s2)					# store blank
	#beq 	$s2, 	$zero,	
	addi 	$s2,	$s2,	-1 				# Addr X - 1 
											# Judge if X reaches -1 ; Not done yet 
N_BKSP:
	lw 		$ra, 	0($sp)					# load back $ra
	add 	$zero,	$zero, 	$zero
	jr 		$ra

Print_Ascii:
	addi 	$s2,	$s2, 	1
	addi 	$t4, 	$zero, 	0x50 			# Judge if X reach 80(DEC_FORMAT) 
	addi 	$t6,	$zero,	0x7f			# Get addr x 
	and 	$t5, 	$s2,	$t6
	bne		$t4,	$t5,	N_Vram_Y_Inc_2
	addi 	$t6, 	$zero,	-128			# Set ffff_ff80, 127 (DEC_FORMAT)
	and 	$s2, 	$s2,	$t6				# keep the Vram Y addr
	addi 	$s2,	$s2, 	0x100  			# Addr Y + 1 
	add 	$zero,	$zero, 	$zero	
N_Vram_Y_Inc_2:
	sw 		$t2, 	0($s2)					# Write Screen
	add 	$zero,	$zero, 	$zero
	lw 		$ra, 	0($sp)					# load back $ra
	jr 		$ra




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
.end