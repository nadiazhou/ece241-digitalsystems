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
