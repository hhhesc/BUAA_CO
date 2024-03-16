`timescale 1ns / 1ps
module IF_IFU(
    input clk,
    input [31:0] NextPC,
    input reset,
    input en,
    output reg[31:0] PC,

    output reg[4:0] ExcCode
    );
	 
	 
	 always @(posedge clk)begin
		if(reset)begin
            PC<=32'h00003000;
        end else begin
            if(en)begin
                if((NextPC[1:0]!=0)||(NextPC>32'h00006ffc)||(NextPC<32'h00003000))begin
                    ExcCode<=4;
                end else
                PC<=NextPC;
            end
		end
    end

endmodule
