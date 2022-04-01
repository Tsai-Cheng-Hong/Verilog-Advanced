//------------------------------------------------------//
//- Digital IC Design 2021                              //
//-                                                     //
//- Lab04b: Verilog Behavioral Level                    //
//------------------------------------------------------//
`timescale 1ns/10ps

`include "SKETCH_ANS.vp"
`include "SKETCH.v"

module TEST;

parameter CYCLE 		= 5;
parameter TEST_IMAGE_NUMBER 	= 3;
parameter DATA_WIDTH 		= 6;
parameter FILE_ROW_NUMBER 	= 72;

reg                   CLK;
reg                   RESET;
reg                   IN_VALID;
reg                   IN_VALID_PRE;
reg  [DATA_WIDTH-1:0] IN_DATA;
wire [DATA_WIDTH-1:0] OUT_DATA;
reg  [DATA_WIDTH-1:0] OUT_DATA_REG;
wire [DATA_WIDTH-1:0] CORRECT_OUT;
wire                  OUT_VALID;
reg                   GOT_OUTPUT;
reg                   NO_OUT_VALID;
reg                   CORRECT;
reg  [DATA_WIDTH-1:0] FILE_DATA[0:FILE_ROW_NUMBER-1];
reg 		[6:0] OUT_NUMBER[0:TEST_IMAGE_NUMBER-1];

integer   seed;
integer   input_ctr;
reg [3:0] image_ctr;
integer   output_ctr;
integer   waiting_cycle;
integer   simulation_cycle;
integer   err_num;

integer   debug_out_num;

// Design Under Test
SKETCH SKETCH
(
   // Output Port
   .OUT_VALID(OUT_VALID),
   .OUT_DATA (OUT_DATA ),
   
   // Input Port
   .CLK     (CLK     ),
   .RESET   (RESET   ),
   .IN_VALID(IN_VALID),
   .IN_DATA (IN_DATA )
);

REF_DESIGN I_REF
(
   // Output Port
   .OUT_DATA  (CORRECT_OUT),
   
   // Input Port
   .CLK       (CLK        ),
   .RESET     (RESET      ),
   .IN_VALID  (IN_VALID   ),
   .IN_DATA   (IN_DATA    ),
   .OUT_VALID (OUT_VALID  ),
   .GOT_OUTPUT(GOT_OUTPUT ),
   .image_ctr (image_ctr  )
);

initial CLK = 0;
always #(CYCLE/2.0) CLK = ~CLK;

initial begin
	$readmemb("INPUT.txt", FILE_DATA);
	$readmemb("OUT_NUM.txt", OUT_NUMBER);
   	$fsdbDumpfile("SKETCH.fsdb");
   	$fsdbDumpvars;
   	$fsdbDumpMDA;
end

initial
begin   

   	RESET = 0;
   	IN_VALID_PRE = 0;
   	IN_VALID = 0;
   	IN_DATA = 0;
   	NO_OUT_VALID = 0;   
   	input_ctr = 0;
   	image_ctr = 0;
   	waiting_cycle = 0;
   	err_num = 0;
   	simulation_cycle = 0;
   	CORRECT = 1;
	debug_out_num = 0;
   	@(posedge CLK)
    	#(0.2*CYCLE) RESET = 1;
       
   	#(CYCLE) ;
   
   	@(posedge CLK)
   		#(0.2*CYCLE) RESET = 0;
   
   	for (image_ctr = 0; image_ctr < TEST_IMAGE_NUMBER; image_ctr = image_ctr + 1) begin
    	for (input_ctr = 0; input_ctr < 24; input_ctr = input_ctr + IN_VALID_PRE)
         	@(posedge CLK)
            	#(0.2*CYCLE) IN_VALID_PRE = 1;
      
      		@(posedge CLK)
         		#(0.2*CYCLE) IN_VALID_PRE = 1'd0;   
      
      		@(posedge GOT_OUTPUT)
         		#(3.2*CYCLE) waiting_cycle = 0;
   	end
   
   	if (NO_OUT_VALID) begin
    	$display ();
      	$display ("OUTPUT_VALID does not assert! ");
      	$display ();
      	$display ("/////////////");
      	$display ("// Fail !! //");
      	$display ("/////////////");
      	$display (); 
   	end
   	else if(err_num !=0) begin
      	$display ();
      	$display ("TOTAL ERRORS = %d", err_num);
      	$display ();
      	$display ("/////////////");
      	$display ("// Fail !! //");
      	$display ("/////////////");
      	$display ();
   	end
   	else begin
      	$display ();
      	$display ("///////////////////");
      	$display ("// Successful !! //");
      	$display ("///////////////////");
      	$display ();
   	end

   	$finish;
end

always@(posedge CLK)
   	simulation_cycle <= simulation_cycle + 1;

always@(posedge CLK or posedge RESET)
	if (RESET)
		OUT_DATA_REG <= 0;
   	else if (OUT_VALID)
     	OUT_DATA_REG <= OUT_DATA;

always@(posedge CLK)
   	if (CORRECT_OUT !== OUT_DATA_REG) begin
    	err_num = err_num + 1;
      	$display ();
      	$display ("ERROR at cycle = %d", simulation_cycle);
      	$display ("  => CORRECT OUT_DATA = %d", CORRECT_OUT);
      	$display ("  => YOUR OUT_DATA    = %d", OUT_DATA_REG);
      	$display ();
      	CORRECT = 0;
   	end
   	else
      	CORRECT = 1;

always@(posedge CLK or posedge RESET)
   	if (RESET)
    	IN_VALID <= 1'd0;
   	else
    	IN_VALID <= #(0.2*CYCLE) IN_VALID_PRE;

always@(posedge CLK or posedge RESET)
   	if (RESET)
    	IN_DATA <= 0;
   	else if (IN_VALID_PRE)
    	IN_DATA <= #(0.2*CYCLE) FILE_DATA[(image_ctr*24)+input_ctr-1]; 	

always@(posedge CLK or posedge RESET)
   	if (RESET) begin
		GOT_OUTPUT <= 0;		
	end
   	else if (input_ctr==24)
   	begin
      	waiting_cycle = waiting_cycle + 1;	  	
      	debug_out_num = OUT_NUMBER[image_ctr];
		if (output_ctr== OUT_NUMBER[image_ctr]) begin
        	GOT_OUTPUT <= 1;
      	//else if (output_ctr != OUT_NUMBER[image_ctr]) err_out_num = 1'b1;
		end
	  	else if (waiting_cycle > 400) begin
        	GOT_OUTPUT <= 1;
        	NO_OUT_VALID <= 1;
      	end
      	else
        	GOT_OUTPUT <= 0;
   	end

always@(posedge CLK or posedge RESET)
	if (RESET)
		output_ctr <= 0;
   	else if (OUT_VALID)
      	output_ctr <= output_ctr + 1;
   	else if (GOT_OUTPUT)
      	output_ctr <= 0;

endmodule


module REF_DESIGN
(
	// Output Port
   	OUT_DATA,
   
   	// Input Port
   	CLK,
   	RESET,
   	IN_VALID,
   	IN_DATA,
   	OUT_VALID,
   	GOT_OUTPUT,   
   	image_ctr 
);

parameter DATA_WIDTH 		= 6;
parameter TEST_IMAGE_NUMBER 	= 3;


input                   CLK;
input                   RESET;
input                   IN_VALID;
input  [DATA_WIDTH-1:0] IN_DATA;
input                   OUT_VALID;
input                   GOT_OUTPUT;
input	[3:0]		image_ctr;
output [DATA_WIDTH-1:0] OUT_DATA;

wire 	[3:0]		image_ctr;	
wire                    CLK;
wire                    RESET;
wire                    IN_VALID;
wire   [DATA_WIDTH-1:0] IN_DATA;
wire                    OUT_VALID;

reg    [DATA_WIDTH-1:0] OUT_DATA;
reg    [DATA_WIDTH-1:0] MEM[0:24];
reg    [           4:0] IN_COUNTER;
reg    [           5:0] OUT_COUNTER;
reg    [DATA_WIDTH+1:0] CORRECT_OUT[0:65];
reg    [DATA_WIDTH:0]   OUT_NUMBER[0:TEST_IMAGE_NUMBER-1];
reg    [DATA_WIDTH+1:0]	EXPECT_DATA[0:65];
reg    [DATA_WIDTH+1:0] out_accumulate[0:TEST_IMAGE_NUMBER-1];


integer i;

initial begin
	$readmemb("EXPECT.txt", EXPECT_DATA);
	$readmemb("OUT_NUM.txt", OUT_NUMBER);	
	
end


initial begin
	
	for (i = 0; i < TEST_IMAGE_NUMBER; i = i+1)
		out_accumulate[i] = 0;
	
	for (i = 0 ; i < TEST_IMAGE_NUMBER ; i = i+1) begin
		if (i == 0) out_accumulate[i] = 0;
		else out_accumulate[i] = OUT_NUMBER[i-1] + out_accumulate[i-1];
	end
	
	for (i = 0 ; i < TEST_IMAGE_NUMBER ; i = i+1) 
		out_accumulate[i] = out_accumulate[i] ;	
end

always@(posedge CLK or posedge RESET)
	if (RESET) begin
		IN_COUNTER <= 0;
		end
   	else if (IN_VALID)
		IN_COUNTER <= IN_COUNTER + 1;
	else if (IN_COUNTER== OUT_NUMBER[image_ctr])
		IN_COUNTER <= 0;
      
always@(posedge CLK or posedge RESET)
	if (RESET)
		for (i=0; i<image_ctr; i=i+1)
			MEM[i] = 0;
   	else if (IN_VALID)
		MEM[IN_COUNTER] <= IN_DATA;

always@(IN_COUNTER)
	if (IN_COUNTER == OUT_NUMBER[image_ctr])
   	begin      
		for (i= 0; i < OUT_NUMBER[image_ctr]; i = i+1) begin
				  
			if(image_ctr == 0)		 
		 		CORRECT_OUT[i] = EXPECT_DATA[i];			
			else				
				CORRECT_OUT[i] = EXPECT_DATA[out_accumulate[image_ctr]+i];				
						
      	end      
   	end

always@(posedge CLK or posedge RESET)
	if (RESET)
		OUT_COUNTER <= 0;
	else if (OUT_VALID)
		OUT_COUNTER <= OUT_COUNTER + 1;
	else if (GOT_OUTPUT)
		OUT_COUNTER <= 0;

always@(posedge CLK or posedge RESET) begin
	if (RESET)
		OUT_DATA <= 0;
	else if (OUT_VALID)
		OUT_DATA <= CORRECT_OUT[OUT_COUNTER] ;

end

endmodule
