`timescale 1ns/1ps
module EX_MD(
	input clk,
	input[31:0] SrcA,
	input[31:0] SrcB,
	input[3:0] MDOp,
	input reset,
	input start,
	output[31:0] MDRes,
	output busy
	); 

`include "parameter.v"	
	reg[31:0] cnt,HI,LO;
	reg[63:0] HILO;
	assign busy = (cnt!=0);

	assign MDRes = (~(start||busy))?(
						(MDOp==MD_Mfhi)?HI: 
						(MDOp==MD_Mflo)?LO: 0
			 	    ):0;

	always@(posedge clk)begin
		if(reset)begin
			HI<=0;
			LO<=0;
			cnt<=0;
			HILO<=0;
		end else begin
			if(start)begin
				case (MDOp)
					MD_Mult:begin
						cnt<=5;
						HILO <= $signed(SrcA)*$signed(SrcB);
					end 
					MD_Multu:begin
						cnt<=5;
						HILO <= SrcA*SrcB;
					end 
					MD_Div:begin
						cnt<=10;
						HILO<={$signed(SrcA)%$signed(SrcB),$signed(SrcA)/$signed(SrcB)};
					end 
					MD_Divu:begin
						cnt<=10;
						HILO<={SrcA%SrcB,SrcA/SrcB};
					end 
					default : /* default */;
				endcase
			end else begin
				if(busy)begin
					cnt<=cnt-1;
					if(cnt==1)begin
						HI<=HILO[63:32];
						LO<=HILO[31:0];
					end
				end else begin
					case (MDOp)
						MD_Mthi:begin
							HI<=SrcA;
						end 
						MD_Mtlo:begin
							LO<=SrcA;
						end 
						default : ;
					endcase
				end
			end
		end
	end

endmodule : EX_MD