// Program to create a generalized averaging filter for noise reduction in a sound signal that accepts a
// parameter for the number of sample over which to average (parametrized version)
module task3_parametrized #(parameter N = 32, EXPONENT = 5) (
	input logic clk, reset, read_ready, write_ready,
	input logic signed [23:0] readdata,

	output logic signed [23:0] writedata,
	output logic read_out, write_out
	);

	logic read, write;	// local read/write signals
		logic empty, full;

	assign read_out = read_ready & write_ready;
	assign write_out = read_ready & write_ready;

	// FSM to handle the state of the register, whether it's inputting zeroes, holding the values, or outputting to accumulator
	enum {ZERO, HOLD, OUT} ps, ns;
	always_ff @(posedge clk) begin
		if (reset) ps <= ZERO;
		else ps <= ns;
	end	// ff

	always_comb begin
		case (ps)
			ZERO: begin		// initial state, input zeroes to prevent overflow
				if (~full) begin
					ns = ZERO;
					read = 0;
					write = 1;
				end else begin
					ns = OUT;
					read = 1;
					write = 0;
				end
			end

			HOLD: begin		// hold original values
				if (~(read_ready & write_ready)) begin
					ns = HOLD;
					read = 0;
					write = 0;
				end else begin
					ns = OUT;
					read = 1;
					write = 1;
				end
			end

			OUT: begin		// output values to accumulator
				if (~(read_ready & write_ready)) begin
					ns = HOLD;
					read = 0;
					write = 0;
				end else begin
					ns = OUT;
					read = 1;
					write = 1;
				end
			end
		endcase
	end	// comb

	logic signed [23:0] local_writedata;
	always_comb begin
		if (ns == ZERO) local_writedata = 0;
		else local_writedata = {{EXPONENT{readdata[23]}}, readdata[23:EXPONENT]};
	end	// comb


	logic [EXPONENT-1:0] read_addr, write_addr;
	logic signed [23:0] local_readdata;

	filter_datapath_parametrized #(.N(N), .EXPONENT(EXPONENT)) filt_d (.clk, .read, .write, .full, .read_addr, .write_addr, .writedata(local_writedata), .buffer_out(local_readdata));

	filter_control_parametrized #(.N(N), .EXPONENT(EXPONENT)) filt_c (.clk, .reset, .read, .write, .empty, .full, .read_addr, .write_addr);

	// preparing data to enter accumulator when in outputting state
	logic signed [23:0] pre_acc;
	always_comb begin
		if (ns == ZERO) pre_acc = local_writedata;
		else if (ns == HOLD) pre_acc = 0;
		else pre_acc = local_writedata - local_readdata;
	end	// comb

	// accumulator logic
	logic signed [23:0] acc;
	always_ff @(posedge clk) begin
		if (reset) acc <= 0;
		else if (read_ready & write_ready) acc <= acc + pre_acc;	// receive values from shift register
		else acc <= acc;											// hold original values
	end	// ff

	assign writedata = acc;
endmodule

// Same testbench as unparametrized version
module task3_parametrized_tb();
	logic clk, reset, read_ready, write_ready;
	logic signed [23:0] readdata;

	logic signed [23:0] writedata;
	logic read_out, write_out;

	task3 dut (.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
		reset <= 1;							@(posedge clk);
		reset <= 0;
		read_ready <= 0;
		write_ready <= 0;
		readdata <= 24'b0;
												@(posedge clk);

		read_ready <= 1;
		write_ready <= 1;
		repeat (8)							@(posedge clk);

		readdata <= 24'b0100;			@(posedge clk);
		for (int i = 0; i < 24; i++) begin
			readdata <= readdata + 1;	@(posedge clk);
		end

		repeat (8)							@(posedge clk);

		$stop;
	end	// initial
endmodule
