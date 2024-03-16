`timescale 1ns / 1ps
module DM(
    input Clk,
    input MemWrite,
    input [31:0] A,
    input [31:0] WD,
    input [1:0] Len,
    input reset,
    input[31:0] PC,
    output [31:0] RD,
    input[31:0] fd
    );
`include "parameter.v"

    reg[31:0] Mem[3071:0];

    assign RD = Len==DM_Word32?Mem[A[13:2]]:
                Len==DM_HalfWord16?(
                    (A[1:0] == 2'b00)?{{16{Mem[A[13:2]][15]}},{Mem[A[13:2]][15:0]}}:
                    {{16{Mem[A[13:2]][31]}},{Mem[A[13:2]][31:16]}}
                ):
                Len==DM_Byte8?(
                    (A[1:0] == 2'b00)?{{24{Mem[A[13:2]][7]}},{Mem[A[13:2]][7:0]}}:
                    (A[1:0]==2'b01)?{{24{Mem[A[13:2]][15]}},{Mem[A[13:2]][15:8]}}:
                    (A[1:0] == 2'b10)?{{24{Mem[A[13:2]][23]}},{Mem[A[13:2]][23:16]}}:
                    (A[1:0] == 2'b11)?{{24{Mem[A[13:2]][31]}},{Mem[A[13:2]][31:24]}}:
                    0
                ):
                0;

    initial begin
        for(reg[31:0] i=0;i<3072;i=i+1) Mem[i]<=0;
    end

    always @(posedge Clk) begin
        if(reset)begin
            for(reg[31:0] i=0;i<3072;i=i+1)begin
                Mem[i]<=0;
            end
        end else if(MemWrite)begin
            case (Len)
                DM_Word32:begin 
                    Mem[A[13:2]] <=WD;
                    //'@0000312c: * 00000000 <= ffffca20
                    $display("%d@%h: *%h <= %h",$time, PC, A, WD);
                    if(fd) $fdisplay(fd,"@%h: *%h <= %h", PC, A, WD);
                end 
                DM_HalfWord16:begin
                    case (A[1:0])
                        2'b00: begin 
                            Mem[A[13:2]][15:0]<=WD[15:0];
                            $display("%d@%h: *%h <= %h",$time, PC, A, {{Mem[A[13:2]][31:16]},{WD[15:0]}});
                            if(fd) $fdisplay(fd,"@%h: *%h <= %h", PC, A, {{Mem[A[13:2]][31:16]},{WD[15:0]}});
                        end 
                        2'b10:begin 
                            Mem[A[13:2]][31:16]<=WD[15:0];
                            $display("%d@%h: *%h <= %h",$time, PC, A, {{WD[15:0]},{Mem[A[13:2]][15:0]}});
                            if(fd) $fdisplay(fd,"@%h: *%h <= %h", PC, A, {{WD[15:0]},{Mem[A[13:2]][15:0]}});
                        end 
                        default : /* default */;
                    endcase
                end 
                DM_Byte8:begin
                    case (A[1:0])
                        2'b00: begin
                            Mem[A[13:2]][7:0]<=WD[7:0];
                            $display("@%h: *%h <= %h", PC, A, {{Mem[A[13:2]][31:8]},{WD[7:0]}});
                            if(fd) $fdisplay(fd,"@%h: *%h <= %h", PC, A, {{Mem[A[13:2]][31:8]},{WD[7:0]}});
                        end 
                        2'b01: begin
                            Mem[A[13:2]][15:8]<=WD[7:0];
                            $display("@%h: *%h <= %h", PC, A, {{Mem[A[13:2]][31:16]},{WD[7:0]},{Mem[A[13:2]][7:0]}});
                            if(fd) $fdisplay(fd,"@%h: *%h <= %h", PC, A, {{Mem[A[13:2]][31:16]},{WD[7:0]},{Mem[A[13:2]][7:0]}});
                        end 
                        2'b10: begin
                            Mem[A[13:2]][23:16]<=WD[7:0];
                            $display("@%h: *%h <= %h", PC, A, {{Mem[A[13:2]][31:24]},{WD[7:0]},{Mem[A[13:2]][15:0]}});
                            if(fd) $fdisplay(fd,"@%h: *%h <= %h", PC, A, {{Mem[A[13:2]][31:24]},{WD[7:0]},{Mem[A[13:2]][15:0]}});
                        end 
                        2'b11: begin
                            Mem[A[13:2]][31:24]<=WD[7:0];  
                            $display("@%h: *%h <= %h", PC, A, {{WD[7:0]},{Mem[A[13:2]][23:0]}});
                            if(fd) $fdisplay(fd,"@%h: *%h <= %h", PC, A, {{WD[7:0]},{Mem[A[13:2]][23:0]}});
                        end                   
                        default : /* default */;
                    endcase
                end 
            endcase
        end
    end
endmodule
