module adc_read #(parameter DATA_WIDTH = 24, DIAP_WIDTH = 2)(
    input clk,
    input rst,
    input sample_adc,
	 input start_conv,
    output complete,
    output[DATA_WIDTH-1:0] data_out_1,
    output[DATA_WIDTH-1:0] data_out_2,
	 output[DIAP_WIDTH-1:0] diap,
	 	 
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
  
  reg sample_adc_last,sample_adc_next;
  
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
  localparam [5:0]  	
				IDLE 					= 6'b000001, 
				START_CONV 			= 6'b000010,
				READ_FOR_DIAP		= 6'b000100,
				CALC_DIAP			= 6'b001000,	
				READ_RESULT 		= 6'b010000, 
				SHIFT_INTEGRATOR 	= 6'b100000,
	


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
				if(start_conv)
				begin
					state_d <= START_CONV;
				end
			end
			
			START_CONV:
			begin
				if ()
				begin
					
				end
				else
				begin
					
				end
			end
			
			READ_FOR_DIAP:
			begin
				if ((sample_adc_last^sample_adc_next)&&(diap_sample_counter<MEASURE_DIAP_SAMPLES))
				begin
					
				end
				
				else
				
				begin
					state_d <= CALC_DIAP;
				end
			end
			
			CALC_DIAP:
			begin
				if ()
				begin
					
				end
				else
				begin
				
					end
			end
			
			READ_RESULT:
			begin
				if ()
				begin
					
				end
				else
				begin
					
				end
			end
			
			SHIFT_INTEGRATOR:
			begin
				if ()
				begin
					
				end
				else
				begin

				end
			end
			
		endcase
	end
	
	  always @(posedge clk) begin
    if (rst) begin

		 state_q<=IDLE;
		 start_q<=1'b0;
		 diap_q<=;
		 complete_q<=1'b0;
		 data_out_1_q<={DATA_WIDTH{1'b0}};
		 data_out_2_q<={DATA_WIDTH{1'b0}};
		 measure_count_q<={MEASURE_COUNT_WIDTH{1'b0}};
		 diap_integrator_q<={DIAP_INTEGRATOR_WIDTH{1'b0}};
		 result_integrator_q<={RESULT_INTEGRATOR_WIDTH{1'b0}};
		 sample_adc_last<=1'b0;
		 sample_adc_next<=1'b0;
		 
		 
    end else begin
		 state_q<=state_d;
		 start_q<=start_d;
		 diap_q<=diap_d;
		 complete_q<=complete_d;
		 data_out_1_q<=data_out_1_d;
		 data_out_2_q<=data_out_2_d;
		 measure_count_q<=measure_count_d;
		 
		 diap_integrator_q<=diap_integrator_d;
		 result_integrator_q<=result_integrator_d;
		 
		 sample_adc_last<=sample_adc_next;
		 sample_adc_next<=sample_adc;
    end
  
  endmodule
  
  
  module adc_read_tb()
  
  endmodule
  