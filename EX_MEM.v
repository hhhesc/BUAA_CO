module EX_MEM(
	input req,
	
	input clk,
	input en,
	input reset,
	input[31:0] PC_in,
	output reg[31:0] PC_out,
	input[31:0] instr_in,
	output reg[31:0] instr_out,
	input[31:0] ALURes_in,
	output reg[31:0] ALURes_out,
	input[31:0] RD2_in,
	output reg[31:0] RD2_out,
	input[31:0] MDRes_in,
	output reg[31:0] MDRes_out,
	input sigA_in,
	output reg sigA_out,
	input[4:0] sigB_in,
	output reg[4:0] sigB_out,
	input condition_in,
	output reg condition_out
	);
`include "parameter.v"
	
		always @(posedge clk) begin
			if(reset||req) begin
				PC_out <= 32'h00003000;
				instr_out<=0;
				ALURes_out<=0;
				RD2_out<=0;
				sigA_out<=0;
				sigB_out<=0;
				condition_out<=0;
				MDRes_out<=0;
			end else begin
				if(en)begin
					PC_out<=PC_in;
					instr_out<=instr_in;
					RD2_out<=RD2_in;
					MDRes_out<=MDRes_in;
					ALURes_out<=ALURes_in;
					sigA_out<=sigA_in;
					sigB_out<=sigB_in;
					condition_out<=condition_in;
				end
			end
		end 

endmodule : EX_MEM

	