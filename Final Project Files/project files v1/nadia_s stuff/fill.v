

module fill
	(
		CLOCK_50,						//	On Board 50 MHz								[1]
		
		KEY,								// On Board Keys									[2]
		SW,								// 													[3]
		
		VGA_CLK,   						//	VGA Clock										[4]
		VGA_HS,							//	VGA H_SYNC										[5]
		VGA_VS,							//	VGA V_SYNC										[6]
		VGA_BLANK_N,					//	VGA BLANK										[7]
		VGA_SYNC_N,						//	VGA SYNC										   [8]
		VGA_R,   						//	VGA Red[7:0]							   	[9]
		VGA_G,	 						//	VGA Green[7:0]							   	[10]
		VGA_B,   						//	VGA Blue[7:0]									[11]
		
		colour,							// ps2 output wires to the controller 		[12]
		x,									// output x											[13]
		y,									// output y											[14]
		write,							// output write									[15]
		
		PS2_CLK,					      // Clock												[16]		
		PS2_DAT,							// Data												[17]
		LEDR,								// LED indicator 									[18]
		received_data,					// data input from PS2 controller 			[19]
		
		up_arrow,						// ps2 inputs										[20]
		down_arrow,						// 													[21]
		left_arrow,						// 													[22]
		right_arrow,					//														[23]
		
		a,									//														[24]
		w,									//														[25]
		s,									//														[26]
		d									//														[27]
	);
	
	input			CLOCK_50;			//	50 MHz
	input	[3:0]	KEY;	
	input [9:0] SW;

	output			VGA_CLK;   		//	VGA Clock
	output			VGA_HS;			//	VGA H_SYNC
	output			VGA_VS;			//	VGA V_SYNC
	output			VGA_BLANK_N;	//	VGA BLANK
	output			VGA_SYNC_N;		//	VGA SYNC
	output	[7:0]	VGA_R;   		//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 		//	VGA Green[7:0]
	output	[7:0]	VGA_B;   		//	VGA Blue[7:0]		

	output wire [2:0] colour;
	output wire [7:0] x;
	output wire [6:0] y;
	output wire write;    // WAHT does this even do 
	
	inout PS2_CLK;
	inout PS2_DAT;
	
	wire writeEn;
	
	output reg [1:0] LEDR;
	output wire [7:0] received_data;
	
	output wire up_arrow;
   output wire down_arrow;
   output wire left_arrow;
   output wire right_arrow;
	
	output wire a;
	output wire w;
	output wire s;
	output wire d;
	
	wire received_data_en;
	
	// PS2_Controller instance
	PS2_Controller #(.INITIALIZE_MOUSE(0)) ps2_controller (
		  .CLOCK_50(CLOCK_50),
        .reset(reset),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .received_data(received_data),
        .received_data_en(received_data_en)
	);
	
	// Two instances of key decoder for multiplayer 
	// map recieve data do arrow keys  
	KeyDecoder key_decoder (
    .clk(CLOCK_50),
    .reset(reset),
    .received_data(received_data),
    .received_data_en(received_data_en),
	 
	 .up_arrow(up_arrow),			// Player 1
    .down_arrow(down_arrow),
    .left_arrow(left_arrow),
    .right_arrow(right_arrow),
	 
	 .a(a),                  		// Player 2 
	 .w(w),
	 .s(s),
	 .d(d)
	 
	);
	
	// Will flash LED when key pressed - indicator\
	// LED active Low 
	wire any_player1_pressed = ~up_arrow | ~down_arrow | ~left_arrow | ~right_arrow;
	wire any_player2_pressed = ~a | ~w | ~s | ~d;

	always @(posedge CLOCK_50) begin
		 if (reset) begin
			  LEDR[1] <= 1;
		 end
		 else if (any_player1_pressed) begin
			  LEDR[1] <= ~LEDR[1];  // Toggle LED on key press
		 end
		 else if (any_player2_pressed) begin
			  LEDR[0] <= ~LEDR[0];  // Toggle LED on key press
		 end
	end
	
	// Need an instance for VGA adapter 
	wire resetn;						// resetn
	assign resetn = KEY[0];	
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "snake-3.mif";
	
	
	// also need one for alternating screens - store first instance of home page in Bram
	// takes from the mif and outputs the coordinates one at a time from the bram
	
	db doublebuffer(
	.clock(CLOCK_50),
	.reset(resetn),
	.write(writeEn),  // careful, this might not be the same writeEn frm the part 2 instatiation
	.colour(colour),  //  the following are outputs
	.x(x),
	.y(y)
	);
	
	
	// instantiate the datapath and control module
	// double buffering static images 

endmodule

module KeyDecoder (
    input clk,
    input reset,
    input [7:0] received_data,
    input received_data_en,
	 
    output reg up_arrow,
    output reg down_arrow,
    output reg left_arrow,
    output reg right_arrow,
	 
	 output reg a,
	 output reg w,
	 output reg s,
	 output reg d
);

// State to track if the next byte is part of a multi-byte scan code
	reg extended_code;

	localparam UP_ARROW_CODE    = 8'h75;
	localparam DOWN_ARROW_CODE  = 8'h72;
	localparam LEFT_ARROW_CODE  = 8'h6B;
	localparam RIGHT_ARROW_CODE = 8'h74;
	localparam A_CODE 			 = 8'h1C;
	localparam W_CODE				 = 8'h1D;
	localparam S_CODE				 = 8'h1B;
	localparam D_CODE				 = 8'h23;
	localparam EXTENDED_CODE    = 8'hE0;
	
	

always @(posedge clk) begin
    if (reset) begin
        up_arrow <= 0;
        down_arrow <= 0;
        left_arrow <= 0;
        right_arrow <= 0;
		  a <= 0;
		  w <= 0;
		  s <= 0;
		  d <= 0;
        extended_code <= 0;
    end
    else if (received_data_en) begin
        if (received_data == EXTENDED_CODE) begin
            extended_code <= 1;
        end
        else if (extended_code) begin
            // Check for specific arrow key scan codes
            case (received_data)
                UP_ARROW_CODE:    up_arrow <= 1;
                DOWN_ARROW_CODE:  down_arrow <= 1;
                LEFT_ARROW_CODE:  left_arrow <= 1;
                RIGHT_ARROW_CODE: right_arrow <= 1;
					 A_CODE:    a <= 1;
                W_CODE:  w <= 1;
                S_CODE:  s <= 1;
                D_CODE: d <= 1;
					 
                default: begin
                    up_arrow <= 0;
                    down_arrow <= 0;
                    left_arrow <= 0;
                    right_arrow <= 0;
						  a <= 0;
						  w <= 0;
						  s <= 0;
						  d <= 0;
                end
            endcase
            extended_code <= 0;
        end
    end
end


endmodule

  
