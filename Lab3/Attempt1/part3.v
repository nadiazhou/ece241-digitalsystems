`timescale 1ns / 1ns // `timescale time_unit/time_precision




module part3(A, B, Function, ALUout);
	parameter N = 4;
	
	input [N-1:0] A;
	input [N-1:0] B;
	input [1:0] Function;
	output reg [N+N-1:0] ALUout;
	
		always @(*)
	begin
		case (Function)
			2'b00: ALUout = A+B;
			2'b01: ALUout = |{A,B};
			2'b10: ALUout = &{A,B};
			2'b11: ALUout = {A,B};
			default: ALUout = 8'b00000000;
		endcase
	end
	
	
endmodule

