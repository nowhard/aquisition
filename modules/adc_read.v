`include "spi_master.v"

module adc_read #(parameter DATA_WIDTH = 24, DIAP_WIDTH = 2)(
    input clk,
    input rst,
    input sample_adc,
	 input start_cycle_conv,
	 input  adc_busy,
	 output adc_cnv,
    output complete,
    output[DATA_WIDTH-1:0] data_out_1,
    output[DATA_WIDTH-1:0] data_out_2,
	 output[DIAP_WIDTH-1:0] diap,
	 output signal_cnv	 
  );
  

  
   parameter ADC_DATA_WIDTH    				= 36;
	parameter INTEGRATOR_WIDTH					= 24;
	parameter MEASURE_FOR_DIAP_PERIODS		=	2;
	parameter MEASURE_FOR_RESULT_PERIODS	= 32;
	parameter MEASURE_SAMPLES_IN_PERIOD		= 32;
	parameter MEASURE_DIAP_SAMPLES			= MEASURE_FOR_DIAP_PERIODS*MEASURE_SAMPLES_IN_PERIOD;
	parameter MEASURE_RESULT_SAMPLES			= MEASURE_FOR_RESULT_PERIODS*MEASURE_SAMPLES_IN_PERIOD;
	
	parameter MEASURE_RESULT_COUNT_WIDTH	= 10;
	parameter MEASURE_DIAP_COUNT_WIDTH		=  6;
	
	parameter DIAP_INTEGRATOR_WIDTH			= 24;
	parameter RESULT_INTEGRATOR_WIDTH		= 28;
	

  localparam STATE_SIZE = 3;
  localparam MEASURE_COUNT_WIDTH = 3;
  
  reg [STATE_SIZE-1:0] state_d, state_q;
  reg start_d, start_q; 
  reg diap_d, diap_q;
  reg complete_d, complete_q;
  reg [DATA_WIDTH-1:0] data_out_1_d, data_out_1_q;
  reg [DATA_WIDTH-1:0] data_out_2_d, data_out_2_q;
  reg [MEASURE_COUNT_WIDTH-1:0] measure_count_d, measure_count_q;
  

  reg [1:0] sample_adc_r;  
  wire sig_start_conv=(sample_adc_r[1]!=sample_adc_r[0])&sample_adc_r[0];
  
  reg [1:0] start_cycle_conv_r;
  wire sig_start_cycle_conv=(start_cycle_conv_r[1]!=start_cycle_conv_r[0])&start_cycle_conv_r[0];
  
  reg [1:0] adc_busy_r;
  wire sig_adc_complete=(adc_busy_r[1]!=adc_busy_r[0])&adc_busy_r[0];
  
  reg [MEASURE_RESULT_COUNT_WIDTH-1:0]result_sample_counter;
  reg [MEASURE_DIAP_COUNT_WIDTH-1:0]diap_sample_counter;
  
  reg[DIAP_INTEGRATOR_WIDTH-1:0] diap_integrator_d, diap_integrator_q;
  reg[RESULT_INTEGRATOR_WIDTH-1:0] result_itegrator_d,result_itegrator_q;
   

  assign complete = state_q == IDLE;
  assign data_out_1 = data_out_1_q;
  assign data_out_2 = data_out_2_q;
  assign new_data = new_data_q;
  assign diap=diap_q;
	
	
//FSM	one-hot state coding
  localparam [14:0]  	
				IDLE 										= 15'b000000000000001, 
				START_READ_DIAPASON					= 15'b000000000000010,
				START_READ_ADC_SAMPLE_DIAPASON	= 15'b000000000000100,
				WAIT_ADC_SAMPLE_DIAPASON			= 15'b000000000001000,
				START_READ_SPI_DIAPASON				= 15'b000000000010000,
				WAIT_SPI_DIAPASON						= 15'b000000000100000,
				SUMM_DIAPASON							= 15'b000000001000000,
				DIAPASON_CHOISE						= 15'b000000010000000,
				START_READ_RESULT						= 15'b000000100000000,
				START_READ_ADC_SAMPLE_RESULT		= 15'b000001000000000,
				WAIT_ADC_SAMPLE_RESULT				= 15'b000010000000000,
				START_READ_SPI_RESULT				= 15'b000100000000000,
				WAIT_SPI_RESULT						= 15'b001000000000000,
				SUMM_RESULT								= 15'b010000000000000,
				DONE										= 15'b100000000000000;

//------------------SPI---------------------------
	 parameter SPI_ADC_CLK_DIV = 2;
	 parameter SPI_ADC_DATA_WIDTH = 36;
	 parameter SPI_ADC_BIT_CNT_WIDTH = 4;
	 
    reg miso;
    wire mosi;
    wire sck;
    reg start;
    reg[DATA_WIDTH-1:0] data_in;
    wire[DATA_WIDTH-1:0] data_out;
    //wire adc_busy;
    wire new_data; 
	 
	 spi_master #(SPI_ADC_CLK_DIV,SPI_ADC_DATA_WIDTH,SPI_ADC_BIT_CNT_WIDTH) adc_spi_master(.clk(clk),.rst(rst),.miso(miso),.mosi(mosi),.sck(sck),.start(start),.data_in(data_in),.data_out(data_out),.busy(adc_busy),.new_data(new_data));

//------------------------------------------------				
				
				
	 always @(posedge clk) begin //async signals
		if (rst) 
		begin
			sample_adc_r<=2'b00;
			start_cycle_conv_r<=2'b00;
			
		end
		else
		begin
			sample_adc_r<={sample_adc_r[0],sample_adc};
			start_cycle_conv_r<={start_cycle_conv_r[0],start_cycle_conv};
		end
	 end

	always @ (*) begin	//FSM
	 
	 state_d=state_q;
	 start_d=start_q;
	 diap_d=diap_q;
	 complete_d=complete_q;
	 data_out_1_d=data_out_1_q;
	 data_out_2_d=data_out_2_q;
	 measure_count_d=measure_count_q;
	 	 
		case (state_q)
		
			IDLE:
			begin
				if(start_cycle_conv_r)
				begin
					state_d <= START_CYCLE_CONV;
				end
			end
			
			START_READ_DIAPASON: //
			begin
				/*if ()
				begin
					
				end
				else
				begin
					
				end*/
			end
			
			START_READ_ADC_SAMPLE_DIAPASON:
			begin
				signal_cnv<=1'b1;
				state_d <= WAIT_ADC_SAMPLE_DIAPASON;
			end
			
			WAIT_ADC_SAMPLE_DIAPASON:
			begin
				if(sig_adc_complete==1'b1)
				begin
					state_d <= START_READ_SPI_DIAPASON;
				end
			end
			
			START_READ_SPI_DIAPASON:
			begin
				/*if ()
				begin
					
				end
				else
				begin
					
				end*/
			end
			
			WAIT_SPI_DIAPASON:
			begin
				/*if ()
				begin
					
				end
				else
				begin

				end*/
			end
			
			SUMM_DIAPASON:
			begin
				/*if ()
				begin
					
				end
				else
				begin

				end*/
			end
			
			DIAPASON_CHOISE:
			begin
				/*if ()
				begin
					
				end
				else
				begin

				end*/
			end
			
			START_READ_RESULT:
			begin
				/*if ()
				begin
					
				end
				else
				begin

				end*/
			end
			
			START_READ_ADC_SAMPLE_RESULT:
			begin
				/*if ()
				begin
					
				end
				else
				begin

				end*/
			end
			
			WAIT_ADC_SAMPLE_RESULT:
			begin
				/*if ()
				begin
					
				end
				else
				begin

				end*/
			end
			
			START_READ_SPI_RESULT:
			begin
				/*if ()
				begin
					
				end
				else
				begin

				end*/
			end
			
			WAIT_SPI_RESULT:
			begin
				/*if ()
				begin
					
				end
				else
				begin

				end*/
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
    if (rst) begin

		 state_q<=IDLE;
		 start_q<=1'b0;
		 //diap_q<=;
		 complete_q<=1'b0;
		 data_out_1_q<={DATA_WIDTH{1'b0}};
		 data_out_2_q<={DATA_WIDTH{1'b0}};
		 measure_count_q<={MEASURE_COUNT_WIDTH{1'b0}};
		 diap_integrator_q<={DIAP_INTEGRATOR_WIDTH{1'b0}};
		 result_integrator_q<={RESULT_INTEGRATOR_WIDTH{1'b0}};
		 
    end 
	 else 
	 begin
		 state_q<=state_d;
		 start_q<=start_d;
		 diap_q<=diap_d;
		 complete_q<=complete_d;
		 data_out_1_q<=data_out_1_d;
		 data_out_2_q<=data_out_2_d;
		 measure_count_q<=measure_count_d;
		 
		 diap_integrator_q<=diap_integrator_d;
		 result_integrator_q<=result_integrator_d;
		 
    end
	end
  endmodule
  
  
 /* module adc_read_tb()
  
  endmodule*/
  