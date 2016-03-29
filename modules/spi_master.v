module spi_master #(parameter CLK_DIV = 2, DATA_WIDTH = 16 ,BIT_CNT_WIDTH = 4)(
    input clk,
    input rst,
    input miso,
    output mosi,
    output sck,
    input start,
    input[DATA_WIDTH-1:0] data_in,
    output[DATA_WIDTH-1:0] data_out,
    output busy,
    output new_data
  );
   
  localparam STATE_SIZE = 2;
  
  localparam IDLE = 2'd0,
				 WAIT_HALF = 2'd1,
				 TRANSFER = 2'd2;
   
  reg [STATE_SIZE-1:0] state_d, state_q;
   
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
   
  always @(*) begin
    sck_d = sck_q;
    data_d = data_q;
    mosi_d = mosi_q;
    ctr_d = ctr_q;
    new_data_d = 1'b0;
    data_out_d = data_out_q;
    state_d = state_q;
     
    case (state_q)
	 
      IDLE: begin
        sck_d = 4'b0;              // reset clock counter
        ctr_d = {BIT_CNT_WIDTH{1'b0}};              // reset bit counter
        if (start == 1'b1) begin   // if start command
          data_d = data_in;        // copy data to send
          state_d = WAIT_HALF;     // change state
        end
      end
		
      WAIT_HALF: begin
        sck_d = sck_q + 1'b1;                  // increment clock counter
        if (sck_q == {CLK_DIV-1{1'b1}}) 
		  begin  // if clock is half full (about to fall)
          sck_d = 1'b0;                        // reset to 0
          state_d = TRANSFER;                  // change state
        end
      end
		
      TRANSFER: begin
        sck_d = sck_q + 1'b1;                           // increment clock counter
       
		  if (sck_q == 4'b0000) 
		  begin                     								// if clock counter is 0
			  mosi_d = data_q[DATA_WIDTH-1];                // output the MSB of data
		  end 
		  
		  else if (sck_q == {CLK_DIV-1{1'b1}}) 
		  begin  // else if it's half full (about to fall)
			  data_d = {data_q[DATA_WIDTH-2:0], miso};                 // read in data (shift in)!!!
		  end 
		  
		  else if (sck_q == {CLK_DIV{1'b1}}) // else if it's full (about to rise)
		  begin    
				 ctr_d = ctr_q + 1'b1;                         // increment bit counter
				 if (ctr_q == {BIT_CNT_WIDTH{1'b1}}) 
				 begin                    // if we are on the last bit
					state_d = IDLE;                             // change state
					data_out_d = data_q;                        // output data
					new_data_d = 1'b1;                          // signal data is valid
				 end			 
		  end
		end
    endcase
  end
   
  always @(posedge clk) begin
    if (rst) begin
      ctr_q <= {BIT_CNT_WIDTH{1'b0}};
      data_q <= {DATA_WIDTH{1'b0}};
      sck_q <= 4'b0;
      mosi_q <= 1'b0;
      state_q <= IDLE;
      data_out_q <= {DATA_WIDTH{1'b0}};
      new_data_q <= 1'b0;
    end else begin
      ctr_q <= ctr_d;
      data_q <= data_d;
      sck_q <= sck_d;
      mosi_q <= mosi_d;
      state_q <= state_d;
      data_out_q <= data_out_d;
      new_data_q <= new_data_d;
    end
  end
   
endmodule

//-----------------------testbench----------------------------
/*`timescale 1 ps/ 1 ps
module spi_master_tb();

	 parameter CLK_DIV = 2;
	 parameter DATA_WIDTH = 16;
	 parameter BIT_CNT_WIDTH = 4;
	 
	 reg clk;
    reg rst;
    reg miso;
    wire mosi;
    wire sck;
    reg start;
    reg[DATA_WIDTH-1:0] data_in;
    wire[DATA_WIDTH-1:0] data_out;
    wire busy;
    wire new_data;
	 
	 reg[DATA_WIDTH-1:0] slave_test_data;
	 reg[BIT_CNT_WIDTH-1:0] slave_test_count;
	 
	 
	 spi_master #(CLK_DIV,DATA_WIDTH,BIT_CNT_WIDTH) dac_spi_master(.clk(clk),.rst(rst),.miso(miso),.mosi(mosi),.sck(sck),.start(start),.data_in(data_in),.data_out(data_out),.busy(busy),.new_data(new_data));

	 initial
	 begin
		clk=0;
		start=0;
		rst=1;
		#500
		rst=0;
		#500
		
		slave_test_data=16'b1111000011110000;
		slave_test_count=4'b0;
		
		data_in=16'b0101010101010101;
		#500
		start=1;
		
	 end
	 
	   always @(negedge sck) 
		begin
			miso=slave_test_data[DATA_WIDTH-1];
			slave_test_data={slave_test_data[DATA_WIDTH-2:0], 1'b0}; 
			slave_test_count=slave_test_count+1'b1;
			
			if(slave_test_count == {BIT_CNT_WIDTH{1'b1}})
			begin
				slave_test_data=16'b1111000011110000;
			end
			
		end
	 
	 always 
		#5  clk =  ! clk;    
endmodule*/
