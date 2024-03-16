`timescale 1ns / 1ps
module EX_ALU(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [3:0] ALUCtrl,
    input [4:0] Shamt,
    output [31:0] ALURes,
    output [1:0] CmpRes,
    input[31:0] instr,

    output[4:0] ExcCode
    );

`include "parameter.v"
wire load,store;
Ctrl uut(.instr(instr),.Load(load),.Store(store));

reg[31:0] i,cnt;
reg[32:0] temp,a,b;
reg Add_overflow,Sub_overflow;

always@(*)begin
    Add_overflow=0;
    a={{SrcA[31]},{SrcA}};
    b={{SrcB[31]},{SrcB}};
    temp=a+b;
    Add_overflow = (temp[32]!=temp[31]);
    temp = a-b;
    Sub_overflow = (temp[32]!=temp[31]);
end

    assign ExcCode = (((ALUCtrl==ALU_Add)&&(Add_overflow)&&(!load)&&(!store))||((ALUCtrl==ALU_Sub)&&(Sub_overflow)))?12:
                     ((ALUCtrl==ALU_Add)&&load)?4:
                     ((ALUCtrl==ALU_Add)&&store)?5:0;

    assign ALURes = ALUCtrl==ALU_Add?SrcA+SrcB:
                    ALUCtrl==ALU_Sub?SrcA-SrcB: 
                    ALUCtrl==ALU_And?SrcA&SrcB: 
                    ALUCtrl==ALU_Or?SrcA|SrcB: 
                    ALUCtrl==ALU_Slt?($signed(SrcA)<$signed(SrcB)): 
                    ALUCtrl==ALU_Sltu?(SrcA<SrcB):
                    ALUCtrl==ALU_Shift?SrcB<<Shamt: 
                    0;

    assign CmpRes = ALUCtrl==ALU_Cmp?(
                        SrcA>SrcB?ALU_CmpResGreater: 
                        SrcA==SrcB?ALU_CmpResEqual: 
                        SrcA<SrcB?ALU_CmpResLess : 
                        0
                    ):0;


endmodule
