module db(clock, reset, write, colour, x, y);
    input clock;
    input reset;
    output write;
    output [2:0] colour;
    output [8:0] x;
    output [7:0] y;
	 
	 // Declare image_read_data as a register
    reg [2:0] image_read_data;

    // Registers and wires
    reg [2:0] write_data;
    reg [16:0] write_address;
    reg write_enable;
    reg [16:0] address;

    // BRAM outputs
    wire [2:0] home_data;
    wire [2:0] done_data;

    // Instantiate BRAMs
    home home(
        .clock(clock),
        .data(write_data),
        .rdaddress(address),
        .wraddress(write_address),
        .wren(write_enable),
        .q(home_data)
    );

    done done(
        .clock(clock),
        .data(write_data),
        .rdaddress(address),
        .wraddress(write_address),
        .wren(write_enable),
        .q(done_data)
    );

    // Image buffer read/write
    reg [16:0] image_read_address;
    reg [2:0] image_write_data;
    reg image_write_enable;

    // Define new wires for buffer outputs
    wire [2:0] image1_data;
    wire [2:0] image2_data;

    // Instantiate image buffers
    imagebuffer image1(
        .clock(clock),
        .data(image_write_data),
        .rdaddress(image_read_address),
        .wraddress(write_address),
        .wren(image_write_enable),
        .q(image1_data)
    );

    imagebuffer image2(
        .clock(clock),
        .data(image_write_data),
        .rdaddress(image_read_address),
        .wraddress(write_address),
        .wren(image_write_enable),
        .q(image2_data)
    );

    // Control signals
    reg [2:0] colour_data;
    reg [1:0] active_buffer;
    reg [2:0] page_data;
    reg [32:0] counter;
    reg current_state;
    assign image_write_address = address;

    // Main control logic
    always @(posedge clock) begin 
        if (reset) begin
            // Reset logic
            write_data <= 3'b0;
            address <= 17'b0;
            write_enable <= 1'b0;
            write_address <= 17'b0;
            image_write_data <= 3'b0;
            image_write_enable <= 1'b0;
            counter <= 33'b0;
            active_buffer <= 2'b00;
            image_read_address <= 17'b0;
            colour_data <= 3'b0;
        end else begin
            // Address and data handling logic
            // ... [your logic for handling addresses and data] ...

            // Buffer output selection
            if (active_buffer == 2'b00) begin
                image_read_data <= image1_data;
            end else begin
                image_read_data <= image2_data;
            end
        end
    end

    // Assigning outputs
    assign x = image_read_address[8:0];
    assign y = image_read_address[16:9];
    assign colour = colour_data;
    assign write = 1;


endmodule
/*// module has inputs for clock and reset 
// outputs for write, colour, x and y
// module has 2 BRAMS, each with pixel data
// image buffer used for double buffering  - need a new module for this 

module db(clock, reset, write, colour, x, y);
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
wire [2:0] home_data;
wire [2:0] done_data;

home home(
    .clock(clock),
    .data(write_data),
    .rdaddress(address),
    .wraddress(write_address),
    .wren(write_enable),
    .q(home_data)
);


done done(
.clock(clock),
.data(write_data),
.rdaddress(address),
.wraddress(write_address),
.wren(write_enable),
.q(done_data)
);



//image buffer read/ write register 
reg [16:0] image_read_address;
wire [2:0] image_read_data;
wire [16:0] image_write_address;
reg [2:0] image_write_data;
reg image_write_enable;

//extra variable to store colours read from Image buffer before passing them to the VGA Adapter's colour input
reg [2:0] colour_data;
reg [1:0] active_buffer; //2 bit signal to track active buffer

//image buffer
imagebuffer image1(
    .clock(clock),
    .data(image_write_data),
    .rdaddress(image_read_address),
    .wraddress(image_write_address),
    .wren(image_write_enable),
    .q(image_read_data)
);


imagebuffer image2(
    .clock(clock),
    .data(image_write_data),
    .rdaddress(image_read_address),
    .wraddress(image_write_address),
    .wren(image_write_enable),
    .q(image_read_data)
);

// signals to be used in always block to store temp values
reg [2:0] page_data;
reg [32:0] counter;
reg current_state;
assign image_write_address = address;

// reading from brams and writing to Image Bram
always @(posedge clock) begin 
    if (reset) begin
        write_data <= 3'b0;
        address <= 17'b0;
        write_enable <= 1'b0;
        write_address <= 17'b0;
        image_write_data <= 3'b0;
        image_write_enable <= 1'b0;
        counter <= 33'b0;
        active_buffer <= 2'b00; // Initialize to buffer 0
    end else begin
        // Increment Read Address
        // Read colour values from both BRAMS at 50Mhz into their registers
        if(address < 76800) begin
            address <=  address + 1'b1;
        end else begin
            address <= 17'b0;
        end

        //Increment counter (alternate current state every second)
		  // this reads in both screens at the same time ? benefit? still tbd
        if (counter < 50000000) begin
            counter <= counter + 1'b1;
        end else begin
            current_state = ~current_state;
            counter <= 33'b0;
        end

        // Depending on state, load data from the active buffer
        if (current_state) begin
            page_data <= home_data;
        end else begin
            page_data <= done_data;
        end

        // Update the active buffer
        if (write_enable) begin
            if (active_buffer == 2'b00) begin
                // Write to buffer 0
                image_write_enable <= 1'b1;
                image_write_data <= page_data;
            end else begin
                // Write to buffer 1
                // Modify image_write_enable and image_write_data for buffer 1
                image_write_enable <= 1'b1;
					 // Modify image_write_data for buffer 1 as needed
					 image_write_data <= ~page_data; // inverted to provide a clear distinction 
            end
        end
    end
end
/*always @(posedge clock) begin 
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
        if(address < 76800) begin
            address <=  address + 1'b1;
        end else begin
            address <= 17'b0;
        end

        //Increment counter (alternate current state every second)
		  // this reads in both screens at the same time ? benefit? still tbd
        if (counter < 50000000) begin
            counter <= counter + 1'b1;
        end else begin
            current_state = ~current_state;
            counter <= 33'b0;
        end

        // Depending on state, load data
        // If current _state  == 1, read the data from Bram's output, else, read from other BRAM
        if(current_state) begin
            page_data <= home_data;
        end else begin
            page_data <= done_data;
        end

        // Now have page data from both screens 
        // register, we need to store it in the Image BRAM. [One Pixel at a time]
        image_write_enable <= 1'b1;
        image_write_data <= page_data;
    end
    end*/

/* Assigning X,Y colour and write signals outputed by module and read by (input to) VGA Adapter
assign x = image_read_address[8:0];
assign y = image_read_address[16:9];
assign colour = colour_data;
assign write = 1;

// coordinates of a 16x16 green box for placeholder? 
reg[2:0] green = 3'b010;
reg[8:0] x1 = 8'b000001000;
reg[7:0] y1 = 8'b0001000;

reg [8:0] x2 = 8'b0001111;
reg [7:0] y2 = 8'b0001111;*/

/*reading from Image BRAM
always @(posedge clock) begin
    if(reset) begin
        image_read_address <= 17'b0;
        colour_data <= 3'b0;
    end else begin
        // Increment Read Address into colout_data register
        // Read colour values from Image 
        if(image_read_address < 76800) begin
            image_read_address <=  image_read_address + 1'b1;
        end else begin
            image_read_address <= 17'b0;
        end
        if(x==0 && y==0) begin
            colour_data <= 3'b010;
        end else begin
            colour_data <= image_read_data;
        end
		  
        
    end
end*/
/*
always @(posedge clock) begin
    if (reset) begin
        // Reset conditions
        image_read_address <= 17'b0;
        colour_data <= 3'b0;
    end else begin
        // Increment Read Address into colour_data register
        // Read colour values from Image
        if (x == 0 && y == 0) begin
            colour_data <= 3'b010; // Default green color
        end else begin
				if(active_buffer == 2'b00) begin
            colour_data <= image_read_data; // Assign from image buffer
				end else begin
				colour_data <= image_read_data;
        end
    end
end
end

endmodule*/