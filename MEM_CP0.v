module MEM_CP0 (
	input clk,    // Clock
	input en, //写使能
	input reset,  
	input[4:0] CP0Add,
	input[31:0] CP0In,
	output[31:0] CP0Out,
	input[31:0] VPC,//受害PC
	input BDIn,//是否是延迟槽指令
	input[4:0] ExcCodeIn,//异常类型
	input[5:0] HWInt,//输入中断信号
	input EXLClr,//复位
	output[31:0] EPCOut,
	output Req
);

	`include "parameter.v"
	reg[31:0] SR,Cause,EPC;

	wire inExc;//是否处于异常的指示信号

	assign inExc = (|ExcCodeIn)&&(!SR[`EXL]);
	//assign inInt = ()

//SR////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
	always @(posedge clk)begin
		if(reset)begin
			SR<=0;
		end else begin
			if(EXLClr) SR[`EXL]<=0;
			else if(inExc)begin
				SR[`EXL]<=1;
			end 
			else if(en&&(CP0Add==12))begin
				SR<=CP0In;
			end
		end
	end

//Cause//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	always @(posedge clk)begin
		if(reset)begin
			Cause<=0;
		end else begin
			if(inExc)begin
				Cause[`BD]<=BDIn;
				Cause[`ExcCode] <= ExcCodeIn;
			end else if(en&&(CP0Add==13))begin
				Cause<=CP0In;
			end
			Cause[`IP]<=HWInt;
		end
	end

//EPC////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	always @(posedge clk)begin
		if(reset)begin
			EPC<=0;
		end else begin
			if(inExc)begin
				if(BDIn) EPC<=(VPC-4);
				else EPC<=VPC;
			end
		end
	end

//read///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	assign CP0Out=(CP0Add==12)?SR: 
				  (CP0Add==13)?Cause: 
				  (CP0Add==14)?EPC:0;
	assign EPCOut = EPC;

	initial begin
		SR<=0;
		Cause<=0;
		EPC<=0;
	end

endmodule