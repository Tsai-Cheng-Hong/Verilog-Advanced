//------------------------------------------------------//
//- Digital IC Design 2021                              //
//-                                                     //
//- Lab06: Logic Synthesis                              //
//------------------------------------------------------//
`timescale 1ns/10ps

`include "Incenter.v"

module TEST ;

parameter CYCLE_TIME = 5.0; 

reg CLK, RESET ;
reg [16:0] IN_NUM [0:305];
reg [16:0] IN_DATA;

reg [15:0] ANS_NUM [0:67];
wire [15:0] OUT_DATA;
reg [15:0] YOU_OUT_DATA;
reg [15:0] correct_ans;

reg [8:0] cnt_input; 
reg [7:0] cnt_output; 
wire OUT_VALID;
reg IN_VALID;
reg [7:0] cnt_error;
reg [6:0] cnt_end;
reg flag;
reg [5:0] cnt_clk;
reg [8:0] cnt_in;


always #(CYCLE_TIME/2.0) CLK = ~CLK;

Incenter u_Incenter(.CLK(CLK), .RESET(RESET), .IN_DATA(IN_DATA), .IN_VALID(IN_VALID), .OUT_DATA(OUT_DATA), .OUT_VALID(OUT_VALID));

initial 
begin
	$fsdbDumpfile("Incenter.fsdb");
	$fsdbDumpvars;
	$fsdbDumpMDA;

	$readmemb("input_data.dat", IN_NUM);
	$readmemb("answer.dat", ANS_NUM);

	CLK = 0;
	IN_VALID = 1'd0;
	cnt_in = 9'd0;
	cnt_input = 9'd1; 
	cnt_output = 8'd0; 
	cnt_error = 8'd0;
	cnt_end = 7'd0;
	cnt_clk = 6'd0;
	correct_ans = 16'd0;
	IN_DATA = 17'd0;
	RESET = 1;
	#(CYCLE_TIME *1 ) RESET = 0;
	#(CYCLE_TIME *2 ) IN_VALID = 1'd1;
	#(15000) 
	$finish ;
end

always@(negedge CLK) 
begin
	if(RESET)
		cnt_in <= 9'd0;
	else
		cnt_in <= cnt_in + 1'd1;
end

always@(negedge CLK) 
begin
	if(!RESET)
	begin
		if(cnt_in < 9'd306)
			IN_VALID <= 1'd1;
		else
			IN_VALID <= 1'd0;
	end
end


always@(negedge CLK) 
begin
	cnt_clk <= cnt_clk + 1;
end

always@(negedge CLK) 
begin
	if(cnt_in == 9'd0)
		IN_DATA <= IN_NUM[cnt_in];
	else if(IN_VALID) 
		IN_DATA <= IN_NUM[cnt_input];
end

always@(negedge CLK) 
begin
	if(IN_VALID) 
		cnt_input <= cnt_input + 1;
end

always@(negedge CLK) 
begin
	if(OUT_VALID) 
		cnt_output <= cnt_output + 1;
end

always@(negedge CLK) 
begin
	if(OUT_VALID) 
		flag <= 1;
	else
		flag <=0;
end

always@(negedge CLK) 
begin
	if(OUT_VALID) 
		correct_ans <= ANS_NUM[cnt_output];
end

always@(negedge CLK) 
begin
	if(OUT_VALID) 
		YOU_OUT_DATA <= OUT_DATA;
end

always@(negedge CLK) 
begin
	if(flag)
	begin
		if(correct_ans != YOU_OUT_DATA)
		begin
			cnt_error <= cnt_error + 1;
			
		end
	end
end

always@(negedge CLK) 
begin
	if(OUT_VALID) 
		cnt_end <= cnt_end + 1;
end	

always@(negedge CLK) 
begin
	if(OUT_VALID && cnt_output > 0) 
		$display ("\n Correct_Answer: ", correct_ans,  ",  OUT_DATA: ", YOU_OUT_DATA );
end

always@(negedge CLK) 
begin
	if(cnt_end == 7'd68) 
		$display ("\n Numbers of Error: ", cnt_error );
end

always @(negedge CLK) 
begin
	if(cnt_end == 7'd68 && cnt_error == 0)
	begin
		$display ();
		$display ("///////////////////////////////////////////");
		$display ("////////////// Successful !! //////////////");
		$display ("///////////////////////////////////////////");	
		$display ();
		#(CYCLE_TIME) $finish;      
	end
	else if(cnt_end == 7'd68 && cnt_error > 0)
	begin 
		$display ();
		$display ("////////////// Error !!!! //////////////");
		$display ();
		#(CYCLE_TIME) $finish;      
	end    
end

endmodule