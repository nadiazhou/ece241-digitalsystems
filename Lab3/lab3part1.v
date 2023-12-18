
`timescale 1ns / 1ns // `timescale time_unit/time_precision

module board(SW, KEY, HEX0, HEX2, HEX3, HEX4);
	input [7:0] SW;
	input [1:0] KEY;
	output [6:0] HEX0, HEX2, HEX3, HEX4;
	
	wire [7:0] chocolate;
	
	part2 wonka(SW[7:4], SW[3:0], KEY, chocolate);
	hex_decoder muffin1(SW[7:4], HEX2);
	hex_decoder muffin2(SW[3:0], HEX0);
	hex_decoder muffin3(chocolate[7:4], HEX4);
	hex_decoder muffin4(chocolate[3:0], HEX3);
	
	
endmodule

module part2(A, B, Function, ALUout);

   input [3:0] A;
	input [3:0] B;
	input [1:0] Function;
	output reg [7:0] ALUout;
	
	wire [7:0] temp4;
	wire [7:0] temp1;
	wire [3:0] couttemp;
	

	assign temp4 = {A,B};
	part1 billy(A,B,0,temp1[3:0],couttemp);
	assign temp1[4] = couttemp[3];
	assign temp1[7:5] = 0;
	always @(*)
	begin
		case (Function)
			2'b00: ALUout = temp1;
			2'b01: ALUout = |temp4;
			2'b10: ALUout = &temp4;
			2'b11: ALUout = temp4;
			default: ALUout = 8'b00000000;
		endcase
	end

endmodule


module part1(a, b, c_in, s, c_out);

    input [3:0] a;
	 input [3:0] b;
	 input c_in;
    output [3:0] s;
	 output [3:0] c_out;

    fulladder u1(a[0],b[0],c_in,s[0],c_out[0]);
	 fulladder u2(a[1],b[1],c_out[0],s[1],c_out[1]);
	 fulladder u3(a[2],b[2],c_out[1],s[2],c_out[2]);
	 fulladder u4(a[3],b[3],c_out[2],s[3],c_out[3]);
	 
endmodule


module fulladder(a, b, c_in, s, c_out);

	input a, b, c_in;
	output s, c_out;
	
	assign c_out = (a&b)|(c_in&b)|(c_in&a);
	assign s = a^b^c_in;
	
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
