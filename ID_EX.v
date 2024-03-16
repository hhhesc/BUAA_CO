module ID_EX (
	input req,

	input clk,    // Clock
	input reset,
	input en,
	input[31:0] instr_in,
	input [31:0] RD1_in,
	input [31:0] RD2_in,
	input[31:0] PC_in,
	output reg[31:0] RD1_out,
	output reg[31:0] RD2_out,
	output reg[31:0] instr_out,
	output reg[31:0] PC_out,
	input [31:0] Ext_in,
	output reg[31:0] EXt_out,
	input sigA_in,
	output reg sigA_out,
	input[4:0] sigB_in,
	output reg[4:0] sigB_out,
	input condition_in,
	output reg condition_out
);

		always @(posedge clk ) begin
			if(reset||req) begin
				instr_out <= 0;
				RD1_out <= 0;
				RD2_out <=0;
				PC_out <= 32'h00003000;
				EXt_out<=0;
				sigA_out<=0;
				sigB_out<=0;
				condition_out<=0;
			end else begin
				if(en)begin
					instr_out <= instr_in;
					RD1_out <= RD1_in;
					RD2_out <= RD2_in;
					PC_out <= PC_in;
					EXt_out <=Ext_in;
					sigA_out<=sigA_in;
					sigB_out<=sigB_in;
					condition_out<=condition_in;
				end
			end
		end 


endmodule : ID_EX