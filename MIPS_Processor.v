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
wire [31:0] PC_8_wire;
wire [31:0] PCtoBranch_wire;
wire [31:0] ReadData_wire;
wire [31:0] MUX_RegisterFile_wire;
wire [31:0] MUX_WriteData_wire;
wire [31:0] MUX_Jump_wire;


integer ALUStatus;


//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Control
ControlUnit
(
	.Jump(Jump_wire),
	.OP(Instruction_wire[31:26]),
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
Adder32bits
PC_Puls_8
(
	.Data0(PC_wire),
	.Data1(8),
	.Result(PC_8_wire)
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
	.Selector(RegDst_wire),
	.MUX_Data0(Instruction_wire[20:16]),
	.MUX_Data1(Instruction_wire[15:11]),
	.MUX_Output(MUX_ForRTypeAndIType_wire)

);

Multiplexer2to1
#(
	.NBits(5)
)
MUX_ForWriteRegister
(
	.Selector(Jal_wire),
	.MUX_Data0(MUX_ForRTypeAndIType_wire),
	.MUX_Data1({5'b11111}),
	.MUX_Output(WriteRegister_wire)
);


Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForWriteData
(
	.Selector(Jal_wire),
	.MUX_Data0(MUX_WriteData_wire),
	.MUX_Data1(PC_4_wire),
	.MUX_Output(MUX_RegisterFile_wire)	
);



RegisterFile
Register_File
(
	.clk(clk),
	.reset(reset),
	.RegWrite(RegWrite_wire),
	.WriteRegister(WriteRegister_wire),
	.ReadRegister1(Instruction_wire[25:21]),
	.ReadRegister2(Instruction_wire[20:16]),
	.WriteData(MUX_RegisterFile_wire),
	.ReadData1(ReadData1_wire),
	.ReadData2(ReadData2_wire)

);

SignExtend
SignExtendForConstants
(   
	.DataInput(Instruction_wire[15:0]),
   .SignExtendOutput(InmmediateExtend_wire)
);



Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForReadDataAndInmediate
(
	.Selector(ALUSrc_wire),
	.MUX_Data0(ReadData2_wire),
	.MUX_Data1(InmmediateExtend_wire),
	
	.MUX_Output(ReadData2OrInmmediate_wire)

);



Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForJr
(
	.Selector(Jr_wire),
	.MUX_Data0(MUX_Jump_wire),
	.MUX_Data1(ReadData1_wire),
	.MUX_Output(MUX_PC_wire)

);




ALUControl
ArithmeticLogicUnitControl
(
	.ALUOp(ALUOp_wire),
	.ALUFunction(Instruction_wire[5:0]),
	.ALUOperation(ALUOperation_wire),
	.Jr(Jr_wire)

);



ALU
ArithmeticLogicUnit 
(
	.ALUOperation(ALUOperation_wire),
	.A(ReadData1_wire),
	.B(ReadData2OrInmmediate_wire),
	.Zero(Zero_wire),
	.ALUResult(ALUResult_wire),
	.Shamt(Instruction_wire[10:6])
);

Adder32bits
PC_Puls_InmmediateExtend_wire
(
	.Data0(PC_4_wire),
	.Data1({InmmediateExtend_wire[29:0],2'b00}),
	
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
	.MUX_Data1(PC_InmmediateExtend_wire),
	.MUX_Output(MUX_PC_InmmediateExtend_wire)
);


Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForJump
(
	.Selector(Jump_wire),
	.MUX_Data0(MUX_PC_InmmediateExtend_wire),
	.MUX_Data1({PC_4_wire[31:28],InmmediateExtend_wire[25:0],2'b00}),
	.MUX_Output(MUX_Jump_wire)
);

DataMemory
RAM_Memory
(
	.WriteData(ReadData2_wire),
	.Address(ALUResult_wire),
	.MemWrite(MemWrite_wire),
	.MemRead(MemRead_wire),
	.clk(clk),
	.ReadData(ReadData_wire)
);
	
Multiplexer2to1
#(
	.NBits(32)
)
MUX_WriteData
(
	.Selector(MemtoReg_wire),
	.MUX_Data0(ALUResult_wire),
	.MUX_Data1(ReadData_wire),
	.MUX_Output(MUX_WriteData_wire)
);



assign ALUResultOut = ALUResult_wire;
assign PCtoBranch_wire = (Zero_wire & BranchEQ_wire) | (~Zero_wire & BranchNE_wire);
assign  PortOut = PC_wire;
endmodule

