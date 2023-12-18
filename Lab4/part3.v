`timescale 1ns / 1ns // `timescale time_unit/time_precision

module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
	input clock, reset, ParallelLoadn, RotateRight, ASRight;
	input [3:0] Data_IN;
		output [3:0] Q;
	
	reg decider;
	always@(*)
	begin
	case(ASRight)
	1'b0: decider <= Q[0];
	1'b1: decider <= Q[3];
	default: decider <= 1'b0;
	endcase
	end
	
	subCircuit Q3(clock, reset, Data_IN[3], RotateRight, ParallelLoadn, Q[3], Q[2], decider);
	subCircuit Q2(clock, reset, Data_IN[2], RotateRight, ParallelLoadn, Q[2], Q[1], Q[3]);
	subCircuit Q1(clock, reset, Data_IN[1], RotateRight, ParallelLoadn, Q[1], Q[0], Q[2]);
	subCircuit Q0(clock, reset, Data_IN[0], RotateRight, ParallelLoadn, Q[0], Q[3], Q[1]);
	
endmodule

module Dflipflop(clock, reset, Data, Q);
 input clock, reset, Data; 
	 output reg Q; 
	 
	 always@(posedge clock)
	 begin
			if(reset) Q <= 1'b0;
			else Q <= Data;
	 end
endmodule

module subCircuit(clock, reset, D, LoadLeft, loadn, Q, right, left);

	input clock, reset;   // load left operators
	input LoadLeft; // mux
	input loadn;    // mux
	input D;
	output Q;
	input right, left;
	reg intone;
	reg inttwo;

	always@(*)
	begin
	case(LoadLeft) 
	1'b0: intone <= right;
	1'b1: intone <= left;
	default: intone <= 1'b0;
	endcase
	end

	always@(*)
	begin
	case(loadn) 
	1'b0: inttwo <= D;
	1'b1: inttwo <= intone;
	default: inttwo <= 1'b0;
	endcase
	end



	Dflipflop call(clock, reset, inttwo, Q);

endmodule

	