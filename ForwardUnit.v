
module ForwardUnit
#(
	parameter N=5
)
(
	input EX_RegWrite_wire_MEM,
	input MEM_RegWrite_wire_WB,
	input [N-1:0] EX_RegisterRd_wire_MEM,
	input [N-1:0] ID_RegisterRs_wire_EX,
	input [N-1:0] ID_RegisterRt_wire_EX,
	input [N-1:0] MEM_RegisterRd_wire_WB,
	
	output reg [1:0] ForwardA,
	output reg [1:0] ForwardB
);

	always@(EX_RegWrite_wire_MEM,
			MEM_RegWrite_wire_WB,
			EX_RegisterRd_wire_MEM,
			ID_RegisterRs_wire_EX,
			ID_RegisterRt_wire_EX,
			MEM_RegisterRd_wire_WB)begin
			
		if(EX_RegWrite_wire_MEM &&
		EX_RegisterRd_wire_MEM != 0 &&
		EX_RegisterRd_wire_MEM == ID_RegisterRs_wire_EX)
			ForwardA = 2'b10; // Se lee el dato desde la salida de la ALU porque hay una dependencia en el registro Rs en la siguiente instruccion
		else
			if(MEM_RegWrite_wire_WB &&
			MEM_RegisterRd_wire_WB != 0 &&
			EX_RegisterRd_wire_MEM != ID_RegisterRs_wire_EX &&
			MEM_RegisterRd_wire_WB == ID_RegisterRs_wire_EX)
				ForwardA = 2'b01; // Se lee el dato desde la salida de Data Memory porque existe una dependencia  en el registro Rs dos instrucciones adelante
			else
				ForwardA = 2'b00; // No existe ninguna dependencia
		
		if(EX_RegWrite_wire_MEM &&
		EX_RegisterRd_wire_MEM != 0 &&
		EX_RegisterRd_wire_MEM == ID_RegisterRt_wire_EX)
			ForwardB = 2'b10; // Se lee el dato desde la salida de la ALU porque hay una dependencia en el registro Rt en la siguiente instruccion
		else
			if(MEM_RegWrite_wire_WB &&
			MEM_RegisterRd_wire_WB != 0 &&
			EX_RegisterRd_wire_MEM != ID_RegisterRt_wire_EX &&
			MEM_RegisterRd_wire_WB == ID_RegisterRt_wire_EX)
				ForwardB = 2'b01; // Se lee el dato desde la salida de Data Memory porque existe una dependencia  en el registro Rt dos instrucciones adelante
			else
				ForwardB = 2'b00; // No existe ninguna dependencia
			
	end

endmodule