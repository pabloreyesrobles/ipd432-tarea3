`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/08/2022 07:56:38 PM
// Design Name:
// Module Name: write_module
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


module write_module#(
	parameter N_VALUES = 1024
	)
	(
	input logic clk,
	input logic reset,
	input logic enable,
	input logic rx_ready,
	input logic bram_sel,
	output logic write_enable_a,
	output logic write_enable_b,
	output logic done
    );
	// INTERNAL LOGIC
	logic write_enable, count_enable, done, max_count;


	// FSM WRITE CTRL
	typedef enum logic [2:0] {IDLE, WRITE, COUNT, HOLD, DONE} state;
	state pr_state, nx_state;

	always_ff @ (posedge clk) begin
		if(reset) pr_state <= IDLE;
		else pr_state <= nx_state;
	end

	always_comb begin
		nx_state = IDLE;
		write_enable = 1'b0;
		count_enable = 1'b0;
		done = 1'b0;

		case (pr_state)
			IDLE: begin
				if (enable && rx_ready) nx_state = WRITE;
				else nx_state = IDLE;
			end

			WRITE: begin
				write_enable = 1'b1;
				if(max_count) nx_state = DONE;
				else nx_state = COUNT;
			end

			COUNT: begin
				count_enable = 1'b1;
				nx_state = HOLD;
			end

			HOLD: begin
				if(rx_ready) nx_state = WRITE;
				else nx_state = HOLD;
			end

			DONE: begin
				done = 1'b1;
				nx_state = IDLE;
			end
		endcase
	end

	// COUNTER
	memory_counter #(
	.N_VALUES(N_VALUES)
	)
	COUNTER_MEM
	(
	  .clk(clk),
	  .reset(reset),
	  .enable(count_enable),
	  .clear(done),
	  .max_count(max_count)
	);

	// MEMORY SELECTION
	always_comb begin
		if(bram_sel) write_enable_b = write_enable;
		else write_enable_a = write_enable;
	end
endmodule
