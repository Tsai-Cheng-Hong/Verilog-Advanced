//------------------------------------------------------//
`timescale 1ns/10ps

module SKETCH
(
   // Output Port
   OUT_VALID,
   OUT_DATA,
   
   // Input Port
   CLK,
   RESET,
   IN_VALID,
   IN_DATA
);

output reg OUT_VALID;
output reg [5:0]OUT_DATA;

input   CLK;
input   RESET;
input   IN_VALID;
input   [5:0]IN_DATA;

// ==========================================
//  Enter your design below
// ==========================================
reg [9:0]	i;
reg [9:0]	clock;
reg [5:0]	data_gap;
reg [1:0] 	in_loop;
reg [9:0]	build_num;
reg [5:0]	data[0:7][0:2];
reg draw_building;
reg [5:0] build_loop_countdown;
reg [5:0] build_loop;
reg get_vertex;
reg [5:0]	map_width;
reg [5:0]	building_shadow[0:30];
reg [5:0] 	last;
reg [5:0] 	current;
reg [5:0]	output_length;
reg [5:0]	output_reg[0:30];
reg [5:0]	giving_out;

always@(posedge CLK or posedge RESET)
begin
	if(RESET)				clock <= 0;
	else if(data_gap == 3)	clock <= 0;
	else 					clock <= clock + 1'b1;
end

/*
 *	counting gap between each data set		
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)							data_gap <= 0;
	else if(!clock)						data_gap <= 0;
	else if(giving_out > output_length)	data_gap <= data_gap + 1'b1;
	else								data_gap <= 0;
end

/*
 *	counting each building data in oreder
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)				in_loop <= 0;
	else if(!clock)			in_loop <= 0;
	else if(clock == 1) 	in_loop <= 0;
	else if(in_loop == 2) 	in_loop <= 0;
	else					in_loop <= in_loop + 1'b1;
end

/*
 *	counting the buildings
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)				build_num <= 0;
	else if(!clock)			build_num <= 0;
	else if(clock == 1) 	build_num <= 0;
	else if(in_loop == 2) 	build_num <= build_num + 1'b1;
end

/*
 *	fill in each building data in 2D array
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)	
		for(i = 0; i < 8; i = i + 1'b1)
		begin
			data[i][0] <= 0;
			data[i][1] <= 0;
			data[i][2] <= 0;
		end
	else if(!clock)
		for(i = 0; i < 8; i = i + 1'b1)
		begin
			data[i][0] <= 0;
			data[i][1] <= 0;
			data[i][2] <= 0;
		end
	else if(IN_VALID)
			data[build_num][in_loop] <= IN_DATA;
end

/*
 *	signel for drawing building's shadow
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)								draw_building <= 0;
	else if(!clock)							draw_building <= 0;
	else if(build_num > 7 & build_loop < 8)	draw_building <= 1;
	else									draw_building <= 0;
end

/*
 *	counting the width for each building
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)				build_loop_countdown <= 0;
	else if(!clock)			build_loop_countdown <= 0;
	else if(clock == 26)	build_loop_countdown <= data[build_loop][0];
	else if(draw_building)
	begin
		if(build_loop_countdown == data[build_loop][2])		build_loop_countdown <= (build_loop == 7) ? 0 : data[build_loop + 1'b1][0];
		else if(build_loop_countdown < data[build_loop][2])	build_loop_countdown <= build_loop_countdown + 1'b1;
		else												build_loop_countdown <= 0;
	end
end

/*
 *	counting the buildings
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)			build_loop <= 0;
	else if(!clock)		build_loop <= 0;
	else if(draw_building)
	begin
		if(build_loop_countdown == data[build_loop][2])
			build_loop <= build_loop + 1'b1;
	end
end

/*
 *	signel for drawing building's shadow
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)				get_vertex <= 0;
	else if(!clock)			get_vertex <= 0;
	else if(map_width > 29)	get_vertex <= 0;
	else if(build_loop > 7)	get_vertex <= 1;
end

/*
 *	draw and save the outer of the buildings
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)		for (i = 0; i < 31; i = i + 1'b1)					building_shadow[i] <= 0;
	else if(!clock)	for (i = 0; i < 31; i = i + 1'b1)					building_shadow[i] <= 0;
	else if(draw_building)
	begin
		if(data[build_loop][1] > building_shadow[build_loop_countdown])	building_shadow[build_loop_countdown] <= data[build_loop][1];
	end
end

/*
 *	count the width of the size limit
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)			map_width <= 0;
	else if(!clock)		map_width <= 0;
	else if(get_vertex)	map_width <= map_width + 1'b1;
end

/*
 *	recording the previous building height
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)			last <= 0;
	else if(!clock)		last <= 0;
	else if(get_vertex)	last <= building_shadow[map_width];
	else				last <= 0;
end

/*
 *	recording the current building height
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)			current <= 0;
	else if(!clock)		current <= 0;
	else if(get_vertex)	current <= building_shadow[map_width + 1'b1];
	else				current <= 0;
end

/*
 *	save the value of each vertex
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)			for (i = 0; i < 16; i = i + 1)	output_reg[i] <= 0;
	else if(!clock)		for (i = 0; i < 16; i = i + 1)	output_reg[i] <= 0;
	else if(get_vertex)
	begin
		if(last != current)
		begin
			output_reg[output_length] 			<= (building_shadow[map_width] < building_shadow[map_width - 1'b1]) ? map_width - 1'b1 : map_width;
			output_reg[output_length + 1'b1] 	<= building_shadow[map_width];
		end
	end
end

/*
 *	recording the length of output
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)			output_length <= 0;
	else if(!clock)		output_length <= 0;
	else if(get_vertex)	output_length <= (last != current) ? output_length + 2'd2 : output_length;
end

/*
 *	counting the output
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)				giving_out <= 0;
	else if(!clock)			giving_out <= 0;
	else if(map_width > 30)	giving_out <= giving_out + 1'b1;
end

/*
 *	output signel
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)								OUT_VALID <= 0;
	else if(giving_out >= output_length)	OUT_VALID <= 0;
	else if(map_width > 30)					OUT_VALID <= 1;
end

/*
 *	output data
 */
always@(posedge CLK or posedge RESET)
begin
	if(RESET)				OUT_DATA <= 0;
	else if(map_width > 30)	OUT_DATA <= output_reg[giving_out];
	else					OUT_DATA <= 0;
end

endmodule
