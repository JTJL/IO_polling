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
	add 	$zero,	$zero, 	$zero	
Write_Screen:
	sw 		$t2, 	0($s2)						# Write Screen
	add 	$zero,	$zero, 	$zero
	lw 		$ra, 	0($sp)						# load back $ra
	jr 		$ra


##############
# 	Function: Clear Screen
#
# 	Return	: None
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