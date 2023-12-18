
module DE1_SoC_Audio_Example (
	// Inputs
	CLOCK_50,
	KEY, enable,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	SW
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
input enable;
input		[3:0]	SW;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;

// Internal Registers

reg [18:0] delay_cnt;
wire [18:0] delay;

reg snd;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
reg [3:0] PS, NS, pitch;
reg [25:0] counter;

localparam 
    Sstart = 4'd1,
    SF1 = 4'd3,
    SF2 = 4'd4,
    SF3 = 4'd5,
    Send = 4'd2;

always @(*)
    begin
        case (PS)
            Sstart:     
                begin
                    if (enable) NS <= SF1;
                    else NS <= Sstart;
                end    
            Send:       
                NS <= Sstart;
            SF1: 
                begin
                    if (counter < 2000000) NS <= SF1;
                    else NS <= SF2;
                end
            SF2: 
                begin
                    if (counter < 4000000) NS <= SF2;
                    else NS <= SF3;
                end
            SF3: 
                begin
                    if (counter < 6000000) NS <= SF3;
                    else NS <= Send;
                end
            default: NS <= Sstart;
        endcase
    end

always @(posedge CLOCK_50)
    begin
        case (PS)
            Sstart:
                begin
                    counter <= 0;
                    pitch <= 0;
                end
            SF1:
                begin
                    counter <= counter + 1;
                    pitch <= 4'b0110;
                end
            SF2:
                begin
                    counter <= counter + 1;
                    pitch <= 4'b0100;
                end
            SF3:
                begin
                    counter <= counter + 1;
                    pitch <= 4'b0010;
                end
            Send:
                begin
                    pitch <= 0;
                end
        endcase
    end

always @(posedge CLOCK_50)
    begin
        if (~KEY[0]) 
            begin
                PS <= Sstart;
            end
        else 
            begin
                PS <= NS;
            end
    end

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign delay = {pitch[3:0], 15'd3000};

wire [31:0] sound = (pitch == 0) ? 0 : snd ? 32'd10000000 : -32'd10000000;


assign read_audio_in			= audio_in_available & audio_out_allowed;

assign left_channel_audio_out	= left_channel_audio_in+sound;
assign right_channel_audio_out	= right_channel_audio_in+sound;
assign write_audio_out			= audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);

endmodule

