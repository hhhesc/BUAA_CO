`timescale 1ns / 1ps
module ID_GRF(
    input clk,
    input reset,
    input RegWrite,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
    input[31:0] PC,
    input[31:0] instr,
    output [31:0] RD1,
    output [31:0] RD2,
    input [31:0] fd
    );

    reg[31:0] Regs[31:0];
    wire FwdA1,FwdA2;
    assign FwdA1 = (A1==A3)&&A3;
    assign FwdA2 = (A2==A3)&&A3;

    assign RD1 =(FwdA1&&RegWrite)?WD:Regs[A1];
    assign RD2 =(FwdA2&&RegWrite)?WD:Regs[A2];

    initial begin
        for(reg[31:0] i=0;i<32;i=i+1)begin
                Regs[i]<=0;
        end
    end

    always @(posedge clk ) begin 
        if(reset) begin
            for(reg[31:0] i=0;i<32;i=i+1)begin
                Regs[i]<=0;
            end
        end else if(RegWrite) begin
            if(A3)begin
                Regs[A3]<=WD;
            end 
        end
    end

endmodule
