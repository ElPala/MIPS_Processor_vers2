
module Multiplexer3to1
#
(
	parameter N=32
)
(
	input [1:0] Selector,
	input [N-1:0] MUX_Data0,
	input [N-1:0] MUX_Data1,
	input [N-1:0] MUX_Data2,
	output reg [N-1:0] MUX_Output
);

	always@(Selector,MUX_Data0,MUX_Data1,MUX_Data2)
	begin
		case (Selector)
			2'b00: MUX_Output <= MUX_Data0;
			2'b01: MUX_Output <= MUX_Data1;
			2'b10: MUX_Output <= MUX_Data2;
			default: MUX_Output <= 'b0;
		endcase
	end

endmodule