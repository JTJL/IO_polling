`timescale 1ns / 1ps

module Mem_I_D(
    clk,
    W_En,
    Addr,
    D_In,
    D_Out
    );
    input               clk;
    input               W_En;
    input       [12: 0] Addr;               // Word address 
    input               Byte_Sel;           // Byte as 16-bit
    input               Half_W;
    input       [31: 0] D_In;
    output reg  [31: 0] D_Out;

    (* bram_map="yes" *)
    reg         [15: 0] RAM[8191:   0];     // The 4Kth Word at RAM[8190:8191]

    wire        [13 :0] Addr_B;             
    assign      Addr_B = {Addr, 1'b0};      // Byte format 14bits with totally 8KB

    initial begin
        $readmemb("../Coe_&_Asm/Game_with_cmd.coe",RAM);
    end

    always @(posedge clk ) begin
        if ( W_En ) begin
            /*
            RAM[Addr] <= D_In;
            */        
            if ( Half_W ) begin 
                RAM[Addr_B + Byte_Sel] <= D_In[15:0];           // Byte address
                /*
                case  ( Byte_Sel ) begin
                    0: begin 
                        RAM[Addr_B    ] <= D_In[15:0];
                    end
                    1:begin 
                        RAM[Addr_B + 1] <= D_In[15:0];
                    end
                endcase 
                */
            end
            else begin                                          // BIG Endian                                                                    
                RAM[Addr_B    ] <= D_In[31:16];                 // Low Address with High Byte
                RAM[Addr_B + 1] <= D_In[15: 0];                 // High Address with Low Byte                
            end
        end
        else begin 
            if ( Half_W ) begin 
                case  ( Byte_Sel ) begin
                    0: begin                                    
                        D_Out <= {RAM[Addr_B], 16'h0};
                    end
                    1:begin 
                        D_Out <= {16'h0, RAM[Addr_B + 1]};
                    end
                endcase  
            end
            else begin 
                D_Out <= {RAM[Addr_B], RAM[Addr_B + 1]};
            end
        end 
    end

endmodule
