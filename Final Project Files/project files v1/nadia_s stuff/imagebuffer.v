module imagebuffer(
    input wire clock,
    input wire [16:0] rdaddress,
    input wire [16:0] wraddress,
    input wire [7:0] data, // Data width changed to 8 bits
    input wire wren,
    output reg [7:0] q // Output data width changed to 8 bits
);

// Parameter for memory depth to match 8-bit data width and 17-bit address.
// This is more than you'll need for a 10-bit address space, but it's here to match your provided address width.
parameter MEMORY_DEPTH = 131072; // For a 17-bit address, 2^17 memory locations

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
