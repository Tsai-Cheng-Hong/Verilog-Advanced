//------------------------------------------------------//
//- Digital IC Design 2021                              //
//-                                                     //
//- Lab03b: Verilog Gate Level                          //
//------------------------------------------------------//
`timescale 1ns/10ps

//Golden Model
module lab03b_beh(a, b, out, sel);
input  [3:0] a, b; 
input  [1:0] sel;
output [7:0] out;

reg    [7:0] out_temp, out_shift;
wire   [3:0] a_2, b_2;

assign a_2= (a[2:0]==3'd0) ? 4'd0 : 
                      a[3] ? {a[3], (~a[2:0]+1'b1)} : {a} ;
assign b_2= (b[2:0]==3'd0) ? 4'd0 :
                      b[3] ? {b[3], (~b[2:0]+1'b1)} : {b} ;
	      
assign out = out_temp;	      
//assign out = (( sel==2'b10) ||  (sel==2'b11)) ? out_temp : out_2[4] 
//			? {out_2[4],(~out_2[3:0]+1'b1)} : out_2;

always@(a_2 or b_2 or sel)
begin
  case(sel)
	2'b00:out_temp = {a,b};
  	2'b01:   
		begin
			if(a[3]==0 && b[3]==0)
			begin
				out_temp = a[2:0] * b[2:0];
				out_temp[7] = 1'b0;
			end
			else if(a[3]==1 && b[3]==1)
			begin
				out_temp = a[2:0] * b[2:0];
				out_temp[7]= 1'b0;
			end
			else begin
				//out_temp[7] = 1'b1;
				out_temp = -a[2:0] * b[2:0];
				out_temp = {1'b1, (~out_temp[6:0]+1'b1)};
			end
		end
	2'b10:begin
		out_temp = {5'b0, b[2:0]} << 1;
		out_temp[7] = b[3];
	end
	2'b11:begin
		out_temp = {5'b0, b[2:0]} >> 1;
		out_temp[7] = b[3];
	end
  endcase
end


endmodule