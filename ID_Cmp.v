module ID_Cmp (
	input clk,    // Clock
	input reset,
	input[31:0] A,
	input[31:0] B,
	output[1:0] CmpRes
);
`include "parameter.v"
	
	assign CmpRes = (A>B)?Cmp_CmpResGreater:
					(A==B)?Cmp_CmpResEqual: 
					Cmp_CmpResLess;

endmodule : ID_Cmp