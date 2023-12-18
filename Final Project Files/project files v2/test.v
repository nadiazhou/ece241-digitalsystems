// module has inputs for clock and reset 
// outputs for write, colour, x and y
// image buffer used for double buffering  - need a new module for this 

module part2(iResetn, iClock, oX,oY, oColour,oPlot,oDone, write);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire iResetn;
   //input wire [2:0] iColour;
   //input wire [6:0] iXY_Coord;
   input wire	     iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output reg 	     oPlot;       // Pixel draw enable
   output wire       oDone;
	
wire [2:0] on_colour;

wire [2:0] write_data;
wire [14:0] write_address;
input wire write;

assign write_enable = 0;

reg [14:0] address;

reg [7:0] x_address;
reg [6:0] y_address;

reg [2:0] colour_reg;

loading on(
	.clock(iClock),
	.address(address),
	.q(on_colour)
	);

always@(posedge iClock) begin

	if (iResetn) begin
		address <= 0;
		y_address <= 0;
		x_address <= 0;
		colour_reg <= 0;
		end
		
	else begin
	
		if (address < 15'd19199) begin
			address <= address + 1'b1;
			end
		else begin
			address <= 0;
			end
		
		if (x_address < 8'd159) begin
			x_address <= x_address + 1;
			end
		else begin
			if (y_address < 7'd119) begin
//				y_address <= y_address + 1;
			end
			else begin
				y_address <= 0;
			end
			x_address <= 0;
			end
		end
		
	colour_reg <= on_colour;
	
	//oPlot <= wire_oPlot;
end
// Assigning X,Y colour and write signals outputed by module and read by (input to) VGA Adapter
assign oX = x_address;
assign oY = y_address;
assign oColour = colour_reg;
assign oDone = 0;

endmodule