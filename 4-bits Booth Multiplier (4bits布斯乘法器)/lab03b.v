//------------------------------------------------------//
//- Digital IC Design 2021                              //
//-                                                     //
//- Lab03b: Verilog Gate Level                          //
//------------------------------------------------------//
`timescale 1ns/10ps

//Main
module lab03b(a, b, out, sel);
input  [3:0] a, b;
input  [1:0] sel;
output [7:0] out;
wire   [7:0]first,second,third,forth;

Concat 		 d1 (.a(a), .b(b), .out(first) );
Booth_multiplier d2 (.a(a), .b(b), .out(second));
Left   		 d3 (.b(b),        .out(third) );
Right  	 	 d4 (.b(b),        .out(forth) );

MX4XL MUX1 (out[0],first[0],third[0],second[0],forth[0],sel[1],sel[0]);
MX4XL MUX2 (out[1],first[1],third[1],second[1],forth[1],sel[1],sel[0]);
MX4XL MUX3 (out[2],first[2],third[2],second[2],forth[2],sel[1],sel[0]);
MX4XL MUX4 (out[3],first[3],third[3],second[3],forth[3],sel[1],sel[0]);
MX4XL MUX5 (out[4],first[4],third[4],second[4],forth[4],sel[1],sel[0]);
MX4XL MUX6 (out[5],first[5],third[5],second[5],forth[5],sel[1],sel[0]);
MX4XL MUX7 (out[6],first[6],third[6],second[6],forth[6],sel[1],sel[0]);
MX4XL MUX8 (out[7],first[7],third[7],second[7],forth[7],sel[1],sel[0]);
endmodule
//Concat
module Concat (a,b,out);
input [3:0] a;
input [3:0] b;
output [7:0]out;
BUFX1 con1 (out[0],b[0]);
BUFX1 con2 (out[1],b[1]);
BUFX1 con3 (out[2],b[2]);
BUFX1 con4 (out[3],b[3]);
BUFX1 con5 (out[4],a[0]);
BUFX1 con6 (out[5],a[1]);
BUFX1 con7 (out[6],a[2]);
BUFX1 con8 (out[7],a[3]);
endmodule
//Left shift
module Left (b,out);
input [3:0] b;
output [7:0] out;
BUFX1 L0 (out[7],b[3]);
BUFX1 L1 (out[6],1'b0);
BUFX1 L2 (out[5],1'b0);
BUFX1 L3 (out[4],1'b0);
BUFX1 L4 (out[3],b[2]);
BUFX1 L5 (out[2],b[1]);
BUFX1 L6 (out[1],b[0]);
BUFX1 L7 (out[0],1'b0);
endmodule
//Right shift
module Right (b,out);
input [3:0] b;
output [7:0] out;
BUFX1 R0 (out[7],b[3]);
BUFX1 R1 (out[6],1'b0);
BUFX1 R2 (out[5],1'b0);
BUFX1 R3 (out[4],1'b0);
BUFX1 R4 (out[3],1'b0);
BUFX1 R5 (out[2],1'b0);
BUFX1 R6 (out[1],b[2]);
BUFX1 R7 (out[0],b[1]);
endmodule

module Booth_multiplier(a,b,out);
input [3:0] a,b;
output [7:0]out;

wire [3:0] Ra,Rb;
wire [3:0] a_bar,b_bar;
wire [7:0] new_x1,new_y1;
wire [7:0] ans,ans_bar;
wire [3:0] S; 
wire [3:0] onlyx,onlyy;
wire [3:0] new_a,new_b;



//use the real number
Encoder encode1 (.a(a),.out(Ra));
Encoder encode2 (.a(b),.out(Rb));
// when a[3] == 1 then use behind
MX2XL MXLa1 (new_a[0],a[0],Ra[0],a[3]); // if (a[3] == 1)  new_a = Ra 
MX2XL MXLa2 (new_a[1],a[1],Ra[1],a[3]); // else new_a = a
MX2XL MXLa3 (new_a[2],a[2],Ra[2],a[3]);
MX2XL MXLa4 (new_a[3],a[3],Ra[3],a[3]);
MX2XL MXLb1 (new_b[0],b[0],Rb[0],b[3]);
MX2XL MXLb2 (new_b[1],b[1],Rb[1],b[3]);
MX2XL MXLb3 (new_b[2],b[2],Rb[2],b[3]);
MX2XL MXLb4 (new_b[3],b[3],Rb[3],b[3]);
//new_a & new_b is real a,b

//here for first x
XOR2X1 XOR1(S[1],new_b[1],new_b[0]);
XOR2X1 XOR2(S[0],new_b[0],1'b0);
Complement N1 (.a(new_a),.out(a_bar));
Complement N2 (.a(new_b),.out(b_bar));
//(real a & real b)'s bar is a_bar & b_bar

//select the first x is + or -
MX2XL MUX_onlyx1 (onlyx[0],new_a[0],a_bar[0],new_b[1]);
MX2XL MUX_onlyx2 (onlyx[1],new_a[1],a_bar[1],new_b[1]);
MX2XL MUX_onlyx3 (onlyx[2],new_a[2],a_bar[2],new_b[1]);
MX2XL MUX_onlyx4 (onlyx[3],new_a[3],a_bar[3],new_b[1]);

NAND2X1 go1 (test,new_b[3],new_a[3]);
NOR3X1 go2 (test1,new_b[3],new_b[2],new_b[1]);
XOR2X1 one1 (ttt1,new_a[3],new_a[1]);
XOR2X1 one2 (ttt2,new_a[2],new_a[0]);
XOR2X1 one3 (ttt3,ttt1,ttt2);
NOR3X1 omg1 (test2,new_b[3],new_b[2],new_b[1]);

//select a,b is ++ or -- 
//if ++ & -- , x need plus 1

//else if +- & -+ , y need plus 1 and 2's. 
XOR2X1 veryimportXOR (t1,new_a[3],new_b[3]); // check ++ or --
//MX2XL MUX_fan1(fan,fan2,1'b1,t1); //if t1 = 0 , x plus 1 ,or plus0
MX4XL MUXok1 (fan,fan5   ,fan6       ,fan7       ,1'b0     ,new_a[3],new_b[3]);
MX2XL MUXok2 (fan5,omg9,1'b0,ttt3);
MX2XL MUXok3 (fan6,1'b0,1'b1,ttt4);
MX2XL MUXok4 (fan7,fan8,1'b0,ttt5);
NOR3X1 go3 (ttt4,new_a[3],new_a[1],new_a[0]);
NOR4X1 go4 (ttt5,new_a[3],new_a[2],new_a[1],new_a[0]);
MX2XL goddma1 (omg9,1'b1,1'b0,test2);
MX2XL goddma2 (fan8,1'b1,1'b0,g5);

MX4XL MUXa1 (new_x1[0],1'b0  ,1'b0      ,onlyx[0]  ,onlyx[0],S[1],S[0]);
MX4XL MUXa2 (new_x1[1],1'b0  ,onlyx[0]  ,onlyx[1]  ,onlyx[1],S[1],S[0]);
MX4XL MUXa3 (new_x1[2],1'b0  ,onlyx[1]  ,onlyx[2]  ,onlyx[2],S[1],S[0]);
MX4XL MUXa4 (new_x1[3],1'b0  ,onlyx[2]  ,onlyx[3]  ,onlyx[3],S[1],S[0]);
MX4XL MUXa5 (new_x1[4],fan   ,onlyx[3]  ,fan       ,fan     ,S[1],S[0]);
MX4XL MUXa6 (new_x1[5],fan   ,fan       ,fan       ,fan     ,S[1],S[0]);
MX4XL MUXa7 (new_x1[6],fan   ,fan       ,fan       ,fan     ,S[1],S[0]);
MX4XL MUXa8 (new_x1[7],fan   ,fan       ,fan       ,fan     ,S[1],S[0]);
// first x select finish


//make second x
XOR2X1 XOR3(S[3],new_b[2],new_b[3]);
XOR2X1 XOR4(S[2],new_b[1],new_b[2]);


//select the second x is + or -
MX2XL MUX_onlyy1 (onlyy[0],new_a[0],a_bar[0],new_b[3]); //y[3] = 1,choose behind
MX2XL MUX_onlyy2 (onlyy[1],new_a[1],a_bar[1],new_b[3]);
MX2XL MUX_onlyy3 (onlyy[2],new_a[2],a_bar[2],new_b[3]);
MX2XL MUX_onlyy4 (onlyy[3],new_a[3],a_bar[3],new_b[3]);

OR2XL ggg1 (g2,new_a[3],new_a[2]);
NOR2XL ggg2 (g3,new_a[1],new_b[3]);
XOR2XL ggg3 (g4,g2,g3);
XOR2XL ggg4 (g5,g4,new_b[2]);
MX2XL MUX_fan100 (fan100,1'b0,fan99,t1);
MX2XL MUX_fan99 (fan99,1'b1,1'b0,ttt5);
//MX2XL MUX_fan98 (fan98,1'b0,1'b1,g4);
MX4XL MUXb1 (new_y1[0],1'b0  ,1'b0    ,1'b0    ,1'b0    ,S[3],S[2]);
MX4XL MUXb2 (new_y1[1],1'b0  ,1'b0    ,1'b0    ,1'b0    ,S[3],S[2]);
MX4XL MUXb3 (new_y1[2],1'b0  ,1'b0    ,onlyy[0],onlyy[0],S[3],S[2]); //the second y is start bit[2]
MX4XL MUXb4 (new_y1[3],1'b0  ,onlyy[0],onlyy[1],onlyy[1],S[3],S[2]);
MX4XL MUXb5 (new_y1[4],1'b0  ,onlyy[1],onlyy[2],onlyy[2],S[3],S[2]);
MX4XL MUXb6 (new_y1[5],1'b0  ,onlyy[2],onlyy[3],onlyy[3],S[3],S[2]);
MX4XL MUXb7 (new_y1[6],fan100   ,onlyy[3],fan100     ,fan100     ,S[3],S[2]);
MX4XL MUXb8 (new_y1[7],fan100   ,fan100     ,fan100     ,fan100     ,S[3],S[2]);

compute compute1 (.a(new_x1),.b(new_y1),.out(ans) );
Complement_8bit N3 (.a(ans),.out(ans_bar));

MX2XL MXLout1 (out[0],ans[0],ans_bar[0],t1);
MX2XL MXLout2 (out[1],ans[1],ans_bar[1],t1);
MX2XL MXLout3 (out[2],ans[2],ans_bar[2],t1);
MX2XL MXLout4 (out[3],ans[3],ans_bar[3],t1);
MX2XL MXLout5 (out[4],ans[4],ans_bar[4],t1);
MX2XL MXLout6 (out[5],ans[5],ans_bar[5],t1);
MX2XL MXLout7 (out[6],ans[6],ans_bar[6],t1);
MX2XL MXLout8 (out[7],1'b0,1'b1,t1);

endmodule

//endcoder
module Encoder (a,out);
input [3:0] a;
output [3:0] out;

//BUFX1 	      	 step1 (a[3],1'b1);
Complement_check step2 ( .a(a),.out(out) );
endmodule

module compute(a,b,out);
input [7:0] a,b;
output [7:0] out;
wire [7:0] c;
ADDHXL ADD1 (out[0],c[0],a[0],b[0]     ); //fist Half adder ,others Full adder
ADDFXL ADD2 (out[1],c[1],a[1],b[1],c[0]);
ADDFXL ADD3 (out[2],c[2],a[2],b[2],c[1]);
ADDFXL ADD4 (out[3],c[3],a[3],b[3],c[2]);
ADDFXL ADD5 (out[4],c[4],a[4],b[4],c[3]);
ADDFXL ADD6 (out[5],c[5],a[5],b[5],c[4]);
ADDFXL ADD7 (out[6],c[6],a[6],b[6],c[5]);
ADDFXL ADD8 (out[7],c[7],a[7],b[7],c[6]);
endmodule

module Complement_8bit (a,out);
input [7:0]a;
output [7:0]out;
wire [7:0]na;
INVX1  INV1 (na[0],a[0]);
INVX1  INV2 (na[1],a[1]);
INVX1  INV3 (na[2],a[2]);
INVX1  INV4 (na[3],a[3]);
INVX1  INV5 (na[4],a[4]);
INVX1  INV6 (na[5],a[5]);
INVX1  INV7 (na[6],a[6]);
INVX1  INV8 (na[7],a[7]);
ADDHXL HLF1 (out[0],c1,na[0],1'b1);
ADDHXL HLF2 (out[1],c2,na[1],c1);
ADDHXL HLF3 (out[2],c3,na[2],c2);
ADDHXL HLF4 (out[3],c4,na[3],c3);
ADDHXL HLF5 (out[4],c5,na[4],c4);
ADDHXL HLF6 (out[5],c6,na[5],c5);
ADDHXL HLF7 (out[6],c7,na[6],c6);
ADDHXL HLF8 (out[7],c8,na[7],c7);
endmodule

//2's complement - 4bits
module Complement(a,out);
input [3:0] a;
output [3:0] out;
wire [3:0] na;
INVX1 INV1 (na[0],a[0]);
INVX1 INV2 (na[1],a[1]);
INVX1 INV3 (na[2],a[2]);
INVX1 INV4 (na[3],a[3]);
ADDHXL HLF1 (out[0],c1,na[0],1'b1);
ADDHXL HLF2 (out[1],c2,na[1],c1);
ADDHXL HLF3 (out[2],c3,na[2],c2);
ADDHXL HLF4 (out[3],c4,na[3],c3);
endmodule

//check input a,b is + or -
module Complement_check(a,out);
input [3:0] a;
output [3:0] out;
wire [3:0] na;
INVX1 INV1 (na[0],a[0]);
INVX1 INV2 (na[1],a[1]);
INVX1 INV3 (na[2],a[2]);

ADDHXL HLF1 (out[0],c1,na[0],1'b1);
ADDHXL HLF2 (out[1],c2,na[1],c1);
ADDHXL HLF3 (out[2],c3,na[2],c2);
BUFX1 BUF1 (out[3],1'b1);
endmodule
//this test bench is for me to debug,please ignore, 3Q
/*
// test bench
module test;
reg [3:0]a,b;
reg [1:0]sel;
wire [7:0] out;
wire [7:0] con;
wire [7:0] booth;
wire [7:0] left;
wire [7:0] right;

wire [7:0] abar,bbar;



lab03b d1 (.a(a) , .b(b) ,.out(out) ,.sel(sel),.con(con),.booth(booth),
	   .right(right),.left(left),.abar(abar),.bbar(bbar) );



initial 
begin

$monitor($time,"ns a=%b,b=%b,sel=%b,out=%b,abar=%b,bbar=%b",a,b,sel,out,abar,bbar);

		a=4'b0001; b=4'b0010; sel=2'b00; 
#100		a=4'b0011; b=4'b1011; sel=2'b01;  
#100		a=4'b0101; b=4'b0011; sel=2'b10;  
#100		a=4'b1001; b=4'b1010; sel=2'b11;  

end
endmodule
*/