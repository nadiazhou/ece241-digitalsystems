//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

module project(iReset,iClock,iDirection,oX,oY,oColor,oPlot,oDone);

   input wire iReset;
   input wire iClock;
   input wire [1:0] iADirection, iBDirection; // 2'b00 = right, 2'b01 = left, 2'b10 = up, 2'b11 = down

   // VGA output signals
   output wire [7:0] oX;           // VGA pixel coordinates 160x120
   output wire [6:0] oY;
   output wire [2:0] oColor;       // VGA pixel colour (0-7)
   output wire oPlot;       	    // Pixel draw enable
   
   output wire oDone;       		 // goes high when finished drawing frame


   // Your code goes here
	wire [7:0] incx, Aheadx, Bheadx, randx;
	wire [6:0] incy, Aheady, Bheady, randy;
   wire [9:0] Aaddress, Baddress;
   wire [7:0] Adata, Aq, Acurrent, Bdata, Bq, Bcurrent;
   wire wren;
	
	
	wire [6:0] PS, NS;

   memory m0(
       .address(Aaddress),
       .clock(iClock),
       .data(Adata),
       .wren(Awren),
       .q(Aq)
    );
   memory m1(
       .address(Baddress),
       .clock(iClock),
       .data(Bdata),
       .wren(Bwren),
       .q(Bq)
    );
	 

	control c0(
		.iClock(iClock), 
		.iReset(iReset), 
		.iADirection(iADirection), 
		.iBDirection(iBDirection), 
		.oPlot(oPlot), 
		.oDone(oDone),
		.oColor(oColor),
		.oX(oX),
		.oY(oY),
		.incx(incx),
		.incy(incy),
		.Aheadx(Aheadx),
		.Aheady(Aheady),
		.Bheadx(Bheadx),
		.Bheady(Bheady),
		.PS(PS),
		.NS(NS),
		.Aaddress(Aaddress),
		.Acurrent(Acurrent),
		.Adata(Adata),
		.Aq(Aq),
		.Awren(Awren),
		.Baddress(Baddress),
		.Bcurrent(Bcurrent),
		.Bdata(Bdata),
		.Bq(Bq),
		.Bwren(Bwren)
	);
	
			
	/* data d0(
		.iClock(iClock), 
		.iReset(iReset), 
		.color(iColour), 
		.coord(iXY_Coord), 
		.ld_x(iLoadX), 
		.ld_y(iPlotBox), 
		.blackout(blackout), 
		.start_plot(start_plot), 
		.oX(oX), 
		.oY(oY), 
		.oColor(oColour),
		.incx(incx),
		.incy(incy)
   );
   */

endmodule // part2

module control(iClock, iReset, iADirection, iBDirection, oPlot, oDone, oColor, oX, oY, incx, incy, Aheadx, Aheady, Bheadx, Bheady, PS, NS, Aaddress, Acurrent, Adata, Aq, Awren, Baddress, Bcurrent, Bdata, Bq, Bwren, foodx, foody, randx, randy);

	input iClock, iReset;
	input [1:0] iDirection;
	output reg oPlot, oDone;
	output reg [2:0] oColor;
	output reg [7:0] oX, incx, headx, foodx, randx;
	output reg [6:0] oY, incy, heady, foody, randy;
	
	
   reg gameover;
	output reg wren;
	output reg [6:0] PS, NS;
   output reg [9:0] address;
	output reg [7:0] current, data;
   input [7:0] q;
	
	reg [7:0] length, foodoffset;

	reg [25:0] waitcounter;
    
   localparam  
		Sreset = 6'd0,
      Ssetup = 6'd1,
      Supdate = 6'd2,
      Scheckbounds = 6'd3,
      Scycleaddress = 6'd4,
      Supdatedata = 6'd5,
      Scheckdata = 6'd6,
		Sprinthead = 6'd7,
		Swait = 6'd8,
      Sgameover = 6'd9,
		Sleavebody = 6'd10,
		Sbodywait = 6'd11,
		Swaitmem = 6'd12,
		Sgrabcurrent = 6'd13,
		Sprintfood = 6'd14;
		


    //state table
	always@(*)
		begin
			case (PS)
				Sreset: NS <= iReset ? Sreset : Ssetup;
            Ssetup: NS <= Supdate;
            Supdate: NS <= Scheckbounds;
            Scheckbounds: 
					begin
						if (headx < 0 || headx > 19 || heady < 0 || heady > 14)
							 begin
								  NS <= Sgameover;
							 end
						else
							 begin
								  NS <= Scycleaddress;
							 end
					end
            Scycleaddress: 
					begin
						if (incx > 18 && incy > 14)
							NS <= Sprintfood;
						else
							NS <= Swaitmem;
					end
				Swaitmem:
					NS <= Sgrabcurrent;
				Sgrabcurrent: NS <= Supdatedata;
            Supdatedata: NS <= Scheckdata;
            Scheckdata:
			   begin
					if (headx == incx && heady == incy) // body collision
						begin
							if (current > 0)
								begin
									NS <= Sgameover;
								end
							else
								NS <= Sleavebody;
						end
					else
						begin
							NS <= Scycleaddress;
						end
			   end
				Sprintfood: NS <= Sprinthead;
				Sprinthead: NS <= Swait;
				Swait: 
					begin
						if (waitcounter > 26'd50000000)
							NS <= Supdate;
						else
							NS <= Swait;
					end
				Sgameover: NS <= Sgameover;
				Sleavebody: NS <= Sbodywait;
				Sbodywait: NS <= Scycleaddress;

				default: NS <= iReset;
			endcase
		end



    always @(posedge iClock)
		begin
			case (PS)
				Sreset: 
					begin
						oDone <= 0;
						oPlot <= 0;
						incx <= 0;
						incy <= 0;
						oX <= 8'd20;
						oY <= 7'd20;
						oColor <= 3'b111;
						length <= 5;
						data <= 0;
						foodoffset <= 0;
						randx <= 0;
						randy <= 0;
					end
				Ssetup:
					begin
						headx <= 10;
						heady <= 10;
						foodx <= 7;
						foody <= 7;
						oColor <= 3'b101;
					end
				Supdate:
					begin
						address <= 0;
						incx <= 0;
						incy <= 0;
						if (iDirection == 2'b00)
							 begin
								  headx <= headx + 1;
							 end
						if (iDirection == 2'b01)
							 begin
								  headx <= headx - 1;
							 end
						if (iDirection ==  2'b10)
							 begin
								  heady <= heady + 1;
							 end
						if (iDirection == 2'b11)
							 begin
								  heady <= heady - 1;
							 end
					end
				Scheckbounds:
					begin
						oPlot <= 0;
						if (headx == foodx && heady == foody) 
							begin
								length <= length+1;
								foodoffset <= foodoffset +1;
								foodx <= randx;
								foody <= randy;
							end
					end

				Scycleaddress:
                    begin
                        wren <= 0;
                        address <= address + 1;
                        begin
                            if (incx < 19) 
                                begin
                                    incx <= incx + 1;
                                end
                            else 
                                begin
                                    incy <= incy + 1;
                                    incx <= 0;
                                end
                        end
                    end
				Sgrabcurrent: current <= q;
                Supdatedata:
                    begin
								oPlot <= 1;
								oX <= incx;
								oY <= incy;
                        if (current > 0)
                            begin
                                data <= current - 1 + foodoffset;
                                oColor <= 3'b110;
										  wren <= 1;
                            end
                        else
                            begin
										  oColor <= 3'b010;
                            end
                        
                    end
                Scheckdata:
                    begin
								wren <= 0;
                        oPlot <= 0;
                    end
				Sprintfood:
					begin
						incx <= 0;
						incy <= 0;
						oX <= foodx;
						oY <= foody;
						oPlot <= 1;
						oColor <= 3'b100;
						waitcounter <= 0;
						if (foodoffset > 0)
							foodoffset <= foodoffset - 1;
						if (randx < 19) 
							begin
								randx <= randx + 1;
							end
						else 
							begin
								randy <= randy + 1;
								randx <= 0;
							end
					end
				Sprinthead:
					begin
						incx <= 0;
						incy <= 0;
						oX <= headx;
						oY <= heady;
						oPlot <= 1;
						oColor <= 3'b111;
						waitcounter <= 0;
					end
				Swait:
					begin
						waitcounter <= waitcounter + 1;
						oPlot<= 0;
					end
                Sgameover:
                    begin
                        gameover <= 1;
								oPlot <= 1;
								oColor <= 3'b100;
                    end
				Sleavebody:
					begin
						wren <= 1;
						data <= length;
					end
				Sbodywait: wren <= 0;

        	endcase
		end



	always @(posedge iClock)
		begin
			if (iReset == 1) 
                begin
                    PS <= Sreset;
                end
			else 
                begin
                    PS <= NS;
                end
		end
								
						
						
endmodule
				
		
/*
module data(iClock, reset, color, coord, ld_x, ld_y, blackout, start_plot, oX, oY, oColor, incx, incy);

    // 30x20 game table
    
	input clk, reset, ld_x, ld_y, blackout, start_plot;
	input [2:0] color;
	input [6:0] coord;
	input [7:0] incx;
	input [6:0] incy;
	
	output reg [7:0] oX;
	output reg [6:0] oY;
	output reg [2:0] oColor;
	
	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] c;





    always @(posedge clk)
        begin
            if (update)
                begin
                    if (q>0)
                        begin
                        end
                            
                end
        end


    // plot increment
    always @(posedge clk)
        begin
            if (oPlot)
                if (incx < 19) 
                    begin
                        incx <= incx + 1;
                    end
                else 
                    begin
                        incy <= incy + 1;
                        incx <= 0;
                    end
        end

    // board increment
    always @(posedge clk)
        begin
            if (oPlot)
                if (incx < 19) 
                    begin
                        incx <= incx + 1;
                    end
                else 
                    begin
                        incy <= incy + 1;
                        incx <= 0;
                    end
        end
	
	 
endmodule                               

*/














// megafunction wizard: %RAM: 1-PORT%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altsyncram 

// ============================================================
// File Name: memory.v
// Megafunction Name(s):
// 			altsyncram
//
// Simulation Library Files(s):
// 			altera_mf
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 18.0.0 Build 614 04/24/2018 SJ Lite Edition
// ************************************************************


//Copyright (C) 2018  Intel Corporation. All rights reserved.
//Your use of Intel Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Intel Program License 
//Subscription Agreement, the Intel Quartus Prime License Agreement,
//the Intel FPGA IP License Agreement, or other applicable license
//agreement, including, without limitation, that your use is for
//the sole purpose of programming logic devices manufactured by
//Intel and sold by Intel or its authorized distributors.  Please
//refer to the applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module memory (
	address,
	clock,
	data,
	wren,
	q);

	input	[9:0]  address;
	input	  clock;
	input	[7:0]  data;
	input	  wren;
	output	[7:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1	  clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [7:0] sub_wire0;
	wire [7:0] q = sub_wire0[7:0];

	altsyncram	altsyncram_component (
				.address_a (address),
				.clock0 (clock),
				.data_a (data),
				.wren_a (wren),
				.q_a (sub_wire0),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.intended_device_family = "Cyclone V",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 1024,
		altsyncram_component.operation_mode = "SINGLE_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "UNREGISTERED",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.widthad_a = 10,
		altsyncram_component.width_a = 8,
		altsyncram_component.width_byteena_a = 1;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: ADDRESSSTALL_A NUMERIC "0"
// Retrieval info: PRIVATE: AclrAddr NUMERIC "0"
// Retrieval info: PRIVATE: AclrByte NUMERIC "0"
// Retrieval info: PRIVATE: AclrData NUMERIC "0"
// Retrieval info: PRIVATE: AclrOutput NUMERIC "0"
// Retrieval info: PRIVATE: BYTE_ENABLE NUMERIC "0"
// Retrieval info: PRIVATE: BYTE_SIZE NUMERIC "8"
// Retrieval info: PRIVATE: BlankMemory NUMERIC "1"
// Retrieval info: PRIVATE: CLOCK_ENABLE_INPUT_A NUMERIC "0"
// Retrieval info: PRIVATE: CLOCK_ENABLE_OUTPUT_A NUMERIC "0"
// Retrieval info: PRIVATE: Clken NUMERIC "0"
// Retrieval info: PRIVATE: DataBusSeparated NUMERIC "1"
// Retrieval info: PRIVATE: IMPLEMENT_IN_LES NUMERIC "0"
// Retrieval info: PRIVATE: INIT_FILE_LAYOUT STRING "PORT_A"
// Retrieval info: PRIVATE: INIT_TO_SIM_X NUMERIC "0"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone V"
// Retrieval info: PRIVATE: JTAG_ENABLED NUMERIC "0"
// Retrieval info: PRIVATE: JTAG_ID STRING "NONE"
// Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "0"
// Retrieval info: PRIVATE: MIFfilename STRING ""
// Retrieval info: PRIVATE: NUMWORDS_A NUMERIC "1024"
// Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0"
// Retrieval info: PRIVATE: READ_DURING_WRITE_MODE_PORT_A NUMERIC "3"
// Retrieval info: PRIVATE: RegAddr NUMERIC "1"
// Retrieval info: PRIVATE: RegData NUMERIC "1"
// Retrieval info: PRIVATE: RegOutput NUMERIC "0"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: SingleClock NUMERIC "1"
// Retrieval info: PRIVATE: UseDQRAM NUMERIC "1"
// Retrieval info: PRIVATE: WRCONTROL_ACLR_A NUMERIC "0"
// Retrieval info: PRIVATE: WidthAddr NUMERIC "10"
// Retrieval info: PRIVATE: WidthData NUMERIC "8"
// Retrieval info: PRIVATE: rden NUMERIC "0"
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: CONSTANT: CLOCK_ENABLE_INPUT_A STRING "BYPASS"
// Retrieval info: CONSTANT: CLOCK_ENABLE_OUTPUT_A STRING "BYPASS"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone V"
// Retrieval info: CONSTANT: LPM_HINT STRING "ENABLE_RUNTIME_MOD=NO"
// Retrieval info: CONSTANT: LPM_TYPE STRING "altsyncram"
// Retrieval info: CONSTANT: NUMWORDS_A NUMERIC "1024"
// Retrieval info: CONSTANT: OPERATION_MODE STRING "SINGLE_PORT"
// Retrieval info: CONSTANT: OUTDATA_ACLR_A STRING "NONE"
// Retrieval info: CONSTANT: OUTDATA_REG_A STRING "UNREGISTERED"
// Retrieval info: CONSTANT: POWER_UP_UNINITIALIZED STRING "FALSE"
// Retrieval info: CONSTANT: READ_DURING_WRITE_MODE_PORT_A STRING "NEW_DATA_NO_NBE_READ"
// Retrieval info: CONSTANT: WIDTHAD_A NUMERIC "10"
// Retrieval info: CONSTANT: WIDTH_A NUMERIC "8"
// Retrieval info: CONSTANT: WIDTH_BYTEENA_A NUMERIC "1"
// Retrieval info: USED_PORT: address 0 0 10 0 INPUT NODEFVAL "address[9..0]"
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT VCC "clock"
// Retrieval info: USED_PORT: data 0 0 8 0 INPUT NODEFVAL "data[7..0]"
// Retrieval info: USED_PORT: q 0 0 8 0 OUTPUT NODEFVAL "q[7..0]"
// Retrieval info: USED_PORT: wren 0 0 0 0 INPUT NODEFVAL "wren"
// Retrieval info: CONNECT: @address_a 0 0 10 0 address 0 0 10 0
// Retrieval info: CONNECT: @clock0 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: @data_a 0 0 8 0 data 0 0 8 0
// Retrieval info: CONNECT: @wren_a 0 0 0 0 wren 0 0 0 0
// Retrieval info: CONNECT: q 0 0 8 0 @q_a 0 0 8 0
// Retrieval info: GEN_FILE: TYPE_NORMAL memory.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL memory.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL memory.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL memory.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL memory_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL memory_bb.v TRUE
// Retrieval info: LIB_FILE: altera_mf

