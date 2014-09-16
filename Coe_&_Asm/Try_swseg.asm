#baseAddr 0000
add $zero, $zero, $zero 
j Data_Init

Main:
    sw $s0, 0($a0)              // display number on segments
    lw $t2, 0($a1)              // read from btn and switch
    and $t2, $t2, $s4           // check the counter_out
    beq $t2, $zero, None_Overflow
    //bne $t0, $zero, None_Overflow
    //lui $t0, 1                // reset counter_lock
    //addi $t0, $zero, 7fff     // Overflow from software counter
    addi $s0, $s0, 1            // real number + 1

    addi $t0, $zero, 2ab        // Turn on the counter
    sw $t0, 0($a1)                  // select 11 to sent ctrl signal
    sw $zero, 4($a1)                // ctrl signal
    addi $t0, $zero, 2a8            
    sw $t0, 0($a1)                  // select chanle 00
    sw $s3, 4($a1)                  // reload 17fff

    None_Overflow:
    add $zero, $zero, $zero       // software counter
j Main

Data_Init:
    addi $a0, $zero, fe00       // Address for seven-seg display
    addi $a1, $zero, ff00       // Address for counter and btn_switch
                                // Mask code
    addi $s7, $zero, 100            // Last bit of button 
    addi $s6, $zero, 400            // Left button 
    addi $s5, $zero, 1000           // Right button
    lui $s4, 8000                   // First bit for counter0_out
    lui $s3, 1
    addi $s3, $s3, 7fff           // counter number

    addi $t0, $zero, 2ab        // Turn on the counter
    sw $t0, 0($a1)                  // select 11 to sent ctrl signal
    sw $zero, 4($a1)                // sent ctrl
    addi $t0, $zero, 2a8            
    sw $t0, 0($a1)                  // select chanle 00
    sw $s3, 4($a1)                  // 17fff

    //lui $t0, fff
    //addi $t0, $zero, 7fff
    add $s0, $zero, $zero
j Main



