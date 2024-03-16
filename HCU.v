module HCU (
	input clk,    // Clock
	input reset,
	input[31:0] instr_ID,
	input[31:0] instr_EX,
	input[31:0] instr_MEM,
	input[31:0] instr_WB,
	input start,
	input busy,
	input condition_ID,
	input condition_EX,
	input condition_MEM,
	input condition_WB,
	output[1:0] FwdALUSrcA,
	output[1:0] FwdALUSrcB,
	output[1:0] FwdCmpA,
	output[1:0] FwdCmpB,
	output[1:0] FwdDM,
	output FwdLS,
	output stall
);
`include "parameter.v"
	wire CalReg_ID,CalReg_EX,CalReg_MEM,CalReg_WB;
	wire CalImm_ID,CalImm_EX,CalImm_MEM,CalImm_WB;
	wire Load_ID,Load_EX,Load_MEM,Load_WB;
	wire Store_ID,Store_EX,Store_MEM,Store_WB;
	wire Branch_ID,Branch_EX,Branch_MEM,Branch_WB;
	wire Jump_ID,Jump_EX,Jump_MEM,Jump_WB;
	wire JR_ID,JR_EX,JR_MEM,JR_WB;
	wire Link_ID,Link_EX,Link_MEM,Link_WB;
	wire MD_ID,MD_EX,MD_MEM,MD_WB;
	wire Load_HILO_ID,Load_HILO_EX,Load_HILO_MEM,Load_HILO_WB;
	wire Store_HILO_ID,Store_HILO_EX,Store_HILO_MEM,Store_HILO_WB;
	wire newins_ID,newins_EX,newins_MEM,newins_WB;

	wire[4:0] tar_EX,tar_MEM,tar_WB;

	HCU_JUD hcu_jud_id(
		.instr (instr_ID),
		.CalReg(CalReg_ID),
		.CalImm(CalImm_ID),
		.Load(Load_ID),
		.Store(Store_ID),
		.Branch(Branch_ID),
		.Jump      (Jump_ID),
		.JR(JR_ID),
		.Link(Link_ID),
		.MD(MD_ID),
		.Load_HILO(Load_HILO_ID),
		.Store_HILO(Store_HILO_ID),
		.newinstr(newins_ID)
		);

	HCU_JUD hcu_jud_ex(
		.instr (instr_EX),
		.CalReg(CalReg_EX),
		.CalImm(CalImm_EX),
		.Load(Load_EX),
		.Store(Store_EX),
		.Branch(Branch_EX),
		.Jump      (Jump_EX),
		.JR(JR_EX),
		.Link  (Link_EX),
		.tar(tar_EX),
		.MD(MD_EX),
		.Load_HILO(Load_HILO_EX),
		.Store_HILO(Store_HILO_EX),
		.newinstr(newins_EX)
		);

	HCU_JUD hcu_jud_mem(
		.instr (instr_MEM),
		.CalReg(CalReg_MEM),
		.CalImm(CalImm_MEM),
		.Load(Load_MEM),
		.Store(Store_MEM),
		.Branch(Branch_MEM),
		.Jump      (Jump_MEM),
		.JR(JR_MEM),
		.Link  (Link_MEM),
		.tar(tar_MEM),
		.MD(MD_MEM),
		.Load_HILO(Load_HILO_MEM),
		.Store_HILO(Store_HILO_MEM),
		.newinstr(newins_MEM)
		);

	HCU_JUD hcu_jud_wb(
		.instr (instr_WB),
		.CalReg(CalReg_WB),
		.CalImm(CalImm_WB),
		.Load(Load_WB),
		.Store(Store_WB),
		.Branch(Branch_W),
		.Jump(Jump_WB),
		.JR(JR_WB),
		.Link  (Link_WB),
		.tar(tar_WB),
		.MD(MD_WB),
		.Load_HILO(Load_HILO_WB),
		.Store_HILO(Store_HILO_WB),
		.newinstr(newins_WB)
		);

	wire[2:0] TUse_Rs,TUse_Rt;
	wire[2:0] TNew_EX,TNew_MEM,TNew_WB;

	assign TUse_Rs = (Branch_ID||JR_ID)?0:
					 (CalImm_ID||CalReg_ID||Load_ID||Store_ID||MD_ID||Store_HILO_ID)?1: 
					 3;
	assign TUse_Rt = (Branch_ID)?0:
					 (CalReg_ID||MD_ID)?1: 
					 (Store_ID)?2: 
					 3;

	assign TNew_EX = (CalReg_EX||CalImm_EX||Load_HILO_EX)?1: 
					(Load_EX)?2: 
					0;

	assign TNew_MEM = (Load_MEM)?1:0;
	assign TNew_WB = 0;
//stall/////////////////////////////////////////////////////////////////////////////////////////////////////
	wire stall_rs_EX = (TUse_Rs < TNew_EX) && (instr_ID[`rs] && instr_ID[`rs]  == tar_EX);
    wire stall_rs_MEM = (TUse_Rs < TNew_MEM) && (instr_ID[`rs]  && instr_ID[`rs]  == tar_MEM);
    
	wire stall_rt_EX = (TUse_Rt < TNew_EX) && (instr_ID[`rt] && instr_ID[`rt]  == tar_EX);
    wire stall_rt_MEM = (TUse_Rt < TNew_MEM) && (instr_ID[`rt]  && instr_ID[`rt]  == tar_MEM);

    wire stall_md = (start||busy)&&(MD_ID||Load_HILO_ID||Store_HILO_ID);//Store也应该阻塞，可能只写了单个值

    assign stall = stall_rs_EX||stall_rs_MEM||stall_rt_EX||stall_rt_MEM||stall_md;
//forward///////////////////////////////////////////////////////////////////////////////////////////////////

	assign FwdALUSrcA = ((TNew_MEM==0)&&(tar_MEM==instr_EX[`rs])&&(tar_MEM))?2: 
						((TNew_WB==0)&&(tar_WB==instr_EX[`rs])&&(tar_WB))?1:0;
	assign FwdALUSrcB = ((TNew_MEM==0)&&(tar_MEM==instr_EX[`rt])&&(tar_MEM)&&(CalReg_EX||MD_EX))?2:
						((TNew_WB==0)&&(tar_WB==instr_EX[`rt])&&(tar_WB)&&(CalReg_EX||MD_EX))?1:0;

	assign FwdCmpA = ((TNew_EX==0)&&(tar_EX==instr_ID[`rs])&&(tar_EX))?1:
					 ((TNew_MEM==0)&&(tar_MEM==instr_ID[`rs])&&(tar_MEM))?2:
					 ((TNew_WB==0)&&(tar_WB==instr_ID[`rs])&&(tar_WB))?3:0;
 					 
	assign FwdCmpB = ((TNew_EX==0)&&(tar_EX==instr_ID[`rt])&&(tar_EX))?1:
					 ((TNew_MEM==0)&&(tar_MEM==instr_ID[`rt])&&(tar_MEM))?2:
					 ((TNew_WB==0)&&(tar_WB==instr_ID[`rt])&&(tar_WB))?3:
					 0;

	assign FwdDM = ((TNew_WB==0)&&(tar_WB==instr_MEM[`rt])&&(tar_WB)&&Store_MEM)?1:0;

	assign FwdLS = ((tar_WB==instr_EX[`rt])&&(tar_WB)&&Store_EX&&Load_WB)?1:0;

endmodule : HCU