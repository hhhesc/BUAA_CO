`timescale 1ns / 1ps
module ID_NPC(
    input [2:0] JumpOp,
    input [31:0] PC_IF,
    input [31:0] PC_ID,
    input [15:0] offset,
    input [25:0] index,
    input [31:0] GPRRs,
    input [1:0] CmpRes,
    input[31:0] EPC,
    input ERET,
    output [31:0] PCPlusFour,
    output [31:0] NextPC,
    output [31:0] PCPlusEight
    );
`include "parameter.v"

    assign PCPlusFour = PC_IF+4;
    assign PCPlusEight = PC_IF+8;

    assign NextPC = ((JumpOp==NPC_Beq)&&(CmpRes==ALU_CmpResEqual)) ?PC_ID+4+{{14{offset[15]}},{offset},{2{1'b0}}}: 
                    //如果是beq,则左移两位并零拓展
                    ((JumpOp==NPC_Bne)&&(CmpRes!=ALU_CmpResEqual)) ?PC_ID+4+{{14{offset[15]}},{offset},{2{1'b0}}}: 
                    //如果是bne,则左移两位并零拓展
                    (JumpOp==NPC_Jal)?{{4{1'b0}},{index},{2{1'b0}}}:
                    //J型根据offset计算偏移量
                    (JumpOp==NPC_Jr)?GPRRs:
                    //jr跳转到rs所在的寄存器
                    (ERET)?(EPC+4):
                    PCPlusFour;

endmodule
