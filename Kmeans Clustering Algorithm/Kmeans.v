//------------------------------------------------------//
//- Digital IC Design 2021                              //
//-                                                     //
//- Lab08: Low-Power Syntheis                           //
//------------------------------------------------------//
`timescale 1ns/10ps

//cadence translate_off
`include "/usr/chipware/CW_minmax.v"
`include "/usr/chipware/CW_mult_n_stage.v"
`include "/usr/chipware/CW_mult.v"
`include "/usr/chipware/CW_pipe_reg.v"
`include "/usr/chipware/CW_sub.v"
//cadence translate_on
      
module Kmeans
( 
    RESET,     //input
    CLK,       //input
    IN_VALID,  //input
    IN_DATA,   //input
    OUT_VALID, //output
    OUT_DATA,  //output
    busy       //output
);

  input RESET;
  input CLK;
  input IN_VALID;
  input [31:0] IN_DATA;
  output reg OUT_VALID;
  output reg busy;
  output reg [1:0] OUT_DATA;

//Write Your Design Here
reg [3:0]count;
reg [3:0]compute;
reg [7:0] c_x1,c_y1,c_x2,c_y2,c_x3,c_y3;

reg [9:0] x,y;
reg [20:0] X_r1,X_r2,X_r3;
wire [1:0] out;
wire [20:0] test;
wire [62:0] total;


reg [9:0] a,b,c,d,e,f;
always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	begin
	X_r1 <= 20'd0;
	X_r2 <= 20'd0;
	X_r3 <= 20'd0;
	end

	else if (count == 4'd8)
	begin
		if (x > c_x1)
		a <= (x - c_x1);
		else 
		a <= (c_x1 - x);

		if (x > c_x2)
		b <= (x - c_x2);
		else 
		b <= (c_x2 - x);

		if (x > c_x3)
		c <= (x - c_x3);
		else 
		c <= (c_x3 - x);

		if (y > c_y1)
		d <= (y - c_y1);
		else 
		d <= (c_y1 - y);

		if (y > c_y2)
		e <= (y - c_y2);
		else 
		e <= (c_y2 - y);
	
		if (y > c_y3)
		f <= (y - c_y3);
		else 
		f <= (c_y3 - y);
	end

	else if (busy)
	begin
	X_r1 <= ( a**2+d**2);
	X_r2 <= ( b**2+e**2 );
	X_r3 <= ( c**2+f**2 );
	end
end


assign total = {X_r3,X_r2,X_r1};
CW_minmax #(21,3) d1 (.a(total), .tc(1'b0) ,.min_max(1'b0), .value(test), .index(out) );


//high-level setting 
always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		count<=4'd0;
	else if (compute == 4'd6)
		count <= 4'd6;
	else if (count == 4'd9)
		count <= count;
	else 
 		count <= count + 1'd1;
end
always@(posedge CLK or posedge RESET)
begin
	if(RESET)
	compute <=4'd0;
	else if (compute == 4'd6)
	compute <= 4'd0;
	else if (busy)
	compute <= compute + 1'd1;
	else
	compute <= 4'd0;
end
always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	begin
	c_x1 <= 8'd0;
	c_y1 <= 8'd0;
	c_x2 <= 8'd0;
	c_y2 <= 8'd0;
	c_x3 <= 8'd0;
	c_y3 <= 8'd0;
	x 	 <= 10'd0;
	y	 <= 10'd0;
	busy <= 1'b0;
	end
	else if (count ==4'd0)
	c_x1[7:0] <= IN_DATA[31:24];
	else if (count ==4'd1)
	c_y1[7:0] <= IN_DATA[31:24];
	else if (count ==4'd2)
	c_x2[7:0] <= IN_DATA[31:24];
	else if (count ==4'd3)
	c_y2[7:0] <= IN_DATA[31:24];
	else if (count ==4'd4)
	c_x3[7:0] <= IN_DATA[31:24];
	else if (count ==4'd5)
	c_y3[7:0] <= IN_DATA[31:24];
	else if (count ==4'd6)
	x	 <= IN_DATA[31:22];
	else if (count ==4'd7)
	begin
	y 	 <= IN_DATA[31:22];
	busy <= 1'b1;
	end
	else if (compute == 4'd6)
	busy <= 1'b0;
end

always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	begin
	OUT_VALID <= 1'b0;
	OUT_DATA <= 1'b0;
	end
	else if (compute==4'd6)
	begin	
	OUT_VALID <= 1'b1;
	OUT_DATA <= out;
	end
	else
	begin
	OUT_VALID <= 1'b0;
	OUT_DATA <= OUT_DATA;
	end
end
endmodule