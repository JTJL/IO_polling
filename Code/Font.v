module font_table (
						clk,
                        Addr,
						D_out
						);
    input               clk;
    input       [12: 0] Addr; // 8*8*128=2^3*2^3*2^7
    output reg          D_out; // font dot
    
    (* bram_map="yes" *)
    reg             rom [0:8191];
    initial begin
        $readmemb("../Coe_&_Asm/Font_table.coe", rom);
    end
    
    always @(negedge clk)begin
        D_out <= rom[Addr];
    end
    
endmodule
