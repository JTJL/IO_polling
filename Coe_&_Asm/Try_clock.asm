#baseAddr 0000
add $zero, $zero, $zero 
j Data_Init

Main:
    lw $t2, 0($a1)              // read from btn and switch
    and $t2, $t2, $s4           // check the counter_out
    beq $t2, $zero, None_Overflow
        addi $s7, $zero, 100
        lw $t2, 0($a1)
        and $t2, $t2, $s7
        slt $t0, $s6, $t2
        add $s6, $t2, $zero
        beq $t0, $zero, None_record
        //lw $t2, 0($a1)
        //and $t2, $t2, $s7               // Check the center button
        //beq $t2, $zero, None_record
            addi $s2, $s2, 4
            add $t3, $a2, $s2 
            sw $zero, 0($a0)
            sw $s0, 0($t3) 
            beq $s2, $t1, EndOCount     // End of the counting (five times of record)
        None_record:

        // -----------------------------   Display number (in BCD) + 1
        addi $s1, $zero, A          
        addi $t4, $t4, 1                // D0 
        bne $t4, $s1, Break
        addi $s1, $zero, A0             
        add $t4, $zero, $zero
        addi $t5, $t5, 10               // D1 
        bne $t5, $s1, Break
        addi $s1, $zero, A00
        add $t5, $zero, $zero
        addi $t6, $t6, 100              // D2
        bne $t6, $s1, Break
        addi $s1, $zero, 9fff
        addi $s1, $s1, 1 
        add $t6, $zero, $zero
        addi $t7, $t7, 1000             // D3
        bne $t7, $s1, Break 
        add $t7, $zero, $zero
        Break:
        add $s0, $t4, $t5
        add $s0, $s0, $t6
        add $s0, $s0, $t7                 
        sw $s0, 0($a0)              // display number on segments
        // -----------------------------   Reset the counter
        addi $t0, $zero, 2ab        
        sw $t0, 0($a1)                  // select 11 to sent ctrl signal
        sw $zero, 4($a1)                // ctrl signal
        addi $t0, $zero, 2a8            
        sw $t0, 0($a1)                  // select chanle 00
        sw $s3, 4($a1)                  // reload 27fff

    None_Overflow:                      // Next check: center button
        add $zero, $zero, $zero         // addi $t0, $t0, -1 // no need software counter

j Main

Data_Init:
    addi $a0, $zero, fe00       // Address for seven-seg display
    addi $a1, $zero, ff00       // Address for counter and btn_switch
    addi $a2, $zero, c00
                                // Mask code
    addi $s7, $zero, 100            // Last bit of button center
    add $s6, $zero, $zero           // center btn
    add $v0, $zero, $zero           // left btn
    add $v1, $zero, $zero           // right btn

    lui $s4, 8000                   // First bit for counter0_out
    //lui $s3, 2
    addi $s3, $zero, 2600             // counter number
    add $s2, $zero, $zero

    addi $t1, $zero, 14         // Five times of btn limit

    addi $t0, $zero, 2ab        // Turn on the counter
    sw $t0, 0($a1)                  // select 11 to sent ctrl signal
    sw $zero, 4($a1)                // sent ctrl
    addi $t0, $zero, 2a8            
    sw $t0, 0($a1)                  // select chanle 00
    sw $s3, 4($a1)                  // 17fff

    //lui $t0, fff
    //addi $t0, $zero, 7fff
    add $s0, $zero, $zero
    sw $s0, 0($a0)              // display number on segments
j Main

EndOCount:
    lw $s0, 0($a2)                  // Read the first record
    add $t8, $zero, $zero
    Start_show:    
        sw $s0, 0($a0)                  // display the record
        lw $t2, 0($a1)
        and $t2, $t2, $s4
        beq $t2, $zero, break_btncheck      // Counter_condition
            addi $s7, $zero, 400
            lw $t2, 0($a1)                  // check button
            and $t2, $t2, $s7               // Check_Left 
            slt $t0, $v0, $t2
            add $v0, $zero, $t2
            beq $t0, $zero, Check_Right
                beq $t8, $zero, Check_Right
                addi $t8, $t8, -4
                add $t0, $t8, $a2
                lw $s0, 0($t0)
            Check_Right:
            addi $s7, $zero, 1000
            lw $t2, 0($a1) 
            and $t2, $t2, $s7
            slt $t0, $v1, $t2
            add $v1, $zero, $t2
            beq $t0, $zero, Check_Center
                beq $t8, $t1, Check_Center
                addi $t8, $t8, 4
                add $t0, $t8, $a2
                lw $s0, 0($t0)
            Check_Center:
            addi $s7, $zero, 100
            lw $t2, 0($a1)
            and $t2, $t2, $s7
            slt $t0, $s6, $t2
            add $s6, $t2, $zero
            bne $t0, $zero, Data_Init
        break_btncheck:
        add $zero, $zero, $zero
    j Start_show
