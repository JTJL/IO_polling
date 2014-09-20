##############################
## 	Test counter
##
## 	
##
##
##
##############################
.text                           # code segment
	addi 	$s0, 	$zero, 	-12288				# Ps2_addr		Radix: DEC_FORMAT
	addi 	$s1, 	$zero, 	-100				# Sev_seg_addr	Radix: DEC_FORMAT
	lui		$s2, 	0xc  						# VRam_addr
	ori 	$s2,	$s2, 	0x101
	ori 	$sp,	$zero,	0x4000				# Stack from 0x0000_4000 to 0x0000_0000
	ori  	$t0,	$zero, 	0x27f				# 'A' ascii 
	ori  	$t1,	$zero, 	0x27f				# 'B' ascii 

	sw 		$t0,	-1($s2)						# Write 'A' and 'B'
	add 	$zero,	$zero, 	$zero
	sw 		$t1,	0($s2)
	add 	$zero,	$zero, 	$zero

	lui		$t6,	0x8000
	addi 	$t7,	$zero,	0x7fff
	addi	$t0,	$zero,	0x3
	sw		$t0,	0($s1)						# Set counter_set = 11
	add 	$zero,	$zero, 	$zero
	sw 		$zero,	4($s1)						# Set Control signal i.e. choose mode 00
	addi	$t0, 	$zero,	0x3f0
	sw		$t0,	0($s1) 						# Set counter chanel 00
	add 	$zero,	$zero, 	$zero	
	sw 		$t7,	4($s1)						# Turn counter on
Polling:
	lw		$t1,	0($s1)
	and 	$t2, 	$t1,	$t6
	beq 	$t2,	$zero,	Polling
	addi	$t3,	$zero,	0x47f
	addi	$s2,	$s2,	0x1
	sw		$t3,	0($s2)
	add 	$zero,	$zero, 	$zero	
	sw		$t0,	0($s1) 						# Set counter chanel 00
	add 	$zero,	$zero, 	$zero
	sw 		$t7,	4($s1)						# Turn counter on
	#addi 	$t0,	$zero, 	1
	#beq 	$v0,	$t0, 	TERIS_GAME			# Enter the game
	j 		Polling