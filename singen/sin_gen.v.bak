module sin_gen(
	input clk,
	input sample_clk,
	input rst,
	input enable,
	output wire [7:0]out,
	output wire new_period,
	output wire start_conv,
	output wire halfcycle
);

reg [7:0]cnt;
reg sample_p;
sine_rom sine(.clock(sample_clk), .address(cnt), .q(out));

assign new_period=(cnt==0)?(1):(0);
assign start_conv=(out[2:0])?(0):(1);
assign halfcycle= (out[6:0])?(0):(1);



always @(posedge clk)
begin
  if (!rst)
  begin
		if(sample_p!=sample_clk)
		begin
			if((sample_clk==1'b1) && (enable==1'b1))
			begin
				cnt=cnt+1'b1;
			end
			sample_p=sample_clk;
		end
	end
  else
	begin 
		sample_p=1'b0;
		cnt<=8'b0;
	end
  
end
endmodule

//--------------------------------------
`timescale 1 ps/ 1 ps
module sin_gen_tb();

	reg clk;
	reg sample_clk;
	reg rst;
	reg enable;
	wire [7:0]out;
	wire new_period;
	wire start_conv;

	sin_gen test_sin_gen(.clk(clk),.sample_clk(sample_clk),.rst(rst),.enable(enable),.out(out),.new_period(new_period),.start_conv(start_conv));
	
	initial
	begin
		clk<=0;
		sample_clk<=0;
		enable<=1'b1;
		rst=0;
		#500
		rst=1;	
	end
	
   always 
		#5  clk =  ! clk;  
		
	always 
		#500  sample_clk =  ! sample_clk;  
		
	always
		#10000 enable =! enable;
	

endmodule
