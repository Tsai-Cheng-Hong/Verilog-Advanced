//------------------------------------------------------//
//- Digital IC Design 2021                              //
//-                                                     //
//- Lab08: Low-Power Syntheis                           //
//------------------------------------------------------//
`timescale 1ns/10ps

`include "Kmeans.v"

module TEST;

parameter CYCLE = 5.0;

reg CLK;
reg RESET;
reg IN_VALID;
reg [31:0] IN_DATA;    // to user

wire OUT_VALID;
wire [1:0] OUT_DATA;  // user answer

reg [31:0] IN_NUM [0:205];
reg [1:0] ANS_NUM [0:99];
reg [8:0] IN_CNT;
reg [8:0] OUT_DATA_CNT;

reg [1:0]CORRECT_ANS;
reg [8:0]CORRECT_CNT;
reg [8:0]ERROR_CNT;
reg error;

wire		  busy;



always #(CYCLE/2.0) CLK = ~CLK;

Kmeans Kmeans(.RESET(RESET), .CLK(CLK), .IN_VALID(IN_VALID), .IN_DATA(IN_DATA), .OUT_VALID(OUT_VALID), .OUT_DATA(OUT_DATA), .busy(busy));

initial begin

	$fsdbDumpfile("Kmeans.fsdb");
	$fsdbDumpvars;
	$fsdbDumpMDA;

       	$readmemh("IN.dat", IN_NUM);
       	$readmemh("ANS.dat", ANS_NUM);

        $toggle_count("TEST.Kmeans");
        $toggle_count_mode(1);

	CLK=0;RESET=0;
        #(CYCLE) RESET = 1'b1;
        #(CYCLE) RESET = 1'b0;
	#(1000*CYCLE);
 	#(CYCLE) $finish;
end

always@(negedge CLK or posedge RESET)
begin
	if(RESET)
		IN_DATA <= 0;
        else if(busy)
		IN_DATA <= 0 ;
	else if(IN_VALID==0 && IN_CNT < 207)
		IN_DATA <= IN_NUM[IN_CNT][31:0];
	else if(IN_VALID==1 && IN_CNT < 207)
		IN_DATA <= IN_NUM[IN_CNT+1][31:0];

end

always@(negedge CLK or posedge RESET)
begin
	if(RESET)
		IN_VALID <= 0;
	else if(IN_CNT ==205)
		IN_VALID <= 0;
	else if(IN_CNT <206 )
		IN_VALID <= 1;
	else
		IN_VALID <= 0;
end

always@(negedge CLK or posedge RESET)
begin
	if(RESET)
		IN_CNT <= 0;
        else if(busy)
		IN_CNT <= IN_CNT;
	else if(IN_CNT == 205)
		IN_CNT <= 0;
	else if(IN_VALID)
		IN_CNT <= IN_CNT+1;
	else
		IN_CNT <= IN_CNT;
end

always@(negedge CLK or posedge RESET)
begin
	if(RESET)
		OUT_DATA_CNT<= 0;
	else if(OUT_VALID)
		OUT_DATA_CNT<=OUT_DATA_CNT+1;

end

always@(negedge CLK or posedge RESET)
begin
	if(RESET)
		CORRECT_ANS<= 0;
	else if(OUT_VALID == 1 && OUT_DATA_CNT<100)
		CORRECT_ANS<= ANS_NUM[OUT_DATA_CNT][1:0];
        else
		CORRECT_ANS<= CORRECT_ANS;
end

always@(negedge CLK or posedge RESET)
begin
	if(RESET)  begin
		error<=0;
		CORRECT_CNT<= 0;
		ERROR_CNT<=0;
	end
	else if(OUT_VALID)
		if(OUT_DATA==ANS_NUM[OUT_DATA_CNT][1:0]) begin
			error<=0;
			CORRECT_CNT<=CORRECT_CNT+1;
					end
		else begin
			ERROR_CNT<=ERROR_CNT+1;
			error<=1;
			$display ("\n\n ERROR answer at %dth pattern cluster center point",OUT_DATA_CNT);
		end
end

always @(negedge CLK)  // msg + finish
begin
       if(OUT_DATA_CNT==100)
       begin 
              if(ERROR_CNT == 0)
		begin
		 		       $display ();
			               $display ("///////////////////");
			               $display ("// Successful !! //");
			               $display ("///////////////////");
			               $display ();
		                       $toggle_count_report_flat("Kmeans_rtl.tcf", "TEST.Kmeans");
		end
	
	#(CYCLE) $finish;
	end	       	
end

endmodule