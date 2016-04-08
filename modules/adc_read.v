//`include "spi_master.v"

/*module adc_sample_read#(parameter DATA_WIDTH = 36)(
	input clk,
	input rst,
	input start,
	output done,
	output[DATA_WIDTH-1:0] data,
	);

	
endmodule*/

module adc_read #(parameter DATA_WIDTH = 24, DIAP_WIDTH = 2)(
    input clk,
    input rst,
	 
    input sample_adc,
	 //input new_period,//???
	 input start_cycle_conv,
	 
	 input read_diapason,
	 
    output complete,
    output[DATA_WIDTH-1:0] data_out_1,
    output[DATA_WIDTH-1:0] data_out_2,
	 
	 //---ADC signals---
	 output reg cnv,
	 input  adc_busy,
	 //---SPI signals---	 	
	 input  miso,
    output sck	
	 //---------------------
  );
  

   parameter CHANNEL_DATA_WIDTH				= 18;
   parameter ADC_DATA_WIDTH    				= CHANNEL_DATA_WIDTH*2;	
	parameter INTEGRATOR_WIDTH					= 24;
	parameter MEASURE_FOR_RESULT_PERIODS	= 32;
	parameter MEASURE_SAMPLES_IN_PERIOD		= 32;
	parameter MEASURE_RESULT_SAMPLES			= MEASURE_FOR_RESULT_PERIODS*MEASURE_SAMPLES_IN_PERIOD;	
	parameter MEASURE_RESULT_COUNT_WIDTH	= 10;
	parameter RESULT_INTEGRATOR_WIDTH		= 28;
	
  localparam STATE_SIZE = 4;
  localparam MEASURE_COUNT_WIDTH = 3;
  
  //----ADC regs----
  wire 	mosi;
  //----SPI regs----
  wire 	spi_busy;
  wire  	spi_done;
  reg		spi_start;
  //----------------
  
  reg [STATE_SIZE-1:0] state_d, state_q;
  reg [MEASURE_COUNT_WIDTH-1:0] measure_count_d, measure_count_q;
  
  reg [DATA_WIDTH-1:0] data_out_1_d,data_out_1_q;
  reg [DATA_WIDTH-1:0] data_out_2_d,data_out_2_q
  
  
  reg [1:0] sample_adc_r;  
  wire sig_start_conv=(sample_adc_r[1]!=sample_adc_r[0])&sample_adc_r[0];
  
  reg [1:0] start_cycle_conv_r;
  wire sig_start_cycle_conv=(start_cycle_conv_r[1]!=start_cycle_conv_r[0])&start_cycle_conv_r[0];
  
  reg [1:0] adc_busy_r;
  wire sig_adc_complete=(adc_busy_r[1]!=adc_busy_r[0])&adc_busy_r[0];
  
  reg [1:0] spi_done_r;
  wire sig_spi_done=(spi_done_r[1]!=spi_done_r[0])&spi_done_r[0];
  
  reg [MEASURE_RESULT_COUNT_WIDTH-1:0]sample_counter_d, sample_counter_q;  
  reg[RESULT_INTEGRATOR_WIDTH-1:0] result_integrator;//_d,result_integrator_q;
   
  assign complete = (state_q == DONE);
	
  assign data_out_1 = data_out_1_q;
  assign data_out_2 = data_out_2_q;
  	
//FSM	 state coding
  localparam [4:0]  	
				IDLE 										= 1, 
				START_READ								= 2,
				START_READ_ADC_SAMPLE				= 3,
				WAIT_ADC_SAMPLE						= 4,
				START_READ_SPI							= 5,
				WAIT_SPI									= 6
				SUMM_RESULT								= 7,
				DONE										= 8;

//------------------SPI---------------------------
	 parameter SPI_ADC_CLK_DIV = 2;
	 parameter SPI_ADC_DATA_WIDTH = ADC_DATA_WIDTH;
	 parameter SPI_ADC_BIT_CNT_WIDTH = 4;
	 
	 
    reg start;
    reg[DATA_WIDTH-1:0] data_in;
    wire[DATA_WIDTH-1:0] data_out;
    //wire adc_busy;
    
	 
	 spi_master #(SPI_ADC_CLK_DIV,SPI_ADC_DATA_WIDTH,SPI_ADC_BIT_CNT_WIDTH) adc_spi_master(.clk(clk),.rst(rst),.miso(miso),.mosi(mosi),.sck(sck),.start(start),.data_in(data_in),.data_out(data_out),.busy(spi_busy),.new_data(adc_done));

//------------------------------------------------				
				
				
	 always @(posedge clk) begin //async signals
		if (rst) 
		begin
			sample_adc_r<=2'b00;
			start_cycle_conv_r<=2'b00;
			spi_done_r<=2'b00;
		end
		else
		begin
			sample_adc_r<={sample_adc_r[0],sample_adc};
			start_cycle_conv_r<={start_cycle_conv_r[0],start_cycle_conv};
			spi_done_r<={spi_done_r[0],spi_done};
		end
	 end

	always @ (*) begin	//FSM
	 
	 state_d=state_q;
	 measure_count_d=measure_count_q;
	 
	 	 
		case (state_q)
		
			IDLE:
			begin
				if(start_cycle_conv_r)
				begin
					state_d <= START_READ;
				end
			end
						
			START_READ:
			begin
				spi_start=1'b0;
				result_integrator<={RESULT_INTEGRATOR_WIDTH{1'b0}};
			end
			
			START_READ_ADC_SAMPLE:
			begin
				cnv<=1'b1;
				state_d <= WAIT_ADC_SAMPLE;
			end
			
			WAIT_ADC_SAMPLE:
			begin
				cnv=1'b0;
				if(sig_adc_complete)
				begin
					state_d <= START_READ_SPI;
				end
			end
			
			START_READ_SPI:
			begin
				spi_start=1'b1;
				state_d <= WAIT_SPI;
			end
			
			WAIT_SPI:
			begin
			
				if (sig_spi_done)
				begin
					state_d <= SUMM_RESULT;
				end	
			end
			
			SUMM_RESULT:
			begin
				/*if ()
				begin
					
				end
				else
				begin

				end*/
			end
			
			DONE:
			begin
				/*if ()
				begin
					
				end
				else
				begin

				end*/
			end
			
			
			
		endcase
	end
	
   always @(posedge clk) begin
    if (rst) 
	 begin
		 state_q<=IDLE;
		 measure_count_q<={MEASURE_COUNT_WIDTH{1'b0}};
		 result_integrator/*_q*/<={RESULT_INTEGRATOR_WIDTH{1'b0}};
		 
    end 
	 else 
	 begin
		 state_q<=state_d;
		 measure_count_q<=measure_count_d;		 
		 //result_integrator_q<=result_integrator_d;
		 
    end
	end
  endmodule
  
  
  module adc_read_tb();
		
	 parameter DATA_WIDTH = 24;
	 parameter DIAP_WIDTH = 2;
	 
    reg clk;
    reg rst;
    reg sample_adc;
	 reg start_cycle_conv;
	 reg  adc_busy;
	 wire adc_cnv;
    wire complete;
    wire[DATA_WIDTH-1:0] data_out_1;
    wire[DATA_WIDTH-1:0] data_out_2;
	 wire signal_cnv;	 
	 
	 adc_read #(DATA_WIDTH, DIAP_WIDTH) test_adc_read(.clk(clk),.rst(rst),.sample_adc(sample_adc),.start_cycle_conv(start_cycle_conv),.adc_busy(adc_busy),.complete(complete),.data_out_1(data_out_1),.data_out_2(data_out_2),.signal_cnv(signal_cnv));
  
		initial
		begin
			clk<=0;
			sample_adc<=0;
			rst=0;
			#500
			rst=1;	
		end
		
		always 
			#5  clk =  ! clk;  
			
		always 
			#500  sample_adc =  ! sample_adc;  
			
		always
			#1000 start_cycle_conv =! start_cycle_conv;
  
  endmodule
  