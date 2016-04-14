module logic(
	input clk,
	input rst,
	
	
	//---ADC signals-------
	output adc_cnv,
	input  adc_busy,
	output [2:0]analog_mux_chn,
	//---ADC SPI signals---	 	
	input  adc_miso,
	output adc_sck,
	//---DAC & comm SPI----
	input  dac_reg_mosi,
	output dac_reg_sck,
	output cs1_dac,
	output cs2_reg,
	//---------------------
	
	//
	input enable

);
    localparam STATE_SIZE = 4;
	 reg [STATE_SIZE-1:0] state_d, state_q;
	 reg analog_mux_chn_d,analog_mux_chn_q;

	 
	 //reg read_diapason_d, read_diapason_q;
	 reg read_diapason;
	
	//FSM	 state coding
  localparam [5:0]  	
				IDLE 										= 1, 
				START_CYCLE								= 2,
				SET_START_DIAPASON					= 3,
				MEASURE_MODE_DIAPASON				= 3,
				ESTABLISH_DIAPASON					= 3,
				MEASURE_MODE_1							= 4,
				MEASURE_MODE_2							= 5,
				MEASURE_MODE_3							= 6,
				MEASURE_MODE_4							= 7,
				MEASURE_MODE_5							= 8,
				DONE										= 9;

// Mode reg
	localparam [7:0]
				REG_MODE_NONE	=8'b00000000,
				REG_MODE_DIAP	=8'b00000001,
				REG_MODE_1		=8'b00000001,
				REG_MODE_2		=8'b00000001,
				REG_MODE_3		=8'b00000001,
				REG_MODE_4		=8'b00000001,
				REG_MODE_5		=8'b00000001;
				
	localparam [2:0]
				MUX_NONE			=3'b000,
				MUX_MN_NM		=3'b001;
	
	localparam [2:0]
				DIAP_5V			=3'b001,
				DIAP_10V			=3'b010,
				DIAP_20V			=3'b100;
				

//---generator 5000 Hz--------------
reg gen_sample_clk;	
wire gen_out;		
wire gen_new_period;
wire gen_start_conv;	
wire gen_enable=enable;
sin_gen dev_sin_gen(.clk(clk),.sample_clk(gen_sample_clk),.rst(rst),.enable(gen_enable),.out(gen_out),.new_period(gen_new_period),.start_conv(gen_start_conv));	
			
//-----------DAC & register----------
localparam SPI_DAC_REG_CLK_DIV=2;
localparam SPI_DAC_REG_DATA_WIDTH=8;

spi_master #(.CLK_DIV(SPI_DAC_REG_CLK_DIV),.DATA_WIDTH(SPI_DAC_REG_DATA_WIDTH)) dac_reg_spi_master(.clk(clk),.rst(rst),.miso(dac_reg_miso),.mosi(dac_reg_mosi),.sck(dac_reg_sck),.start(dac_reg_start),.data_in(dac_reg_data_in),.data_out(dac_reg_data_out),.busy(dac_reg_busy),.new_data(dac_reg_new_data));
//------------ADC read----------------
localparam ADC_OUTPUT_DATA_WIDTH = 24;
reg adc_read_diapason;
wire adc_cycle_complete;
wire [ADC_OUTPUT_DATA_WIDTH-1:0]adc_data_out_1;
wire [ADC_OUTPUT_DATA_WIDTH-1:0]adc_data_out_2;
adc_read  #(.OUTPUT_DATA_WIDTH(ADC_OUTPUT_DATA_WIDTH))dev_adc_read(.clk(clk),.rst(rst),.sample_adc(gen_start_conv),.start_cycle_conv(adc_start_cycle_conv),.read_diapason(adc_read_diapason),.complete(adc_cycle_complete),.data_out_1(adc_data_out_1),.data_out_2(adc_data_out_2),.cnv(adc_cnv),.adc_busy(adc_busy),.miso(adc_miso),.sck(adc_sck));
//------------------------------------				
always @ (*) begin	//FSM
	 
	 state_d=state_q;
	 analog_mux_chn_d=analog_mux_chn_q;
	// read_diapason_d=read_diapason_q;
 	 
		case (state_q)
		
			IDLE:
			begin
				if(enable && gen_new_period)
				begin
					state_d <= START_CYCLE;
				end
			end
						
			START_CYCLE:
			begin
				
			end
			
			MEASURE_MODE_DIAPASON:
			begin

			end
			
			MEASURE_MODE_1:
			begin

			end
			
			MEASURE_MODE_2:
			begin

			end
			
			MEASURE_MODE_3:
			begin

			end
			
			MEASURE_MODE_4:
			begin

			end
			
			MEASURE_MODE_5:
			begin

			end
			
			DONE:
			begin

			end		
		endcase
	end
	
   always @(posedge clk) begin
    if (rst) 
	 begin
		 state_q<=IDLE;
		 analog_mux_chn_q<=3'b0;	 
    end 
	 else 
	 begin
		 state_q<=state_d;
		 analog_mux_chn_q=analog_mux_chn_d;
		 //read_diapason_q<=read_diapason_d;	 
    end
	end			

endmodule
