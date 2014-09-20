#########################################
##	Function: Draw_Block
##	
##	Parameters: $a0[ 4: 2] [ 1: 0] for Patterns(5) and Rotation(4)
##				$a1[13: 8] [ 7: 0] for address Y(60) and X(80)
##				
##  Return 	:	$v0 zero for Draw-Succeed otherwise Draw-Failure
#########################################


Draw_Block:
	addi 	$sp, 	$sp,	-123
	sw 		$,		($sp)
	sw 		$,		($sp)
	sw 		$ra,	($sp)

	andi	$t0,	$a0, 	0x1c 				# To get pattern
	andi 	$t1,	$a0, 	0x3	 				# To get rotation

	la 		$t2,	Case_Pattern_Begin
	add

Case_Pattern_Begin: 				






	lw 		$ra,	($sp)
	lw 		$,		($sp)
	lw 		$,		($sp)
	jr 		$ra