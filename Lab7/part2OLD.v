module part2(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot,oDone);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire iResetn, iPlotBox, iBlack, iLoadX;
   input wire [2:0] iColour;
   input wire [6:0] iXY_Coord;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel iXY_Coordinates
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output reg 	   oPlot;       // Pixel Plot enable
   output wire       oDone;       // goes high when finished Ploting frame
	
   //
   // Your code goes here
   //
	
	wire [7:0] X;
	wire [6:0] Y;
	wire oLoadX, oLoadYC, oBlack;
	
			
	               
	ControlPath cp(iClock, 
						iResetn, 
						iPlotBox, 
						iBlack, 
						iLoadX, 
						oLoadX, 
						oLoadYC, 
						Plot, 
						clearset,
						clear,
						oDone);
	ControlPath cp(iClock, iResetn, iPlotBox, iBlack, iLoadX, oLoadX, oLoadYC, oPlot, oBlack);
	DataPath dp(iResetn, oPlot, oBlack, oLoadYC, oLoadX, iClock, iColour, iXY_Coord, oX, oY, oColour);

endmodule // part2




module ControlPath(iClock, iResetn, iPlotBox, iBlack, iLoadX, oLoadX, oLoadYC, oPlot, oBlack);
input iClock, iResetn, iPlotBox, iBlack, iLoadX; 
output reg oLoadX, oLoadYC, oPlot, oBlack;

reg [2:0] PS, NS;
parameter   Reset  = 3'd0,
				LoadX = 3'd1,
				WaitX = 3'd2,
				LoadYC = 3'd3,
				Plot  = 3'd5,
				Done  = 3'd6,
				Black = 3'd7;


	
					
	// State Table
	always@(*)
		begin: state_table
			case (PS)
				Reset: begin
				NS = Reset;
				end
				LoadX: NS = iLoadX ? LoadX : WaitX;
				WaitX: NS = iPlotBox?LoadYC:WaitX;
				LoadYC: NS = iPlotBox?LoadYC:Plot;
				Plot: NS = Plot;
				Done: NS = Done;
				
			endcase
		end // state_table
	
	always @(*)
		begin: enable_signals
      // By default make all our signals 0
      oLoadX = 1'b0;
      oLoadYC = 1'b0;
		oPlot = 1'b0;
		oBlack = 1'b0;
			
      case (PS)
			WaitX: begin
				oLoadX = 1'b1;
				end
			LoadYC: begin
				oLoadYC = 1'b1;
				end
			Plot: begin
				oPlot = 1'b1;
				end
			Black: begin
				oBlack = 1'b1;
				oPlot = 1'b1;
				end
			
		endcase
	end

	always @(posedge iClock)
		begin: state_FFs
			if(iResetn == 1'b1)
				PS <= LoadX; // Should set Reset state to state A
			else if (iBlack)
				PS <= Clear;
			else if (iLoadX)
				PS <= LoadX;
			else
				PS <= NS;
	end // state_FFS


endmodule 


module DataPath (

	input iReset, iPlot, iBlack, iLoadYC, iLoadX, clock,
	
	input [2:0] iColor,
	input [6:0] iXY_Coord, 
	
	output reg [7:0] regX, 
	output reg [6:0] regY,
	output reg [2:0] regC,
	
	output reg oDone);
	
	
	wire [2:0] C;
	wire [7:0] X; //xiXY_Coord
	wire [6:0] Y; //yiXY_Coord
	reg [5:0] xypixel;
	reg [7:0] xblkpix;
	reg [6:0] yblkpix;
	

		
	
				
		
	register8bit xiXY_Coord({0,iXY_Coord}, iLoadX, clock, iReset, X);
	register7bit yiXY_Coord(iXY_Coord, iLoadYC, clock, iReset, Y);
	register3bit color(iColor, iLoadYC, clock, iReset, C);
	
	
	
	
	always@(posedge clock)
		begin
			if (iPlot) 
			begin
				if (xypixel < 5'd1000)
					xypixel <= xypixel + 1;
				else 
					begin
					xypixel <= 0;
					end
			end
		end
	
	
	always@(posedge clock)
		begin
			if (iBlack) 
			begin
				if (xblkpix < 8'd160)
					xblkpix <= xblkpix + 1;
				else if (xblkpix == 8'd160 && yblkpix < 7'd120)
					begin
					yblkpix <= yblkpix + 1;
					xblkpix <= 0;
					end
				else 
					begin
					xblkpix <= 0;
					yblkpix <= 0;
					end
			end
		end
	
	
	always@(*)
		begin
			if (iPlot)
			case(iBlack)
				0: begin
					regX <= X + xypixel[1:0];
					regY <= Y + xypixel[3:2];
					regC <= C;
					end
				1: begin
					regX <= xblkpix;
					regY <= yblkpix;
					regC <= 3'b000;
					end
				endcase
		end
		

 
endmodule


module register8bit(pre, enable, clock, Reset, out); 

	input [7:0] pre;
	input enable, clock, Reset;
	output reg [7:0] out;

	always@(posedge clock)
	begin
		if (Reset) out <= 8'b00000000;
		else if (enable) out <= pre;
		else out <= out;
	end
endmodule

module register7bit(pre, enable, clock, Reset, out); 

	input [6:0] pre;
	input enable, clock, Reset;
	output reg [6:0] out;

	always@(posedge clock)
	begin
		if (Reset) out <= 7'b0000000;
		else if (enable) out <= pre;
		else out <= out;
	end
endmodule

module register3bit(pre, enable, clock, Reset, out); 

	input [2:0] pre;
	input enable, clock, Reset;
	output reg [2:0] out;

	always@(posedge clock)
	begin
		if (Reset) out <= 3'b000;
		else if (enable) out <= pre;
		else out <= out;
	end
endmodule
