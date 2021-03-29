// Control unit to handle the finite state machine, which switches between states using data from the datapath unit
module control (

	input logic clk, reset, start,
	input logic [7:0] A_shift,

	output logic load, shift, increment, done

	);


	// FSM
	enum {S1, S2, S3} ps, ns;

	always_ff @(posedge clk) begin
		if (reset) ps <= S1;
		else ps <= ns;
	end	// ff

	always_comb begin
		case (ps)
			S1: begin	// Reset state, check start signal
				if (start) begin
					ns = S2;
				end

				else begin
					ns = S1;
				end
			end

			S2: begin	// Shift state, check if string is empty, if not then stay in this state
				if (A_shift == 0) begin
					ns = S3;
				end

				else begin
					ns = S2;
				end
			end

			S3: begin	// Done state, check start signal to restart FSM
				if (start) begin
					ns = S3;
				end

				else begin
					ns = S1;
				end
			end

		endcase
	end	// comb

	assign load = (~start) & (ps == S1);	// Load A when in state 1 and start signal is not true
	assign shift = (ps == S2);	// Shift A every clock edge in state 2
	assign increment = (A_shift[0] == 1) & (ps == S2) & (ns == S2);	// Increment counter when 1 is detected in state 2
	assign done = (ps == S3);	// Done when in state 3

endmodule

// testbench that simulates a shifting register A, and tests whether it gives the correct output
module control_tb ();

	logic clk, reset, start;
	logic [7:0] A_shift;
	logic load, shift, increment, done;

	control dut (.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
		reset <= 1;				@(posedge clk);
		reset <= 0;
		start <= 0;
		A_shift <= 8'b01010101;	@(posedge clk);
		start <= 1;				@(posedge clk);
								@(posedge clk);
		A_shift <= 8'b00101010;	@(posedge clk);
		A_shift <= 8'b00010101;	@(posedge clk);
		A_shift <= 8'b00001010;	@(posedge clk);
		A_shift <= 8'b00000101;	@(posedge clk);
		A_shift <= 8'b00000010;	@(posedge clk);
		A_shift <= 8'b00000001;	@(posedge clk);
		A_shift <= 8'b00000000;	@(posedge clk);
								@(posedge clk);
								@(posedge clk);

		$stop;

	end
endmodule
