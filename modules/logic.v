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

	output [1:0]cs_dac_reg,
	//---------------------
	input enable
);
    localparam STATE_SIZE = 5;
	 reg [STATE_SIZE-1:0] state_d, state_q;
	 reg [2:0] analog_mux_chn_d,analog_mux_chn_q;
	 reg [4:0] keys_d, keys_q;
	 reg [2:0] diap_d, diap_q;
	 reg [1:0] cs_dac_reg_d, cs_dac_reg_q;
	 
	 reg dac_reg_start_d, dac_reg_start_q; 
	 wire dac_reg_start=dac_reg_start_q;
	 
	 reg gen_enable_d, gen_enable_q;
	 wire gen_enable=gen_enable_q;
	 
	 reg [1:0]delay_counter_d, delay_counter_q;

	 reg [7:0] dac_reg_data_out;
	 reg dac_reg_new_data;
	 //reg read_diapason_d, read_diapason_q;
	 reg read_diapason;
	

	// CS DAC REG
	localparam [1:0]
				CS_DAC_REG_NONE		=2'b3,
				CS_DAC_REG_DAC			=2'b1,
				CS_DAC_REG_REG			=2'b2;
	//FSM	 state coding	
  localparam [STATE_SIZE-1:0]  	
				IDLE 										= 1, 
				START_CYCLE								= 2,
				//SET_START_DIAPASON					= 3,???
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
//MUX 				
	localparam [2:0]
				MUX_NONE			=3'b000,
				MUX_MN_NM		=3'b001,
				MUX_CURRENT		=3'b010;
	
	localparam [2:0]
				DIAP_5V			=3'b001,
				DIAP_10V			=3'b010,
				DIAP_20V			=3'b100;
				
	localparam WAIT_PERIODS	= 2;
//---generator 5000 Hz--------------
reg gen_sample_clk;	
wire gen_out;		
wire gen_new_period;
wire gen_start_conv;	
wire gen_enable=enable;
wire gen_halfcycle;
sin_gen dev_sin_gen(.clk(clk),.sample_clk(gen_sample_clk),.rst(rst),.enable(gen_enable),.out(gen_out),.new_period(gen_new_period),.start_conv(gen_start_conv),.halfcycle(gen_halfcycle));	
			
//-----------DAC & register----------
localparam SPI_DAC_REG_CLK_DIV=2;
localparam SPI_DAC_REG_DATA_WIDTH=8;

spi_master #(.CLK_DIV(SPI_DAC_REG_CLK_DIV),.DATA_WIDTH(SPI_DAC_REG_DATA_WIDTH)) dac_reg_spi_master(.clk(clk),.rst(rst),.miso(dac_reg_miso),.mosi(dac_reg_mosi),.sck(dac_reg_sck),.start(dac_reg_start),.data_in(dac_reg_data_in),.data_out(dac_reg_data_out),.busy(dac_reg_busy),.new_data(dac_reg_new_data));
//------------ADC read----------------
localparam ADC_OUTPUT_DATA_WIDTH = 24;
reg adc_read_diapason;
reg adc_start_cycle_conv;
wire adc_cycle_complete;
wire [ADC_OUTPUT_DATA_WIDTH-1:0]adc_data_out_1;
wire [ADC_OUTPUT_DATA_WIDTH-1:0]adc_data_out_2;
adc_read  #(.OUTPUT_DATA_WIDTH(ADC_OUTPUT_DATA_WIDTH))dev_adc_read(.clk(clk),.rst(rst),.sample_adc(gen_start_conv),.start_cycle_conv(adc_start_cycle_conv),.halfcycle(gen_halfcycle),.read_diapason(adc_read_diapason),.complete(adc_cycle_complete),.data_out_1(adc_data_out_1),.data_out_2(adc_data_out_2),.cnv(adc_cnv),.adc_busy(adc_busy),.miso(adc_miso),.sck(adc_sck));
//------------------------------------				
always @ (*) begin	//FSM
	 
	 state_d=state_q;
	 analog_mux_chn_d=analog_mux_chn_q;
	 keys_d=keys_q;
	 diap_d=diap_q;
	 cs_dac_reg_d=cs_dac_reg_q;
	 dac_reg_start_d=dac_reg_start_q;
	 gen_enable_d=gen_enable_q;
	 delay_counter_d=delay_counter_q;
	// read_diapason_d=read_diapason_q;
 	 
		case (state_q)
		
			IDLE:
			begin
				if(enable && gen_new_period)
				begin
					state_d <= START_CYCLE;
				end
			end
//------------------------------------------------						
			START_CYCLE:
			begin
				
			end
//------------------------------------------------			
			MEASURE_MODE_DIAPASON:
			begin

			end
//------------------------------------------------			
			MEASURE_MODE_1_START:
			begin
				cs_dac_reg_d<=CS_DAC_REG_REG;
				state_d<=MEASURE_MODE_1_START_SET_DIAP;
			end
			
			MEASURE_MODE_1_START_SET_DIAP:
			begin
				dac_reg_data_out<={diap_d,keys_d};
				dac_reg_start_d<=1'b1;
				state_d<=MEASURE_MODE_1_WAIT_SPI;
			end
			
			MEASURE_MODE_1_WAIT_SPI:
			begin
				dac_reg_start_d<=1'b0;
				if(dac_reg_new_data)
				begin
					state_d<=MEASURE_MODE_1_GENERATOR_ON;
				end
			end
			
			MEASURE_MODE_1_GENERATOR_ON:
			begin
				cs_dac_reg_d<=CS_DAC_REG_DAC;
				gen_enable_d<=1'b1;
				state_d<=MEASURE_MODE_1_SET_MULTIPLEXOR;
			end
			
			MEASURE_MODE_1_SET_MULTIPLEXOR:
			begin
				analog_mux_chn_d<=MUX_CURRENT;
				delay_counter_d<=WAIT_PERIODS;
				state_d<=MEASURE_MODE_1_DELAY;
			end
			
			MEASURE_MODE_1_SET_DELAY_1:
			begin
				if(gen_new_period)
				begin
					if(delay_counter_d!=0)
					begin
						delay_counter_d=delay_counter_d-1;
					end
					else 
					begin
						state_d<=MEASURE_MODE_1_START_MEASURE;
					end
				end
			end

			MEASURE_MODE_1_START_MEASURE:
			begin
				adc_start_cycle_conv=1'b1;
				state_d<=MEASURE_MODE_1_WAIT_MEASURE_RESULT;
			end
			
			MEASURE_MODE_1_WAIT_MEASURE_RESULT:
			begin
				adc_start_cycle_conv=1'b0;
				if(adc_cycle_complete)
				begin
					state_d<=MEASURE_MODE_1_SEND_TO_FIFO;
				end
			end			
			
			MEASURE_MODE_1_SEND_TO_FIFO:
			begin
				//
				state_d<=MEASURE_MODE_1_SET_MULTIPLEXOR_2;
			end

			MEASURE_MODE_1_SET_MULTIPLEXOR_2:
			begin
				analog_mux_chn_d<=MUX_MN_NM;
				delay_counter_d<=WAIT_PERIODS;
				state_d<=MEASURE_MODE_2_DELAY;
			end

			MEASURE_MODE_1_SET_DELAY_2:
			begin
				if(gen_new_period)
				begin
					if(delay_counter_d!=0)
					begin
						delay_counter_d=delay_counter_d-1;
					end
					else 
					begin
						state_d<=MEASURE_MODE_1_START_MEASURE_2;
					end
				end
			end	
	
			MEASURE_MODE_1_START_MEASURE_2:
			begin
				adc_start_cycle_conv=1'b1;
				state_d<=MEASURE_MODE_1_WAIT_MEASURE_RESULT_2;
			end
			
			MEASURE_MODE_1_WAIT_MEASURE_RESULT_2:
			begin
				adc_start_cycle_conv=1'b0;
				if(adc_cycle_complete)
				begin
					state_d<=MEASURE_MODE_1_SEND_TO_FIFO_2;
				end
			end			
			
			MEASURE_MODE_1_SEND_TO_FIFO_2:
			begin
			//
				state_d<=MEASURE_MODE_1_GENERATOR_OFF;
			end	
		
			MEASURE_MODE_1_GENERATOR_OFF:
			begin
				cs_dac_reg_d<=CS_DAC_REG_NONE;
				gen_enable_d<=1'b0;
				state_d<=MEASURE_MODE_1_MULTIPLEXOR_OFF;
			end	
	
			MEASURE_MODE_1_MULTIPLEXOR_OFF:
			begin
				analog_mux_chn_d<=MUX_NONE;
				state_d<=MEASURE_MODE_1_END;
			end	
		
			MEASURE_MODE_1_END:
			begin
			
			end			
//------------------------------------------------			
			MEASURE_MODE_2:
			begin

			end
//------------------------------------------------			
			MEASURE_MODE_3:
			begin

			end
//------------------------------------------------			
			MEASURE_MODE_4:
			begin

			end
			
			MEASURE_MODE_5:
			begin

			end
//------------------------------------------------			
			DONE:
			begin

			end		
//------------------------------------------------			
		endcase
	end
	
   always @(posedge clk) begin
    if (rst) 
	 begin
		 state_q<=IDLE;
		 analog_mux_chn_q<=3'b0;	
		 cs_dac_reg_q<=CS_DAC_REG_NONE; 
		 dac_reg_start_q<=1'b1;
		 gen_enable_q<=1'b0;
		 delay_counter_q<=2'b00;
    end 
	 else 
	 begin
		 state_q<=state_d;
		 analog_mux_chn_q=analog_mux_chn_d;
		 keys_q<=keys_d;
		 diap_q<=diap_d;
		 cs_dac_reg_q<=cs_dac_reg_d;
		 dac_reg_start_q<=dac_reg_start_d;
		 gen_enable_q<=gen_enable_d;
		 delay_counter_q<=delay_counter_d;
		 //read_diapason_q<=read_diapason_d;	 
    end
	end			

endmodule

/*
module mode_cycle(

);

endmodule*/
