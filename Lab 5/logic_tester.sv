module filter(clk, enable, Din, Dout);
	input logic clk, enable;
	input logic signed [23:0] Din;
	output logic signed [23:0] Dout;

	logic signed [23:0] Q1, Q2, Q3, Q4, Q5, Q6, Q7;

	always_ff @(posedge clk) begin
		if(enable) begin
			Q1 <= Din;
			Q2 <= Q1;
			Q3 <= Q2;
			Q4 <= Q3;
			Q5 <= Q4;
			Q6 <= Q5;
			Q7 <= Q6;
		end
	end

	assign Dout = (Din >>> 3) + (Q1 >>> 3) + (Q2 >>> 3) + (Q3 >>> 3) + (Q4 >>> 3) + (Q5 >>> 3) + (Q6 >>> 3) +
					  (Q7 >>> 3);

endmodule
