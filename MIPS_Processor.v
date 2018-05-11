/******************************************************************
* Description
*	This is the top-level of a MIPS processor that can execute the next set of instructions:
*		add
*		addi
*		sub
*		ori
*		or
*		bne
*		beq
*		and
*		nor
* This processor is written Verilog-HDL. Also, it is synthesizable into hardware.
* Parameter MEMORY_DEPTH configures the program memory to allocate the program to
* be execute. If the size of the program changes, thus, MEMORY_DEPTH must change.
* This processor was made for computer organization class at ITESO.
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	12/06/2016
******************************************************************/


module MIPS_Processor
#(
	parameter MEMORY_DEPTH = 54
)

(
	// Inputs
	input clk,
	input reset,
	input [7:0] PortIn,
	// Output
	output [31:0] ALUResultOut,
	output [31:0] PortOut
);
//******************************************************************/
//******************************************************************/


//******************************************************************/
//******************************************************************/
// Data types to connect modules

//ALU CONTROL
wire BranchNE_wire;
wire BranchEQ_wire;
wire RegDst_wire;
wire NotZeroANDBrachNE;
wire ZeroANDBrachEQ;
wire ORForBranch;
wire ALUSrc_wire;
wire RegWrite_wire;
wire Zero_wire;
wire Jump_wire;
wire MemRead_wire;
wire MemtoReg_wire;
wire MemWrite_wire;
wire Jr_wire;
wire Jal_wire;


wire [2:0] ALUOp_wire;
wire [3:0] ALUOperation_wire;
wire [4:0] WriteRegister_wire;
wire [4:0] MUX_ForRTypeAndIType_wire;

//wire [31:0] MUX_PC_wire; 
wire [31:0]	PC_wire;
wire [31:0] Instruction_wire;
wire [31:0] ReadData1_wire;
wire [31:0] ReadData2_wire;
wire [31:0] InmmediateExtend_wire;
wire [31:0] PC_InmmediateExtend_wire;
wire [31:0] MUX_PC_InmmediateExtend_wire;
wire [31:0] ReadData2OrInmmediate_wire;
wire [31:0] ALUResult_wire;
wire [31:0] PC_4_wire;


wire  PCtoBranch_wire;
wire [31:0] ReadData_wire;
wire [31:0] MUX_RegisterFile_wire;
wire [31:0] MUX_WriteData_wire;
//wire [31:0] MUX_Jump_wire;



//Pipeline IF to ID
wire [31:0]IF_PC_4_wire_ID;
wire [31:0]IF_Instruction_wire_ID;


//Pipeline ID to EX
wire ID_Jump_wire_EX;//1
wire ID_RegDst_wire_EX;//1
wire ID_BranchNE_wire_EX;//1
wire ID_BramchEQ_wire_EX;//1
wire [2:0]ID_ALUOp_wire_EX;//3
wire ID_ALUSrc_wire_EX;//1
wire ID_RegWrite_wire_EX;//1
wire ID_MemRead_wire_EX;//1
wire ID_MemWrite_wire_EX;//1
wire ID_MemtoReg_wire_EX;//1
wire ID_Jal_wire_EX;//1
wire [31:0]ID_PC_4_wire_EX; //32
wire [31:0]ID_ReadData1_wire_EX; //32
wire [31:0]ID_ReadData2_wire_EX; //32
wire [31:0]ID_InmmediateExtend_wire_EX;// 32
wire [4:0]ID_Rt_wire_EX; //5
wire [4:0]ID_Rd_wire_EX; //5


//Pipeline Ex to to MEM
wire EX_MemtoReg_wire_MEM;//1
wire EX_BranchNE_wire_MEM; //1
wire EX_BramchEQ_wire_MEM;//1
wire EX_RegWrite_wire_MEM; //1
wire EX_MemRead_wire_MEM;//1
wire EX_MemWrite_wire_MEM;//1
wire [31:0]EX_PC_InmmediateExtend_wire_MEM; //32
wire EX_Zero_wire_MEM;//1
wire [31:0]EX_ALUResult_wire_MEM; //32
wire [31:0]EX_ReadData2_wire_MEM;//32
wire [4:0]EX_MUX_ForRTypeAndIType_wire_MEM; //5

//Pipeline MEM to WB
wire MEM_RegWrite_wire_WB;//1
wire MEM_MemtoReg_wire_WB; //1
wire [31:0]MEM_ReadData_wire_WB; //32
wire [31:0]MEM_ALUResult_wire_WB; //32
wire [4:0]MEM_MUX_ForRTypeAndIType_wire_WB; //5
					
					

integer ALUStatus;


//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/

Pipeline
#(
	.N(64)
)
IF_Pipeline_ID
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({
					PC_4_wire,
					Instruction_wire}),
	.DataOutput({
					IF_PC_4_wire_ID,
					IF_Instruction_wire_ID})
);

Pipeline
#(
	.N(151)
)
ID_Pipeline_EX
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({
					Jump_wire,//1
					RegDst_wire,//1
					BranchNE_wire,//1
					BranchEQ_wire,//1
					ALUOp_wire,//3
					ALUSrc_wire,//1
					RegWrite_wire,//1
					MemRead_wire,//1
					MemWrite_wire,//1
					MemtoReg_wire,//1
					Jal_wire,//1
					IF_PC_4_wire_ID, //PC 32
					ReadData1_wire, //32
					ReadData2_wire, //32
					InmmediateExtend_wire, // 32
					IF_Instruction_wire_ID[20:16], //5
					IF_Instruction_wire_ID[15:11] //5
					}),
	.DataOutput({
					ID_Jump_wire_EX,
					ID_RegDst_wire_EX,
					ID_BranchNE_wire_EX,
					ID_BramchEQ_wire_EX,
					ID_ALUOp_wire_EX,//[146:144]
					ID_ALUSrc_wire_EX,//[143]
					ID_RegWrite_wire_EX,//[142]
					ID_MemRead_wire_EX,//[141]
					ID_MemWrite_wire_EX,//[140]
					ID_MemtoReg_wire_EX,//[139]
					ID_Jal_wire_EX,//[138]
					ID_PC_4_wire_EX, //PC [137:106]
					ID_ReadData1_wire_EX,//[105:74]
					ID_ReadData2_wire_EX, //[73:42]
					ID_InmmediateExtend_wire_EX,// [41:10]
					ID_Rt_wire_EX, //instruction [9:5]
					ID_Rd_wire_EX, //instruction [4:0]	
					})
);



Pipeline
#(
	.N(108)
)
EX_Pipeline_MEM
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({
					ID_MemtoReg_wire_EX, //1
					ID_BranchNE_wire_EX, //1
					ID_BramchEQ_wire_EX, //1
					ID_RegWrite_wire_EX, //1
					ID_MemRead_wire_EX, //1
					ID_MemWrite_wire_EX, //1
					PC_InmmediateExtend_wire, //32
					Zero_wire,//1
					ALUResult_wire, //32
					ID_ReadData2_wire_EX,//32
					MUX_ForRTypeAndIType_wire //5
					}),
	.DataOutput({
					EX_MemtoReg_wire_MEM,//1
					EX_BranchNE_wire_MEM, //1
					EX_BramchEQ_wire_MEM,//1
					EX_RegWrite_wire_MEM, //1
					EX_MemRead_wire_MEM,//1
					EX_MemWrite_wire_MEM,//1
					EX_PC_InmmediateExtend_wire_MEM, //32
					EX_Zero_wire_MEM,//1
					EX_ALUResult_wire_MEM, //32
					EX_ReadData2_wire_MEM,//32
					EX_MUX_ForRTypeAndIType_wire_MEM //5)
					})
);



Pipeline
#(
	.N( 71)
)
MEM_Pipeline_WB
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({
					EX_RegWrite_wire_MEM, //1
					EX_MemtoReg_wire_MEM, //1
					ReadData_wire, //32
					EX_ALUResult_wire_MEM, //32
					EX_MUX_ForRTypeAndIType_wire_MEM //5
					}),
	.DataOutput({
					MEM_RegWrite_wire_WB,//1
					MEM_MemtoReg_wire_WB, //1
					MEM_ReadData_wire_WB, //32
					MEM_ALUResult_wire_WB, //32
					MEM_MUX_ForRTypeAndIType_wire_WB//5
					})
);


Control
ControlUnit
(
	.Jump(Jump_wire),
	.OP(IF_Instruction_wire_ID[31:26]),
	.RegDst(RegDst_wire),
	.BranchNE(BranchNE_wire),
	.BranchEQ(BranchEQ_wire),
	.ALUOp(ALUOp_wire),
	.ALUSrc(ALUSrc_wire),
	.RegWrite(RegWrite_wire),
	.MemRead(MemRead_wire),
	.MemWrite(MemWrite_wire),
	.MemtoReg(MemtoReg_wire),
	.Jal(Jal_wire)
);
PC_Register
#(
	.N(32)
)
program_counter
(
	.clk(clk),
	.reset(reset),
	.NewPC(MUX_PC_wire),
	.PCValue(PC_wire)
);



ProgramMemory
#(
	.MEMORY_DEPTH(MEMORY_DEPTH)
)
ROMProgramMemory
(
	.Address(PC_wire),
	.Instruction(Instruction_wire)
);

Adder32bits
PC_Puls_4
(
	.Data0(PC_wire),
	.Data1(4),
	
	.Result(PC_4_wire)
);




//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Multiplexer2to1
#(
	.NBits(5)
)
MUX_ForRTypeAndIType
(
	.Selector(ID_RegDst_wire_EX),
	.MUX_Data0(ID_Rt_wire_EX),
	.MUX_Data1(ID_Rd_wire_EX),
	.MUX_Output(MUX_ForRTypeAndIType_wire)

);

//Multiplexer2to1
//#(
//	.NBits(5)
//)
//MUX_ForWriteRegister
//(
//	.Selector(Jal_wire),
//	.MUX_Data0(MUX_ForRTypeAndIType_wire),
//	.MUX_Data1({5'b11111}),
//	.MUX_Output(WriteRegister_wire)
//);


//Multiplexer2to1
//#(
//	.NBits(32)
//)
//MUX_ForWriteData
//(
//	.Selector(Jal_wire),
//	.MUX_Data0(MUX_WriteData_wire),
//	.MUX_Data1(PC_4_wire),
//	.MUX_Output(MUX_RegisterFile_wire)	
//);



RegisterFile
Register_File
(
	.clk(clk),
	.reset(reset),
	.RegWrite(MEM_RegWrite_wire_WB),
	.WriteRegister(EX_MUX_ForRTypeAndIType_wire_MEM),
	.ReadRegister1(IF_Instruction_wire_ID[25:21]),
	.ReadRegister2(IF_Instruction_wire_ID[20:16]),
	.WriteData(MUX_WriteData_wire),
	.ReadData1(ReadData1_wire),
	.ReadData2(ReadData2_wire)

);


SignExtend
SignExtendForConstants
(   
	.DataInput(IF_Instruction_wire_ID[15:0]),
   .SignExtendOutput(InmmediateExtend_wire)
);



Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForReadDataAndInmediate
(
	.Selector(ID_ALUSrc_wire_EX),
	.MUX_Data0(ID_ReadData2_wire_EX),
	.MUX_Data1(ID_InmmediateExtend_wire_EX),
	
	.MUX_Output(ReadData2OrInmmediate_wire)

);



//Multiplexer2to1
//#(
//	.NBits(32)
//)
//MUX_ForJr
//(
//	.Selector(Jr_wire),
//	.MUX_Data0(MUX_Jump_wire),
//	.MUX_Data1(ReadData1_wire),
//	.MUX_Output(MUX_PC_wire)
//
//);




ALUControl
ArithmeticLogicUnitControl
(
	.ALUOp(ID_ALUOp_wire_EX),
	.ALUFunction(ID_InmmediateExtend_wire_EX[5:0]),
	.ALUOperation(ALUOperation_wire),
	.Jr(Jr_wire)

);



ALU
ArithmeticLogicUnit 
(
	.ALUOperation(ALUOperation_wire),
	.A(ID_ReadData1_wire_EX),
	.B(ReadData2OrInmmediate_wire),
	.Zero(Zero_wire),
	.ALUResult(ALUResult_wire),
	.Shamt(ID_InmmediateExtend_wire_EX[10:6])
);

Adder32bits
PC_Puls_InmmediateExtend_wire
(
	.Data0(ID_PC_4_wire_EX),
	.Data1({ID_InmmediateExtend_wire_EX[29:0],2'b00}),
	.Result(PC_InmmediateExtend_wire)
);



Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForAddress
(
	.Selector(PCtoBranch_wire),
	.MUX_Data0(PC_4_wire),
	.MUX_Data1(EX_PC_InmmediateExtend_wire_MEM),
	.MUX_Output(MUX_PC_wire)
);


//Multiplexer2to1
//#(
//	.NBits(32)
//)
//MUX_ForJump
//(
//	.Selector(Jump_wire),
//	.MUX_Data0(MUX_PC_InmmediateExtend_wire),
//	.MUX_Data1({PC_4_wire[31:28],InmmediateExtend_wire[25:0],2'b00}),
//	.MUX_Output(MUX_Jump_wire)
//);

DataMemory
RAM_Memory
(
	.WriteData(EX_ReadData2_wire_MEM),
	.Address(EX_ALUResult_wire_MEM),
	.MemWrite(EX_MemWrite_wire_MEM),
	.MemRead(EX_MemRead_wire_MEM),
	.clk(clk),
	.ReadData(ReadData_wire)
);

	
Multiplexer2to1
#(
	.NBits(32)
)
MUX_WriteData
(
	.Selector(MEM_MemtoReg_wire_WB),
	.MUX_Data0(MEM_ReadData_wire_WB),
	.MUX_Data1(MEM_ALUResult_wire_WB),
	.MUX_Output(MUX_WriteData_wire)
);



assign ALUResultOut = ALUResult_wire;
assign PCtoBranch_wire = (EX_Zero_wire_MEM & EX_BramchEQ_wire_MEM) | (~EX_Zero_wire_MEM & EX_BranchNE_wire_MEM);
assign  PortOut = PC_wire;
endmodule

