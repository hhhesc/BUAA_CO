`timescale 1ns / 1ps
module BE(
	input[31:0] Din,
	input[31:0] A,
	input[1:0] len,
	output[31:0] Dout
	);
`include "parameter.v"
wire[3:0] m_data_byteen;

assign m_data_byteen =  (len==DM_Word32)?4'b1111: 
                            ((len==DM_HalfWord16))?(
                                (A[1:0]==2'b00)?4'b0011: 
                                (A[1:0]==2'b10)?4'b1100: 
                                4'b0000
                            ):((len==DM_Byte8))?(
                                (A[1:0]==2'b00)?4'b0001: 
                                (A[1:0]==2'b01)?4'b0010: 
                                (A[1:0]==2'b10)?4'b0100: 
                                (A[1:0]==2'b11)?4'b1000: 
                                4'b0000
                            ):4'b0000;

	assign Dout = (m_data_byteen==4'b1111)?Din: 
				  (m_data_byteen==4'b0011)?{{16{Din[15]}},{Din[15:0]}}: 
				  (m_data_byteen==4'b1100)?{{16{Din[31]}},{Din[31:16]}}:  
				  (m_data_byteen==4'b0001)?{{24{Din[7]}},{Din[7:0]}}: 
				  (m_data_byteen==4'b0010)?{{24{Din[15]}},{Din[15:8]}}: 
				  (m_data_byteen==4'b0100)?{{24{Din[23]}},{Din[23:16]}}: 
				  (m_data_byteen==4'b1000)?{{24{Din[31]}},{Din[31:24]}}: 
				  0;

endmodule : BE