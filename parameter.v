	parameter

	Ext_ZeroExt = 0,
	Ext_LeftShiftForTwo = 1,
	Ext_SignExt = 2,
	Ext_Lui = 3,
	Ext_OneExt = 4,


	ALU_Add = 0,
	ALU_Sub = 1,
	ALU_And = 2,
	ALU_Or = 3,
	ALU_Shift = 4,
	ALU_Slt = 5,
	ALU_Sltu = 6,
	ALU_Cmp = 15,
	ALU_CmpResLess = 2,
	ALU_CmpResEqual = 1,
	ALU_CmpResGreater = 0,

	MD_Free = 0,
	MD_Mult = 1,
	MD_Multu = 2,
	MD_Div = 3,
	MD_Divu = 4,
	MD_Mfhi = 5,
	MD_Mflo = 6,
	MD_Mthi = 7,
	MD_Mtlo = 8,

	Cmp_CmpResLess = 2,
	Cmp_CmpResEqual = 1,
	Cmp_CmpResGreater = 0,

	NPC_Beq = 1,
	NPC_Jal = 2,
	NPC_Jr = 3,
	NPC_Bne = 4,

	DM_Word32 = 3,
	DM_HalfWord16 = 1,
	DM_Byte8 = 2;

`define rs  25:21
`define rt  20:16
`define rd  15:11
`define offset 15:0 
`define index 25:0 
`define op 31:26
`define funct 5:0 
`define imm 15:0

`define IM 15:10
`define EXL 1
`define IE 0
`define BD 31
`define IP 15:10
`define ExcCode 6:2 
