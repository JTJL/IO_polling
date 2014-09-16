`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:44:59 08/23/2014 
// Design Name: 
// Module Name:    VGA_Controller 
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
module Vga_Controller(
							vga_clk,
							rst,
							Vram_Data,
							H_SYNC,
							V_SYNC,
							Vga_rdn,
							Vram_Addr,
							R,
							G,
							B						
							);
							
	 input 			vga_clk;
	 input 			rst;
	 input  [10: 0]	Vram_Data;
	 output 		H_SYNC;
	 output 		V_SYNC;
	 output 		Vga_rdn;
	 output [12 :0] Vram_Addr;
	 output [ 2: 0]	R, G;
	 output [ 1: 0]	B;
	 
	 wire	[12: 0]	Font_Addr;
	 wire   [ 8: 0] Vga_row;
	 wire   [ 9: 0] Vga_col;
	 wire 	[ 7: 0] Char_rgb;
	 wire   [ 5: 0] Char_row;
	 wire   [ 6: 0] Char_col;
	 wire 			Font_out;
	 
	 assign Char_row 	= Vga_row[ 8: 3];
	 assign Char_col 	= Vga_col[ 9: 3]; 

	 
	 assign Font_Addr 	= {Vram_Data[ 6: 0], Vga_row[ 2: 0], Vga_col[ 2: 0]};
	 assign Vram_Addr 	= Char_row * (64 + 16) + Char_col;
	 
	 
	 Vga_Sync     Vga_S(
	 						.vga_clk	(vga_clk),
							.clrn		(~rst),
							.row_addr	(Vga_row),
							.col_addr	(Vga_col),
							.rdn		(Vga_rdn),
							.hs			(H_SYNC),
							.vs			(V_SYNC)
							);
							
								
	 font_table  Font_table(
                            .clk        (vga_clk),
							.Addr		(Font_Addr),
							.D_out		(Font_out)
							);

										
	 assign Char_rgb 	= Font_out 	? 	{{3{Vram_Data[10]}}, {3{Vram_Data[9]}}, {2{Vram_Data[8]}}} /*8'b010_001_00*/	: 8'b110_101_10;
	
	 assign {R,G,B}		= Vga_rdn	? 	8'b0			: Char_rgb;
	 
endmodule
