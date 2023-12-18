module imagebuffer(
    input wire clock,
    input wire [16:0] rdaddress,
    input wire [16:0] wraddress,
    input wire [7:0] data, // Data width changed to 8 bits
    input wire wren,
    output reg [7:0] q // Output data width changed to 8 bits
);

parameter MEMORY_DEPTH = 131072; 

// Memory declaration
reg [7:0] memory [0:MEMORY_DEPTH-1];

// Write operation
always @(posedge clock) begin
    if (wren) begin
        memory[wraddress] <= data;
    end
end

// Read operation
always @(posedge clock) begin
    q <= memory[rdaddress];
end

endmodule
