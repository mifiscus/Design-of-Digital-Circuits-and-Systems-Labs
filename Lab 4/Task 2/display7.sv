// hex display module translates 5-bit values into hexadecimal form that can be shown on the FPGA's display
module display7 (HEX, bcd);

	output logic [6:0] HEX;
	input logic [4:0] bcd; // input from data or address
	
	always_comb begin
	
		case (bcd)
			5'b00000: HEX = 7'b1000000; // 0
			5'b00001: HEX = 7'b1111001; // 1
			5'b00010: HEX = 7'b0100100; // 2
			5'b00011: HEX = 7'b0110000; // 3
			5'b00100: HEX = 7'b0011001; // 5
			5'b00101: HEX = 7'b0010010; // 5
			5'b00110: HEX = 7'b0000010; // 6
			5'b00111: HEX = 7'b1111000; // 7
			5'b01000: HEX = 7'b0000000; // 8
			5'b01001: HEX = 7'b0010000; // 9
			5'b01010: HEX = 7'b0001000; // a
			5'b01011: HEX = 7'b0000011; // b
			5'b01100: HEX = 7'b1000110; // c
			5'b01101: HEX = 7'b0100001; // d
			5'b01110: HEX = 7'b0000110; // e
			5'b01111: HEX = 7'b0001110; // f
			default: HEX = 7'b1111111; // blank
		endcase
		
	end // comb
	
endmodule 

module display7_tb();

	logic [6:0] HEX;
	logic [3:0] bcd;
	
	display7 dut (.HEX, .bcd);
	
	initial begin
		// count to 15 and check the displays
		for (int i = 0; i <= 5'b01111; i++) begin
			bcd = i; #10;
		end
	end // initial
	
endmodule 