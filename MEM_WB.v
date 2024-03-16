module MEM_WB (
	input clk,    // Clock
	input reset,
	input en,
	input[31:0] PC_in,
	output reg[31:0] PC_out,
	input[31:0] DMRD_in,
	output reg[31:0] DMRD_out,
	input[31:0] ALURes_in,
	output reg[31:0] ALURes_out,
	input[31:0] instr_in,
	output reg[31:0] instr_out,
	input[31:0] MDRes_in,
	output reg[31:0] MDRes_out,
	input sigA_in,
	output reg sigA_out,
	input[31:0] sigB_in,
	output reg[31:0] sigB_out,
	input condition_in,
	output reg condition_out
);

		always @(posedge clk ) begin
			if(reset) begin
				PC_out <= 32'h00003000;
				DMRD_out<=0;
				ALURes_out<=0;
				instr_out<=0;
				MDRes_out<=0;
				sigA_out<=0;
				sigB_out<=0;
				condition_out<=0;
			end else begin
				if(en)begin
					PC_out<=PC_in;
					DMRD_out<=DMRD_in;
					ALURes_out<=ALURes_in;
					instr_out<=instr_in;
					MDRes_out<=MDRes_in;
					sigA_out<=sigA_in;
					sigB_out<=sigB_in;
					condition_out<=condition_in;
				end
			end
		end

endmodule : MEM_WB