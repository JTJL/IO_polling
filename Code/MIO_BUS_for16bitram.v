
`timescale 1ns / 1ps

module MIO_BUS(clk,
				rst,
				BTN,
				SW,
				mem_w,
				Cpu_data2bus,									//data_from_CPU
				addr_bus,
				ram_data_out,
				led_out,
																// Ps/2_Info
				ps2_ready,
				ps2_rd,
				key_scan,
																// Counter_Info
				counter_out,
				counter0_out,
				counter1_out,
				counter2_out,
				counter_we,										// Counter_Write_Enable

				Cpu_data4bus,									// Write to CPU
				ram_data_in,									// From CPU write to Memory
				ram_addr,										// Memory Address signals
				data_ram_we,									// Ram_Write_Enable

																// GPIO_Info
				GPIOf0000000_we,
				GPIOe0000000_we,
				Peripheral_in,
																// Vram_Info
				Vram_W_Addr_x_y,
				Vram_W_Data,
				Vram_W_En


				);


	input wire         	clk, rst, mem_w;
	input wire 		    counter0_out, counter1_out, counter2_out;
	input wire 	[ 4: 0] BTN;
	input wire 	[ 7: 0] SW, led_out;

	// Ps2_Infor
	input wire 			ps2_ready;
	input wire 	[ 7: 0] key_scan;
	output reg 			ps2_rd;

	input wire 	[31: 0] Cpu_data2bus,
						ram_data_out,
						addr_bus,
						counter_out;

	output reg 		    data_ram_we 	= 0,
						GPIOe0000000_we = 0,
						GPIOf0000000_we = 0,
						counter_we 		= 0;
	output reg 	[31: 0] Cpu_data4bus 	= 0,
						ram_data_in 	= 0,
						Peripheral_in 	= 0;
	output reg 	[12: 0] ram_addr 		= 0;

	// Vram_Info
	output reg			Vram_W_En 		= 0;
	output reg  [10: 0] Vram_W_Data		= 0;
	output reg  [13: 0] Vram_W_Addr_x_y	= 0;


	reg 		[ 7: 0] led_in 			= 0;
	wire counter_over;

	always @(*) begin : proc_RAM_IO_DECODE_SIGNAL
		data_ram_we 					= 0;
		counter_we 						= 0;
		GPIOf0000000_we 				= 0;
		GPIOe0000000_we 				= 0;
		ram_addr 						= 13'h0;
		ram_data_in 					= 32'h0;
		Peripheral_in 					= 32'h0;
		Cpu_data4bus 					= 32'h0;
		ps2_rd	 						= 0;
		Vram_W_En						= 0;
		Vram_W_Addr_x_y					= 13'h0;
		Vram_W_Data 					= 8'b0;
		casex ( addr_bus[31: 8] )
			24'h0000_xx : begin											// 24'h0000_00XX   Instruction
				data_ram_we 			= mem_w;
				ram_addr 				= addr_bus[14: 2];					// For stack data, 0x0000_4000 -> Down
				ram_data_in 			= Cpu_data2bus;						// Instructions from [11: 2] 10bits
				Cpu_data4bus 			= ram_data_out;
			end

			24'h000c_xx : begin												// 32'h000c_xxxx Word Addr bus_addr[13: 0] for Vram
				Vram_W_En 				= mem_w;
				Vram_W_Addr_x_y 		= addr_bus[13: 0];					// Addr_x_y[ 7: 0] for x and Addr_x_y[13: 8] for y
				Vram_W_Data 			= Cpu_data2bus[10: 0];

			end


			24'hffff_dx : begin
				ps2_rd 				 	= ~mem_w;
				Peripheral_in 		 	= Cpu_data2bus;
				Cpu_data4bus  		 	= {23'b0, ps2_ready, key_scan};
			end
			24'hffff_fe : begin											// 32'hffff_fe00 -- Seven_Seg display
				 GPIOe0000000_we		= mem_w;
				 Peripheral_in 		 	= Cpu_data2bus;
				 Cpu_data4bus 			= counter_out;
			end
			24'hffff_ff: begin											// 32'hffff_ff00 --
				if ( addr_bus[2] ) begin
					counter_we 			= mem_w;							// Counter_Signal
					Peripheral_in 		= Cpu_data2bus;						// Write counter lock number
					Cpu_data4bus 		= counter_out;
				end
				else begin
					GPIOf0000000_we	 	= mem_w;							// Led & Btn & Switch
					Peripheral_in 		= Cpu_data2bus;						// set counter_ctrl signal
					Cpu_data4bus 		= {counter0_out, counter1_out, counter2_out, 8'h0, led_out, BTN, SW};
				end
			end
			default : ;
		endcase
	end

endmodule
