`timescale 1ns/1ps
module CDT (
	input clk,    // Clock
	input[31:0] GPRRS,
	input[31:0] GPRRT,
	output reg conditionOri
);

	reg[31:0] i;
	always@(*)begin
		conditionOri=0;
		for(i=0;i<32;i=i+1)begin
			if(GPRRS[i]!=GPRRS[31-i])begin
				break;
			end
		end
		if(i==32) conditionOri<=1;
	end

endmodule 