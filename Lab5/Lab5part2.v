
/*- Want a 4 bit counter 
- Display on hex0
- Active high reset synchronous 
- Up counter 
- Counts at two speeds 1 Hz speed 0 
- 0.5 Hz speeds 1 
- 50 mHz clock on DEI-soC board*/


module part2 #(parameter CLOCK_FREQUENCY = 50000000)(
	input ClockIn,
	input Reset,
	input [1:0] Speed,
	output reg [3:0] CounterValue);
	
	
	wire Enable;

	
	rateDivider #CLOCK_FREQUENCY gulp(ClockIn, Reset, Speed[1:0], Enable);
	always@(posedge ClockIn)
	begin
		if (Reset == 1'b1)
				CounterValue <= 4'b0000;
		if (Enable)
			CounterValue[3:0] <= CounterValue + 1'b1;
	end

endmodule


module demo (
	input CLOCK_50,
	input [9:0] SW,
	output [6:0] HEX0);
	
	wire [3:0] counterValue;
	
	part2 baaah(CLOCK_50, SW[9], SW[1:0], counterValue[3:0]);
	
	hex_decoder gawk(counterValue[3:0], HEX0);
	
endmodule


module rateDivider #(parameter CLOCK_FREQUENCY = 50000000) (
	input ClockIn,
	input reset,
	input [1:0] speed,
	output Enable);
	
	reg [31:0] downCount;
	
	always@(posedge ClockIn)
	begin
	if ((reset == 1'b1) || (downCount == 32'd0))
		begin
		if (speed == 2'b00)
				downCount <= 32'd0;
		else if (speed == 2'b01)
				downCount <= CLOCK_FREQUENCY-1;
		else if (speed == 2'b10)
				downCount <= (2*CLOCK_FREQUENCY)-1;
		else if (speed == 2'b11)
				downCount <= (4*CLOCK_FREQUENCY)-1;
		end
		else
			begin
				downCount <= downCount - 1'b1;
			end
		end
	assign Enable = (downCount == 1'b0)?1'b1:1'b0;
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
			
				
	