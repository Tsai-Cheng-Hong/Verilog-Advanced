//------------------------------------------------------//
//- Digital IC Design 2021                              //
//-                                                     //
//- Lab06: Logic Synthesis                              //
//------------------------------------------------------//
`timescale 1ns/10ps

module  Incenter(
			CLK,
			RESET,
			IN_DATA,
			IN_VALID,
			OUT_DATA,
			OUT_VALID
			);

	input CLK, RESET;
	input [16:0] IN_DATA;
	input IN_VALID;
	output reg [15:0] OUT_DATA;
	output reg OUT_VALID;

//Write Your Design Here
reg [16:0] x1,y1,x2,y2,x3,y3,a,b,c;
reg [3:0] count;


reg [18:0] ab,abc;
reg [31:0] ax1;
reg [32:0] ax1bx2,ax1bx2cx3;
reg [32:0] ay1,ay1by2,ay1by2cy3;
reg flag;
reg [15:0] x_total,y_total;

always@(posedge CLK or posedge RESET)	
begin
	if (RESET)
	count <= 4'd1;
	else if (count == 4'd9)
	count <= 4'd1;
	else
	count <= count + 1'b1;
end

always@(posedge CLK or posedge RESET)	//take out IN_DATA
begin
	if (RESET)
		begin
		x1 <= 17'd0;
		y1 <= 17'd0;
		x2 <= 17'd0;
		y2 <= 17'd0;
		x3 <= 17'd0;
		y3 <= 17'd0;
		 a <= 17'd0;
		 b <= 17'd0;
		 c <= 17'd0;	
		ax1 		 <= 32'd0;
		ax1bx2 	  	 <= 33'd0;
		ax1bx2cx3 	 <= 33'd0;
		ab 		 <= 19'd0;
		abc		 <= 19'd0;	
		ay1 <= 33'd0;
		ay1by2 <= 33'd0;
		ay1by2cy3 <= 33'd0;
		x_total <= 16'd0; 
		y_total <= 16'd0;
		end
	else if (count == 4'd1 )
		begin
		x1 <= IN_DATA;
		ay1 <= a * y1;
		end
	else if (count == 4'd2 )
		begin
		y1 <= IN_DATA;
		ay1by2 <= (b * y2) + ay1;
		end
	else if (count == 4'd3 )
		begin
		x2 <= IN_DATA;
		ay1by2cy3 <= (c * y3) + ay1by2;
		end
	else if (count == 4'd4 )
		begin
		y2 <= IN_DATA;
		x_total <= ax1bx2cx3 / abc;
		end
	else if (count == 4'd5 )
		begin
		x3 <= IN_DATA;
		y_total <= ay1by2cy3 / abc;
		end
	else if (count == 4'd6 )
		y3 <= IN_DATA;
	else if (count == 4'd7 )
		begin
		a <= IN_DATA;
		ax1 <= IN_DATA*x1;
		end
	else if (count == 4'd8 )
		begin

		b <= IN_DATA;
		ax1bx2 <= (IN_DATA * x2) + ax1;
		ab <= a + IN_DATA;
		end

	else if (count == 4'd9 )
		begin
		c <= IN_DATA;
		ax1bx2cx3 <= (IN_DATA * x3) + ax1bx2;
		abc <= IN_DATA + ab;
		end 

	else 
		begin
		x1 <= x1;
		y1 <= y1;
		x2 <= x2;
		y2 <= y2;
		x3 <= x3;
		y3 <= y3;
		 a <= a;
		 b <= b;
		 c <= c;	
		ax1 		 <= ax1;
		ax1bx2 	  	 <= ax1bx2;
		ax1bx2cx3 	 <= ax1bx2cx3;
		ab 		 <= ab;
		abc		 <= abc;
		ay1 <= ay1;
		ay1by2 <= ay1by2;
		ay1by2cy3 <= ay1by2cy3;
		x_total <= x_total;
		y_total <= y_total;
		end
end

always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	flag <= 1'b1;
	else if (count >= 4'd9)
	flag <= 1'b0;
	else 
	flag <= flag;
end



always@(posedge CLK or posedge RESET)
begin
	if (RESET)
	begin
	OUT_VALID <= 1'b0;
	OUT_DATA <= 16'd0;
	end	
	else if (flag == 1'b0 & count == 4'd6)
	begin
	OUT_VALID <= 1'b1;
	OUT_DATA <= x_total;
	end
	else if (flag == 1'b0 & count == 4'd7)
	begin
	OUT_VALID <= 1'b1;
	OUT_DATA <= y_total;
	end
	else
	begin
	OUT_VALID <= 1'b0;
	OUT_DATA <= 16'd0;
	end
end

endmodule