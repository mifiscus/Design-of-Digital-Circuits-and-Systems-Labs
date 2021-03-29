// Datapath unit
// Implementation of a bit-counting circuit based on a given ASMD chart utilizing a datapath unit and control unit
module DE1_SoC (
	input CLOCK_50,
	input logic [9:0] SW,
	input logic [3:0] KEY,

	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
	output logic [9:0] LEDR
	);

	logic [3:0] count;
	logic clk, reset, start, load, shift, increment, done;
	logic [7:0] A, A_shift;
	logic [19:0] delay_counter;

	// I/O
		// 8-bit input SW0-7
		// synchronous reset KEY0
		// synchronous start signal SW9
		// 50 MHz clock
		// display number of 1s counted (output) on HEX0
		// algorithm finish signal LEDR9

	// logic
		// Datapath
			// counter to store result
			// shift register A
		// Control
			// FSM

	// Unused hex displays
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;

	assign clk = CLOCK_50;
	assign A = SW[7:0];
	//assign start = SW[9];
	assign reset = ~KEY[0];
	assign LEDR[9] = done;

	// synchronous start using switch 9
	always_ff @(posedge clk) begin
		delay_counter = delay_counter + 1;
		if (SW[9] & (delay_counter == 20'b11110100001001000000))	begin // delay start signal by 1 million clock cycles
			start = 1;
		end
		else if (~SW[9] & (delay_counter == 20'b11110100001001000000))	begin
			start = 0;
		end
	end	// ff


	control ctl (.clk, .reset, . start, .A_shift, .load, .shift, .increment, .done);

	display7 dis (.HEX(HEX0), .bcd(count));

	// Datapath section
	// Based on commands from the control unit, load or shift the shift register A while keeping count of 1's
	always_ff @(posedge clk) begin
		if (reset | ~start) begin
			count = 0;
		end
		if (load) begin
			A_shift <= A;
		end

		if (shift) begin
			A_shift <= (A_shift >> 1);
		end

		if (increment) begin
			count = count + 1;
		end

	end	// ff

endmodule

// testbench to make sure keys and switches give the right outputs
module DE1_SoC_tb ();
	logic CLOCK_50;
	logic [9:0] SW;
	logic [3:0] KEY;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;

	DE1_SoC dut (.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end

	initial begin
		KEY[0] <= 0;					@(posedge CLOCK_50);	// reset
		KEY[0] <= 1;
		SW[9] <= 0;
		SW[7:0] <= 8'b01010101;			@(posedge CLOCK_50);
		SW[9] <= 1;						@(posedge CLOCK_50);

		for (int i = 0; i < 12; i++) begin
										@(posedge CLOCK_50);
		end	// end

		$stop;
	end


endmodule
