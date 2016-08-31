module sin_gen_test(
	input clk,
	input rst,
	output wire [7:0]out,
	output wire new_period,
	output wire start_conv,
	output wire halfcycle
);
reg[13:0] cnt;
reg enable;
wire sample_clk=((cnt==6'd40)?(1'b1):(1'b0));

sin_gen sin_gen_mod(
	.clk(clk),
	.sample_clk(sample_clk),
	.rst(rst),
	.enable(enable),
	.out(out),
	.new_period(new_period),
	.start_conv(start_conv),
	.halfcycle(halfcycle)
);


always @(posedge clk)
begin
  if (!rst)
  begin
		
		if(sample_clk==1'b0)
		begin
			cnt<=cnt+6'b1;
		end
		else
		begin
			cnt<=6'b0;
		end
  end
  else
  begin 
		cnt<=6'b0;
		enable<=1'b1;
  end
  
end
endmodule