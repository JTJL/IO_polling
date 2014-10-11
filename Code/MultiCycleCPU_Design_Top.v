`timescale 1ns / 1ps
module Top_Muliti_IOBUS(
                        clk_50mhz,
                        BTN,
                        // I/O:
                        SW,
						KEYBOARD_CLK,
						KEYBOARD_DATA,
                        LED,
                        SEGMENT,
                        AN_SEL,
						R,
						G,
						B,
						H_SYNC,
						V_SYNC
                        );

    input 			clk_50mhz;

	// Static Input
	input  	[ 4: 0] BTN;
	input  	[ 7: 0] SW;

	// KeyBoard Interface
	input 		   	KEYBOARD_CLK;
	input 		   	KEYBOARD_DATA;

	// LED and Segment Interface
	output 	[ 7: 0] LED, SEGMENT;
    output 	[ 3: 0] AN_SEL;

	// VGA Interface
	output 	[ 2: 0] R, G;
	output 	[ 1: 0] B;
	output         	H_SYNC;
    output         	V_SYNC;


    wire 		   	Clk_CPU, rst, clk_m, mem_w, data_ram_we, GPIOf0000000_we, GPIOe0000000_we, counter_we;
    wire 		   	counter_OUT0, counter_OUT1, counter_OUT2;
    wire 		   	MIO_ready;
    wire 		   	CPU_MIO;
	wire 		   	ps2_ready;
    wire           	ps2_rd;
	wire   	[ 1: 0] Counter_set;
    wire   	[ 4: 0] state;
    wire   	[ 3: 0] digit_anode, blinke;
    wire   	[ 4: 0] button_out;
    wire   	[ 7: 0] SW_OK, led_out; 						//led_out is current LED light
    wire   	[ 7: 0] ps2_key;
    wire   	[12: 0] ram_addr;
    wire   	[21: 0] GPIOf0;
    wire   	[31: 0] pc, Inst, addr_bus, Cpu_data2bus, ram_data_out, disp_num;
    wire   	[31: 0] clkdiv, Cpu_data4bus, counter_out, ram_data_in, Peripheral_in;

	// PS/2 wire
	wire   	[ 7: 0] key;
    reg    	        ps2_rdn;
    reg    	[31: 0] key_d;

	// Vram <=> Vga_c wire
	wire   	[10: 0] Vram_Data_Out;
    wire   	[12: 0] Vram_Addr_f_Vga;

	// Vram  <=> Cpu wire
	wire   			Vram_W_En;
	wire   	[10: 0] Vram_W_Data;
    wire    [12: 0] Vram_W_Addr;
	wire 	[13: 0]	Vram_W_Addr_x_y;



    assign MIO_ready	= ~button_out[1];
    assign rst		    = button_out[3];

    assign SW2 		   	= SW_OK[2];
    assign LED 	      	= {led_out[7]|Clk_CPU,led_out[6:0]};
    assign clk_m 		= ~clk_50mhz;
    assign AN_SEL       = digit_anode;
    assign clk_io 	   	= ~Clk_CPU;

    seven_seg_dev      seven_seg(
                                .disp_num			(disp_num),
                                .clk				(clk_50mhz),
                                .clr				(rst),
                                .SW					(SW_OK[1:0]),
                                .Scanning			(clkdiv[19:18]),
                                .SEGMENT			(SEGMENT),
                                .AN					(digit_anode)
                                );

    BTN_Anti_jitter     BTN_OK(
                                clk_50mhz,
                                BTN,
                                SW,
                                button_out,
                                SW_OK
                                );

    clk_div             div_clk(
                                clk_50mhz,
                                rst,
                                SW2,
                                clkdiv,
                                Clk_CPU
                                ); // Clock divider-


// ============================= muliti_cycle_cpu ================================
    Muliti_cycle_Cpu    MC_cpu(
                                .clk            (Clk_CPU),
                                .reset          (rst),
                                .MIO_ready      (MIO_ready), //MIO_ready
                                // Internal signals:
                                .pc_out         (pc), //Test
                                .Inst           (Inst), //Test
                                .mem_w          (mem_w),
                                .Addr_out       (addr_bus),
                                .data_out       (Cpu_data2bus),
                                .data_in        (Cpu_data4bus),
                                .CPU_MIO        (CPU_MIO),
                                .state          (state) //Test
                                );

    Mem_I_D               RAM_I_D(
                                .clk           	(clk_m),
                                .W_En           (data_ram_we),
                                .Addr          	(ram_addr),
                                .D_In           (ram_data_in),
                                .D_Out          (ram_data_out)
                                ); // Addre_Bus [9 : 0] ,Data_Bus [31 : 0]

// ===============================================================================

// ============================== Simple BUS =====================================
    MIO_BUS         MIO_interface(
                                .clk            (clk_50mhz),
                                .rst            (rst),
                                .BTN            (button_out),
                                .SW             (SW_OK),
                                .led_out        (led_out),
								.mem_w          (mem_w),

								.ps2_ready      (ps2_ready),
								.key_scan       (key),							// Need to be improved
                                .ps2_rd         (ps2_rd),

                                .counter_out    (counter_out),
                                .counter0_out   (counter_OUT0),
                                .counter1_out   (counter_OUT1),
                                .counter2_out   (counter_OUT2),
								.counter_we     (counter_we),

                                .Cpu_data4bus   (Cpu_data4bus),					// Write to CPU
                                .ram_data_in    (ram_data_in),				 	// From CPU write to Memory
                                .ram_addr       (ram_addr),						// Memory Address signals
                                .Cpu_data2bus   (Cpu_data2bus),					// Data from CPU
								.data_ram_we    (data_ram_we),
                                .addr_bus       (addr_bus),
                                .ram_data_out   (ram_data_out),

								.Vram_W_En		(Vram_W_En),					// Vga Logic
								.Vram_W_Addr_x_y(Vram_W_Addr_x_y),
								.Vram_W_Data	(Vram_W_Data),

                                .GPIOf0000000_we(GPIOf0000000_we),
                                .GPIOe0000000_we(GPIOe0000000_we),
                                .Peripheral_in  (Peripheral_in)
                                );

    led_Dev_IO     Device_led(
                                clk_io,
                                rst,
                                GPIOf0000000_we,
                                Peripheral_in,
                                Counter_set,
                                led_out,
                                GPIOf0
                                );

	 /* GPIO out use on 7-seg display & CPU state display addre=e0000000-efffffff */
    seven_seg_Dev_IO    Device_7seg(
                                .clk            (clk_io),
                                .rst            (rst),
                                .GPIOe0000000_we(GPIOe0000000_we),
                                .Test           (SW_OK[7:5]),
                                .disp_cpudata   (Peripheral_in), //CPU data output
                                .Test_data0     (pc),
                                .Test_data1     (counter_out), //counter
                                .Test_data2     (Inst), //Inst
                                .Test_data3     (addr_bus), //addr_bus
                                .Test_data4     (Cpu_data2bus), //Cpu_data2bus;
                                .Test_data5     ({27'b0,counter_we, 3'b0,counter_OUT0}), //Cpu_data4bus;
                                .Test_data6     (key_d),
                                //pc;
                                .disp_num       (disp_num)
                                );

    Counter_x           Counter_xx(
                                .clk            (clk_io),
                                .rst            (rst),
                                .clk0           (clkdiv[9]),
                                .clk1           (clkdiv[10]),
                                .clk2           (clkdiv[10]),
                                .counter_we     (counter_we),
                                .counter_val    (Peripheral_in),
                                .counter_ch     (Counter_set),
                                .counter0_OUT   (counter_OUT0),
                                .counter1_OUT   (counter_OUT1),
                                .counter2_OUT   (counter_OUT2),
                                .counter_out    (counter_out)
                                );

// ============================ VGA Logic =========================


	BUFG            VGA_CLOCK_BUF(
                                .O(Vga_clk),
                                .I(clkdiv[1])
                                );

	Vga_Controller 			Vga_C(
								.vga_clk		(Vga_clk),
								.rst			(rst),
								.Vram_Data		(Vram_Data_Out),
								.H_SYNC			(H_SYNC),
								.V_SYNC			(V_SYNC),
								.Vga_rdn		(Vga_rdn),
								.Vram_Addr		(Vram_Addr_f_Vga),
								.R				(R),
								.G				(G),
								.B				(B)
								);
/*
	 assign vram_write = ~vga_access & wvram;
	 assign vram_addr = vga_access? vram_addr_f_vga :
			            (wvram | rvram)? m_addr[14:2] : 13'hx;
*/

    assign Vram_W_Addr  = Vram_W_Addr_x_y[13: 8] * 80 + Vram_W_Addr_x_y[ 7: 0];

    Char_Ram  				C_Ram(
								.Addr_a			(Vram_W_Addr),  	// addr_bus[14: 2]
								.Din_a			(Vram_W_Data),		// Peripheral_in
								.clk_a			(~clk_50mhz),
								.W_en			(Vram_W_En),			// Vram_write
								.Addr_b			(Vram_Addr_f_Vga),	//
								.rdn_b			(Vga_rdn),
								.Dout_b			(Vram_Data_Out)
								);


//	============================ PS2 Logic =========================== DONE


	always @(posedge Clk_CPU or posedge rst) begin
        if ( rst ) begin
            ps2_rdn     <= 1;
            key_d       <= 0;
        end
        else if ( ps2_rd && ps2_ready ) begin
            key_d       <= {key_d[23: 0], ps2_key};
            ps2_rdn     <= ~ps2_rd | ~ps2_ready;
        end
        else ps2_rdn    <= 1;
    end

	assign key = (ps2_rd && ps2_ready) ? ps2_key : 8'h41;
    //assign key =  ps2_key ;



	 PS2_Keyboard    KeyBoard_Ctrl(
								.clk        	(clkdiv[0]),
								.clrn       	(~rst),
								.ps2_clk    	(KEYBOARD_CLK),
								.ps2_data   	(KEYBOARD_DATA),
								.rdn        	(ps2_rdn),
                                .data       	(ps2_key),
                                .ready      	(ps2_ready),
								.overflow   	()
								);

endmodule
