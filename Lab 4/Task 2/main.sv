// Program for a binary search algorithm that utilizes the control and datapath units from Task 1 to search through a 32x8 RAM module,
// using user inputs for addressing
module DE1_SoC (
	input CLOCK_50,
	input logic [9:0] SW,
	input logic [3:0] KEY,

	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
	output logic [9:0] LEDR
	);

	logic clk, reset, start;
	logic internal_reset, update_address, set_1, set_2, found, not_found, done;
	logic [7:0] value, result;
	logic [4:0] address, range_1, range_2, next_address;
	logic found_out, not_found_out, done_out;

	// unused hex displays
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;

	// I/O
	assign clk = CLOCK_50;
	assign reset = ~KEY[0];
	assign value = SW[7:0];
	assign LEDR[9] = found_out;
	assign LEDR[8] = not_found_out;


	//assign start = SW[9];
	// synchronous start
	logic [19:0] delay_counter;
	always_ff @(posedge clk) begin
		delay_counter = delay_counter + 1;
		if (SW[9] & (delay_counter == 20'b11110100001001000000))	begin // delay start signal by 1 million clock cycles
			start = 1;
		end
		else if (~SW[9] & (delay_counter == 20'b11110100001001000000))	begin
			start = 0;
		end
	end	// ff

	// Control and datapath units separated into their own modules
	binary_search_control ctl (.clk, .reset, .start, .value, .result, .range_1, .range_2, .internal_reset, .update_address, .set_1, .set_2, .found, .not_found, .done);
	binary_search_datapath dat (.clk, .internal_reset, .update_address, .set_1, .set_2, .found, .not_found, .done, .address, .range_1, .range_2, .next_address, .found_out, .not_found_out, .done_out);

	// 32x8 RAM module
	ram32x8 ram (.address(next_address), .clock(clk), .data(), .wren(1'b0), .q(result));

	// 2 figure hex displays for HEX address values
	display7 dis_1 (.HEX(HEX1), .bcd(address_1));
	display7 dis_0 (.HEX(HEX0), .bcd(address_0));

	logic [4:0] address_0, address_1;
	always_ff @(posedge clk) begin
		if (found_out) begin
			address_1 <= address[4];
			address_0 <= address[3:0];
		end
		else begin
			address_1 <= 5'b10000;
			address_0 <= 5'b10000;
		end
	end	// ff


endmodule

`timescale 1 ps / 1 ps

// testbench for edge case and example target case
module DE1_SoC_tb();

	logic CLOCK_50;
	logic [9:0] SW;
	logic [3:0] KEY;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic found_out, done_out;

	DE1_SoC dut (.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end

	initial begin
		KEY[0] <= 0;					@(posedge CLOCK_50);	// reset
		KEY[0] <= 1;
		SW[7:0] <= 8'b00001101;			@(posedge CLOCK_50);	// set target value 12
		SW[9] <= 1;						@(posedge CLOCK_50);	// start

		for (int i = 0; i < 24; i++) begin
										@(posedge CLOCK_50);	// wait until addresses are read
		end

		SW[9] <= 0;
		SW[7:0] <= 8'b11111111;			@(posedge CLOCK_50);	// set unreachable target value
		SW[9] <= 1;						@(posedge CLOCK_50);	// restart

		for (int j = 0; j < 48; j++) begin
										@(posedge CLOCK_50);
		end

		$stop;

	end	// initial

endmodule
