module KeyDecoder (
    input clk,
    input reset,
    input [7:0] received_data,
    input received_data_en,
	 
	 inout PS2_CLK,
	 inout PS2_DAT,
	 
    output reg up_arrow,
    output reg down_arrow,
    output reg left_arrow,
    output reg right_arrow,
	 
	 output reg a,
	 output reg w,
	 output reg s,
	 output reg d,
	 
	 output reg[1:0] iADirection,  //2 bit array
	 output reg[1:0] iBDirection
	
);



	wire [7:0] key_data;
	wire key_pressed;
	
	assign key_data = received_data;
	assign key_pressed = received_data_en;
	
	
// State to track if the next byte is part of a multi-byte scan code
	reg [7:0] last_data_received;
	
	

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
		  iADirection <= 2'b10; //initialize to down
		  iBDirection <= 2'b10;
		  last_data_received <= 8'h00;
    end
    else if (key_pressed) begin
        last_data_received <= key_data;
   
    
    // data recieved, output reg set to 1 
            case (last_data_received)
                // player 1
					 UP_ARROW_CODE:    
                begin 
					 up_arrow <= 1;
					 iADirection <= 2'b11;
                end 
                DOWN_ARROW_CODE:
					 begin 
					 down_arrow <= 1;
					 iADirection <= 2'b10;
                end	 
                LEFT_ARROW_CODE:
					 begin 
					 left_arrow <= 1;
					 iADirection = 2'b01;
                end	 
                RIGHT_ARROW_CODE:
					 begin 
					 right_arrow <= 1;
					 iADirection <= 2'b00;
                end	 
					 
					 //player 2
					 A_CODE:  
					 begin 
					 a <= 1;
					 iBDirection <= 2'b11;
                end 
                W_CODE:  
					 begin 
					 w <= 1;
					 iBDirection <= 2'b10;
                end 
                S_CODE:
					 begin 
					 s <= 1;
					 iBDirection <= 2'b01;
                end 
                D_CODE:
					 begin 
					 d <= 1;
					 iBDirection <= 2'b00;
                end 
					 
                default: begin
                    up_arrow <= 0;
                    down_arrow <= 0;
                    left_arrow <= 0;
                    right_arrow <= 0;
						  a <= 0;
						  w <= 0;
						  s <= 0;
						  d <= 0;
						  iADirection <= 2'b10; //initialize to down
						  iBDirection <= 2'b10;
                end
            endcase
	end
end
    


	PS2_Controller ps2_controller (
		  .CLOCK_50(CLOCK_50),
        .reset(reset),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .received_data(key_data),
        .received_data_en(key_pressed)
	);

endmodule

