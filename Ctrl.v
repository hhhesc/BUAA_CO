`timescale 1ns / 1ps
module Ctrl(
    input clk,
    input[31:0] instr,
    input stall,
    input condition,
    output RegWrite,
    output [2:0] ExtCtrl,
    output MemWrite,
    output [3:0] ALUOp,
    output SrcBFromExt,
    output WDFromDM,
    output A3FromRt,
    output WriteRa,
    output [1:0] len,
    output[2:0] JumpOp,
    output [3:0] MDOp,
    output start,
    output CalImm,
    output CalReg,
    output Jump,
    output Link,
    output Load,
    output Store,
    output Load_HILO,
    output Store_HILO,
    output Branch,
    output JR,
    output MD,
    output BDins,
    output ERET,
    output MFC0,
    output MTC0,
    output CP0Write,
    output newinstr,
    output IF_IDEN,
    output ID_EXEN,
    output EX_MEMEN,
    output MEM_WBEN,

    output [4:0] ExcCode
    );

//DEFINE///////////////////////////////////////////////////////////////////////////////////////////////////////////////
 wire[5:0] Op,funct;
    assign Op = instr[31:26];
    assign funct =instr[5:0];


     wire add,sub,lui,lw,sw,beq,jal,lh,lb,sh,sb,ins_and,ins_or,slt,sltu,addi,andi,ori,mult;
     wire multu,div,divu,mfhi,mflo,mthi,mtlo,newins,eret,mfc0,mtc0;
     assign newins = Op==6'b110110;
     assign newinstr = newins;
    //cal_reg $rd,$rs,$rt
    assign add = ((Op == 6'b000000 && funct == 6'b100001)||(Op == 6'b000000 && funct == 6'b100000));
    assign sub = ((Op == 6'b000000 && funct == 6'b100011)||(Op == 6'b000000 && funct == 6'b100010));
    assign ins_and = (Op == 6'b000000 && funct == 6'b100100);
    assign ins_or = (Op == 6'b000000 && funct == 6'b100101);
    assign slt = (Op == 6'b000000 && funct == 6'b101010);
    assign sltu = (Op == 6'b000000 && funct == 6'b101011);
    //cal_imm $rs,$rt,imm
    assign ori = (Op===6'b001101);
    assign lui = (Op===6'b001111);//rs==0
    assign addi = (Op===6'b001000||Op==6'b001001);
    assign andi = (Op===6'b001100);
    assign ori = (Op===6'b001101);
    //load mem $rt,imm($rs)
    assign lw = (Op===6'b100011);
    assign lh = (Op==6'b100001);
    assign lb = (Op==6'b100000);
    //store mem $rt,imm($rs)
    assign sw = (Op===6'b101011);
    assign sh = (Op==6'b101001);
    assign sb = (Op==6'b101000);
    //branch $rs,$rt,offset
    assign beq = (Op===6'b000100);
    assign bne = (Op===6'b000101);
    //jump index
    assign jal = (Op===6'b000011);
    //jr $rs
    assign jr = (Op===6'b000000)&&(funct===6'b001000);
    //MD $rs,$rt
    assign mult = (Op===6'b000000)&&(funct===6'b011000);
    assign multu = (Op===6'b000000)&&(funct===6'b011001);
    assign div = (Op===6'b000000)&&(funct===6'b011010);
    assign divu = (Op===6'b000000)&&(funct===6'b011011);
    //mf $rs
    assign mfhi = (Op===6'b000000)&&(funct===6'b010000);
    assign mflo = (Op===6'b000000)&&(funct===6'b010010);
    //mt $rs
    assign mthi = (Op===6'b000000)&&(funct===6'b010001);
    assign mtlo = (Op===6'b000000)&&(funct===6'b010011);
    //eret
    assign eret = (Op==6'b010000)&&(funct==6'b011000);
    //mfc0
    assign mfc0 = (Op==6'b010000)&&(instr[25:21]==5'b00000);
    //mtc0
    assign mtc0 = (Op==6'b010000)&&(instr[25:21]==5'b00100);

`include "parameter.v"

    assign CalReg = add||sub||ins_and||ins_or||slt||sltu;//calreg $rd,$rs,$rt
    assign CalImm = ori||lui||addi||andi;//calimm $rt,$rs,imm lui(rs==0)
    assign Load = lw||lh||lb;//lw $rt,imm($rs)
    assign Store = sw||sh||sb;//sw $rt,imm($rs)
    assign Branch = beq||bne;//beq $rs,$rt,label
    assign JR = jr;//jr $rs
    assign Jump = jal;//jump index
    assign Link = jal;//$31<-PC+4
    assign MD = mult||multu||div||divu;//mult $rs,$rt
    assign Load_HILO = mfhi||mflo;//mf $rs
    assign Store_HILO = mthi||mtlo;//mt $rs
    assign ERET = eret;
    assign MFC0 = mfc0;
    assign MTC0 = mtc0;

    assign BDIns = Branch||Jump||JR;
//DEFINE///////////////////////////////////////////////////////////////////////////////////////////////////////////////

assign EXcCode = (CalImm||CalReg||Load_HILO||Load||Store||ERET||MFC0||MTC0
    ||Store_HILO||Link||Jump||JR||MD||Branch||((Op==0)&&(funct==0)))?10:0;

//Exc//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    assign RegWrite = CalImm||CalReg||Load_HILO||Load||Link||MFC0;

    assign MemWrite = Store;

    assign A3FromRt = CalImm||Load||MFC0;

    assign start = MD;

    assign WDFromDM = Load;

    assign SrcBFromExt = CalImm||Load||Store;

    assign CP0Write = MTC0;

//Ctrl inside module////////////////////////////////////////////

    assign ExtCtrl = (Load||Store||addi)?Ext_SignExt: 
                     (Branch)?Ext_LeftShiftForTwo: 
                     (0)?Ext_OneExt:
                     Ext_ZeroExt;

    assign ALUOp =  (add)?ALU_Add: 
                    (sub)?ALU_Sub: 
                    (andi||ins_and)?ALU_And:
                    (ori||ins_or)?ALU_Or: 
                    (lui)?ALU_Shift: 
                    (slt)?ALU_Slt: 
                    (sltu)?ALU_Sltu:
                    (beq)?ALU_Cmp: 
                    4'b0000;//默认是加法

    assign MDOp = (mult)?MD_Mult: 
                  (multu)?MD_Multu: 
                  (div)?MD_Div: 
                  (divu)?MD_Divu: 
                  (mfhi)?MD_Mfhi: 
                  (mflo)?MD_Mflo: 
                  (mthi)?MD_Mthi: 
                  (mtlo)?MD_Mtlo: 
                  MD_Free;


    assign JumpOp = beq?NPC_Beq:
                    jal?NPC_Jal: 
                    jr?NPC_Jr: 
                    bne?NPC_Bne: 
                    3'b000;

    assign len =(lw||sw)?DM_Word32: 
                (lh||sh)?DM_HalfWord16:
                (sb||lb)?DM_Byte8:
                0;

    assign IF_IDEN = ~stall;
    assign ID_EXEN = 1;
    assign EX_MEMEN = 1;
    assign MEM_WBEN = 1;

endmodule