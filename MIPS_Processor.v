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

//Top Module

module MIPS_Processor
#(
	parameter MEMORY_DEPTH = 200
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
wire MemRead_wire;
wire MemToReg_wire;
wire MemWrite_wire;
wire PCtoBranch_wire;
wire Jump_wire;
wire Jr_wire; 
wire Jal_wire;

wire Flush_wire;
wire IF_Enable_wire_ID;
wire Stall_wire;

wire Flush_Jump_wire; //added
wire Flush_BranchNE_wire;
wire Flush_BranchEQ_wire;
wire Flush_RegDst_wire;				
wire [2:0] Flush_ALUOp_wire;					
wire Flush_ALUSrc_wire;					
wire Flush_RegWrite_wire;					
wire Flush_MemWrite_wire;					
wire Flush_MemRead_wire;				
wire Flush_MemToReg_wire;

wire ID_Flush_BranchNE_wire_EX;//added
wire ID_Flush_BramchEQ_wire_EX;//added
wire Jr_Flush_Jr_wire;//added
wire ID_Flush_Jump_wire_EX;//added
wire ID_Flush_RegWrite_wire_EX;
wire ID_Flush_MemWrite_wire_EX;
wire ID_Flush_MemRead_wire_EX;	
wire ID_Flush_MemtoReg_wire_EX;
		
wire [2:0] 	ALUOp_wire;
wire [3:0] 	ALUOperation_wire;
wire [4:0] 	WriteRegister_wire;
wire [1:0]	ForwardA_wire;
wire [1:0]	ForwardB_wire;
wire [31:0] ReadData1_wire;
wire [31:0] ReadData2_wire;
wire [31:0] InmmediateExtend_wire;
wire [31:0] PC_InmmediateExtend_wire;
wire [31:0] ALUResult_wire;
wire [31:0] ReadDataOut_wire;
wire [31:0] PC_wire;
wire [31:0] PC_4_wire;
wire [31:0] ReadData2OrInmmediate_wire;
wire [31:0] Instruction_wire;
wire [31:0] Jump_PC_wire;
wire [31:0] MUX_FinalPC_wire;
wire [31:0] MUX_PC_Stall_wire;
wire [31:0] MUX_WriteData_wire;
wire [31:0] MUX_FinalWriteData_wire;
wire [4:0] 	MUX_WriteRegister_wire;
wire [31:0] MUX_Jump_wire;
wire [31:0] MUX_Jr_wire;
wire [31:0] MUX_Output_A_wire;
wire [31:0] MUX_Output_B_wire;
wire [31:0] Flush_Instruction_wire;

//Pipeline IF to ID
wire [31:0] IF_PC_4_wire_ID;
wire [31:0] IF_Instruction_wire_ID;

//Pipeline ID to EX	
wire ID_Jump_wire_EX;//1
wire ID_Jal_wire_EX;//1
wire ID_RegDst_wire_EX;//1
wire ID_BranchNE_wire_EX;//1
wire ID_BramchEQ_wire_EX;//1
wire ID_ALUSrc_wire_EX;
wire ID_RegWrite_wire_EX;
wire ID_MemWrite_wire_EX;
wire ID_MemRead_wire_EX; 
wire ID_MemtoReg_wire_EX;
wire [2:0]	ID_ALUOp_wire_EX;
wire [31:0] ID_PC_4_wire_EX;
wire [31:0] ID_ReadData1_wire_EX;
wire [31:0] ID_ReadData2_wire_EX;
wire [31:0] ID_Instruction_wire_Ex;
wire [31:0] ID_InmmediateExtend_wire_EX;

//Pipeline Ex to to MEM
wire EX_Jr_wire_MEM;
wire EX_Jump_wire_MEM;
wire EX_BranchNE_wire_MEM; //1
wire EX_BramchEQ_wire_MEM;//1
wire EX_MemtoReg_wire_MEM;			
wire EX_Zero_wire_MEM;				
wire EX_RegWrite_wire_MEM;	
wire EX_MemRead_wire_MEM;
wire [4:0] 	EX_MUX_ForRTypeAndIType_wire_MEM;			
wire [31:0]	EX_PC_InmmediateExtend_wire_MEM;			
wire [31:0] EX_ALUResult_wire_MEM;			
wire [31:0] EX_ReadData2_wire_MEM;			

//Pipeline MEM to WB
wire MEM_RegWrite_wire_WB;
wire MEM_MemtoReg_wire_WB;		
wire [4:0]  MEM_MUX_ForRTypeAndIType_wire_WB;  
wire [31:0] MEM_ReadData_wire_WB;
wire [31:0] MEM_ALUResult_wire_WB; 		


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
	.enable(IF_Enable_wire_ID),
	.DataInput({
					PC_4_wire,
					Flush_Instruction_wire
					}),
	.DataOutput({
					IF_PC_4_wire_ID, 
					IF_Instruction_wire_ID
					})
);	

Pipeline
#(
	.N(171)
)
ID_Pipeline_EX
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({
					Flush_Jump_wire, //added
					Flush_BranchNE_wire,
					Flush_BranchEQ_wire,
					Flush_RegDst_wire,					
					Flush_ALUOp_wire,						
					Flush_ALUSrc_wire,					
					Flush_RegWrite_wire,					
					Flush_MemWrite_wire,					
					Flush_MemRead_wire,					
					Flush_MemToReg_wire,					
					IF_PC_4_wire_ID, 				 
					ReadData1_wire,				
					ReadData2_wire,				
					InmmediateExtend_wire,		
					IF_Instruction_wire_ID		
					}),
	.DataOutput({
					ID_Jump_wire_EX,//1
					ID_BranchNE_wire_EX,//1
					ID_BramchEQ_wire_EX,
					ID_RegDst_wire_EX,					
					ID_ALUOp_wire_EX,						 
					ID_ALUSrc_wire_EX,					
					ID_RegWrite_wire_EX,					
					ID_MemWrite_wire_EX,					
					ID_MemRead_wire_EX,					
					ID_MemtoReg_wire_EX,					
					ID_PC_4_wire_EX, 					   
					ID_ReadData1_wire_EX,				
					ID_ReadData2_wire_EX,				
					ID_InmmediateExtend_wire_EX,		
					ID_Instruction_wire_Ex  		
	})	
);	


Pipeline
#(
	.N(110)
)
EX_Pipeline_MEM
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({
					ID_Flush_BranchNE_wire_EX,//added
					ID_Flush_BramchEQ_wire_EX,//added
					Jr_Flush_Jr_wire,//added
					ID_Flush_Jump_wire_EX,//added
					ID_Flush_RegWrite_wire_EX,
					ID_Flush_MemWrite_wire_EX,
					ID_Flush_MemRead_wire_EX,	
					ID_Flush_MemtoReg_wire_EX,
					Zero_wire,
					PC_InmmediateExtend_wire,
					ALUResult_wire,
					MUX_Output_B_wire,
					MUX_WriteRegister_wire
					}),
	.DataOutput({
					EX_BranchNE_wire_MEM, //1
					EX_BramchEQ_wire_MEM,//1
					EX_Jr_wire_MEM,
					EX_Jump_wire_MEM,
					EX_RegWrite_wire_MEM,
					EX_MemWrite_wire_MEM,
					EX_MemRead_wire_MEM,	
					EX_MemtoReg_wire_MEM,
					EX_Zero_wire_MEM,
					EX_PC_InmmediateExtend_wire_MEM,
					EX_ALUResult_wire_MEM,
					EX_ReadData2_wire_MEM,
					EX_MUX_ForRTypeAndIType_wire_MEM	
					}) 
);	

Pipeline
	#(
		.N(71)
	)
MEM_Pipeline_WB
(
		.clk(clk),
		.reset(reset),
		.enable(1),
		.DataInput({
					EX_RegWrite_wire_MEM,	
					EX_MemtoReg_wire_MEM,	
					ReadDataOut_wire,			
					EX_ALUResult_wire_MEM, 
					EX_MUX_ForRTypeAndIType_wire_MEM  
					}),
		.DataOutput({
					MEM_RegWrite_wire_WB,	
					MEM_MemtoReg_wire_WB,	
					MEM_ReadData_wire_WB,	
					MEM_ALUResult_wire_WB, 
					MEM_MUX_ForRTypeAndIType_wire_WB
		})   
	);	


integer ALUStatus;
assign  PortOut = PC_wire;


Control
ControlUnit
(
	.OP(IF_Instruction_wire_ID[31:26]),
	.RegDst(RegDst_wire),
	.BranchNE(BranchNE_wire),
	.BranchEQ(BranchEQ_wire),
	.ALUOp(ALUOp_wire),
	.ALUSrc(ALUSrc_wire),
	.RegWrite(RegWrite_wire),
	.MemWrite(MemWrite_wire),
	.MemRead(MemRead_wire),
	.MemtoReg(MemToReg_wire),
	.Jump(Jump_wire),
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
	.NewPC(MUX_PC_Stall_wire),
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


//************************************************************************************************************/
//************************************************************************************************************/
//************************************************************************************************************/
//************************************************************************************************************/
//************************************************************************************************************/


Multiplexer2to1
#(
	.N(5)
)
MUX_ForRTypeAndIType		//rt rd
(
	.Selector(ID_RegDst_wire_EX),
	.MUX_Data0(ID_Instruction_wire_Ex[20:16]),
	.MUX_Data1(ID_Instruction_wire_Ex[15:11]),
	.MUX_Output(MUX_WriteRegister_wire)

);



RegisterFile
Register_File
(
	.clk(clk),
	.reset(reset),
	.RegWrite(MEM_RegWrite_wire_WB),
	.WriteRegister(MEM_MUX_ForRTypeAndIType_wire_WB),
	.ReadRegister1(IF_Instruction_wire_ID[25:21]),	//rs
	.ReadRegister2(IF_Instruction_wire_ID[20:16]),	//rt
	.WriteData(MUX_FinalWriteData_wire),
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
	.N(32)
)
MUX_ForReadDataAndInmediate
(
	.Selector(ID_ALUSrc_wire_EX),
	.MUX_Data0(MUX_Output_B_wire),
	.MUX_Data1(ID_InmmediateExtend_wire_EX),
	.MUX_Output(ReadData2OrInmmediate_wire)

);

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
	.A(MUX_Output_A_wire),
	.B(ReadData2OrInmmediate_wire),
	.Zero(Zero_wire),
	.ALUResult(ALUResult_wire),
	.Shamt(ID_InmmediateExtend_wire_EX[10:6])
);

 DataMemory 
#(	 .DATA_WIDTH(32),		//este valor tendrá que ser de 32
	 .MEMORY_DEPTH(1024)
)
RAM(
	.WriteData(EX_ReadData2_wire_MEM),
	.Address(EX_ALUResult_wire_MEM),
	.MemWrite(EX_MemWrite_wire_MEM),
	.MemRead(EX_MemRead_wire_MEM),
	.clk(clk),
	.ReadData(ReadDataOut_wire)
);


Multiplexer2to1
#(
	.N(32)
)
MUX_To_WriteData
(
	.Selector(MEM_MemtoReg_wire_WB),
	.MUX_Data0(MEM_ALUResult_wire_WB),
	.MUX_Data1(MEM_ReadData_wire_WB),
	
	.MUX_Output(MUX_WriteData_wire)
);

Adder32bits
AdderPC
(
	.Data0(ID_PC_4_wire_EX),
	.Data1({ID_InmmediateExtend_wire_EX[30:0],2'b00}),
	
	.Result(PC_InmmediateExtend_wire)
);
//
//Multiplexer2to1
//#(
//	.N(32)
//)
//MUX_ForAddress
//(
//	.Selector(PCtoBranch_wire),
//	.MUX_Data0(PC_4_wire),
//	.MUX_Data1(InmmediateExtend_wire),
//	
//	.MUX_Output(Jump_PC_wire)
//);

Multiplexer2to1
#(
	.N(32)
)
MUX_To_Jump	
(
	.Selector(Jump_wire),
	.MUX_Data0(Jump_PC_wire),
	.MUX_Data1({ PC_4_wire[31:28],  InmmediateExtend_wire[25:0],2'b00}),
	
	.MUX_Output(MUX_Jump_wire)
);

Multiplexer2to1 
#(
	.N(32)
)
MUX_Jr		
(
	.Selector(Jr_wire),
	.MUX_Data0(MUX_Jump_wire),
	.MUX_Data1(ReadData1_wire),
	
	.MUX_Output(MUX_Jr_wire)
);

Multiplexer2to1
#(
	.N(5)
)
MUX_Jal		
(
	.Selector(Jal_wire),
	.MUX_Data0(MUX_WriteRegister_wire ),
	.MUX_Data1({5'b11111}),
	.MUX_Output(WriteRegister_wire)
);

Multiplexer2to1
#(
	.N(32)
)
MUX2_Jal		
(
	.Selector(Jal_wire),
	.MUX_Data0(MUX_WriteData_wire),
	.MUX_Data1(PC_4_wire),
	
	.MUX_Output(MUX_FinalWriteData_wire)
);


	
	Multiplexer2to1
#(
	.N(32)
)
MUX_Left_to_PC		
(
	.Selector(PCtoBranch_wire),
	.MUX_Data0(PC_4_wire),
	.MUX_Data1(EX_ALUResult_wire_MEM),
	
	.MUX_Output(MUX_FinalPC_wire)
);

//Cambiar wire
//Add multiplexor 			

ForwardUnit
#(
	.N(5)
)
ForwardingUnit
(
	.ID_RegisterRs_wire_EX(ID_Instruction_wire_Ex[25:21]),
	.ID_RegisterRt_wire_EX(ID_Instruction_wire_Ex[20:16]),
	.EX_RegisterRd_wire_MEM(EX_MUX_ForRTypeAndIType_wire_MEM),
	.EX_RegWrite_wire_MEM(EX_RegWrite_wire_MEM),
	.MEM_RegisterRd_wire_WB(MEM_MUX_ForRTypeAndIType_wire_WB),
	.MEM_RegWrite_wire_WB(MEM_RegWrite_wire_WB),
	.ForwardA(ForwardA_wire),
	.ForwardB(ForwardB_wire)
);



Multiplexer3to1
#(
	.N(32)
)
MUX_ForA
(
	.Selector(ForwardA_wire),
	.MUX_Data0(ID_ReadData1_wire_EX),
	.MUX_Data1(MUX_FinalWriteData_wire),
	.MUX_Data2(EX_ALUResult_wire_MEM),
	
	.MUX_Output(MUX_Output_A_wire)
);


Multiplexer3to1
#(
	.N(32)
)
MUX_ForB
(
	.Selector(ForwardB_wire),
	.MUX_Data0(ID_ReadData2_wire_EX),
	.MUX_Data1(MUX_FinalWriteData_wire),
	.MUX_Data2(EX_ALUResult_wire_MEM),
	
	.MUX_Output(MUX_Output_B_wire)
);




HazardUnit
#(
	.N(5)
)
Hazard
(

	.ID_MemRead_wire_EX(ID_MemRead_wire_EX),
	.ID_RegisterRt_wire_EX(ID_Instruction_wire_Ex[20:16]),
	.IF_RegisterRs_wire_ID(IF_Instruction_wire_ID[25:21]),
	.IF_RegisterRt_wire_ID(IF_Instruction_wire_ID[20:16]),
	.Flush_wire(Flush_wire),
	.IF_Enable_wire_ID(IF_Enable_wire_ID),
	.Stall_wire(Stall_wire)
);


Multiplexer2to1
#(
	.N(32)
)
MUX_Stall
(
	.Selector(Stall_wire),
	.MUX_Data0(MUX_FinalPC_wire),
	.MUX_Data1(PC_wire),
	.MUX_Output(MUX_PC_Stall_wire)
);


Multiplexer2to1
MUX_IF_Flush_ID
(
	.Selector(PCtoBranch_wire | Jump_wire | Jr_wire),
	.MUX_Data0(Instruction_wire),
	.MUX_Data1(0),
	
	.MUX_Output(Flush_Instruction_wire)
);


Multiplexer2to1
#(
	.N(12)
)
MUX_ID_Flush_EX
(
	.Selector(Flush_wire | PCtoBranch_wire | EX_Jump_wire_MEM | EX_Jr_wire_MEM),
	.MUX_Data0({
					Jump_wire, //1
					BranchNE_wire,//1
					BranchEQ_wire,//1
					RegDst_wire,//1			
					ALUOp_wire,//3				
					ALUSrc_wire,//1				
					RegWrite_wire,//1				
					MemWrite_wire,//1			
					MemRead_wire,		//1			
					MemToReg_wire		//1
	}),
	.MUX_Data1(0),
	.MUX_Output({
					Flush_Jump_wire, //added
					Flush_BranchNE_wire,
					Flush_BranchEQ_wire,
					Flush_RegDst_wire,					
					Flush_ALUOp_wire,						
					Flush_ALUSrc_wire,					
					Flush_RegWrite_wire,					
					Flush_MemWrite_wire,					
					Flush_MemRead_wire,					
					Flush_MemToReg_wire
	})

);


Multiplexer2to1
#(
	.N(8)
)
MUX_EX_Flush_MEM
(
	.Selector(PCtoBranch_wire | EX_Jump_wire_MEM | EX_Jr_wire_MEM),
	.MUX_Data0(
				{
				ID_BranchNE_wire_EX,//added
				ID_BramchEQ_wire_EX,//added
				Jr_wire,//added
				ID_Jump_wire_EX,//added
				ID_RegWrite_wire_EX,
				ID_MemWrite_wire_EX,
				ID_MemRead_wire_EX,	
				ID_MemtoReg_wire_EX}),
				
	.MUX_Data1(0),
	
	.MUX_Output({
					ID_Flush_BranchNE_wire_EX,//added
					ID_Flush_BramchEQ_wire_EX,//added
					Jr_Flush_Jr_wire,//added
					ID_Flush_Jump_wire_EX,//added
					ID_Flush_RegWrite_wire_EX,
					ID_Flush_MemWrite_wire_EX,
					ID_Flush_MemRead_wire_EX,	
					ID_Flush_MemtoReg_wire_EX	
	})
);

assign PCtoBranch_wire = (EX_Zero_wire_MEM & EX_BramchEQ_wire_MEM ) | (EX_BranchNE_wire_MEM &  ~EX_Zero_wire_MEM);

assign ALUResultOut = ALUResult_wire;
endmodule

