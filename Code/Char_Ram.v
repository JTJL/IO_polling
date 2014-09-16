`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:17:43 08/23/2014 
// Design Name: 
// Module Name:    Char_Ram 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Char_Ram(
					Addr_a,
					Din_a,
					clk_a,
					W_en,
					Addr_b,
					rdn_b,
					Dout_b
					);
	input	[12: 0] 	Addr_a;
	input 	[10: 0] 	Din_a;
	input  				clk_a;
	input 				W_en;
	input 	[12: 0] 	Addr_b;
	input  				rdn_b;
    output 	[10: 0] 	Dout_b;
	 
	(* bram_map="yes" *)
	reg 		[10: 0] VRAM[4799: 0];
	 
	initial begin
		$readmemh("../Coe_&_Asm/Teris_vram_init.txt", VRAM);
	end

	always @ (posedge clk_a ) begin
        if ( W_en ) begin
			VRAM[Addr_a] <= Din_a;
		end
	end
	
	assign Dout_b = rdn_b ? 8'b0: VRAM[Addr_b];

endmodule
