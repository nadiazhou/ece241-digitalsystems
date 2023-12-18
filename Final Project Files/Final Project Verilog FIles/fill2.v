module fill2
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
		received_data,					// data input from PS2 controller 			[19]												[23]
		
		HEX3, HEX2, HEX1, HEX0,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
		
	);
	
input	wire			AUD_ADCDAT;

// Bidirectionals
inout	wire			AUD_BCLK;
inout	wire			AUD_ADCLRCK;
inout		wire		AUD_DACLRCK;

inout		wire		FPGA_I2C_SDAT;

// Outputs
output		wire		AUD_XCK;
output		wire		AUD_DACDAT;

output		wire		FPGA_I2C_SCLK;




	
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

	//output reg [2:0] colour;
	//output reg [7:0] x;
	//output reg [6:0] y;
	
	output wire [2:0] colour;
	output wire [7:0] x;
	output wire [6:0] y;
	
	output wire [6:0] HEX3, HEX2, HEX1, HEX0;
	
	inout PS2_CLK;
	inout PS2_DAT;
	
	wire writeEn;
				
	
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
		defparam VGA.BACKGROUND_IMAGE = "loading.mif";
		
	
	output reg [3:0] LEDR;
	output wire [7:0] received_data;
	output wire write;
	
	
	wire a;
	wire w;
	wire s;
	wire d;
	
	wire received_data_en;
	
	//newwwwww
	//assign writeEnn = 1'b1;
	wire left, right, up, down, enter, space;
	wire [7:0] output_keyboard;
		
	wire [1:0] iADirection;
	wire [1:0] iBDirection;
	wire start;
	
	PS2_Demo inputsfromKB(CLOCK_50, KEY[0], PS2_CLK, PS2_DAT, output_keyboard);
	kbDecoder kd(output_keyboard, left, right, up, down, w, s, a, d, enter, space, iADirection, iBDirection, start);


	// Need an instance for VGA adapter 
	wire resetn;						// resetn
	assign resetn = KEY[0];	
	
	// start enable
	wire draw_background, erase;
	wire [2:0] background_color;
	
	// plot enable
	wire erase_plot;
	
	// done states
	wire done_erase;
	
	// wire [8:0] background color
	wire [7:0] x_background;
	wire [6:0] y_background;
	

	/* //loading mifs
	always @(*)
	begin

			colour <= background_color;
			x <= x_background;
			y <= y_background;
	
	end*/
	
	//load_background load_background0(.draw_background(draw_background), .resetn(resetn), .clock(CLOCK_50), 
		//.out_color(background_color), .done_erase(done_erase), .final_x(x_background), .final_y(y_background), .erase_plot(erase_plot));
		
	wire enable;
				
	project p2 (
		.iClock(CLOCK_50),
		.iStart(enter),
		.iReset(!KEY[0]),
		.iCheat(!KEY[3]),
		.iSpeedup(!KEY[2]),
		.iADirection(iBDirection),
		.iBDirection(iADirection),
		.oX(x),
		.oY(y),
		.oColor(colour),
		.oPlot(writeEn),
		.oDone(done),
		.HEX3(HEX3), 
		.HEX2(HEX2), 
		.HEX1(HEX1), 
		.HEX0(HEX0),
		.audioenable(enable)
	);
	
	
	DE1_SoC_Audio_Example aud(
	// Inputs
	CLOCK_50,
	KEY, enable,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	SW
);
	
	 /*db2 db2_instance (
        .clock(clock),
        .reset(reset),
        .write(write),
        .icolour(colour),
        .ix(x),
        .iy(y)
    );*/
	 
	 
	// also need one for alternating screens - store first instance of home page in Bram
	// takes from the mif and outputs the coordinates one at a time from the bram
	

endmodule

module load_background(draw_background, resetn, clock, out_color, done_erase, erase_plot, final_x, final_y);
	
	input clock, resetn, draw_background;
	output reg [2:0] out_color; // 3 bit cpolor
	
	//output [10:0] final_x, final_y;
	output [7:0] final_x;
	output [8:0] final_y;
	output reg done_erase, erase_plot;
	
	//reg [9:0] counter_x, counter_y, counter;
	reg [7:0] counter_x;
	reg [8:0] counter_y;
	
	reg [14:0] memory_address;
	
	wire [2:0] color_play;
	
	always@(posedge clock)
	begin
		if (resetn)
		begin
			erase_plot <= 1'b0;
			out_color <= 2'b0;
			done_erase <= 1'b0;
			counter_x <= 8'b0;
			counter_y <= 9'b0;
			memory_address <= 15'b0;
		end
			
		if (draw_background)
		begin
			erase_plot <= 1'b1;
			out_color <= color_play;
			memory_address <= memory_address + 1;
			
				if (counter_x < 8'd255)
					 counter_x <= counter_x + 1;
				else if (counter_x == 8'd255 && counter_y < 9'd511)
				begin
					 counter_x <= 8'b0;
					 counter_y <= counter_y + 1;
				end
				else if (counter_x == 8'd255 && counter_y == 9'd511)
				begin
					 erase_plot <= 1'b0;
					 done_erase <= 1'b1;
				end

		end
		
	end
	assign final_x = counter_x - 8'd3;
	assign final_y = counter_y;
	
	loadingbackground b0 (.address(memory_address), .clock(clock), .data(3'b0), .wren(1'b0), .q(color_play));
	//gameover g0 (.address(memory_address), .clock(clock), .q(color_end));
endmodule


