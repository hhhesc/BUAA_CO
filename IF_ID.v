module IF_ID (
	input req,

	input clk,    
	input reset, 
	input en,  
	input[31:0] PC_in,
	input[31:0] instr_in,
	output reg[31:0] instr_out,
	output reg[31:0] PC_out,
	input sigA_in,
	output reg sigA_out,
	input[4:0] sigB_in,
	output reg[4:0] sigB_out
);

	always @(posedge clk) begin
		if(reset||req) begin
			instr_out <= 0;
			PC_out <= 32'h00003000;
			sigA_out<=0;
			sigB_out<=0;
		end else begin
			if(en)begin
				instr_out <= instr_in;
				PC_out <= PC_in;
				sigA_out<=sigA_in;
				sigB_out<=sigB_in;
			end
		end
	end

endmodule : IF_ID