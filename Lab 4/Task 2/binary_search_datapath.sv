// Datapath unit for binary search module
module binary_search_datapath (
	input logic clk, internal_reset, update_address, set_1, set_2, found, not_found, done,

	output logic [4:0] address, range_1, range_2, next_address,
	output logic found_out, not_found_out, done_out
	);


	always_ff @(posedge clk) begin
		if (internal_reset) begin
			range_1 <= 5'b00000;
			range_2 <= 5'b11111;
			address <= 5'b00000;
			found_out <= 0;
			not_found_out <= 0;
			done_out <= 0;
		end

		// checks inputs from control unit and sends signals to update the state machine
		if (update_address) begin
			address <= next_address;
		end

		if (set_1) begin
			range_1 <= next_address + 1;
		end

		if (set_2) begin
			range_2 <= next_address - 1;
		end

		if (found) begin
			found_out <= 1;
		end

		if (not_found) begin
			not_found_out <= 1;
		end

		if (done) begin
			done_out <= 1;
		end

	end	// ff

	assign next_address = (range_1 + range_2) / 2;	// middle register between range

endmodule

// testbench simulates a control unit and signals from the unit to ensure this module works alone
module binary_search_datapath_tb ();

	logic clk, internal_reset, update_address, set_1, set_2, found, not_found, done;
	logic [4:0] address, range_1, range_2, next_address;
	logic found_out, not_found_out, done_out;

	binary_search_datapath dut (.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
		internal_reset <= 1;			@(posedge clk);
		internal_reset <= 0;

		// test search and update feature
		for (int i = 0; i < 8; i++) begin
			set_1 <= 1;					@(posedge clk);
			set_1 <= 0;
			update_address <= 1;		@(posedge clk);
			update_address <= 0;
		end	// for

		internal_reset <= 1;			@(posedge clk);
		internal_reset <= 0;

		// simulate looking for 12
		set_2 <= 1;						@(posedge clk);
		set_2 <= 0;
		update_address <= 1;			@(posedge clk);
		update_address <= 0;

		set_1 <= 1;						@(posedge clk);
		set_1 <= 0;
		update_address <= 1;			@(posedge clk);
		update_address <= 0;

		set_1 <= 1;						@(posedge clk);
		set_1 <= 0;
		update_address <= 1;			@(posedge clk);
		update_address <= 0;

		set_2 <= 1;						@(posedge clk);
		set_2 <= 0;
		update_address <= 1;			@(posedge clk);
		update_address <= 0;

		$stop;
	end	// initial

endmodule
