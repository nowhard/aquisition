module spi_slave#(parameter DATA_WIDTH = 16 ,BIT_CNT_WIDTH = 4)(
    input clk,
    input rst,
    input ss,
    input mosi,
    output miso,
    input sck,
    output done,
    input [DATA_WIDTH-1:0] din,
    output [DATA_WIDTH-1:0] dout
  );
  
   
  reg mosi_d, mosi_q;
  reg ss_d, ss_q;
  reg sck_d, sck_q;
  reg sck_old_d, sck_old_q;
  reg [DATA_WIDTH-1:0] data_d, data_q;
  reg done_d, done_q;
  reg [BIT_CNT_WIDTH-1:0] bit_ct_d, bit_ct_q;
  reg [DATA_WIDTH-1:0] dout_d, dout_q;
  reg miso_d, miso_q;
   
  assign miso = miso_q;
  assign done = done_q;
  assign dout = dout_q;
   
  always @(*) begin
    ss_d = ss;
    mosi_d = mosi;
    miso_d = miso_q;
    sck_d = sck;
    sck_old_d = sck_q;
    data_d = data_q;
    done_d = 1'b0;
    bit_ct_d = bit_ct_q;
    dout_d = dout_q;
     
    if (ss_q) 
	 begin                           // if slave select is high (deselcted)
      bit_ct_d = {BIT_CNT_WIDTH{1'b0}};                        // reset bit counter
      data_d = din;                           // read in data
      miso_d = data_q[DATA_WIDTH-1];                     // output MSB
    end 
	 
	 else 
	 
	 begin                            // else slave select is low (selected)
      if (!sck_old_q && sck_q) 
		begin          // rising edge
        data_d = {data_q[DATA_WIDTH-2:0], mosi_q};       // read data in and shift
        bit_ct_d = bit_ct_q + 1'b1;           				// increment the bit counter
		  
        if (bit_ct_q == {BIT_CNT_WIDTH{1'b1}} ) // if we are on the last bit
		  begin         												
          dout_d = {data_q[DATA_WIDTH-2:0], mosi_q};     // output the byte(word)
          done_d = 1'b1;                      // set transfer done flag
          data_d = din;                       // read in new byte
        end
		  
      end 
		
		else if (sck_old_q && !sck_q)// falling edge 	
		begin 
        miso_d = data_q[DATA_WIDTH-1];                   // output MSB
      end
    end
  end
   
  always @(posedge clk) begin
    if (rst) begin
      done_q <= 1'b0;
      bit_ct_q <= {BIT_CNT_WIDTH{1'b0}}; 
      dout_q <= {DATA_WIDTH{1'b0}};
      miso_q <= 1'b1;
    end else begin
      done_q <= done_d;
      bit_ct_q <= bit_ct_d;
      dout_q <= dout_d;
      miso_q <= miso_d;
    end
     
    sck_q <= sck_d;
    mosi_q <= mosi_d;
    ss_q <= ss_d;
    data_q <= data_d;
    sck_old_q <= sck_old_d;
     
  end
   
endmodule


//-----------------------testbench----------------------------
`timescale 1 ps/ 1 ps
module spi_slave_tb();


	 parameter DATA_WIDTH = 16;
	 parameter BIT_CNT_WIDTH = 4;
	 
	 
	 reg clk;
    reg rst;
    reg ss;
    reg mosi;
    wire miso;
    reg sck;
    wire done;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
	 
	 reg [BIT_CNT_WIDTH-1:0] cnt;
	 reg [DATA_WIDTH-1:0] data_test;
	 
	 spi_slave #(DATA_WIDTH,BIT_CNT_WIDTH) comm_spi_slave(.clk(clk),.rst(rst),.ss(ss),.miso(miso),.mosi(mosi),.sck(sck),.done(done),.din(din),.dout(dout));

	 initial
	 begin
		clk<=0;
		rst<=1;
		cnt<=0;
		data_test<=16'b0101010101010101;
		#500
		rst=0;
		#500
		ss=0;
						
//		data_in=0;
//		data_out=0;
//		busy=0;
//		new_data=0;
		
//		#500
		//data_in=16'b0101010101010101;
//		#500
		//start=1;
		
	 end
	 
	 always @(posedge sck) 
	 begin
	 
		mosi=data_test[DATA_WIDTH-1];
		data_test[DATA_WIDTH-1:0]={data_test[DATA_WIDTH-2:0], 1'b0}; 
		cnt=cnt+1'b1;
		
		if(cnt == {BIT_CNT_WIDTH{1'b1}})
		begin
			data_test=16'b0101010101010101;
		end
	 end
	 
	 
	 always 
		#5  clk =  ! clk;    
		
	 always 
		#50  sck =  ! sck;   
endmodule
