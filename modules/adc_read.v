module adc_read #(parameter OUTPUT_DATA_WIDTH = 18)(
    input clk,
    input rst, 
    input sample_adc,
	 //input new_period,//???
	 input start_cycle_conv,	 
	 input read_diapason,	 
    output complete,
    output reg [OUTPUT_DATA_WIDTH-1:0] data_out_1,
    output reg [OUTPUT_DATA_WIDTH-1:0] data_out_2,	 
	 //---ADC signals---
	 output cnv,
	 input  adc_busy,
	 //---SPI signals---	 	
	 input  miso,
    output sck	
  );
  
   parameter CHANNEL_DATA_WIDTH				= 18;
   parameter ADC_DATA_WIDTH    				= CHANNEL_DATA_WIDTH*2;	
	parameter INTEGRATOR_WIDTH					= 24;
	parameter MEASURE_FOR_RESULT_PERIODS	= 32;
	parameter MEASURE_FOR_DIAP_PERIODS		=	2;
	parameter MEASURE_SAMPLES_IN_PERIOD		= 32;
	parameter MEASURE_RESULT_SAMPLES			= MEASURE_FOR_RESULT_PERIODS*MEASURE_SAMPLES_IN_PERIOD;	
	parameter MEASURE_DIAP_SAMPLES			= MEASURE_FOR_DIAP_PERIODS*MEASURE_SAMPLES_IN_PERIOD;	
	//parameter MEASURE_RESULT_COUNT_WIDTH	= 11;
	parameter RESULT_INTEGRATOR_WIDTH		= 28;
	
	//FSM	 state coding
  localparam [4:0]  	
				IDLE 										= 1, 
				START_READ								= 2,
				START_READ_ADC_SAMPLE				= 3,
				WAIT_ADC_SAMPLE						= 4,
				START_READ_SPI							= 5,
				WAIT_SPI									= 6,
				SUMM_RESULT								= 7,
				TEST_FOR_END_CYCLE					= 8,
				RESULT_OUT								= 9,
				DONE										= 10;
	
  localparam STATE_SIZE = 4;
  localparam MEASURE_COUNT_WIDTH = 11;
  

  
  reg [STATE_SIZE-1:0] state_d, state_q;
  reg cnv_d,cnv_q;
  reg [MEASURE_COUNT_WIDTH-1:0] measure_count_d, measure_count_q;
  
/*  reg [OUTPUT_DATA_WIDTH-1:0] data_out_1_d,data_out_1_q;
  reg [OUTPUT_DATA_WIDTH-1:0] data_out_2_d,data_out_2_q;*/
  
  reg [1:0] sample_adc_r;  
  wire sig_start_conv=(sample_adc_r[1]!=sample_adc_r[0])&sample_adc_r[0];
  
  reg [1:0] start_cycle_conv_r;
  wire sig_start_cycle_conv=(start_cycle_conv_r[1]!=start_cycle_conv_r[0])&start_cycle_conv_r[0];
  
  reg [1:0] adc_busy_r;
  wire sig_adc_complete=(adc_busy_r[1]!=adc_busy_r[0])&(!adc_busy_r[0]);
  
  reg [1:0] spi_done_r;
  wire sig_spi_done=(spi_done_r[1]!=spi_done_r[0])&spi_done_r[0];
  
  //reg [MEASURE_RESULT_COUNT_WIDTH-1:0]sample_counter_d, sample_counter_q;  
  reg[RESULT_INTEGRATOR_WIDTH-1:0] result_integrator_1_d, result_integrator_1_q, result_integrator_2_d, result_integrator_2_q;//_d,result_integrator_q;
   
  assign complete = (state_q == DONE);
	
  /*assign data_out_1 = data_out_1_q;
  assign data_out_2 = data_out_2_q;*/
  
  assign cnv=cnv_q;
  	
//------------------SPI---------------------------

  //----ADC regs----
  wire 	mosi;
  //----SPI regs----
  wire 	spi_busy;
  wire  	spi_done;
  //wire	spi_start;
  reg 	spi_start_d,spi_start_q;
  wire   spi_start=spi_start_q;
  //----------------
  
	 parameter SPI_ADC_CLK_DIV = 2;
	 parameter SPI_ADC_DATA_WIDTH = ADC_DATA_WIDTH;
	 //parameter SPI_ADC_BIT_CNT_WIDTH = 4;
	 	 
    //reg start;
    reg[ADC_DATA_WIDTH-1:0] spi_data_in;
    wire[ADC_DATA_WIDTH-1:0] spi_data_out;
    	 
	 spi_master #(.CLK_DIV(SPI_ADC_CLK_DIV),.DATA_WIDTH(SPI_ADC_DATA_WIDTH)) adc_spi_master(.clk(clk),.rst(rst),.miso(miso),.mosi(mosi),.sck(sck),.start(spi_start),.data_in(spi_data_in),.data_out(spi_data_out),.busy(spi_busy),.new_data(spi_done));
//------------------------------------------------				
							
 always @(posedge clk) begin //async signals
		if (rst) 
		begin
			sample_adc_r<=2'b00;
			start_cycle_conv_r<=2'b00;
			spi_done_r<=2'b00;
			adc_busy_r<=2'b00;
		end
		else
		begin
			sample_adc_r<={sample_adc_r[0],sample_adc};
			start_cycle_conv_r<={start_cycle_conv_r[0],start_cycle_conv};
			spi_done_r<={spi_done_r[0],spi_done};
			adc_busy_r<={adc_busy_r[0],adc_busy};
		end
	 end

	always @ (*) begin	//FSM
	 
	 state_d=state_q;
	 spi_start_d=spi_start_q;
	 measure_count_d=measure_count_q;
	 cnv_d=cnv_q;
	 result_integrator_1_d=result_integrator_1_q;
	 result_integrator_2_d=result_integrator_2_q;
    /*data_out_1_d<=data_out_1_q;
	 data_out_2_d<=data_out_2_q;*/	 
		case (state_q)
		
			IDLE:
			begin
				if(sig_start_cycle_conv)
				begin
					state_d <= START_READ;
				end
			end
						
			START_READ:
			begin
				spi_start_d=1'b0;
				result_integrator_1_d<={RESULT_INTEGRATOR_WIDTH{1'b0}};
				result_integrator_2_d<={RESULT_INTEGRATOR_WIDTH{1'b0}};
				measure_count_d<={MEASURE_COUNT_WIDTH{1'b0}};
				state_d <= START_READ_ADC_SAMPLE;
			end
			
			START_READ_ADC_SAMPLE:
			begin
				if(sig_start_conv)
				begin
					cnv_d<=1'b1;
					state_d <= WAIT_ADC_SAMPLE;
				end
			end
			
			WAIT_ADC_SAMPLE:
			begin
				cnv_d=1'b0;
				if(sig_adc_complete)
				begin
					state_d <= START_READ_SPI;
				end
			end
			
			START_READ_SPI:
			begin
				spi_start_d=1'b1;
				state_d <= WAIT_SPI;
			end
			
			WAIT_SPI:
			begin	
				spi_start_d=1'b0;
				if (sig_spi_done)
				begin
					state_d <= SUMM_RESULT;
				end	
			end
			
			SUMM_RESULT:
			begin
				measure_count_d<=measure_count_q+1;
				result_integrator_1_d<=result_integrator_1_q+spi_data_out[CHANNEL_DATA_WIDTH-1:0];
				result_integrator_2_d<=result_integrator_2_q+spi_data_out[ADC_DATA_WIDTH-1:CHANNEL_DATA_WIDTH];
				state_d <= TEST_FOR_END_CYCLE;
			end
			
			TEST_FOR_END_CYCLE:
			begin
				if (((read_diapason==1) && (measure_count_q==MEASURE_DIAP_SAMPLES))||((read_diapason==0) && (measure_count_q==MEASURE_RESULT_SAMPLES)))
				begin
					state_d <= RESULT_OUT;
				end
				else
				begin
					state_d <= START_READ_ADC_SAMPLE;
				end
			end
			
			RESULT_OUT:
			begin
				if(read_diapason)
				begin
					data_out_1[CHANNEL_DATA_WIDTH-1:0]<=result_integrator_1_q[RESULT_INTEGRATOR_WIDTH-5:6];
					data_out_2[CHANNEL_DATA_WIDTH-1:0]<=result_integrator_2_q[RESULT_INTEGRATOR_WIDTH-5:6];
				end
				else
				begin
					data_out_1[CHANNEL_DATA_WIDTH-1:0]<=result_integrator_1_q[RESULT_INTEGRATOR_WIDTH-1:10];
					data_out_2[CHANNEL_DATA_WIDTH-1:0]<=result_integrator_2_q[RESULT_INTEGRATOR_WIDTH-1:10];
				end
				state_d <= DONE;
			end	
		
			DONE:
			begin
				state_d <= IDLE;
			end		
		endcase
	end
	
   always @(posedge clk) begin
    if (rst) 
	 begin
		 state_q<=IDLE;
		 measure_count_q<={MEASURE_COUNT_WIDTH{1'b0}};
		 result_integrator_1_q<={RESULT_INTEGRATOR_WIDTH{1'b0}};
		 result_integrator_2_q<={RESULT_INTEGRATOR_WIDTH{1'b0}}; 
		 cnv_q<=1'b0;	
		 spi_start_q<=1'b0;
		 data_out_1<={OUTPUT_DATA_WIDTH{1'b0}};
		 data_out_2<={OUTPUT_DATA_WIDTH{1'b0}};		 
    end 
	 else 
	 begin
		 state_q<=state_d;
		 measure_count_q<=measure_count_d;		
		 cnv_q<=cnv_d; 
		 spi_start_q<=spi_start_d;
		 result_integrator_1_q<=result_integrator_1_d;
		 result_integrator_2_q<=result_integrator_2_d;
		 /*data_out_1_q<=data_out_1_d;
		 data_out_2_q<=data_out_2_d;*/
    end
	end
  endmodule
  
  
 `timescale 1 ns/ 1 ns 
 module adc_read_tb();
	
    parameter OUTPUT_DATA_WIDTH =24;
	 
	 reg clk;
    reg rst;	 
    reg sample_adc;
	 reg start_cycle_conv;	 
	 reg read_diapason; 
    wire complete;
    wire [OUTPUT_DATA_WIDTH-1:0] data_out_1;
    wire [OUTPUT_DATA_WIDTH-1:0] data_out_2;
	 //---ADC signals---
	 wire cnv;
	 reg  adc_busy;
	 //---SPI signals---	 	
	 reg  miso;
    wire sck;
	 
	 //-------adc emul---
	 
	 reg [35:0] adc_shift_reg;
	 //------------------
	 
	 adc_read  #(OUTPUT_DATA_WIDTH)test_adc_read(.clk(clk),.rst(rst),.sample_adc(sample_adc),.start_cycle_conv(start_cycle_conv),.read_diapason(read_diapason),.complete(complete),.data_out_1(data_out_1),.data_out_2(data_out_2),.cnv(cnv),.adc_busy(adc_busy),.miso(miso),.sck(sck));
  
		initial
		begin
			clk<=0;
			sample_adc<=0;
			start_cycle_conv<=0;
			read_diapason<=0;
			adc_busy<=0;
			rst<=0;
			#500
			rst=1;	
			#500
			rst=0;
			#500
			start_cycle_conv<=1;
			
		end
		
		always 
			#10  clk =  ! clk;  
			
		always 
			#6250  sample_adc =  ! sample_adc;  
			
		/*always
			#74600000 start_cycle_conv =! start_cycle_conv;*/
			
		
		 always @(posedge clk) begin
		 
		 end
		 
		 always @(posedge cnv) begin
			adc_busy<=1;
			adc_shift_reg=36'b1;
			#100
			adc_busy<=0;
		 end
		
		 always @(posedge sck) begin
			miso<=adc_shift_reg[35];
			adc_shift_reg[35:0]<={adc_shift_reg[34:0],1'b0};
		 end
			
  
  endmodule
  