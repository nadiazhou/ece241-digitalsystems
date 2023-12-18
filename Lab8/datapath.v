module dataPath (clk, reset, color, coord, ld_x, ld_y, blackout, start_plot, oX, oY, oColor, incx, incy);

	input clk, reset, ld_x, ld_y, blackout, start_plot;
	input [2:0] color;
	input [6:0] coord;
	input [7:0] incx;
	input [6:0] incy;
	
	output reg [7:0] oX;
	output reg [6:0] oY;
	output reg [2:0] oColor;
	
	// reg DirH and DirY 

	reg [1:0] DirH; // horizontal
	reg [1:0] DirY; // vertical
	
	
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