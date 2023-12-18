// 
module part3 #(parameter CLOCK_FREQUENCY = 6)(
	input wire ClockIn, 
	input wire Reset, 
	input wire Start, 
	input wire [2:0] Letter, 
	output reg DotDashOut, 
	output reg NewBitOut
);

	wire slowClock;
	wire preSlowClock;
	wire [11:0] pload;
	wire [11:0] Q;
	reg [3:0] CounterValue;

	rateDivider #CLOCK_FREQUENCY gluck(ClockIn, Start, slowClock);
	mux pluck(Letter, pload);
	shiftReg fluck(pload, ClockIn, Reset, Q, Start, slowClock);

	always@(posedge ClockIn)
	begin
		if (Start)
			CounterValue <= 4'b0000;
		else if (slowClock)
			CounterValue[3:0] <= CounterValue + 1'b1;
		else if (CounterValue == 4'b1111)
			CounterValue[3:0] <= 4'b1101;
	end
	
	always@(posedge ClockIn)
	begin
		if (Reset)
			NewBitOut <= 0;
		else if (CounterValue < 4'd12) 
			NewBitOut <= slowClock;
		else if (CounterValue > 4'd11)
			NewBitOut <= 0;
	end
	
	always@(posedge ClockIn)
		if (Reset)
			DotDashOut = 0;
		else if (slowClock)
			DotDashOut <= Q[0];

endmodule

module rateDivider #(parameter CLOCK_FREQUENCY = 6) (
	input ClockIn,
	input start,
	output Enable);
	
	reg [31:0] downCount;
	
	always@(posedge ClockIn)
	begin
	if (start == 1'b1)
		begin
			downCount <= (CLOCK_FREQUENCY/2)-2;
		end
	
	
		else if (downCount == 32'd0)
		begin
			downCount <= (CLOCK_FREQUENCY/2)-1;
		end
		else
			begin
				downCount <= downCount - 1'b1;
			end
		end
	assign Enable = (downCount == 1'b0)?1'b1:1'b0;
endmodule 


module shiftReg(pload, clock, reset, Q, pEnable, slowClock);
	input [11:0] pload;
	input clock, reset, pEnable;
	output reg [11:0] Q;
	input slowClock;
	always @ (posedge clock)
	begin
		if(reset)
			Q <= 0; 
		else if (pEnable)
			Q <= pload;
		else if (slowClock)
		begin 
			Q[11] <= 0;
			Q[10] <= Q[11];
			Q[9] <= Q[10];
			Q[8] <= Q[9];
			Q[7] <= Q[8];
			Q[6] <= Q[7];
			Q[5] <= Q[6];
			Q[4] <= Q[5];
			Q[3] <= Q[4];
			Q[2] <= Q[3];
			Q[1] <= Q[2];
			Q[0] <= Q[1];
			
		end
	end 
endmodule 

module mux(letterSelect, pload);
	input [2:0] letterSelect;
	output reg [11:0] pload;
	
	always@(*)
	begin
		case(letterSelect)
			3'b000: pload <= 12'b000000011101;
			3'b001: pload <= 12'b000101010111;
			3'b010: pload <= 12'b010111010111;
			3'b011: pload <= 12'b000001010111;
			3'b100: pload <= 12'b000000000001;
			3'b101: pload <= 12'b000101110101;
			3'b110: pload <= 12'b000101110111;
			3'b111: pload <= 12'b000001010101;
			default: pload <= 12'd0;
		endcase
	end
endmodule

	
	
	
	
	
	
	
	
	
	
	
	
	