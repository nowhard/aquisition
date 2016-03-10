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

	/*reg		[2:0]state;
	reg 		start;
	reg 		new_data;
	
	reg 		[4:0]measure_count;*/
	
  reg [DATA_WIDTH-1:0] data_d, data_q;
  reg [CLK_DIV-1:0] sck_d, sck_q;
  reg mosi_d, mosi_q;
  reg [BIT_CNT_WIDTH-1:0] ctr_d, ctr_q;
  reg new_data_d, new_data_q;
  reg [DATA_WIDTH-1:0] data_out_d, data_out_q;
   
  assign mosi = mosi_q;
  assign sck = (~sck_q[CLK_DIV-1]) & (state_q == TRANSFER);
  assign busy = state_q != IDLE;
  assign data_out = data_out_q;
  assign new_data = new_data_q;

	
	
	
//FSM	
	parameter 	IDLE 					= 0, 
					START_CONV 			= 1,
					READ_FOR_DIAP		= 2,
					CALC_DIAP			= 3,	
					READ_RESULT 		= 4, 
					SHIFT_INTEGRATOR 	= 5;
	
/*	// Output depends only on the state
	always @ (state) begin
		case (state)
			IDLE:
			begin
				measure_count=4'b0;
			end
			
			START_CONV:
			begin
				start=1'b1;
			end
			
			READ_FOR_DIAP:
			begin
			//
			end
			
			CALC_DIAP:
			begin
			//
			end
			
			READ_RESULT:
			begin
			//
			end
			
			SHIFT_INTEGRATOR:
			begin
			//
			end
			
			default:
			begin
			//
			end
			
		endcase
	end*/
	
	// Determine the next state
	always @ (posedge clk ) begin
   /* sck_d = sck_q;
    data_d = data_q;
    mosi_d = mosi_q;
    ctr_d = ctr_q;
    new_data_d = 1'b0;
    data_out_d = data_out_q;
    state_d = state_q;*/
			case (state)
			
				IDLE:
				begin
					if(start_conv)
					begin
						state <= START_CONV;
					end
				end
				
				START_CONV:
				begin
					if ()
						state <= S2;
					else
						state <= S1;
				end
				
				READ_FOR_DIAP:
					if (data_in)
						state <= S3;
					else
						state <= S1;
				CALC_DIAP:
					if ()
						state <= S2;
					else
						state <= S3;		
				READ_RESULT:
					if ()
						state <= S2;
					else
						state <= S3;
				SHIFT_INTEGRATOR:
					if ()
						state <= S2;
					else
						state <= S3;						
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
    end else begin
     /* ctr_q <= ctr_d;
      data_q <= data_d;
      sck_q <= sck_d;
      mosi_q <= mosi_d;
      state_q <= state_d;
      data_out_q <= data_out_d;
      new_data_q <= new_data_d;*/
    end
  
  endmodule
  
  
  module adc_read_tb()
  
  endmodule
  