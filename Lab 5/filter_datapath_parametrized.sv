// Parametrized version of the datapath module to allow for customization of the sampling length
module filter_datapath_parametrized #(parameter N = 32, EXPONENT = 5) (
	input logic clk, read, write, full,
	input logic [EXPONENT-1:0] read_addr, write_addr,
	input logic signed [23:0] writedata,

	output logic signed [23:0] buffer_out
	);

	logic signed [23:0] buffer [0:N-1];

	// writing to memory
	// write enable when (write and not full) or (read and write)
	always_ff @(posedge clk) begin
		if ((write & ~full) | (read & write)) begin
			buffer[write_addr] <= writedata;
		end
	end	// ff

	assign buffer_out = buffer[read_addr];
endmodule
