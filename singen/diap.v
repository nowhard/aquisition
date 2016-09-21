module diap #(parameter DATA_WIDTH = 18)(
    input clk,
    input rst,
	 input [DATA_WIDTH-1:0]current,
	 input [DATA_WIDTH-1:0]voltage,
	 input start,
	 output ready,
	 output [2:0]diap
  );
 begin
 
 localparam R_SHUNT =   10; //Ohm

 localparam STATE_SIZE = 5;
 reg 	[STATE_SIZE-1:0] state_d, state_q;
 reg  ready_d, ready_q;
 assign ready=ready_q;
 
 //FSM	 state coding	
localparam [STATE_SIZE-1:0]  	
				IDLE 										= 1, 
				START_CYCLE								= 2,
				
				DONE										= 3;
				
//Diap	
localparam [2:0]
			DIAP_1V			=3'b001,
			DIAP_5V			=3'b010,
			DIAP_20V			=3'b100;
			
localparam R_MARGIN_1	=	3;//Ohm
localparam R_MARGIN_2	=	10;//Ohm
			
	always @ (*) begin	//FSM	 
		state_d=state_q;
		ready_d=1'b0;
		
		case (state_q)
			IDLE:
			begin
				if(start)
				begin
					state_d <= START_CYCLE;
				end
			end
				
			START_CYCLE:
			begin
				state_d <= DONE;
			end
			
			DONE:
			begin
				ready_d=1'b1;
				state_d <= IDLE;
			end
			
		 endcase
	end	

   always @(posedge clk) begin
    if (rst) 
	 begin
		 state_q<=IDLE;
		 ready_q<=1'b0;
    end 
	 else 
	 begin
		 state_q<=state_d;
		 ready_q<=ready_d;
    end
	end

	
 end
 
 
 module diap_tb();

   parameter DATA_WIDTH = 18;
	reg clk;
	reg rst;
	reg start;
	
	reg [DATA_WIDTH-1:0]current;
	reg [DATA_WIDTH-1:0]voltage;
	
	wire ready;
	wire [2:0]diap;
	
	diap ( .DATA_WIDTH(DATA_WIDTH))(.clk(clk),.rst(rst),.current(current),.voltage(voltage),.start(start),.ready(ready),.diap(diap));
    initial
	 begin
		clk<=0;
		rst<=0;

		#50
		rst=1;
		#50
		rst=0;
		
		current<=100;
		voltage<=1000;
		
		start<=1'b1;
		#10
		start<=1'b0;
	 end
	 
//	 always @(posedge clk) 
//	 begin
//
//	 end
	
	
	always 
		#5  clk =  ! clk;   
 
endmodule 