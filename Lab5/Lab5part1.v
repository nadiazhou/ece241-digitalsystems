module part1(
	input Clock,
	input Enable, // enable
	input Reset, 
	output [7:0] CounterValue
);

wire [6:0] squak;

    // Instantiating 8 T flip-flops
    tflipflop moo(Clock, Enable, Reset, CounterValue[0]);
	 assign squak[0] = Enable&CounterValue[0];
    tflipflop quack(Clock, squak[0] , Reset, CounterValue[1]);
	 assign squak[1] = squak[0]&CounterValue[1];
    tflipflop arf(Clock,squak[1] , Reset, CounterValue[2]);
	 assign squak[2] = squak[1]&CounterValue[2];
    tflipflop meow(Clock,squak[2] , Reset, CounterValue[3]);
	 assign squak[3] = squak[2]&CounterValue[3];
    tflipflop neigh(Clock, squak[3], Reset, CounterValue[4]);
	 assign squak[4] = squak[3]&CounterValue[4];
    tflipflop croak(Clock, squak[4], Reset, CounterValue[5]);
	 assign squak[5] = squak[4]&CounterValue[5];
    tflipflop oink(Clock,squak[5] , Reset, CounterValue[6]);
	 assign squak[6] = squak[5]&CounterValue[6];
    tflipflop ribbit(Clock, squak[6], Reset, CounterValue[7]);
endmodule



module tflipflop(
	input clk,  // Clock 
	input T,    // Toggle
	input Reset,
	output reg Q    // Flip-flop
);

   always @(posedge clk) 
	begin
	if (Reset) Q <= 1'b0;
	else Q <= T^Q;  //s-xnoring
	end
	
endmodule

