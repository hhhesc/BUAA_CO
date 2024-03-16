`timescale 1ns / 1ps
module mips(
    input clk,
    input reset,

    output[31:0] i_inst_addr,
    input [31:0] i_inst_rdata,

    input[31:0] m_data_rdata,
    output[31:0] m_data_addr,
    output[31:0] m_data_wdata,
    output[3:0] m_data_byteen,
    output[31:0] m_inst_addr,

    output w_grf_we,
    output[4:0] w_grf_addr,
    output[31:0] w_grf_wdata,
    output[31:0] w_inst_addr 
    );

`include "parameter.v"

    //DEBUG///////////////////////////////////////////////////////////////////////////////////////
    reg[31:0] fd;
    initial begin
        fd=0;
        fd = $fopen("res.txt","w");
    end
    //DEBUG///////////////////////////////////////////////////////////////////////////////////////
    wire[31:0] PC_IF,PC_ID,PC_EX,PC_MEM,PC_WB;
    wire[31:0] instr_ID,instr_EX,instr_MEM,instr_WB;
    wire[1:0] CmpRes_EX,CmpRes_ID;
    wire[31:0] RD1_EX,RD2_EX,ExtRes_EX;
    wire[31:0] ALURes_MEM,RD2_MEM,RD2_EX_New,MDRes,MDRes_MEM,MDRes_WB;
    wire[31:0] ALURes_WB,DMRD_WB;
    wire IF_IDEN,ID_EXEN,EX_MEMEN,MEM_WBEN,IFU_EN,clean_EX;
    wire [31:0] NextPC,instr,PCPlusFour,PCPlusEight,WD,ALURes,RD1,RD2,SrcA,SrcB,DMWD,RD,ExtRes,A,CmpSrcA,CmpSrcB;
    wire RegWrite,WriteRa,WDFromDM,MemWrite,SrcBFromExt,A3FromRt,Store_EX,BDins;
    wire[1:0] len;
    wire [2:0] ExtCtrl;
    wire [4:0] A1,A2,A3,shamt;
    wire[3:0] ALUOp,MDOp;
    wire[2:0] JumpOp,JumpOp_WB;
    wire[31:0] Fwd_Out_EX,Fwd_Out_MEM,Fwd_Out_WB;
    wire stall,start,busy;
    wire[1:0] FwdDM,FwdCmpA,FwdCmpB,FwdALUSrcA,FwdALUSrcB;
    wire FwdLS;
    wire cond_ID,cond_EX,cond_MEM,cond_WB; 
    wire eret_ID,eret_EX,eret_MEM;
    wire[4:0] exccode_IF,exccode_ID,exccode_EX,exccode_MEM,exccode_ID_temp,exccode_EX_temp,exccode_MEM_temp;
    wire req_IF_ID,req_ID_EX,req_EX_MEM,BD_IF,BD_ID,BD_EX,BD_MEM;
//异常处理的流水通路///////////////////////////////////////////////////////////////////////////////////////
//CP0////////////////////////////
    wire CP0_en;
    wire[31:0] EPCOut,CP0Out,CP0In;
    wire[4:0] CP0Add;
    assign CP0Add = instr_MEM[`rd];
    assign CP0In = instr_MEM[`rt];

//req///////////////////////////
assign req_IF_ID = (|exccode_ID)||(|exccode_EX)||(|exccode_MEM);
assign req_ID_EX = (|exccode_EX)||(|exccode_MEM);
assign req_EX_MEM = (|exccode_MEM);
//exccode////////////////////////
assign exccode_ID = ((exccode_ID_temp!=0)&&(exccode_IF==0))?exccode_ID_temp:exccode_IF;
assign exccode_EX = ((exccode_EX_temp!=0)&&(exccode_ID==0))?exccode_EX_temp:exccode_ID;
assign exccode_MEM = ((exccode_MEM_temp!=0)&&(exccode_EX==0))?exccode_MEM_temp:exccode_EX;
//BD/////////////////////////////
Ctrl uut(.instr(instr_ID),.BDins(BDins));
assign BD_IF = BDins;
 
//外接//////////////////////////////////////////////////////////////////////////////////////////////////
    assign i_inst_addr =(eret_ID)?EPCOut : PC_IF;
    assign instr = i_inst_rdata;

    assign m_data_addr = A;
    assign m_inst_addr = PC_MEM;
    assign m_data_wdata = DMWD<<(A[1:0]*8);

    assign w_grf_we = RegWrite;
    assign w_grf_addr = A3;
    assign w_grf_wdata =WD;
    assign w_inst_addr = PC_WB;
//外接//////////////////////////////////////////////////////////////////////////////////////////////////
    //OUT
    wire CalReg_MEM,CalImm_MEM,Load_MEM,Store_MEM,JR_MEM,MD_MEM,Link_MEM,Load_HILO_MEM,newins_MEM,Jump_MEM;
    wire CalReg_WB,CalImm_WB,Load_WB,Store_WB,JR_WB,Load_HILO_WB,Store_HILO_WB,Link_WB,newins_WB,Jump_WB,mfc0_WB;
    Ctrl mips_hcu_jud_mem(
        .instr (instr_MEM),
        .CalReg(CalReg_MEM),
        .CalImm(CalImm_MEM),
        .Load(Load_MEM),
        .Store(Store_MEM),
        .JR(JR_MEM),
        .Link      (Link_MEM),
        .Load_HILO (Load_HILO_MEM),
        .MD(MD_MEM),
        .newinstr(newins_MEM),
        .Jump(Jump_MEM)
        );


    Ctrl mips_hcu_jud_wb(
        .instr (instr_WB),
        .CalReg(CalReg_WB),
        .CalImm(CalImm_WB),
        .Load(Load_WB),
        .Store(Store_WB),
        .Link      (Link_WB),
        .JR(JR_WB),
        .Load_HILO (Load_HILO_WB),
        .Store_HILO(Store_HILO_WB),
        .newinstr(newins_WB),
        .Jump(Jump_WB),
        .MFC0(mfc0_WB)
        );

    assign Fwd_Out_EX = PC_EX+8;
    assign Fwd_Out_MEM = (Link_MEM)?(PC_MEM+8):
                         (Load_HILO_MEM)?(MDRes_MEM): 
                         ALURes_MEM;
    assign Fwd_Out_WB = (Link_WB)?(PC_WB+8):
                        (Load_WB)?DMRD_WB:
                        (Load_HILO_WB)?MDRes_WB:
                        ALURes_WB;

    //ID_GRF|WB_GRF
    assign A1=instr_ID[`rs];
    assign A2=instr_ID[`rt];
    assign A3=  (Link_WB)?31: 
                (A3FromRt)?instr_WB[`rt]:  
                instr_WB[`rd];
    assign WD= (Link_WB)?(PC_WB+8): 
                (WDFromDM)?DMRD_WB: 
                (Load_HILO_WB)?MDRes_WB: 
                (mfc0_WB)?CP0Out: 
                ALURes_WB;

    //ID_NPC
    assign CmpSrcA = (FwdCmpA==1)? Fwd_Out_EX: 
                     (FwdCmpA==2)? Fwd_Out_MEM: 
                     (FwdCmpA==3)? Fwd_Out_WB:
                     RD1;

    assign CmpSrcB = (FwdCmpB==1)? Fwd_Out_EX: 
                     (FwdCmpB==2)? Fwd_Out_MEM: 
                     (FwdCmpB==3)? Fwd_Out_WB:
                     RD2;
    //EX_ALU
    assign SrcA=(FwdALUSrcA==2)? Fwd_Out_MEM: 
                (FwdALUSrcA==1)? Fwd_Out_WB:
                RD1_EX;

	assign SrcB=(FwdALUSrcB==2)? Fwd_Out_MEM: 
                (FwdALUSrcB==1)? Fwd_Out_WB:
                ((SrcBFromExt)?ExtRes_EX:RD2_EX);

    assign shamt = 5'h10;

    assign RD2_EX_New = (FwdLS)? Fwd_Out_WB :RD2_EX;

    //MEM_DM
    assign DMWD=(FwdDM==1)?Fwd_Out_WB:RD2_MEM;
    assign A=ALURes_MEM;

    //HCU////////////////////////////////////////////////////////////////////////////////////////

    HCU hcu(
        .clk       (clk),
        .reset     (reset),
        .instr_ID  (instr_ID),
        .instr_EX  (instr_EX),
        .instr_MEM (instr_MEM),
        .instr_WB  (instr_WB),
        .condition_ID (cond_ID),
        .condition_EX (cond_EX),
        .condition_MEM(cond_MEM),
        .condition_WB (cond_WB),
        .stall     (stall),
        .FwdALUSrcA(FwdALUSrcA),
        .FwdALUSrcB(FwdALUSrcB),
        .FwdDM     (FwdDM),
        .FwdCmpA   (FwdCmpA),
        .FwdCmpB   (FwdCmpB),
        .FwdLS(FwdLS),
        .start(start),
        .busy(busy)
        );

    assign IF_IDEN = ~stall;
    assign clean_EX = stall;
    assign IFU_EN = ~stall;
    
    //IF////////////////////////////////////////////////////////////////////////////////////////
    Ctrl if_ctrl(
        .clk        (clk),
        .instr      (instr),
        .stall (stall),
        .IF_IDEN    (IF_IDEN)
        );

    IF_IFU if_ifu(
        .NextPC(NextPC),
        .clk   (clk),
        .en(IFU_EN),
        .reset (reset),
        .PC    (PC_IF),
        .ExcCode(exccode_IF)
        );

    //IF_ID
    IF_ID if_id(
        .req      (req_IF_ID),
        .reset    (reset),
        .clk      (clk),
        .en       (IF_IDEN),
        .PC_in       (PC_IF),
        .PC_out (PC_ID),
        .instr_in (instr),
        .instr_out(instr_ID),
        .sigA_in  (BD_IF),
        .sigA_out (BD_ID),
        .sigB_in(exccode_IF),
        .sigB_out(exccode_ID)
        );

    //ID////////////////////////////////////////////////////////////////////////////////////////
    Ctrl ID_ctrl(
        .clk        (clk),
        .instr      (instr_ID),
        .ExtCtrl    (ExtCtrl),
        .JumpOp     (JumpOp),
        .ID_EXEN    (ID_EXEN),
        .ExcCode(exccode_ID_temp),
        .ERET(eret_ID)
        );

    CDT conditionuut(
        .clk         (clk),
        .GPRRS       (CmpSrcA),
        .GPRRT       (CmpSrcB),
        .conditionOri(cond_ID)
        );

    ID_NPC id_npc(
        .PC_IF        (PC_IF),
        .PC_ID (PC_ID),
        .NextPC    (NextPC),
        .JumpOp    (JumpOp),
        .offset    (instr_ID[`offset]),
        .index     (instr_ID[`index]),
        .CmpRes    (CmpRes_ID),
        .PCPlusFour(PCPlusFour),
        .PCPlusEight(PCPlusEight),
        .GPRRs     (CmpSrcA),
        .ERET(eret_ID),
        .EPC(EPCOut)
        );


    ID_GRF id_grf(
        .clk     (clk),
        .reset   (reset),
        .RegWrite(RegWrite),
        .A1      (A1),
        .A2      (A2),
        .A3      (A3),
        .WD      (WD),
        .RD1     (RD1),
        .PC      (PC_WB),
        .RD2     (RD2),
        .instr (instr_ID),
        .fd(fd)
        );

    ID_Ext id_ext(
        .ExtCtrl(ExtCtrl),
        .ExtRes (ExtRes),
        .In     (instr_ID[`imm])
        );

    ID_Cmp id_cmp(
        .clk(clk),
        .reset (reset),
        .A (CmpSrcA),
        .B (CmpSrcB),
        .CmpRes (CmpRes_ID)
        );

    //ID_EX
    wire ID_EX_Reset = reset||clean_EX;
    wire[1:0] FwdCmpA_EX;
    ID_EX id_ex(
        .req          (req_ID_EX),
        .clk(clk),
        .reset(ID_EX_Reset),
        .en(ID_EXEN),
        .PC_in(PC_ID),
        .PC_out(PC_EX),
        .instr_in(instr_ID),
        .instr_out(instr_EX),
        .RD1_in(CmpSrcA),
        .RD2_in(CmpSrcB),
        .RD1_out  (RD1_EX),
        .RD2_out  (RD2_EX),
        .Ext_in   (ExtRes),
        .EXt_out  (ExtRes_EX),
        .condition_in (cond_ID),
        .condition_out(cond_EX),
         .sigA_in(BD_ID),
         .sigA_out(BD_EX),
         .sigB_in(exccode_ID),
         .sigB_out(exccode_EX)
        );

    //EX////////////////////////////////////////////////////////////////////////////////////////
    Ctrl ex_ctrl(
        .clk        (clk),
        .instr      (instr_EX),
        .ALUOp      (ALUOp),
        .start(start),
        .SrcBFromExt(SrcBFromExt),
        .EX_MEMEN     (EX_MEMEN),
        .MDOp(MDOp)
        );

    EX_ALU ex_alu(
        .instr(instr_EX),
        .SrcA   (SrcA),
        .SrcB   (SrcB),
        .CmpRes (CmpRes_EX),
        .ALURes (ALURes),
        .ALUCtrl(ALUOp),
        .Shamt  (shamt),
        .ExcCode(exccode_EX_temp)
        );
    EX_MD ex_md(
        .clk(clk),
        .SrcA (SrcA),
        .SrcB (SrcB),
        .reset(reset),
        .MDOp (MDOp),
        .start(start),
        .MDRes(MDRes),
        .busy (busy)
        );

    //EX_MEM
    wire[1:0] FwdCmpA_MEM;
    EX_MEM ex_mem(
        .req(req_EX_MEM),
        .clk       (clk),
        .reset     (reset),
        .en        (EX_MEMEN),
        .PC_in     (PC_EX),
        .PC_out    (PC_MEM),
        .RD2_in    (RD2_EX_New),
        .RD2_out   (RD2_MEM),
        .instr_in  (instr_EX),
        .instr_out (instr_MEM),
        .ALURes_in (ALURes),
        .ALURes_out(ALURes_MEM),
        .MDRes_in (MDRes),
        .MDRes_out(MDRes_MEM),
        .condition_in (cond_EX),
        .condition_out(cond_MEM),
         .sigA_in(BD_EX),
         .sigA_out(BD_MEM),
         .sigB_in(exccode_EX),
         .sigB_out(exccode_MEM)
        );

    //MEM//////////////////////////////////////////////////////////////////////////////////////// 
    assign m_data_byteen =  ((len==DM_Word32)&&MemWrite)?4'b1111: 
                            ((len==DM_HalfWord16)&&MemWrite)?(
                                (A[1:0]==2'b00)?4'b0011: 
                                (A[1:0]==2'b10)?4'b1100: 
                                4'b0000
                            ):((len==DM_Byte8)&&MemWrite)?(
                                (A[1:0]==2'b00)?4'b0001: 
                                (A[1:0]==2'b01)?4'b0010: 
                                (A[1:0]==2'b10)?4'b0100: 
                                (A[1:0]==2'b11)?4'b1000: 
                                4'b0000
                            ):4'b0000;
    Ctrl mem_ctrl(
        .clk        (clk),
        .instr(instr_MEM),
        .MemWrite   (MemWrite),
        .len        (len),
        .MEM_WBEN   (MEM_WBEN),
        .CP0Write(CP0_en)
        ); 

    BE be(
        .len(len),
        .A(A),
        .Din          (m_data_rdata),
        .Dout         (RD)
        );
    //CP0////////////////////

    MEM_CP0 cp0(
        .clk      (clk),
        .reset    (reset),
        .en       (CP0_en),
        .VPC      (PC_MEM),
        .BDIn     (BD_MEM),
        .ExcCodeIn(exccode_MEM),
        .EXLClr   (eret_MEM),
        .EPCOut   (EPCOut),
        .CP0Out   (CP0Out),
        .CP0Add   (CP0Add),
        .CP0In    (CP0In)

        );
    //CP0////////////////////

    //MEM_WB
    MEM_WB mem_wb(
        .clk     (clk),
        .reset   (reset),
        .en      (MEM_WBEN),
        .PC_in   (PC_MEM),
        .PC_out  (PC_WB),
        .DMRD_in (RD),
        .DMRD_out(DMRD_WB),
        .ALURes_in (ALURes_MEM),
        .ALURes_out(ALURes_WB),
        .instr_in  (instr_MEM),
        .instr_out (instr_WB),
        .MDRes_in(MDRes_MEM),
        .MDRes_out(MDRes_WB),
        .condition_in (cond_MEM),
        .condition_out(cond_WB)
        // .sigA_in(),
        // .sigA_out(),
        // .sigB_in(),
        // .sigB_out()
        );

    //WB////////////////////////////////////////////////////////////////////////////////////////
    Ctrl wb_ctrl(
        .clk        (clk),
        .instr(instr_WB),
        .RegWrite   (RegWrite),
        .A3FromRt   (A3FromRt),
        .WriteRa    (WriteRa),
        .WDFromDM   (WDFromDM),
        .JumpOp (JumpOp_WB),
        .condition(cond_WB)
        );


endmodule
