module sin_gen(
	input clk,
	input sample_clk,
	input rst,
	input enable,
	output [7:0]out,
	output ready,
	output new_period,
	output start_conv,
	output halfcycle
);

reg [7:0]cnt;
sin_rom sine(.clock(sample_clk), .address(cnt), .q(out));

assign new_period=(cnt==0)?(1):(0);
assign start_conv=(cnt[2:0])?(0):(1);
assign halfcycle= (cnt[6:0])?(0):(1);

reg [2:0]sample;
wire sample_signal=(sample[1]&(!sample[2]));

reg data_ready;
assign ready=data_ready;

always @(posedge clk)
begin
	if(!rst)
	begin
		sample<={sample[1:0],sample_clk};
	end
	else
	begin
		sample<=3'b0;		
	end
end

always @(posedge clk)
begin
  if (!rst)
  begin
		if(sample_signal && enable)
		begin
			cnt<=cnt+8'b1;
			data_ready<=1'b1;
		end
		else
		begin
			data_ready<=1'b0;
		end
	end
  else
	begin 
		cnt<=8'b0;
		data_ready<=1'b0;
	end
  
end
endmodule

/*//--------------------------------------
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
	

endmodule*/
