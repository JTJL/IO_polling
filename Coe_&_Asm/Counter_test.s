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

	

	addi 	$t7,	$zero,	-100
	addi	$t0,	$zero,	0x3
	sw		$t0,	0($s1)						# Set counter_set = 11
	add 	$zero,	$zero, 	$zero
	sw 		$zero,	4($s1)						# Set Control signal i.e. choose mode 00
	addi	$t0, 	$zero,	0x7ff0
	sw		$t0,	0($s1) 						# Set counter chanel 00
	add 	$zero,	$zero, 	$zero	
	sw 		$t7,	4($s1)						# Turn counter on
Polling:
	lui		$t6,	0x8000
	lw		$t1,	0($s1)
	add 	$zero,	$zero,	$zero
	and 	$t2, 	$t1,	$t6
	beq 	$t2,	$zero,	Polling
	addi	$t3,	$zero,	0x461
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
Write_Screen:
	sw		$t3,	0($s2)
	add 	$zero,	$zero, 	$zero	
	add 	$zero,	$zero,	$zero
	addi 	$t7,	$zero,	0x7ffc
	sw		$t7,	0($s1) 						# Set counter chanel 00
	add 	$zero,	$zero, 	$zero
	add 	$zero,	$zero,	$zero
	addi 	$t7,	$zero,	-1000
	sw 		$t7,	4($s1)						# Turn counter on
	add 	$zero,	$zero,	$zero
	add 	$zero,	$zero,	$zero
	j 		Polling