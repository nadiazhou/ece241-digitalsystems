// module has inputs for clock and reset 
// outputs for write, colour, x and y
// module has 2 BRAMS, which are pixel data 
// image buffer used for double buffering  - need a new module for this 

module db2(clock, reset, write, colour, x, y);
input clock;
input reset;
output write;
output [2:0] colour;
output [8:0] x;
output [7:0] y;

// not writing any data to initialized brams so a write data, write)address and write_enable will be set to 0 when reset, and will
// be set to 1 when the write signal is high

reg [2:0] write_data;
reg [16:0] write_address;
reg write_enable;

// read addresses
reg [16:0] address;

// individual data for bram
wire [2:0] loading_data;
wire [2:0] ending_data;



loadingbackground page(
	.address(address),
	.clock(clock),
	.data(write_data),
	.wren(write_enable),
	.q(loading_data)
	);

/*ending page(
	.address(address),
	.clock(clock),
	.data(write_data),
	.wren(write_enable),
	.q(ending_data)
	);*/

//image buffer read/ write register 
reg [14:0] image_read_address;
reg [14:0] image_read_data;
wire [14:0] image_write_address;
reg [2:0] image_write_data;
reg image_write_enable;

//extra variable to store colours read from Image buffer before passing them to the VGA Adapter's colour input
reg [2:0] colour_data;

/*image buffer
imagebuffer image1(
    .clock(clock),
    .data(image_write_data),
    .rdaddress(image_read_address),
    .wraddress(image_write_address),
    .wren(image_write_enable),
    .q(image_read_data)
);

//image buffer 2
imagebuffer image2(
    .clock(clock),
    .data(image_write_data),
    .rdaddress(image_read_address),
    .wraddress(image_write_address),
    .wren(image_write_enable),
    .q(image_read_data)
);*/

// signals to be used in always block to store temp values
reg [2:0] mif_data;
reg [32:0] counter;
reg current_state;
assign image_write_address = address;

// reading from brams and writing to Image Bram
always @(posedge clock) begin 
    if(reset) begin
        write_data <= 3'b0;
        address <= 17'b0;
        write_enable <= 1'b0;
        write_address <= 17'b0;
        image_write_data <= 3'b0;
        image_write_enable <= 1'b0;
        counter <= 33'b0;
    end
    else begin
        // Increment Read Address
        // Read colour values from both BRAMS at 50Mhz into their registers
        if(address < 19200) begin
            address <=  address + 1'b1;
        end else begin
            address <= 17'b0;
        end

        //Increment counter (alternate current state every second)
        if (counter < 50000000) begin
            counter <= counter + 1'b1;
        end else begin
            current_state = ~current_state;
            counter <= 33'b0;
        end

        /*Depending on state, load flag_data 
        // If current _state  == 1, read the data from lading output, else, read from ending
        if(current_state) begin
            mif_data <= loading_data;
        end else begin
            mif_data <= ending_data;
        end*/

        // Now we have the mif's colour data 
        // mif_data register, we need to store it  in the Image BRAM. [One Pixel at a time]
        image_write_enable <= 1'b1;
        image_write_data <= mif_data;
    end
    end

// Assigning X,Y colour and write signals outputed by module and read by (input to) VGA Adapter
assign x = image_read_address[7:0];
assign y = image_read_address[14:8];
assign colour = colour_data;
assign write = 1;

// coordinates of a 16x16 green box 
reg[2:0] green = 3'b010;
reg[8:0] x1 = 8'b000001000;
reg[7:0] y1 = 8'b0001000;

reg [8:0] x2 = 8'b0001111;
reg [7:0] y2 = 8'b0001111;

//reading from Image BRAM
always @(posedge clock) begin
    if(reset) begin
        image_read_address <= 15'b0;
        colour_data <= 3'b0;
    end else begin
        // Increment Read Address into colout_data register
        // Read colour values from Image 
        if(image_read_address < 19200) begin
            image_read_address <=  image_read_address + 1'b1;
        end else begin
            image_read_address <= 17'b0;
        end
        if(x==0 && y==0)begin
            colour_data <= 3'b010;
        end else begin
            colour_data <= image_read_data;
        end
        
    end
end 

endmodule