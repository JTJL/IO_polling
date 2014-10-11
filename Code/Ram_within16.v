`timescale 1ns / 1ps

module Mem_I_D(
                clk,
                W_En,
                Addr,
                Byte_Sel,
                Half_W,
                D_In,
                D_Out
                );
    input               clk;
    input               W_En;
    input       [12: 0] Addr;               // Word address 
    input               Byte_Sel;           // Byte as 16-bit
    input               Half_W;
    input       [31: 0] D_In;
    output wire [31: 0] D_Out;

    wire                WenH, 
                        WenL; 
    wire        [12 :0] ByteAddr_H,
                        ByteAddr_L;
    wire        [15: 0] Din_H,
                        Din_L,
                        Dout_H,
                        Dout_L;

    assign      Wen_H   = W_En & ( ~Half_W | ~Byte_Sel );
    assign      Wen_L   = W_En & ( ~Half_W |  Byte_Sel );
    assign ByteAddr_H   = {Addr[11: 0], 1'b0};
    assign ByteAddr_L   = {Addr[11: 0], 1'b1};
    assign      Din_H   = D_In[31:16];
    assign      Din_L   = D_In[15: 0];





    dual_ram Mem_in16bit(
                        .clka       (clk),          // input clka
                        .wea        (Wen_H),        // input [0 : 0] wea
                        .addra      (ByteAddr_H),   // input [12 : 0] addra
                        .dina       (Din_H),        // input [15 : 0] dina
                        .douta      (Dout_H),       // output [15 : 0] douta

                        .clkb       (clk),          // input clkb
                        .web        (Wen_L),        // input [0 : 0] web
                        .addrb      (ByteAddr_L),   // input [12 : 0] addrb
                        .dinb       (Din_L),        // input [15 : 0] dinb
                        .doutb      (Dout_L)        // output [15 : 0] doutb
                        );

    assign      D_Out   = (~Half_W)? {Dout_H, Dout_L}:
                            Byte_Sel? {16'h0, Dout_L}: {16'h0, Dout_H};

/*
    (* bram_map="yes" *)
    reg         [15: 0] RAM[8191:   0];     // The 4Kth Word at RAM[8190:8191]

    wire        [12 :0] Addr_B;             
    wire        [15: 0] D_InH,
                        D_InL;

    initial begin
        $readmemb("../Coe_&_Asm/Game_with_cmd.coe",RAM);
    end

    assign      Addr_B  = {Addr[11: 0], 1'b0};      // Byte format 14bits with totally 8KB
    assign      D_InH   = D_In[31:16];
    assign      D_InL   = D_In[15: 0];
    
    always @(posedge clk ) begin
        if ( W_En ) begin     
            if ( Half_W == 0 ) begin 
                RAM[Addr_B    ] = D_InH;                 // Low Address with High Byte
                RAM[Addr_B + 1] = D_InL;                 // High Address with Low Byte         
            end
            else begin                                          // BIG Endian                                                                    
                case  ( Byte_Sel ) 
                    0: begin 
                        RAM[Addr_B    ] = D_InL;
                    end
                    1:begin 
                        RAM[Addr_B + 1] = D_InL;
                    end
                endcase 
            end
        end
        else begin 
            if ( Half_W == 0 ) begin 
                D_Out = {RAM[Addr_B], RAM[Addr_B + 1]};
            end
            else begin 
                case  ( Byte_Sel )
                    0: begin                                    
                        D_Out = {RAM[Addr_B], 16'h0};
                    end
                    1: begin 
                        D_Out = {16'h0, RAM[Addr_B + 1]};
                    end
                endcase  
            end
        end 
    end
*/


endmodule
