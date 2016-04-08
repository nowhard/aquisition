module logic(
	input clk,
	input rst,
	
	
	//---ADC signals---
	output adc_cnv,
	input  adc_busy,
	//---SPI signals---	 	
	input  adc_miso,
	output adc_sck	
	//---------------------
	
	output [2:0]analog_mux_chn

);
	 localparam STATE_SIZE = 4;
	 reg [STATE_SIZE-1:0] state_d, state_q;
	 reg analog_mux_chn_d,analog_mux_chn_q;

	 
	 //reg read_diapason_d, read_diapason_q;
	 reg read_diapason;
	
	//FSM	 state coding
  localparam [4:0]  	
				IDLE 										= 1, 
				START_CYCLE								= 2,
				MEASURE_MODE_DIAPASON				= 3,
				MEASURE_MODE_1							= 4,
				MEASURE_MODE_2							= 5,
				MEASURE_MODE_3							= 6,
				MEASURE_MODE_4							= 7,
				MEASURE_MODE_5							= 8,
				DONE										= 9;
				
				
always @ (*) begin	//FSM
	 
	 state_d=state_q;
	 analog_mux_chn_d=analog_mux_chn_q;
	// read_diapason_d=read_diapason_q;
 	 
		case (state_q)
		
			IDLE:
			begin

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
