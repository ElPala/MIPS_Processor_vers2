
module HazardUnit
#(
	parameter N=5
)
(
	input ID_MemRead_wire_EX,
	input [N-1:0] ID_RegisterRt_wire_EX,
	input [N-1:0] IF_RegisterRs_wire_ID,
	input [N-1:0] IF_RegisterRt_wire_ID,
	
	output reg Flush_wire,
	output reg IF_Enable_wire_ID,
	output reg Stall_wire
);

	always@(ID_MemRead_wire_EX,
			ID_RegisterRt_wire_EX,
			IF_RegisterRs_wire_ID,
			IF_RegisterRt_wire_ID)
			begin
			
			if	(ID_MemRead_wire_EX &&
				(ID_RegisterRt_wire_EX == IF_RegisterRs_wire_ID ||ID_RegisterRt_wire_EX == IF_RegisterRt_wire_ID))
				begin
					Flush_wire = 1;
					IF_Enable_wire_ID = 0;
					Stall_wire = 1;
				end
			else
				begin
					Flush_wire = 0;
					IF_Enable_wire_ID = 1;
					Stall_wire = 0;
				end	
			end
endmodule
