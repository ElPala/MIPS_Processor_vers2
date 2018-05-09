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
wire [31:0] MUX_PC_wire; 
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
wire [31:0] MUX_Jump_wire;
wire [63:0] Pipeline_IF_ID;
wire [150:0] Pipeline_ID_EX;
wire [107:0] Pipeline_EX_MEM;
wire [70:0] Pipeline_MEM_WB;
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
	.DataInput({PC_4_wire,Instruction_wire}),
	.DataOutput(Pipeline_IF_ID)
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
					Jump_wire,//[150]
					RegDst_wire,//[149]
					BranchNE_wire,//[148]
					BranchEQ_wire,//[147]
					ALUOp_wire,//[146:144]
					ALUSrc_wire,//[143]
					RegWrite_wire,//[142]
					MemRead_wire,//[141]
					MemWrite_wire,//[140]
					MemtoReg_wire,//[139]
					Jal_wire,//[138]
					Pipeline_IF_ID[63:32], //PC [137:106]
					ReadData1_wire, //[105:74]
					ReadData2_wire, //[73:42]
					InmmediateExtend_wire, // [41:10]
					Pipeline_IF_ID[20:16], //instruction [9:5]
					Pipeline_IF_ID[15:11] //instruction [4:0]
					}),
	.DataOutput(Pipeline_ID_EX)
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
					Pipeline_ID_EX[139], //MemtoReg [107]
					Pipeline_ID_EX[148], //BranchNE [106]
					Pipeline_ID_EX[147], //BranchEQ[105]
					Pipeline_ID_EX[142], //RegWrite[104]
					Pipeline_ID_EX[141], //MemRead[103]
					Pipeline_ID_EX[140], //MemWrite[102]
					PC_InmmediateExtend_wire, //[ 101:70]
					Zero_wire,// [69]
					ALUResult_wire, //[68:37]
					Pipeline_ID_EX[73:42],//Dato2[36:5]
					MUX_ForRTypeAndIType_wire //[4:0]
					}),
	.DataOutput(Pipeline_EX_MEM)
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
					Pipeline_EX_MEM[104], //RegWrite[70]
					Pipeline_EX_MEM[107], //MemtoReg[69]
					ReadData_wire, //data[68:37]
					Pipeline_EX_MEM[68:37], //aluresult [36:5]
					Pipeline_EX_MEM[4:0] //writeregister [4:0]
					}),
	.DataOutput(Pipeline_MEM_WB)
);


Control
ControlUnit
(
	.Jump(Jump_wire),
	.OP(Pipeline_IF_ID[31:26]),
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
	.Selector(Pipeline_ID_EX[149]),
	.MUX_Data0(Pipeline_ID_EX[20:16]),
	.MUX_Data1(Pipeline_ID_EX[15:11]),
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
	.RegWrite(Pipeline_MEM_WB[70] ),
	.WriteRegister( Pipeline_MEM_WB[4:0]),
	.ReadRegister1(Pipeline_IF_ID[25:21]),
	.ReadRegister2(Pipeline_IF_ID[20:16]),
	.WriteData(MUX_WriteData_wire),
	.ReadData1(ReadData1_wire),
	.ReadData2(ReadData2_wire)

);

SignExtend
SignExtendForConstants
(   
	.DataInput(Pipeline_IF_ID[15:0]),
   .SignExtendOutput(InmmediateExtend_wire)
);



Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForReadDataAndInmediate
(
	.Selector(Pipeline_ID_EX[143]),
	.MUX_Data0(Pipeline_ID_EX[73:42]),
	.MUX_Data1(Pipeline_ID_EX[41:10]),
	
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
	.ALUOp(Pipeline_ID_EX[146:144]),
	.ALUFunction(Pipeline_ID_EX[15:10]),
	.ALUOperation(ALUOperation_wire),
	.Jr(Jr_wire)

);



ALU
ArithmeticLogicUnit 
(
	.ALUOperation(ALUOperation_wire),
	.A(Pipeline_ID_EX[105:74]),
	.B(ReadData2OrInmmediate_wire),
	.Zero(Zero_wire),
	.ALUResult(ALUResult_wire),
	.Shamt(Pipeline_ID_EX[14:10])
);

Adder32bits
PC_Puls_InmmediateExtend_wire
(
	.Data0(Pipeline_ID_EX[137:106]),
	.Data1({Pipeline_ID_EX[39:10],2'b00}),
	
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
	.MUX_Data1(Pipeline_EX_MEM[101:70]),
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
	.WriteData(Pipeline_EX_MEM[36:5]),
	.Address(Pipeline_EX_MEM[68:37]),
	.MemWrite(Pipeline_EX_MEM[102]),
	.MemRead(Pipeline_EX_MEM[103]),
	.clk(clk),
	.ReadData(ReadData_wire)
);
	
Multiplexer2to1
#(
	.NBits(32)
)
MUX_WriteData
(
	.Selector(Pipeline_EX_MEM[69]),
	.MUX_Data0(Pipeline_EX_MEM[36:5]),
	.MUX_Data1(Pipeline_EX_MEM[68:37]),
	.MUX_Output(MUX_WriteData_wire)
);



assign ALUResultOut = ALUResult_wire;
assign PCtoBranch_wire = (Pipeline_EX_MEM[69] & Pipeline_EX_MEM[105]) | (~Pipeline_EX_MEM[69] & Pipeline_EX_MEM[106]);
assign  PortOut = PC_wire;
endmodule

