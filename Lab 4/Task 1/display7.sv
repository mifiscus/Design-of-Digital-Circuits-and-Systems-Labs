// hex display module translates 4-bit values into hexadecimal form that can be shown on the FPGA's display
module display7 (HEX, bcd);

	output logic [6:0] HEX;
	input logic [3:0] bcd; // input from data or address

	always_comb begin
		case (bcd)
			4'b0000: HEX = 7'b1000000; // 0
			4'b0001: HEX = 7'b1111001; // 1
			4'b0010: HEX = 7'b0100100; // 2
			4'b0011: HEX = 7'b0110000; // 3
			4'b0100: HEX = 7'b0011001; // 4
			4'b0101: HEX = 7'b0010010; // 5
			4'b0110: HEX = 7'b0000010; // 6
			4'b0111: HEX = 7'b1111000; // 7
			4'b1000: HEX = 7'b0000000; // 8
			4'b1001: HEX = 7'b0010000; // 9
			default: HEX = 7'b1111111; // blank
		endcase

	end // comb

endmodule

// hex display testbench
module display7_tb();

	logic [6:0] HEX;
	logic [3:0] bcd;

	display7 dut (.HEX, .bcd);

	initial begin
		// count to 15 and check the displays
		for (int i = 0; i <= 4'b1111; i++) begin
			bcd = i; #10;
		end
	end // initial

endmodule
