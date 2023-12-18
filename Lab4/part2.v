`timescale 1ns / 1ns // `timescale time_unit/time_precision
module board(SW, KEY, HEX0, HEX1, HEX4, HEX5, LEDR);
	input [9:0] SW;
	input [1:0] KEY;
	output [6:0] HEX0, HEX1, HEX4, HEX5;
	output [7:0] LEDR; 
	
	part2 turkey (KEY[0], KEY[1], SW[3:0], SW[9:8], LEDR[7:0]);

	hex_decoder seed(SW[3:0], HEX0);
	hex_decoder weed(SW[9:8], HEX1);
	hex_decoder corn(LEDR[7:4], HEX4);
	hex_decoder peas(LEDR[3:0], HEX5);
endmodule

module part2(Clock, Reset_b, Data, Function, ALUout);

   input Clock, Reset_b;
	input [3:0] Data; 
	input [1:0] Function;
	output [7:0] ALUout;
	
	wire [7:0] SignalB;
	wire [7:0] Pre_reg_ALUout;
	
	register horsey(Pre_reg_ALUout, Clock, Reset_b, ALUout);

	ALU donkey(Data, SignalB, Function, Pre_reg_ALUout);

	assign SignalB[7:0] = ALUout[7:0];
	
endmodule

module ALU(A, B, Function, ALUout);
	input[3:0]A;
	input[7:0]B;
	input[1:0] Function;
	output reg [7:0] ALUout;
	always @(*)
		begin
			case (Function)
				2'b00: ALUout <= A + B[3:0]; // A + B
				2'b01: ALUout <= A * B[3:0]; // A * B 
				2'b10: ALUout <= B[3:0] << A; // Left shift B by A bits using shift operator
				2'b11: ALUout <= B; // hold current value in the Register, the register dnc
			default: ALUout <= 8'b00000000;
			endcase
		end	
endmodule

module register(Pre_reg_ALUout, Clock, Reset_b, ALUout); 

	input [7:0] Pre_reg_ALUout;
	input Clock, Reset_b;
	output reg [7:0] ALUout;
	
	always@(posedge Clock)
	begin
		if (Reset_b) ALUout <= 8'b00000000;
		else ALUout <= Pre_reg_ALUout;
	end
endmodule

module hex_decoder(c, display);
	
	input [3:0] c;
	output [6:0] display;

	
	assign display[6] = (~c[3]&~c[2]&~c[1]&~c[0])|(~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&c[2]&c[1]&c[0])|(c[3]&c[2]&~c[1]&~c[0]);
	assign display[5] = (~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&~c[2]&c[1]&~c[0])|(~c[3]&~c[2]&c[1]&c[0])|(~c[3]&c[2]&c[1]&c[0])|(c[3]&c[2]&~c[1]&c[0]);
	assign display[4] = (~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&~c[2]&c[1]&c[0])|(~c[3]&c[2]&~c[1]&~c[0])|(~c[3]&c[2]&~c[1]&c[0])|(~c[3]&c[2]&c[1]&c[0])|(c[3]&~c[2]&~c[1]&c[0]);
	assign display[3] = (~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&c[2]&~c[1]&~c[0])|(~c[3]&c[2]&c[1]&c[0])|(c[3]&~c[2]&~c[1]&c[0])|(c[3]&~c[2]&c[1]&~c[0])|(c[3]&c[2]&c[1]&c[0]);
	assign display[2] = (~c[3]&~c[2]&c[1]&~c[0])|(c[3]&c[2]&~c[1]&~c[0])|(c[3]&c[2]&c[1]&~c[0])|(c[3]&c[2]&c[1]&c[0]);
	assign display[1] = (~c[3]&c[2]&~c[1]&c[0])|(~c[3]&c[2]&c[1]&~c[0])|(c[3]&~c[2]&c[1]&c[0])|(c[3]&c[2]&~c[1]&~c[0])|(c[3]&c[2]&c[1]&~c[0])|(c[3]&c[2]&c[1]&c[0]);
	assign display[0] = (~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&c[2]&~c[1]&~c[0])|(c[3]&~c[2]&c[1]&c[0])|(c[3]&c[2]&~c[1]&c[0]);
	
endmodule
