// Datapath module for the averaging noise filter that handles when data can be written to memory
module filter_datapath (
	input logic clk, read, write, full,
	input logic [2:0] read_addr, write_addr,
	input logic signed [23:0] writedata,

	output logic signed [23:0] buffer_out
	);

	logic signed [23:0] buffer [0:7];

	// writing to memory
	// write enable when (write and not full) or (read and write)
	always_ff @(posedge clk) begin
		if ((write & ~full) | (read & write)) begin
			buffer[write_addr] <= writedata;
		end
	end	// ff

	assign buffer_out = buffer[read_addr];
endmodule
