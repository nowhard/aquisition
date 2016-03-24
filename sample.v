module sample(
	input clk,
	input rst,
	input sample_adc,
	output wire  sig_conv
	);
  
  reg [1:0] sample_adc_r;
  
  assign sig_conv=(sample_adc_r[1]!=sample_adc_r[0])&sample_adc_r[0];
  
  always @(posedge clk)
    begin
      if(rst)
        begin
          sample_adc_r<=2'b00;
        end
      else
        begin
          sample_adc_r<={sample_adc_r[0],sample_adc};
        end
    end
  
  /* always @(posedge clk)
    begin
      
    end*/
  
endmodule   

module sample_tb(

	);
  reg clk;
  reg rst;
  reg sample_adc;
  wire sig_conv;
  
  sample sample1(.clk(clk),.rst(rst),.sample_adc(sample_adc),.sig_conv(sig_conv));
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
      clk=0;
      rst=0;
      #100
      rst=1;
      #100
      rst=0;
      sample_adc=0;
    end
  	
  always 
		#50  clk =  ! clk;  
		
  always 
		#500  sample_adc =  ! sample_adc;  
  
endmodule