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
	output dac_reg_mosi,
	output dac_reg_sck,

	output [1:0]cs_dac_reg,
	//---------------------
	input enable,	
	//--FIFO signals-------
	output [23:0]fifo_data_out,
	output fifo_empty,
	input  fifo_rd_en,
	input  rdclk,
	output cycle_done
);
localparam STATE_SIZE = 5;
reg 	[STATE_SIZE-1:0] state_d, state_q;
reg 	[2:0] analog_mux_chn_d,analog_mux_chn_q;
assign analog_mux_chn=analog_mux_chn_q;
reg 	[4:0] mode_keys_d, mode_keys_q;
wire  [2:0] diap_keys;
reg 	[1:0] cs_dac_reg_d, cs_dac_reg_q;
assign cs_dac_reg=cs_dac_reg_q;

reg 	dac_reg_start_d, dac_reg_start_q; 
wire dac_reg_start=dac_reg_start_q;
 
//	 reg gen_enable_d, gen_enable_q;
//	 wire gen_enable=gen_enable_q;
 
reg 	[7:0]delay_counter_d, delay_counter_q;
 
reg 	[2:0] mode_reg_d, mode_reg_q;

//reg 	[7:0] dac_reg_data_out;



wire dac_reg_new_data;
reg 	read_diapason;

	

	// CS DAC REG
localparam [1:0]
				CS_DAC_REG_NONE		=2'b11,
				CS_DAC_REG_DAC			=2'b01,
				CS_DAC_REG_REG			=2'b10;

//FSM	 state coding	
localparam [STATE_SIZE-1:0]  	
				IDLE 										= 1, 
				START_CYCLE								= 2,
				MEASURE_MODE_DIAPASON				= 3,
				MEASURE_MODE_START					= 4,
				MEASURE_MODE_START_SET_DIAP_MODE_KEYS = 5,
				MEASURE_MODE_WAIT_SPI				= 6,
				MEASURE_MODE_GENERATOR_ON			= 7,
				MEASURE_MODE_SET_MULTIPLEXOR		= 8,
				MEASURE_MODE_SET_DELAY_1			= 9,
				MEASURE_MODE_START_MEASURE			= 10,
				MEASURE_MODE_WAIT_MEASURE_RESULT	= 11,
				MEASURE_MODE_SEND_TO_FIFO_1		= 12,
				MEASURE_MODE_SEND_TO_FIFO_2		= 13,
				MEASURE_MODE_SET_MULTIPLEXOR_2	= 14,
				MEASURE_MODE_SET_DELAY_2			= 15,
				MEASURE_MODE_START_MEASURE_2		= 16,
				MEASURE_MODE_WAIT_MEASURE_RESULT_2 = 17,
				MEASURE_MODE_SEND_TO_FIFO_3		= 18,
				MEASURE_MODE_SEND_TO_FIFO_4		= 19,
				MEASURE_MODE_GENERATOR_OFF			= 20,
				MEASURE_MODE_MULTIPLEXOR_OFF		= 21,
				MEASURE_MODE_END						= 22,
				DONE										= 23,
				MEASURE_MODE_START_DETERMINATE_DIAPASON = 24,
				MEASURE_MODE_WAIT_FOR_DETERMINATE_DIAPASON=25,
				MEASURE_MODE_DIAP_TO_FIFO			=26;
				
				
// Measure mode
  localparam [2:0] 
			MEASURE_MODE_DIAP						= 0,
			MEASURE_MODE_1							= 1,
			MEASURE_MODE_2							= 2,
			MEASURE_MODE_3							= 3,
			MEASURE_MODE_4							= 4,
			MEASURE_MODE_5							= 5;

//MUX 				
localparam [2:0]
			MUX_NONE			=3'b000,
			MUX_MN_NM		=3'b001,
			MUX_CURRENT		=3'b010;
//Diap	
localparam [2:0]
			DIAP_KEYS_1V			=3'b001,
			DIAP_KEYS_5V			=3'b010,
			DIAP_KEYS_20V			=3'b100;
//Key states				
localparam [4:0] 
			MEASURE_MODE_DIAP_KEY	= 0,
			MEASURE_MODE_1_KEY		= 1,
			MEASURE_MODE_2_KEY		= 2,
			MEASURE_MODE_3_KEY		= 3,
			MEASURE_MODE_4_KEY		= 4,
			MEASURE_MODE_5_KEY		= 5;
			
localparam [23:0]
			DIAP1_MARGIN				= 0,
			DIAP2_MARGIN				= 1,
			DIAP3_MARGIN				= 2;
			
localparam WAIT_PERIODS	= 16;

//---generator 5000 Hz--------------
reg 	gen_sample_clk;	
//assign sample_clk=dac_reg_new_data;
wire 	[7:0]gen_out;	

wire 	gen_new_period;
wire 	gen_start_conv;	
reg 	gen_enable_d, gen_enable_q;
wire 	gen_enable=gen_enable_q;
wire  gen_halfcycle;
wire  gen_data_ready;
sin_gen dev_sin_gen(.clk(clk),.sample_clk(gen_sample_clk),.rst(rst),.enable(gen_enable),.out(gen_out),.ready(gen_data_ready),.new_period(gen_new_period),.start_conv(gen_start_conv),.halfcycle(gen_halfcycle));	
			
//reg 	[1:0] sample_clk_r;
//wire 	sig_sample_clk=(sample_clk_r[1]!=sample_clk_r[0])&sample_clk_r[0];	


//--------------FIFO-------------------
//wire 	[23:0]fifo_data_out;
wire 	fifo_full;
//wire 	fifo_empty;
reg  	[23:0]fifo_data_in_d, fifo_data_in_q;


reg  	fifo_wr_en_d, fifo_wr_en_q;
reg  	fifo_rd_en_d, fifo_rd_en_q;

wire 	fifo_wr_en=fifo_wr_en_q;
//wire 	fifo_rd_en=fifo_rd_en_q;


dc_fifo dev_dc_fifo (.data(fifo_data_in),.rdclk(rdclk),.rdreq(fifo_rd_en),.wrclk(clk),.wrreq(fifo_wr_en),.q(fifo_data_out),.rdempty(fifo_empty),.wrfull(fifo_full));

wire  	[7:0] dac_reg_data_out=(cs_dac_reg_q==CS_DAC_REG_REG)?({diap_keys,mode_keys_q}):((cs_dac_reg_q==CS_DAC_REG_DAC)?(gen_out):(8'b0)); 
wire     adc_start_conv=((cs_dac_reg_q==CS_DAC_REG_DAC)&&(gen_start_conv))?(dac_reg_new_data) :(1'b0) ;
//-----------DAC & register----------
localparam SPI_DAC_REG_CLK_DIV=4;
localparam SPI_DAC_REG_DATA_WIDTH=8;

spi_master #(.CLK_DIV(SPI_DAC_REG_CLK_DIV),.DATA_WIDTH(SPI_DAC_REG_DATA_WIDTH)) dac_reg_spi_master(.clk(clk),.rst(rst),.miso(dac_reg_miso),.mosi(dac_reg_mosi),.sck(dac_reg_sck),.start(dac_reg_start),.data_in(dac_reg_data_out),.data_out(dac_reg_data_in),.busy(dac_reg_busy),.new_data(dac_reg_new_data));
//-------------------------------------

//------------ADC read----------------
localparam ADC_OUTPUT_DATA_WIDTH = 24;
reg 	adc_read_diapason; // read diapason flag
reg 	adc_start_cycle_conv_d, adc_start_cycle_conv_q;
wire 	adc_cycle_complete;
wire 	[ADC_OUTPUT_DATA_WIDTH-1:0]adc_data_out_1;
wire 	[ADC_OUTPUT_DATA_WIDTH-1:0]adc_data_out_2;

reg	[ADC_OUTPUT_DATA_WIDTH-1:0] diap_current, diap_voltage;

adc_read  #(.OUTPUT_DATA_WIDTH(ADC_OUTPUT_DATA_WIDTH))dev_adc_read(.clk(clk),.rst(rst),.sample_adc(adc_start_conv),.start_cycle_conv(adc_start_cycle_conv_q),.halfcycle(gen_halfcycle),.read_diapason(adc_read_diapason),.complete(adc_cycle_complete),.data_out_1(adc_data_out_1),.data_out_2(adc_data_out_2),.cnv(adc_cnv),.adc_busy(adc_busy),.miso(adc_miso),.sck(adc_sck));

//------------------------------------
reg [5:0] fifo_cycle_index_d, fifo_cycle_index_q;//for index of elements fifo
//---------------DIAPASON-------------	
reg  diap_start_d, diap_start_q;
wire diap_ready;
wire [1:0] diap_result;
assign     diap_keys=(diap_result==0)?(3'b001):((diap_result==1)?(3'b010):((diap_result==2)?(3'b100):(3'b000)));
 diap #(.DATA_WIDTH(18)) dev_diap(.clk(clk),.rst(rst),.current(diap_current),.voltage(diap_voltage),.start(diap_start_q),.ready(diap_ready),.diap_result(diap_result));

 //------------------------------------
assign cycle_done=((state_q==DONE) & enable);
 //------------------------------------

localparam CLOCK_DIVIDER	= 39;
reg [6:0]clock_div_counter;
always @(posedge clk) begin//clock divider
	if(rst)
	begin
		clock_div_counter<=7'b0;
		gen_sample_clk<=1'b0;
	end
	else
	begin
		
		if(clock_div_counter==CLOCK_DIVIDER)
		begin
			gen_sample_clk<=!gen_sample_clk;
			clock_div_counter<=7'b0;
		end
		else 
		begin
			clock_div_counter<=clock_div_counter+7'b1;
		end
	end
end
//------------------------------------- 
//always @(posedge clk) begin//???
//	if(rst)
//	begin
//		sample_clk_r<=2'b00;
//	end
//	else
//	begin
//		sample_clk_r<={sample_clk_r[0],gen_sample_clk};
//	end
//end
//------------------------------------		
always @ (*) begin	//FSM	 
	 state_d=state_q;
	 analog_mux_chn_d=analog_mux_chn_q;
	 mode_keys_d=mode_keys_q;
	 cs_dac_reg_d=cs_dac_reg_q;
	 dac_reg_start_d=1'b0;
	 gen_enable_d=gen_enable_q;
	 delay_counter_d=delay_counter_q;
	 mode_reg_d=mode_reg_q;
	 adc_start_cycle_conv_d=adc_start_cycle_conv_q;
	 
	 fifo_wr_en_d=fifo_wr_en_q;
	 fifo_rd_en_d=fifo_rd_en_q;
	 
	 fifo_cycle_index_d=fifo_cycle_index_q;
	 
	 diap_start_d=1'b0;
	 
	 fifo_data_in_d=fifo_data_in_q;
	 
		case (state_q)
			IDLE:
			begin
				//gen_enable_d<=1;
				if(enable /*&& gen_new_period*/)
				begin
					state_d <= START_CYCLE;
					fifo_cycle_index_d<=6'b0;
				end
			end
//------------------------------------------------						
			START_CYCLE:
			begin
				//state_d<=MEASURE_MODE_DIAPASON;
				state_d<=MEASURE_MODE_START;
				mode_reg_d<=MEASURE_MODE_DIAP;
			end
//------------------------------------------------			
//			MEASURE_MODE_DIAPASON://???
//			begin
//				state_d<=MEASURE_MODE_DETERMINATE_DIAPASON;
//			end
			
		   MEASURE_MODE_START_DETERMINATE_DIAPASON:
			begin			
				diap_start_d<=1'b1;
				state_d<=MEASURE_MODE_WAIT_FOR_DETERMINATE_DIAPASON;
			end
			
			MEASURE_MODE_WAIT_FOR_DETERMINATE_DIAPASON:
			begin		
				if(diap_ready)
				begin	
					state_d<=MEASURE_MODE_DIAP_TO_FIFO;
					fifo_data_in_d<={fifo_cycle_index_q[5:0],{16{1'b0}},diap_result};
					fifo_wr_en_d<=1'b1;
				end
			end
			
			MEASURE_MODE_DIAP_TO_FIFO://???
			begin						
				fifo_cycle_index_d<=fifo_cycle_index_q+1;
				fifo_wr_en_d<=1'b0;
				state_d<=MEASURE_MODE_START;//???
			end
//------------------------------------------------			
			MEASURE_MODE_START:
			begin
				cs_dac_reg_d<=CS_DAC_REG_REG;
				state_d<=MEASURE_MODE_START_SET_DIAP_MODE_KEYS;
				
				//set keys from mode (case)
				case (mode_reg_q)
				
					MEASURE_MODE_DIAP:
					begin
						mode_keys_d<=MEASURE_MODE_DIAP_KEY;
					end	
				
					MEASURE_MODE_1:
					begin
						mode_keys_d<=MEASURE_MODE_1_KEY;
					end	
					
					MEASURE_MODE_2:
					begin
						mode_keys_d<=MEASURE_MODE_2_KEY;
					end	

					MEASURE_MODE_3:
					begin
						mode_keys_d<=MEASURE_MODE_3_KEY;
					end	

					MEASURE_MODE_4:
					begin
						mode_keys_d<=MEASURE_MODE_4_KEY;
					end	

					MEASURE_MODE_5:
					begin
						mode_keys_d<=MEASURE_MODE_5_KEY;
					end
				endcase
				//-----------------
			end
			
			MEASURE_MODE_START_SET_DIAP_MODE_KEYS:
			begin			
				dac_reg_start_d<=1'b1;
				state_d<=MEASURE_MODE_WAIT_SPI;
			end
			
			MEASURE_MODE_WAIT_SPI:
			begin
				if(dac_reg_new_data)
				begin
					state_d<=MEASURE_MODE_GENERATOR_ON;
				end
			end
			
			MEASURE_MODE_GENERATOR_ON:
			begin
				cs_dac_reg_d<=CS_DAC_REG_DAC;
				gen_enable_d<=1'b1;
				state_d<=MEASURE_MODE_SET_MULTIPLEXOR;
			end
			
			MEASURE_MODE_SET_MULTIPLEXOR:
			begin
				//set mux from mode (case)		
				analog_mux_chn_d<=MUX_CURRENT;
				delay_counter_d<=WAIT_PERIODS;
				state_d<=MEASURE_MODE_SET_DELAY_1;				
			end
			
			MEASURE_MODE_SET_DELAY_1:
			begin
				if(gen_new_period)
				begin
					if(delay_counter_q!=0)
					begin
						delay_counter_d=delay_counter_q-1;
					end
					else 
					begin
						state_d<=MEASURE_MODE_START_MEASURE;
						//state_d<=MEASURE_MODE_GENERATOR_OFF;
					end
				end
			end

			MEASURE_MODE_START_MEASURE:
			begin
				if(mode_reg_q==MEASURE_MODE_DIAP)//???
				begin
					adc_read_diapason=1'b1;
				end
				else
				begin
					adc_read_diapason=1'b0;
				end
				
				adc_start_cycle_conv_d=1'b1;
				state_d<=MEASURE_MODE_WAIT_MEASURE_RESULT;
			end
			
			MEASURE_MODE_WAIT_MEASURE_RESULT:
			begin
				adc_start_cycle_conv_d=1'b0;
				if(adc_cycle_complete)
				begin
					if(mode_reg_q==MEASURE_MODE_DIAP)
					begin
						diap_current<=adc_data_out_1;
						state_d<=MEASURE_MODE_SET_MULTIPLEXOR_2;						
					end
					else
					begin
						state_d<=MEASURE_MODE_SEND_TO_FIFO_1;
						fifo_data_in_d<={fifo_cycle_index_q[5:0],adc_data_out_1[17:0]};
						fifo_wr_en_d<=1'b1;
					end
					
				end
			end			
			
//			MEASURE_MODE_SEND_TO_FIFO_1:
//			begin
//				//fifo_data_in<={fifo_cycle_index_q[5:0],adc_data_out_1[17:0]};
//				//fifo_wr_en_d<=1'b1;
//				fifo_cycle_index_d<=fifo_cycle_index_q+1;
//				state_d<=MEASURE_MODE_SEND_TO_FIFO_2;
//				fifo_data_in_d<={fifo_cycle_index_q[5:0],adc_data_out_2[17:0]};
//			end
//			
//			MEASURE_MODE_SEND_TO_FIFO_2: //??????????????????
//			begin
//				//fifo_data_in<={fifo_cycle_index_q[5:0],adc_data_out_2[17:0]};
//				fifo_cycle_index_d<=fifo_cycle_index_q+1;
//				fifo_wr_en_d<=1'b0;
//				if(mode_reg_q==MEASURE_MODE_1)
//				begin
//					state_d<=MEASURE_MODE_GENERATOR_OFF;
//				end
//				else
//				begin
//					state_d<=MEASURE_MODE_SET_MULTIPLEXOR_2;
//				end				
//			end

			MEASURE_MODE_SEND_TO_FIFO_1: 
			begin
				//fifo_data_in<={fifo_cycle_index_q[5:0],adc_data_out_2[17:0]};
				fifo_cycle_index_d<=fifo_cycle_index_q+1;
				fifo_wr_en_d<=1'b0;
				if(mode_reg_q==MEASURE_MODE_1)
				begin
					state_d<=MEASURE_MODE_GENERATOR_OFF;
				end
				else
				begin
					state_d<=MEASURE_MODE_SET_MULTIPLEXOR_2;
				end				
			end

			MEASURE_MODE_SET_MULTIPLEXOR_2:
			begin		
				analog_mux_chn_d<=MUX_MN_NM;//???
				delay_counter_d<=WAIT_PERIODS;
				state_d<=MEASURE_MODE_SET_DELAY_2;
			end

			MEASURE_MODE_SET_DELAY_2:
			begin
				if(gen_new_period)
				begin
					if(delay_counter_q!=0)
					begin
						delay_counter_d=delay_counter_q-1;
					end
					else 
					begin
						state_d<=MEASURE_MODE_START_MEASURE_2;
					end
				end
			end	
	
			MEASURE_MODE_START_MEASURE_2:
			begin
				adc_start_cycle_conv_d<=1'b1;
				state_d<=MEASURE_MODE_WAIT_MEASURE_RESULT_2;
			end
			
			MEASURE_MODE_WAIT_MEASURE_RESULT_2:
			begin
				adc_start_cycle_conv_d<=1'b0;
				if(adc_cycle_complete)
				begin
					if(mode_reg_q==MEASURE_MODE_DIAP)//???
					begin
						diap_voltage<=adc_data_out_1;
						state_d<=MEASURE_MODE_GENERATOR_OFF;						
					end
					else
					begin
						state_d<=MEASURE_MODE_SEND_TO_FIFO_3;
						fifo_wr_en_d<=1'b1;
						fifo_data_in_d<={fifo_cycle_index_q[5:0],adc_data_out_1[17:0]};
					end
				end
			end			
						
			MEASURE_MODE_SEND_TO_FIFO_3:
			begin
				//fifo_data_in<={fifo_cycle_index_q[5:0],adc_data_out_1[17:0]};
				fifo_cycle_index_d<=fifo_cycle_index_q+1;
				//fifo_wr_en_d<=1'b1;
				state_d<=MEASURE_MODE_SEND_TO_FIFO_4;
				fifo_data_in_d<={fifo_cycle_index_q[5:0],adc_data_out_2[17:0]};
			end
			
			MEASURE_MODE_SEND_TO_FIFO_4: 
			begin
				//fifo_data_in<={fifo_cycle_index_q[5:0],adc_data_out_2[17:0]};
				fifo_cycle_index_d<=fifo_cycle_index_q+1;
				fifo_wr_en_d<=1'b0;
				state_d<=MEASURE_MODE_GENERATOR_OFF;
			end
		
			MEASURE_MODE_GENERATOR_OFF:
			begin
				cs_dac_reg_d<=CS_DAC_REG_NONE;
				gen_enable_d<=1'b0;
				state_d<=MEASURE_MODE_MULTIPLEXOR_OFF;
			end	
	
			MEASURE_MODE_MULTIPLEXOR_OFF:
			begin
				analog_mux_chn_d<=MUX_NONE;
				state_d<=MEASURE_MODE_END;
			end	
		
			MEASURE_MODE_END:
			begin
				if(mode_reg_q==MEASURE_MODE_5)
				begin
					state_d<=DONE;
				end
				else if(mode_reg_q==MEASURE_MODE_DIAP)
				begin
					mode_reg_d<=mode_reg_q+1;
					state_d<=MEASURE_MODE_START_DETERMINATE_DIAPASON;
				end
				else
				begin
					mode_reg_d<=mode_reg_q+1;
					state_d<=MEASURE_MODE_START;
				end
			end			
//------------------------------------------------			
			DONE:
			begin
				state_d <= IDLE;
			end		
//------------------------------------------------			
		endcase
		
		if(gen_enable)//send sample on DAC
		begin
			if(gen_data_ready)
			begin
				dac_reg_start_d<=1'b1;
			end
		end
		
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
		 mode_reg_q<=MEASURE_MODE_1;//
//		 diap_q<=2'b00;
		 fifo_wr_en_q<=1'b0;
		 fifo_rd_en_q<=1'b0;	
		 
		 adc_start_cycle_conv_q<=1'b0;
		 fifo_cycle_index_q<=6'b0;
		 
		 diap_start_q<=1'b0;
		 
		 fifo_data_in_q<=24'b0;
    end 
	 else 
	 begin
		 state_q<=state_d;
		 analog_mux_chn_q=analog_mux_chn_d;
		 mode_keys_q<=mode_keys_d;
//		 diap_q<=diap_d;
		 cs_dac_reg_q<=cs_dac_reg_d;
		 dac_reg_start_q<=dac_reg_start_d;
		 gen_enable_q<=gen_enable_d;
		 delay_counter_q<=delay_counter_d;
		 mode_reg_q<=mode_reg_d;	
		 
		 adc_start_cycle_conv_q<=adc_start_cycle_conv_d;
		
		 fifo_wr_en_q<=fifo_wr_en_d;
		 fifo_rd_en_q<=fifo_rd_en_d;	
		 
		 fifo_cycle_index_q<=fifo_cycle_index_d;
		 
		 diap_start_q<=diap_start_d;
		 
		 fifo_data_in_q<=fifo_data_in_d;
    end
	end			

endmodule


//-----------------------testbench----------------------------
`timescale 1 ps/ 1 ps
module logic_tb();

	reg clk;
	reg rst;
	//---ADC signals-------
	wire adc_cnv;
	reg  adc_busy;
	wire [2:0]analog_mux_chn;
	
	//---ADC SPI signals---	 	
	wire  adc_miso;
	wire adc_sck;
	//---DAC & comm SPI----
	wire  dac_reg_mosi;
	wire dac_reg_sck;

	wire [1:0]cs_dac_reg;

	reg enable;
	
	wire fifo_data_out;
	wire fifo_empty;
	reg  fifo_rd_en;
	reg  rdclk;
	
	wire cycle_done;
	
	 //-------adc emul---
	 reg [35:0] adc_shift_reg;
	 //-------------------------
	assign adc_miso=adc_shift_reg[35];
	logic test_logic(.clk(clk),.rst(rst),.adc_cnv(adc_cnv),.adc_busy(adc_busy),.analog_mux_chn(analog_mux_chn),.adc_miso(adc_miso),.adc_sck(adc_sck),.dac_reg_mosi(dac_reg_mosi),.dac_reg_sck(dac_reg_sck),.cs_dac_reg(cs_dac_reg),.enable(enable),.fifo_data_out(fifo_data_out),.fifo_empty(fifo_empty),.fifo_rd_en(fifo_rd_en),.rdclk(rdclk),.cycle_done(cycle_done));
	
	 initial
	 begin
		clk<=0;
		rst<=0;
		enable<=1;
		adc_busy<=0;
		#50
		rst=1;
		#50
		rst=0;
	 end
	 
	/*always @(negedge sck) 
	begin

		
	end*/
	
	 always @(posedge clk) begin
	 
	 end
	 
	 always @(posedge adc_cnv) begin
		adc_busy<=1;
		adc_shift_reg=36'b000000000000000001000000000000000001;
		#100
		adc_busy<=0;
	 end
	
	 always @(negedge adc_sck) begin
		//adc_miso<=adc_shift_reg[35];
		adc_shift_reg[35:0]<={adc_shift_reg[34:0],1'b0};
	 end
	 
	 always 
		#5  clk =  ! clk;    
endmodule
