module sin_gen(
	input clk,
	input sample_clk,
	input rst,
	input enable,
	output reg [7:0]out,
	output reg new_period,
	output reg start_conv,
	output reg halfcycle
);

reg [7:0]cnt;

reg sample_p;

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
	
		
    case (cnt)

		8'd0:
		 begin
		 out<=8'd128;
		 start_conv<=1'b1;
		 new_period<=1'b1;
		 halfcycle<=1'b1;
		 end
		8'd1:
		 begin
		 out<=8'd131;
		 start_conv<=1'b0;
		 new_period<=1'b0;
		 end
		8'd2: out<=8'd134;
		8'd3: out<=8'd137;
		8'd4: out<=8'd140;
		8'd5: out<=8'd144;
		8'd6: out<=8'd147;
		8'd7: out<=8'd150;
		8'd8:
		 begin
		 out<=8'd153;
		 start_conv<=1'b1;
		 end
		8'd9:
		 begin
		 out<=8'd156;
		 start_conv<=1'b0;
		 end
		8'd10: out<=8'd159;
		8'd11: out<=8'd162;
		8'd12: out<=8'd165;
		8'd13: out<=8'd168;
		8'd14: out<=8'd171;
		8'd15: out<=8'd174;
		8'd16:
		 begin
		 out<=8'd177;
		 start_conv<=1'b1;
		 end
		8'd17:
		 begin
		 out<=8'd179;
		 start_conv<=1'b0;
		 end
		8'd18: out<=8'd182;
		8'd19: out<=8'd185;
		8'd20: out<=8'd188;
		8'd21: out<=8'd191;
		8'd22: out<=8'd193;
		8'd23: out<=8'd196;
		8'd24:
		 begin
		 out<=8'd199;
		 start_conv<=1'b1;
		 end
		8'd25:
		 begin
		 out<=8'd201;
		 start_conv<=1'b0;
		 end
		8'd26: out<=8'd204;
		8'd27: out<=8'd206;
		8'd28: out<=8'd209;
		8'd29: out<=8'd211;
		8'd30: out<=8'd213;
		8'd31: out<=8'd216;
		8'd32:
		 begin
		 out<=8'd218;
		 start_conv<=1'b1;
		 end
		8'd33:
		 begin
		 out<=8'd220;
		 start_conv<=1'b0;
		 end
		8'd34: out<=8'd222;
		8'd35: out<=8'd224;
		8'd36: out<=8'd226;
		8'd37: out<=8'd228;
		8'd38: out<=8'd230;
		8'd39: out<=8'd232;
		8'd40:
		 begin
		 out<=8'd234;
		 start_conv<=1'b1;
		 end
		8'd41:
		 begin
		 out<=8'd235;
		 start_conv<=1'b0;
		 end
		8'd42: out<=8'd237;
		8'd43: out<=8'd239;
		8'd44: out<=8'd240;
		8'd45: out<=8'd241;
		8'd46: out<=8'd243;
		8'd47: out<=8'd244;
		8'd48:
		 begin
		 out<=8'd245;
		 start_conv<=1'b1;
		 end
		8'd49:
		 begin
		 out<=8'd246;
		 start_conv<=1'b0;
		 end
		8'd50: out<=8'd248;
		8'd51: out<=8'd249;
		8'd52: out<=8'd250;
		8'd53: out<=8'd250;
		8'd54: out<=8'd251;
		8'd55: out<=8'd252;
		8'd56:
		 begin
		 out<=8'd253;
		 start_conv<=1'b1;
		 end
		8'd57:
		 begin
		 out<=8'd253;
		 start_conv<=1'b0;
		 end
		8'd58: out<=8'd254;
		8'd59: out<=8'd254;
		8'd60: out<=8'd254;
		8'd61: out<=8'd255;
		8'd62: out<=8'd255;
		8'd63: out<=8'd255;
		8'd64:
		 begin
		 out<=8'd255;
		 start_conv<=1'b1;
		 end
		8'd65:
		 begin
		 out<=8'd255;
		 start_conv<=1'b0;
		 end
		8'd66: out<=8'd255;
		8'd67: out<=8'd255;
		8'd68: out<=8'd254;
		8'd69: out<=8'd254;
		8'd70: out<=8'd254;
		8'd71: out<=8'd253;
		8'd72:
		 begin
		 out<=8'd253;
		 start_conv<=1'b1;
		 end
		8'd73:
		 begin
		 out<=8'd252;
		 start_conv<=1'b0;
		 end
		8'd74: out<=8'd251;
		8'd75: out<=8'd250;
		8'd76: out<=8'd250;
		8'd77: out<=8'd249;
		8'd78: out<=8'd248;
		8'd79: out<=8'd246;
		8'd80:
		 begin
		 out<=8'd245;
		 start_conv<=1'b1;
		 end
		8'd81:
		 begin
		 out<=8'd244;
		 start_conv<=1'b0;
		 end
		8'd82: out<=8'd243;
		8'd83: out<=8'd241;
		8'd84: out<=8'd240;
		8'd85: out<=8'd239;
		8'd86: out<=8'd237;
		8'd87: out<=8'd235;
		8'd88:
		 begin
		 out<=8'd234;
		 start_conv<=1'b1;
		 end
		8'd89:
		 begin
		 out<=8'd232;
		 start_conv<=1'b0;
		 end
		8'd90: out<=8'd230;
		8'd91: out<=8'd228;
		8'd92: out<=8'd226;
		8'd93: out<=8'd224;
		8'd94: out<=8'd222;
		8'd95: out<=8'd220;
		8'd96:
		 begin
		 out<=8'd218;
		 start_conv<=1'b1;
		 end
		8'd97:
		 begin
		 out<=8'd216;
		 start_conv<=1'b0;
		 end
		8'd98: out<=8'd213;
		8'd99: out<=8'd211;
		8'd100: out<=8'd209;
		8'd101: out<=8'd206;
		8'd102: out<=8'd204;
		8'd103: out<=8'd201;
		8'd104:
		 begin
		 out<=8'd199;
		 start_conv<=1'b1;
		 end
		8'd105:
		 begin
		 out<=8'd196;
		 start_conv<=1'b0;
		 end
		8'd106: out<=8'd193;
		8'd107: out<=8'd191;
		8'd108: out<=8'd188;
		8'd109: out<=8'd185;
		8'd110: out<=8'd182;
		8'd111: out<=8'd179;
		8'd112:
		 begin
		 out<=8'd177;
		 start_conv<=1'b1;
		 end
		8'd113:
		 begin
		 out<=8'd174;
		 start_conv<=1'b0;
		 end
		8'd114: out<=8'd171;
		8'd115: out<=8'd168;
		8'd116: out<=8'd165;
		8'd117: out<=8'd162;
		8'd118: out<=8'd159;
		8'd119: out<=8'd156;
		8'd120:
		 begin
		 out<=8'd153;
		 start_conv<=1'b1;
		 end
		8'd121:
		 begin
		 out<=8'd150;
		 start_conv<=1'b0;
		 end
		8'd122: out<=8'd147;
		8'd123: out<=8'd144;
		8'd124: out<=8'd140;
		8'd125: out<=8'd137;
		8'd126: out<=8'd134;
		8'd127: out<=8'd131;
		8'd128:
		 begin
		 out<=8'd128;
		 start_conv<=1'b1;
		 halfcycle<=1'b0;
		 end
		8'd129:
		 begin
		 out<=8'd125;
		 start_conv<=1'b0;
		 end
		8'd130: out<=8'd122;
		8'd131: out<=8'd119;
		8'd132: out<=8'd116;
		8'd133: out<=8'd112;
		8'd134: out<=8'd109;
		8'd135: out<=8'd106;
		8'd136:
		 begin
		 out<=8'd103;
		 start_conv<=1'b1;
		 end
		8'd137:
		 begin
		 out<=8'd100;
		 start_conv<=1'b0;
		 end
		8'd138: out<=8'd97;
		8'd139: out<=8'd94;
		8'd140: out<=8'd91;
		8'd141: out<=8'd88;
		8'd142: out<=8'd85;
		8'd143: out<=8'd82;
		8'd144:
		 begin
		 out<=8'd79;
		 start_conv<=1'b1;
		 end
		8'd145:
		 begin
		 out<=8'd77;
		 start_conv<=1'b0;
		 end
		8'd146: out<=8'd74;
		8'd147: out<=8'd71;
		8'd148: out<=8'd68;
		8'd149: out<=8'd65;
		8'd150: out<=8'd63;
		8'd151: out<=8'd60;
		8'd152:
		 begin
		 out<=8'd57;
		 start_conv<=1'b1;
		 end
		8'd153:
		 begin
		 out<=8'd55;
		 start_conv<=1'b0;
		 end
		8'd154: out<=8'd52;
		8'd155: out<=8'd50;
		8'd156: out<=8'd47;
		8'd157: out<=8'd45;
		8'd158: out<=8'd43;
		8'd159: out<=8'd40;
		8'd160:
		 begin
		 out<=8'd38;
		 start_conv<=1'b1;
		 end
		8'd161:
		 begin
		 out<=8'd36;
		 start_conv<=1'b0;
		 end
		8'd162: out<=8'd34;
		8'd163: out<=8'd32;
		8'd164: out<=8'd30;
		8'd165: out<=8'd28;
		8'd166: out<=8'd26;
		8'd167: out<=8'd24;
		8'd168:
		 begin
		 out<=8'd22;
		 start_conv<=1'b1;
		 end
		8'd169:
		 begin
		 out<=8'd21;
		 start_conv<=1'b0;
		 end
		8'd170: out<=8'd19;
		8'd171: out<=8'd17;
		8'd172: out<=8'd16;
		8'd173: out<=8'd15;
		8'd174: out<=8'd13;
		8'd175: out<=8'd12;
		8'd176:
		 begin
		 out<=8'd11;
		 start_conv<=1'b1;
		 end
		8'd177:
		 begin
		 out<=8'd10;
		 start_conv<=1'b0;
		 end
		8'd178: out<=8'd8;
		8'd179: out<=8'd7;
		8'd180: out<=8'd6;
		8'd181: out<=8'd6;
		8'd182: out<=8'd5;
		8'd183: out<=8'd4;
		8'd184:
		 begin
		 out<=8'd3;
		 start_conv<=1'b1;
		 end
		8'd185:
		 begin
		 out<=8'd3;
		 start_conv<=1'b0;
		 end
		8'd186: out<=8'd2;
		8'd187: out<=8'd2;
		8'd188: out<=8'd2;
		8'd189: out<=8'd1;
		8'd190: out<=8'd1;
		8'd191: out<=8'd1;
		8'd192:
		 begin
		 out<=8'd1;
		 start_conv<=1'b1;
		 end
		8'd193:
		 begin
		 out<=8'd1;
		 start_conv<=1'b0;
		 end
		8'd194: out<=8'd1;
		8'd195: out<=8'd1;
		8'd196: out<=8'd2;
		8'd197: out<=8'd2;
		8'd198: out<=8'd2;
		8'd199: out<=8'd3;
		8'd200:
		 begin
		 out<=8'd3;
		 start_conv<=1'b1;
		 end
		8'd201:
		 begin
		 out<=8'd4;
		 start_conv<=1'b0;
		 end
		8'd202: out<=8'd5;
		8'd203: out<=8'd6;
		8'd204: out<=8'd6;
		8'd205: out<=8'd7;
		8'd206: out<=8'd8;
		8'd207: out<=8'd10;
		8'd208:
		 begin
		 out<=8'd11;
		 start_conv<=1'b1;
		 end
		8'd209:
		 begin
		 out<=8'd12;
		 start_conv<=1'b0;
		 end
		8'd210: out<=8'd13;
		8'd211: out<=8'd15;
		8'd212: out<=8'd16;
		8'd213: out<=8'd17;
		8'd214: out<=8'd19;
		8'd215: out<=8'd21;
		8'd216:
		 begin
		 out<=8'd22;
		 start_conv<=1'b1;
		 end
		8'd217:
		 begin
		 out<=8'd24;
		 start_conv<=1'b0;
		 end
		8'd218: out<=8'd26;
		8'd219: out<=8'd28;
		8'd220: out<=8'd30;
		8'd221: out<=8'd32;
		8'd222: out<=8'd34;
		8'd223: out<=8'd36;
		8'd224:
		 begin
		 out<=8'd38;
		 start_conv<=1'b1;
		 end
		8'd225:
		 begin
		 out<=8'd40;
		 start_conv<=1'b0;
		 end
		8'd226: out<=8'd43;
		8'd227: out<=8'd45;
		8'd228: out<=8'd47;
		8'd229: out<=8'd50;
		8'd230: out<=8'd52;
		8'd231: out<=8'd55;
		8'd232:
		 begin
		 out<=8'd57;
		 start_conv<=1'b1;
		 end
		8'd233:
		 begin
		 out<=8'd60;
		 start_conv<=1'b0;
		 end
		8'd234: out<=8'd63;
		8'd235: out<=8'd65;
		8'd236: out<=8'd68;
		8'd237: out<=8'd71;
		8'd238: out<=8'd74;
		8'd239: out<=8'd77;
		8'd240:
		 begin
		 out<=8'd79;
		 start_conv<=1'b1;
		 end
		8'd241:
		 begin
		 out<=8'd82;
		 start_conv<=1'b0;
		 end
		8'd242: out<=8'd85;
		8'd243: out<=8'd88;
		8'd244: out<=8'd91;
		8'd245: out<=8'd94;
		8'd246: out<=8'd97;
		8'd247: out<=8'd100;
		8'd248:
		 begin
		 out<=8'd103;
		 start_conv<=1'b1;
		 end
		8'd249:
		 begin
		 out<=8'd106;
		 start_conv<=1'b0;
		 end
		8'd250: out<=8'd109;
		8'd251: out<=8'd112;
		8'd252: out<=8'd116;
		8'd253: out<=8'd119;
		8'd254: out<=8'd122;
		8'd255: out<=8'd125;
    endcase
	end
  else
	begin 
		out<=8'd128;
		new_period<=1'b0;
		start_conv<=1'b0;
		halfcycle<=1'b0;
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
