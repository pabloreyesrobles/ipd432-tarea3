`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/08/2022 08:11:50 PM
// Design Name:
// Module Name: memory_counter
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
// Instantation template
/*------------------------------------------
memory_counter #(
.N_VALUES()
)
COUNTER_MEM
(
  .clk(),
  .reset(),
  .enable(),
  .clear(),
  .max_count()
);
------------------------------------------*/

module memory_counter#(
	parameter N_VALUES = 1024
	)
	(
	input logic clk,
	input logic reset,
	input logic enable,
	input logic clear,
	output logic max_count
    );

	localparam  COUNTER_WIDTH = $clog2(N_VALUES);
	logic [COUNTER_WIDTH-1:0] counter;

	always_ff @ (posedge clk) begin
		if(reset || clear) counter <= 'd0;
		else begin
			if(enable) begin
				if(counter == N_VALUES-1) counter <= 'd0;
				else counter <= counter + 'd1;
			end
			else counter <= counter;
		end
	end

	always_comb begin
		if(counter == N_VALUES-1) max_count = 1'b1;
		else max_count = 1'b0;
	end
endmodule
