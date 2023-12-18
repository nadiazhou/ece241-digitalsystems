//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

module part2(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot,oDone);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire iResetn, iPlotBox, iBlack, iLoadX;
   input wire [2:0] iColour;
   input wire [6:0] iXY_Coord;
   input wire iClock;
   output wire [7:0] oX;          // VGA pixel coordinates
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire oPlot;       		 // Pixel draw enable
   output wire oDone;       		 // goes high when finished drawing frame

   //
   // Your code goes here
	wire blackout, start_plot;
	wire [7:0] incx, xpix;
	wire [6:0] incy, ypix;
	
	assign xpix = X_SCREEN_PIXELS;
	assign ypix = Y_SCREEN_PIXELS;
	
	control c0(
			.clk(iClock), 
			.reset(iResetn), 
			.iLoadX(iLoadX), 
			.iPlotBox(iPlotBox), 
			.iBlack(iBlack), 
			.blackout(blackout), 
			.start_plot(start_plot), 
			.oPlot(oPlot), 
			.oDone(oDone),
			.incx(incx),
			.incy(incy),
			.xpix(xpix),
			.ypix(ypix)
	);
			
	dataPath d0(
			.clk(iClock), 
			.reset(iResetn), 
			.color(iColour), 
			.coord(iXY_Coord), 
			.ld_x(iLoadX), 
			.ld_y(iPlotBox), 
			.blackout(blackout), 
			.start_plot(start_plot), 
			.oX(oX), 
			.oY(oY), 
			.oColor(oColour),
			.incx(incx),
			.incy(incy)
   );
   //

endmodule // part2

module control (clk, reset, iLoadX, iPlotBox, iBlack, blackout, start_plot, oPlot, oDone, incx, incy, xpix, ypix);

	input clk, reset, iLoadX, iPlotBox, iBlack;
	output reg blackout, start_plot, oPlot, oDone;
	output reg [7:0] incx, xpix;
	output reg [6:0] incy, ypix;
	
	reg [3:0] PS, NS;
	
	localparam  iReset        = 4'd0,
               LoadX   	  = 4'd1,
               WaitX    = 4'd2,
               LoadYC     = 4'd3,
               WaitYC     = 4'd4,
					Plot			  = 4'd5,
					Black	  = 4'd6,
					Done		  = 4'd7,
					BlackPlot	 = 4'd8;
					
	//state table
	always@(*)
		begin
			case (PS)
				iReset: NS <= iLoadX ? LoadX : iReset;
				LoadX: NS <= iLoadX ? LoadX : WaitX;
				WaitX: NS <= iPlotBox ? LoadYC : WaitX;
				LoadYC: NS <= iPlotBox ? LoadYC : WaitYC;
				WaitYC: NS <= Plot;
				Plot: 
					begin
						if (incx == 8'd3 && incy == 7'd3)
							NS <= Done;
						else
							NS <= Plot;
					end
				Done: NS <= iLoadX ? LoadX : Done;
				Black: NS <= BlackPlot;
				BlackPlot: 
					begin
						if (incx == xpix-1 && incy == ypix-1)
							NS <= Done;
						else
							NS <= BlackPlot;
					end
			default: NS <= iReset;
			endcase
		end
		
	always @(posedge clk)
		begin
			
			case (PS)
				iReset: begin
					oDone <= 0;
					oPlot <= 0;
					incx <= 0;
					incy <= 0;
					blackout <= 0;
					start_plot <= 0;
				end
				WaitYC: begin
					start_plot <= 1;
				end
				Plot: begin
					oPlot	<= 1;
					begin
						if (incx < 3) 
						begin
							incx <= incx + 1;
						end
						else 
						begin
							incy <= incy + 1;
							incx <= 0;
						end
					end
				end
				Done: 
				begin
					start_plot <= 0;
					oPlot <= 0;
					oDone <= 1;
					blackout <= 0;
					incx <= 0;
					incy <= 0;
				end
				Black: 
				begin
					start_plot <= 1;
					oPlot <= 0;
					oDone <= 0;
					blackout <= 1;
				end
				BlackPlot: 
				begin
					oPlot <= 1;
					begin
						if (incx < xpix-1) 
						begin
							incx <= incx + 1;
						end
						else 
						begin
							incy <= incy + 1;
							incx <= 0;
						end
					end
				end
			endcase
		end
	
	always @(posedge clk)
		begin
		
			if (reset == 0) 
			begin
				PS <= iReset;
			end
			else if (iBlack && !blackout) 
			begin
				PS <= Black;
			end
			else 
			begin
				PS <= NS;
			end
		end
		
endmodule
					
		
	
	

module dataPath (clk, reset, color, coord, ld_x, ld_y, blackout, start_plot, oX, oY, oColor, incx, incy);

	input clk, reset, ld_x, ld_y, blackout, start_plot;
	input [2:0] color;
	input [6:0] coord;
	input [7:0] incx;
	input [6:0] incy;
	
	output reg [7:0] oX;
	output reg [6:0] oY;
	output reg [2:0] oColor;
	
	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] c;
	
	
	always @(posedge clk) 
		begin
			if (!reset) 
				begin
					x <= 8'd0;
					y <= 7'd0;
					c <= 3'd0;
				end
			else if (blackout) 
				begin
					x <= 8'd0;
					y <= 8'd0;
					c <= 3'd0;
				end
			else 
				begin
					if (ld_x) 
						begin
							x <= {1'b0, coord};
						end
					if (ld_y) 
						begin
							y <= coord;			
							c <= color;
						end
				end
		end
		
	always @(posedge clk)
		begin
			
		if (!reset) 
			begin
				oX <= 8'd0;
				oY <= 7'd0;
				oColor <= 3'd0;
			end
		else if (start_plot) 
			begin		
				oX <= x + incx;
				oY <= y + incy;
				oColor <= c;
			end

		end
		
endmodule

