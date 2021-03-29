// Control module for the noise removal averaging filter, using a finite state machine to handle logic for pointers used in the datapath module
module filter_control (
	input logic clk, reset, read, write,

	output logic empty, full,
	output logic [2:0] read_addr, write_addr
	);

	logic empty_signal, empty_signal_next, full_signal, full_signal_next;
	logic [2:0] read_pointer, read_pointer_next, read_pointer_increment;
	logic [2:0] write_pointer, write_pointer_next, write_pointer_increment;

	// FSM to handle pointer logic
	always_ff @(posedge clk) begin
		if (reset) begin
			empty_signal <= 1;
			full_signal <= 0;
			read_pointer <= 3'b0;
			write_pointer <= 3'b0;
		end else begin
			empty_signal <= empty_signal_next;
			full_signal <= full_signal_next;
			read_pointer <= read_pointer_next;
			write_pointer <= write_pointer_next;
		end
	end	// ff

	// read and write signals coming from datapath module, determining whether its corresponding pointer should be incremented
	always_comb begin
		empty_signal_next = empty_signal;
		full_signal_next = full_signal;
		read_pointer_next = read_pointer;
		write_pointer_next = write_pointer;

		read_pointer_increment = read_pointer + 1;
		write_pointer_increment = write_pointer + 1;

		case ({read, write})
			2'b01: begin	// write only
				if (~full_signal) begin
					empty_signal_next = 0;
					write_pointer_next = write_pointer_increment;
					if (write_pointer_increment == read_pointer) full_signal_next = 1;
				end
			end

			2'b10: begin	// read only
				if (~empty_signal) begin
					full_signal_next = 0;
					read_pointer_next = read_pointer_increment;
					if (read_pointer_increment == write_pointer) empty_signal_next = 1;
				end
			end

			2'b11: begin	// read and write
				read_pointer_next = read_pointer_increment;
				write_pointer_next = write_pointer_increment;
			end

			default: begin end

		endcase
	end	// comb

	assign empty = empty_signal;
	assign full = full_signal;
	assign read_addr = read_pointer;
	assign write_addr = write_pointer;
endmodule

// testbench simulating read and writes from the datapath module and testing if pointers are incremented correctly
module filter_control_tb();
	logic clk, reset, read, write;
	logic empty, full;
	logic [2:0] read_addr, write_addr;

	filter_control dut (.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
		reset <= 1;					@(posedge clk);
		reset <= 0;
		read <= 0;
		write <= 0;					@(posedge clk);

		for (int i = 0; i < 12; i++) begin
			write <= 1;				@(posedge clk);
			write <= 0;				@(posedge clk);
		end	// for

		for (int i = 0; i < 12; i++) begin
			read <= 1;				@(posedge clk);
			read <= 0;				@(posedge clk);
		end	// for

		for (int i = 0; i < 5; i++) begin
			write <= 1;				@(posedge clk);
			write <= 0;				@(posedge clk);
		end	// for

		for (int i = 0; i < 3; i++) begin
			read <= 1;				@(posedge clk);
			read <= 0;				@(posedge clk);
		end	// for

		$stop;
	end	// initial
endmodule
