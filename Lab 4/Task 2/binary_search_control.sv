// Control unit for binary search program
module binary_search_control (
	input logic clk, reset, start,
	input logic [7:0] value, result,
	input logic [4:0] range_1, range_2,

	output logic internal_reset, update_address, set_1, set_2, found, not_found, done
	);


	// Finite state machine
	enum {S1, S2, S3, S_wait, S4} ps, ns;
	always_ff @(posedge clk) begin
		if (reset) begin
			ps <= S1;
		end
		else begin
			ps <= ns;
		end
	end	// ff

	always_comb begin
		case (ps)
			S1: begin	// start
				if (start) begin	// check for start signal to begin loop
					ns = S2;
				end
				else begin
					ns = S1;
				end
			end

			S2: begin
				if (result == value) begin    // if the target is found
					ns = S4;
				end
				else begin
					ns = S3;
				end
			end

			S3: begin
				if (range_1 >= range_2) begin    // entire range has been searched
					ns = S4;
				end
				else begin
					ns = S_wait;
				end
			end

			S_wait: begin
				ns = S2;
			end

			S4: begin	// done
				if (start) begin	// check for start signal to restart FSM
					ns = S4;
				end
				else begin
					ns = S1;
				end
			end

		endcase
	end	// comb

	assign internal_reset = (ps == S1);
	assign update_address = (ps == S3);
	assign set_1 = (ps == S3) & (result < value);
	assign set_2 = (ps == S3) & (result > value);
	assign found = (ps == S4) & (result == value);
	assign not_found = (ps == S4) & (~found);
	assign done = (ps == S4);


endmodule

// testbench using a simulated datapath module to ensure this unit works alone
module binary_search_control_tb ();

	logic clk, reset, start;
	logic [7:0] value, result;
	logic [4:0] range_1, range_2;
	logic internal_reset, update_address, set_1, set_2, found, not_found, done;

	binary_search_control dut (.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
		reset <= 1;					@(posedge clk);
		reset <= 0;
		start <= 1;
		value <= 8'b00011110;	@(posedge clk);	// target value 30

		// simulate datapath module reading from memory and changing address accordingly
		result <= 8'b00001111;	@(posedge clk);	// start at middle (15)

		result <= 8'b00010111;	@(posedge clk);	// 23

		result <= 8'b00011011;	@(posedge clk);	// 27

		result <= 8'b00011101;	@(posedge clk);	// 29

		result <= 8'b00011110;	@(posedge clk);	// 30, found and done should be output true
										@(posedge clk);
										@(posedge clk);

		$stop;
	end	// initial

endmodule
