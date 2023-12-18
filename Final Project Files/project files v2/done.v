module done(
    input wire clock,
    input wire [16:0] rdaddress,
    input wire [16:0] wraddress,
    input wire [7:0] data,
    input wire wren,
    output wire [7:0] q
);

// BRAM instantiation
altsyncram #(
    .operation_mode("DUAL_PORT"),
    .width_a(8),              // 8-bit color depth
    .widthad_a(17),           // 17-bit address for sufficient pixel addressing
    .numwords_a(131072),      // Memory depth (adjust as needed)
    .width_b(8),
    .widthad_b(17),
    .numwords_b(131072),
    .lpm_type("altsyncram"),
    .outdata_reg_b("UNREGISTERED"),
    .indata_aclr_a("NONE"),
    .wrcontrol_aclr_a("NONE"),
    .address_aclr_a("NONE"),
    .address_aclr_b("NONE"),
    .outdata_aclr_b("NONE"),
    .intended_device_family("Cyclone V"),
    .init_file("done.mif")  // done.mif
									// play animation parsing 3 snake images leaving all at once?
									// maybe if have time later
) bram (
    .clock0(clock),
	 .clock1(clock),
    .address_a(wraddress),
    .data_a(data),
    .wren_a(wren),
    .address_b(rdaddress),
    .q_b(q)
);

endmodule