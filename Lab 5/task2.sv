module task2 (
	input logic clk, read_ready, write_ready,
	input logic signed [23:0] readdata,
	
	output logic signed [23:0] writedata
	);
	
	logic signed [23:0] data, data1, data2, data3, data4, data5, data6, data7;
	
	always_ff @(posedge clk) begin
		if (read_ready & write_ready) begin
			//data <= readdata;
			data <= {{3{readdata[23]}}, readdata[23:3]};
			data1 <= data;
			data2 <= data1;
			data3 <= data2;
			data4 <= data3;
			data5 <= data4;
			data6 <= data5;
			data7 <= data6;
		end
	end	// ff
	
	assign writedata = data + data1 + data2 + data3 + data4 + data5 + data6 + data7;
endmodule


module task2_tb();
	logic clk;
	logic signed [23:0] readdata;
	logic read_ready, write_ready;
	
	logic signed [23:0] writedata;

	task2 dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		read_ready <= 1;
		write_ready <= 1;	
		readdata <= 24'b011000;								@(posedge clk);
		
		for (int i = 0; i < 12; i++) begin
			readdata <= readdata + 1;						@(posedge clk);
		end	// for

		repeat (8)														@(posedge clk);

		$stop;
		
	end	// initial
endmodule 

