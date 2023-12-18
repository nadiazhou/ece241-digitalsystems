
module kbDecoder(output_keyboard, left, right, up, down, w, s, a, d, enter, space, iADirection, iBDirection, start);

input [7:0] output_keyboard;
output reg left, right, up, down, w, s, a, d, enter, space;
output reg [1:0] iADirection, iBDirection;
output reg start;

always @(*) begin

	left = 1'b0;
	right = 1'b0;
	up = 1'b0;
	down = 1'b0;
	enter = 1'b0;
	space = 1'b0;
	
	case(output_keyboard)
	
		8'h75: begin up = 1'b1;  iADirection <= 2'b11; end
		8'h72: begin down = 1'b1; iADirection <= 2'b10; end
		8'h6b: begin left = 1'b1;iADirection = 2'b01; end
		8'h74: begin right = 1'b1; iADirection <= 2'b00; end
		
		
		8'h1D: begin w = 1'b1;  iBDirection <= 2'b11; end
		8'h1B: begin s = 1'b1; iBDirection <= 2'b10; end
		8'h1C: begin a = 1'b1;iBDirection = 2'b01; end
		8'h23: begin d = 1'b1; iBDirection <= 2'b00; end
		
		
		8'h5a: begin enter = 1'b1;  end
		8'h29: begin space = 1'b1;  end 
		
	endcase
	
end
endmodule

module PS2_Demo (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	last_data_received,
	last_data_en
	
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

output reg			[7:0]	last_data_received;
output 						last_data_en;



/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire 		[7:0]	ps2_key_data;
wire 				ps2_key_pressed;

// Internal Registers

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
	reg [4:0] current_state, next_state;
	reg pressingSig, resettingSig;
	
	localparam S_WAIT = 5'd0,
				  S_PRESSING = 5'd1,
				  S_RELEASE = 5'd2,
				  S_RESET = 5'd3;

	
	always @(*) begin 
	
		case (current_state)
			S_WAIT : next_state =  ps2_key_pressed ? S_PRESSING : S_WAIT;
			S_PRESSING : next_state = (ps2_key_data == 8'hf0) ? S_RELEASE : S_PRESSING;
			S_RELEASE : next_state = (ps2_key_data != 8'hf0) ? S_RESET: S_RELEASE;
			S_RESET : next_state = ps2_key_pressed ? S_WAIT: S_RESET  ;
		endcase
	 
	end
	 
	always @(*) begin 
	 
		
		pressingSig = 1'b0;
		resettingSig = 1'b0;
		
		case(current_state)
			S_PRESSING: pressingSig = 1'b1; 
			S_RESET: resettingSig = 1'b1;
		endcase
	
	end
	  
	always @(posedge CLOCK_50) begin 
			current_state <= next_state;
	end



	always @(posedge CLOCK_50)  

	begin
	if (KEY[0] == 1'b0 || resettingSig )
		last_data_received <= 8'h00;
	else
		last_data_received <= ps2_key_data;
	end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);



endmodule

