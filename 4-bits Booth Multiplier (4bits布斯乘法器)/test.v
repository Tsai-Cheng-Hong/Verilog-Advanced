//------------------------------------------------------//
//- Digital IC Design 2021                              //
//-                                                     //
//- Lab03b: Verilog Gate Level                          //
//------------------------------------------------------//
`timescale 1ns/10ps

`define CYCLE 30

`include "lab03b.vp"
`include "lab03b.v"
`include "lab03b_beh.v"

module test;

reg        clk, rst;
reg  [1:0] sel;
reg  [3:0] a,b;
wire [7:0] out, correct_out;



integer   simulation_cycle;
integer   err_num;


always #(`CYCLE/2.0) clk = ~clk;

always@(posedge clk or posedge rst)
begin
  if(rst) begin
  	{a,b} <= 4'b0;
  end else begin	
	a   <= {$random} % 16; 
        b   <= {$random} % 16;	
	sel <= {$random} % 4;
  end
end

lab03b_beh lab03b_beh(.a(a), .b(b), .sel(sel), .out(correct_out));
lab03b  lab03b(.a(a),.b(b),.sel(sel),.out(out) );

initial begin

	$fsdbDumpfile("lab03b.fsdb");
	$fsdbDumpvars;

	err_num = 0;
	simulation_cycle = 0;
	clk=0;rst=1;
	repeat (2) @(posedge clk);
	@(negedge clk) rst=0;
	repeat (30) @(posedge clk);

	$display ();
	$display ("------------------------------------");
	$display ("TOTAL CYCLE  = %d", simulation_cycle);
	
	if(err_num !=0) begin
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

always@(negedge clk)
   simulation_cycle <= simulation_cycle + 1;
   
always@(negedge clk)
   if ((correct_out !== out) && rst==0)
   begin
      err_num = err_num + 1;
      $display ();
      $display ("ERROR at cycle = %d", simulation_cycle);
      $display ("  => CORRECT OUT_DATA = %d", correct_out);
      $display ("  => YOUR OUT_DATA    = %d", out);
      $display ();      
   end

endmodule