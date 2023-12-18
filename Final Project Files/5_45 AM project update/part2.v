//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

module project(iReset,iStart, iClock,iCheat,iSpeedup,iADirection,iBDirection,oX,oY,oColor,oPlot,oDone, HEX3, HEX2, HEX1, HEX0);

   input wire iReset;
   input wire iClock;
	input wire iStart;
	input wire iCheat;
	input wire iSpeedup;
   input wire [1:0] iADirection, iBDirection; // 2'b00 = right, 2'b01 = left, 2'b11 = up, 2'b10 = down

   // VGA output signals
   output wire [7:0] oX;           // VGA pixel coordinates 160x120
   output wire [6:0] oY;
   output wire [2:0] oColor;       // VGA pixel colour (0-7)
   output wire oPlot;       	    // Pixel draw enable
   
   output wire oDone;       		 // goes high when finished drawing frame

	output [6:0] HEX3, HEX2, HEX1, HEX0;

   // Your code goes here
	wire [7:0] incx, Aheadx, Bheadx, randx, boardX;
	wire [6:0] incy, Aheady, Bheady, randy, boardY;
	wire [2:0] boardColor, mode;
	wire boardPlot;
   wire [9:0] Aaddress, Baddress;
   wire [7:0] Adata, Aq, Acurrent, Bdata, Bq, Bcurrent;
   wire Awren, Bwren, plotDone;
	wire [7:0] Alength, Blength;
	
	
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
	 
	 /*loading on(
		.clock(iClock),
		.address(address),
		.q(on_colour)
	);*/
	
	 
	control c0(
		.iClock(iClock), 
		.iReset(iReset), 
		.iADirection(iADirection), 
		.iBDirection(iBDirection), 
		.oPlot(boardPlot), 
		.oDone(oDone),
		.oColor(boardColor),
		.oX(boardX),
		.oY(boardY),
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
		.Bwren(Bwren),
		.plotDone(plotDone),
		.mode(mode),
		.iStart(iStart),
		.iCheat(iCheat),
		.iSpeedup(iSpeedup),
		.Alength(Alength),
		.Blength(Blength)
	);
	
			
	data d0(
		.iClock(iClock), 
		.iReset(iReset), 
		.boardX(boardX),
		.boardY(boardY),
		.boardColor(boardColor),
		.boardPlot(boardPlot),
		.oX(oX), 
		.oY(oY), 
		.oColor(oColor),
		.oPlot(oPlot),
		.plotDone(plotDone),
		.mode(mode)
   );
	hexlength hexy0(Alength, Blength, HEX3, HEX2, HEX1, HEX0);

  
endmodule // part2

module control(iClock, iStart, iReset, iCheat,iSpeedup,iADirection, iBDirection, oPlot, oDone, oColor, oX, oY, incx, incy, Aheadx, Aheady, Bheadx, Bheady, PS, NS, Aaddress, Acurrent, Adata, Aq, Awren, Baddress, Bcurrent, Bdata, Bq, Bwren, foodx, foody, randx, randy, plotDone, mode, write,Alength,Blength);

	input iClock, iStart, iReset, iCheat, plotDone;
	input [1:0] iADirection, iBDirection;

	input iSpeedup;
	reg [25:0] speed;
	
	output reg oPlot, oDone;
	
	output reg [2:0] oColor, mode;
	output reg [7:0] oX, incx, Aheadx, Bheadx, foodx, randx;
	output reg [6:0] oY, incy, Aheady, Bheady, foody, randy;
	
	
   reg gameover;
	output reg Awren, Bwren;
	output reg [6:0] PS, NS;
   output reg [9:0] Aaddress, Baddress;
	output reg [7:0] Acurrent, Adata, Bcurrent, Bdata, Alength, Blength;
   input [7:0] Aq, Bq;
	
	reg [7:0] Afoodoffset, Bfoodoffset;

	reg [25:0] waitcounter;
	
   wire [2:0] on_colour;

	wire [2:0] write_data;
	wire [14:0] write_address;
	wire write_enable;

	assign write_enable = 0;

	reg [14:0] address;

	reg [7:0] x_address;
	reg [6:0] y_address;

	reg [2:0] colour_reg;
	output reg write;
	wire wire_oPlot;
	
	part2 p(
		 .iResetn(resetn),
		 .iClock(CLOCK_50),
		 .oX(x),
		 .oY(y),
		 .oColour(colour),
		 .oPlot(wire_oPlot),
		 .oDone(done),
		 .write(write)
	);
	
   localparam 
		Shardreset = 6'd25,
		Sresetwait = 6'd26,
		Sreset = 6'd0,
      Ssetup = 6'd1,
		Smemclear = 6'd22,
      Supdate = 6'd2,
      Scheckbounds = 6'd3,
      Scycleaddress = 6'd4,
      Supdatedata = 6'd5,
      Scheckdata = 6'd6,
		SprintheadA = 6'd7,
		Swait = 6'd8,
      SgameoverA = 6'd9,
		SgameoverB = 6'd23,
		Sgameovertie = 6'd24,
		SleavebodyA = 6'd10,
		SbodywaitA = 6'd11,
		Swaitmem = 6'd12,
		Sgrabcurrent = 6'd13,
		Sprintfood = 6'd14,
		SprintheadB = 6'd15,
		SleavebodyB = 6'd16,
		SbodywaitB = 6'd17,
		Swaitplotdata = 6'd18,
		Swaitplotfood = 6'd19,
		SwaitplotheadA = 6'd20,
		SwaitplotheadB = 6'd21;
	

    //state table
	always@(*)
		begin
			case (PS)
				Shardreset: NS <= iReset ? Shardreset : Sresetwait;
				Sresetwait: NS <= iStart ? Sreset : Sresetwait;
				Sreset: NS <= Ssetup;
            Ssetup: NS <= plotDone ? Smemclear:Ssetup;
				Smemclear: 
					begin
						if (Baddress < 660)
							begin
								NS <= Smemclear;
							end
						else
							begin
								NS <= Supdate;
							end
					end
            Supdate: NS <= Scheckbounds;
            Scheckbounds: 
					begin
						if (Aheadx < 0 || Aheadx > 29 || Aheady < 0 || Aheady > 21)
							 begin
								  NS <= SgameoverB;
							 end
						else if (Bheadx < 0 || Bheadx > 29 || Bheady < 0 || Bheady > 21)
							 begin
								  NS <= SgameoverA;
							 end
						else
							 begin
								  NS <= Scycleaddress;
							 end
					end
            Scycleaddress: 
					begin
						if (incx > 28 && incy > 20)
							NS <= Sprintfood;
						else
							NS <= Swaitmem;
					end
				Swaitmem:
					NS <= Sgrabcurrent;
				Sgrabcurrent: NS <= Supdatedata;
            Supdatedata: NS <= Swaitplotdata;
				Swaitplotdata: NS <= plotDone ? Scheckdata:Swaitplotdata;
            Scheckdata:
			   begin
					if (Aheadx == Bheadx && Aheady == Bheady)
						begin
							NS <= Sgameovertie;
						end
					else if (Aheadx == incx && Aheady == incy) // body collision
						begin
							if (Acurrent > 0 || Bcurrent > 0)
								begin
									NS <= SgameoverB;
								end
							else
								NS <= SleavebodyA;
						end
					else if (Bheadx == incx && Bheady == incy) // body collision
						begin
							if (Acurrent > 0 || Bcurrent > 0)
								begin
									NS <= SgameoverA;
								end
							else
								NS <= SleavebodyB;
						end
					else
						begin
							NS <= Scycleaddress;
						end
			   end
				Sprintfood: NS <= Swaitplotfood;
				Swaitplotfood: NS <= plotDone ? SprintheadA:Swaitplotfood;
				SprintheadA: NS <= SwaitplotheadA;
				SwaitplotheadA: NS <= plotDone ? SprintheadB:SwaitplotheadA;
				SprintheadB: NS <= Swait;
				SwaitplotheadB: NS <= plotDone ? Swait:SwaitplotheadB;
				Swait: 
					begin
						if (waitcounter > speed)
							NS <= Supdate;
						else
							NS <= Swait;
					end
				SgameoverA: NS <= SgameoverA;
				SgameoverB: NS <= SgameoverB;
				Sgameovertie: NS <= Sgameovertie;
				SleavebodyA: NS <= SbodywaitA;
				SbodywaitA: NS <= Scycleaddress;
				SleavebodyB: NS <= SbodywaitB;
				SbodywaitB: NS <= Scycleaddress;
				

				default: NS <= iReset;
			endcase
		end
		
		
		
	always @(posedge iClock)
		begin
			if (iReset == 1) 
                begin
                    PS <= Shardreset;
                end
			else 
                begin
                    PS <= NS;
                end
		end

	
	always@(*)
		begin
			case (iSpeedup)
				1'b0: speed <= 26'd50000000;
				1'b1: speed <= 26'd10000000;
			endcase
		end
				
	
	
		
	// integrated combined datapath.
   always @(posedge iClock)
		begin
	
			case (PS)
				Sresetwait: begin	
					write <= 1;
					if(write) begin
					oPlot <= wire_oPlot;
					end else begin
					oPlot <= 0;
					end
					
				end // diplay start mif here
				Sreset: 
					begin
						oDone <= 0;
						oPlot <= 1;
						Alength <= 0;
						Blength <= 0;
						Adata <= 0;
						Afoodoffset <= 0;
						Bdata <= 0;
						Bfoodoffset <= 0;
						randx <= 0;
						randy <= 0;
						mode <= 2;
					end
				Ssetup:
					begin
						oPlot <= 0;
						Aheadx <= 5;
						Aheady <= 11;
						Bheadx <= 22;
						Bheady <= 11;
						foodx <= 15;
						foody <= 11;
						Aaddress <= 0;
						Baddress <= 0;
						Awren <= 1;
						Bwren <= 1;
						mode <= 0;
					end
				Smemclear:
					begin
						mode <= 0;
						Aaddress <= Aaddress + 1;
						Baddress <= Baddress + 1;
					end
				Supdate:
					begin
						Awren <= 0;
						Bwren <= 0;
						Aaddress <= -1;
						Baddress <= -1;
						incx <= -1;
						incy <= 0;
						case(iADirection)
							2'b00: Aheadx <= Aheadx + 1; 
							2'b01: Aheadx <= Aheadx - 1; 
							2'b10: Aheady <= Aheady + 1; 
							2'b11: Aheady <= Aheady - 1; 
						endcase
						case(iBDirection)
							2'b00: Bheadx <= Bheadx + 1;  
							2'b01: Bheadx <= Bheadx - 1; 
							2'b10: Bheady <= Bheady + 1;  
							2'b11: Bheady <= Bheady - 1;  
						endcase
					end
				Scheckbounds:
					begin
						oPlot <= 0;
						if (Aheadx == foodx && Aheady == foody) 
							begin
								Alength <= Alength+1;
								Afoodoffset <= Afoodoffset +1;
								foodx <= randx;
								foody <= randy;
							end
						if (Bheadx == foodx && Bheady == foody) 
							begin
								Blength <= Blength+1;
								Bfoodoffset <= Bfoodoffset +1;
								foodx <= randx;
								foody <= randy;
							end
						if (iCheat)
							begin
								Alength <= Alength+1;
								Afoodoffset <= Afoodoffset +1;
							end
					end
				Scycleaddress:
					begin
						Awren <= 0;
						Bwren <= 0;
						Aaddress <= Aaddress + 1;
						Baddress <= Baddress + 1;
						begin
							 if (incx < 29 || incx > 40) 
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
				Sgrabcurrent: 
					begin
						Acurrent <= Aq;
						Bcurrent <= Bq;
					end
				Supdatedata:
					begin
						oPlot <= 1;
						mode <= 1;
						oX <= incx;
						oY <= incy;
						if (Acurrent > 0)
							begin
								Adata <= Acurrent - 1 + Afoodoffset;
								oColor <= 3'b111;
								Awren <= 1;
							end
						else if (Bcurrent > 0)
							begin
								Bdata <= Bcurrent - 1 + Bfoodoffset;
								oColor <= 3'b111;
								Bwren <= 1;
							end
						else
							begin
								oColor <= 3'b000;
							end
					end
				Swaitplotdata: 
					begin
						mode <= 0;
						oPlot <= 0;
					end
				Scheckdata:
					begin
						Awren <= 0;
						Bwren <= 0;
                  oPlot <= 0;
               end
				Sprintfood:
					begin
						incx <= 0;
						incy <= 0;
						oX <= foodx;
						oY <= foody;
						oPlot <= 1;
						mode <= 1;
						oColor <= 3'b110;
						waitcounter <= 0;
						if (Afoodoffset > 0)
							Afoodoffset <= Afoodoffset - 1;
						if (Bfoodoffset > 0)
							Bfoodoffset <= Bfoodoffset - 1;
						if (randx < 29) 
							begin
								randx <= randx + 1;
							end
						else 
							begin
								randy <= randy + 1;
								randx <= 0;
							end
					end
				Swaitplotfood: 
					begin
						mode <= 0;
						oPlot <= 0;
					end
				SprintheadA:
					begin
						incx <= 0;
						incy <= 0;
						oX <= Aheadx;
						oY <= Aheady;
						mode <= 3;
						oColor <= 3'b010;
						oPlot <= 1;
						waitcounter <= 0;
					end
				SwaitplotheadA: 
					begin
						mode <= 0;
						oPlot <= 0;
					end
				SprintheadB:
					begin
						incx <= 0;
						incy <= 0;
						oX <= Bheadx;
						oY <= Bheady;
						mode <= 3;
						oColor <= 3'b011;
						oPlot <= 1;
						waitcounter <= 0;
					end
				SwaitplotheadB:
					begin
						mode <= 0;
						oPlot <= 0;
					end
				Swait:
					begin
						waitcounter <= waitcounter + 1;
						oPlot<= 0;
					end
				SgameoverA: // display mif for player A winner (left)
					begin
						oPlot <= 1;
						
					end
				SgameoverB:
					begin

					end
				Sgameovertie:
					begin

					end
				
				SleavebodyA:
					begin
						Awren <= 1;
						Adata <= Alength;
					end
				SbodywaitA: Awren <= 0;
				SleavebodyB:
					begin
						Bwren <= 1;
						Bdata <= Blength;
					end
				SbodywaitB: Bwren <= 0;

        	endcase
		end					
						
						
endmodule
				
		

module data(iClock, iReset, boardX, boardY, boardColor, boardPlot, oX, oY, oColor, oPlot, plotDone, mode);
	input wire iClock, iReset, boardPlot;
	input wire [7:0] boardX;
	input wire [6:0] boardY;
	input wire [2:0] boardColor;
	
   output reg [7:0] oX;           // VGA pixel coordinates 160x120
   output reg [6:0] oY;
   output reg [2:0] oColor;       // VGA pixel colour (0-7)
   output reg oPlot, plotDone; 

	reg [7:0] offsetX;     
   reg [6:0] offsetY;
	reg [5:0] counter;
	
	input [2:0] mode;
	reg [2:0] modeselect;

	reg [14:0] address;

	reg [7:0] x_address;
	reg [6:0] y_address;

	reg [2:0] colour_reg;
	wire [2:0] on_colour;

	always @(posedge iClock)
		begin
			if (boardPlot)
				begin
					counter <= 0;
					offsetX <= 0;
					offsetY <= 0;
					plotDone <= 0;
					modeselect <= mode;
					
				end
			if (iReset)
				begin
					counter <= 100;
					offsetX <= 0;
					offsetY <= 0;
					plotDone <= 0;
					oColor <= 3'b001;
					modeselect <= mode;
				end
			
			case (modeselect)
				3'd0: 
					begin
						oPlot <= 0;
						plotDone <= 0;
					end
				3'd1: 
					begin
						if (counter < 16)
							begin
								oX <= 5 + 5*boardX + offsetX;
								oY <= 5 + 5*boardY + offsetY;
								oColor <= boardColor;
								oPlot <= 1;
								
								counter <= counter+1;
								if (offsetX < 3)
									begin
										offsetX <= offsetX+1;
									end
								else
									begin
										offsetY <= offsetY+1;
										offsetX <= 0;
									end
							end
						else if (counter == 16)
							begin
								plotDone <= 1;
								modeselect <= 0;
							end
					end
				3'd2: 
					begin
					
						if (offsetX < 160 && offsetY < 120)
							begin
								oX <= offsetX;
								oY <= offsetY;
								oPlot <= 1;
								if (offsetX < 159)
									begin
										offsetX <= offsetX+1;
									end
								else
									begin
										offsetY <= offsetY+1;
										offsetX <= 0;
									end
							end
						else 
							begin
								plotDone <= 1;
								modeselect <= 0;
							end
					end
				3'd3:
					begin
						if (counter < 16)
							begin
								oX <= 5 + 5*boardX + offsetX;
								oY <= 5 + 5*boardY + offsetY;
								oColor <= boardColor;
								oPlot <= 1;
								if (((offsetX == 0 || offsetX == 3) && offsetY == 1)||((offsetX == 1 || offsetX == 2) && offsetY == 3))
									begin
										oColor <= 3'd111;
									end
								counter <= counter+1;
								if (offsetX < 3)
									begin
										offsetX <= offsetX+1;
									end
								else
									begin
										offsetY <= offsetY+1;
										offsetX <= 0;
									end
							end
						else if (counter == 16)
							begin
								plotDone <= 1;
								modeselect <= 0;
							end
					end
			/*3'd4:
				begin 
						if (iReset) begin
						address <= 0;
						y_address <= 0;
						x_address <= 0;
						colour_reg <= 0;
						end
						
					else begin
					
						if (address < 15'd19199) begin
							address <= address + 1'b1;
							end
						else begin
							address <= 0;
							end
						
						if (x_address < 8'd159) begin
							x_address <= x_address + 1;
							end
						else begin
							if (y_address < 7'd119) begin
								y_address <= y_address + 1;
							end
							else begin
								y_address <= 0;
							end
							x_address <= 0;
							end
						end
						
					
					plotDone <= 1;
					modeselect <= 0;
				end */
				
			endcase
			
		end

	 
endmodule                               


module hexlength(lengthA, lengthB, HEX3, HEX2, HEX1, HEX0);
	input [7:0] lengthA, lengthB;
	output wire [6:0] HEX3, HEX2, HEX1, HEX0;
	
	reg [3:0] Aleft, Aright, Bleft, Bright;
	
	always@(*)
		begin
			Aleft <= lengthA/10;
			Aright <= lengthA%10;
			Bleft <= lengthB/10;
			Bright <= lengthB%10;
		end
	
	hex_decoder h1(Aleft, HEX3);
	hex_decoder h2(Aright, HEX2);
	hex_decoder h3(Bleft, HEX1);
	hex_decoder h4(Bright, HEX0);

	
endmodule
	

module hex_decoder(c, display);
	
	input [3:0] c;
	output [6:0] display;

	
	assign display[6] = (~c[3]&~c[2]&~c[1]&~c[0])|(~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&c[2]&c[1]&c[0])|(c[3]&c[2]&~c[1]&~c[0]);
	assign display[5] = (~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&~c[2]&c[1]&~c[0])|(~c[3]&~c[2]&c[1]&c[0])|(~c[3]&c[2]&c[1]&c[0])|(c[3]&c[2]&~c[1]&c[0]);
	assign display[4] = (~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&~c[2]&c[1]&c[0])|(~c[3]&c[2]&~c[1]&~c[0])|(~c[3]&c[2]&~c[1]&c[0])|(~c[3]&c[2]&c[1]&c[0])|(c[3]&~c[2]&~c[1]&c[0]);
	assign display[3] = (~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&c[2]&~c[1]&~c[0])|(~c[3]&c[2]&c[1]&c[0])|(c[3]&~c[2]&~c[1]&c[0])|(c[3]&~c[2]&c[1]&~c[0])|(c[3]&c[2]&c[1]&c[0]);
	assign display[2] = (~c[3]&~c[2]&c[1]&~c[0])|(c[3]&c[2]&~c[1]&~c[0])|(c[3]&c[2]&c[1]&~c[0])|(c[3]&c[2]&c[1]&c[0]);
	assign display[1] = (~c[3]&c[2]&~c[1]&c[0])|(~c[3]&c[2]&c[1]&~c[0])|(c[3]&~c[2]&c[1]&c[0])|(c[3]&c[2]&~c[1]&~c[0])|(c[3]&c[2]&c[1]&~c[0])|(c[3]&c[2]&c[1]&c[0]);
	assign display[0] = (~c[3]&~c[2]&~c[1]&c[0])|(~c[3]&c[2]&~c[1]&~c[0])|(c[3]&~c[2]&c[1]&c[0])|(c[3]&c[2]&~c[1]&c[0]);
	
endmodule







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

