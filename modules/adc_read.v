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
	

  localparam STATE_SIZE = 3;
  localparam MEASURE_COUNT_WIDTH = 3;
  
  reg [STATE_SIZE-1:0] state_d, state_q;
  reg start_d, start_q; 
  reg diap_d, diap_q;
  reg complete_d, complete_q;
  reg [DATA_WIDTH-1:0] data_out_1_d, data_out_1_q;
  reg [DATA_WIDTH-1:0] data_out_2_d, data_out_2_q;
  reg [MEASURE_COUNT_WIDTH-1:0] measure_count_d, measure_count_q;
   

 // assign busy = state_q != IDLE;
  assign data_out_1 = data_out_1_q;
  assign data_out_2 = data_out_2_q;
  assign new_data = new_data_q;

	
	
	
//FSM	one-hot state coding
  localparam [5:0]  	
				IDLE 					= 6'b000001, 
				START_CONV 			= 6'b000010,
				READ_FOR_DIAP		= 6'b000100,
				CALC_DIAP			= 6'b001000,	
				READ_RESULT 		= 6'b010000, 
				SHIFT_INTEGRATOR 	= 6'b100000,
	

	
	// Determine the next state
	always @ (posedge clk ) begin
	 
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
						//state <= S2;
					else
						//state <= S1;
				end
				
				READ_FOR_DIAP:
					if (data_in)
						//state <= S3;
					else
						//state <= S1;
				CALC_DIAP:
					if ()
						//state <= S2;
					else
						//state <= S3;		
				READ_RESULT:
					if ()
						//state <= S2;
					else
						//state <= S3;
				SHIFT_INTEGRATOR:
					if ()
						//state <= S2;
					else
						//state <= S3;						
			endcase
	end
	
	  always @(posedge clk) begin
    if (rst) begin
   /*   ctr_q <= {BIT_CNT_WIDTH{1'b0}};
      data_q <= {DATA_WIDTH{1'b0}};
      sck_q <= 4'b0;
      mosi_q <= 1'b0;
      state_q <= IDLE;
      data_out_q <= {DATA_WIDTH{1'b0}};
      new_data_q <= 1'b0;*/
		
		 state_q<=IDLE;
		 start_q<=1'b0;
		 diap_q<=;
		 complete_q<=1'b0;
		 data_out_1_q<={DATA_WIDTH{1'b0}};
		 data_out_2_q<={DATA_WIDTH{1'b0}};
		 measure_count_q<={MEASURE_COUNT_WIDTH{1'b0}};
    end else begin
		 state_q<=state_d;
		 start_q<=start_d;
		 diap_q<=diap_d;
		 complete_q<=complete_d;
		 data_out_1_q<=data_out_1_d;
		 data_out_2_q<=data_out_2_d;
		 measure_count_q<=measure_count_d;
    end
  
  endmodule
  
  
  module adc_read_tb()
  
  endmodule
  