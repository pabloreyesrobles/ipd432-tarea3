`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/08/2022 06:13:17 PM
// Design Name:
// Module Name: fsm_op_ctrl
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
fsm_op_ctrl #(
  .CMD_WIDTH(3)
)
FSM_OP_CTRL
(
  .clk(),
  .reset(),
  .enable(),
  .op_done(),
  .write_done(),
  .cmd(),
  .write_enable(),
  .op_enable(),
  .module_done()
);
------------------------------------------*/

module fsm_op_ctrl#(
	parameter CMD_WIDTH = 3
	)
	(
	input logic clk,
	input logic reset,
	input logic enable,
	input logic op_done,
	input logic write_done,
	input logic [CMD_WIDTH-1:0] cmd,
	output logic write_enable,
	output logic op_enable,
	output logic module_done
    );
	enum logic [CMD_WIDTH-1:0]{WRITE = 3'd1, READ = 3'd2, SUM = 3'd3, AVG = 3'd4, MAN = 3'd5} commands;
	typedef enum logic [2:0] {IDLE, OP_SEL, WRITE_OP, COMMON_OP, DONE} state;
	state pr_state, nx_state;

	always_ff @ (posedge clk) begin
		if(reset) pr_state <= IDLE;
		else pr_state <= nx_state;
	end

	always_comb begin
		nx_state = IDLE;
		write_enable = 1'b0;
		op_enable = 1'b0;
		module_done = 1'b0;
		case (pr_state)

			IDLE: begin
				if(enable) nx_state = OP_SEL;
				else nx_state = IDLE;
			end

			OP_SEL: begin
				if(cmd == WRITE) nx_state = WRITE_OP;
				else nx_state = COMMON_OP;
			end

			WRITE_OP: begin
				write_enable = 1'b1;
				if(write_done) nx_state = DONE;
				else nx_state = WRITE_OP;
			end

			COMMON_OP: begin
				op_enable = 1'b1;
				if(op_done) nx_state = DONE;
				else nx_state = COMMON_OP;
			end

			DONE: begin
				module_done = 1'b1;
				nx_state = IDLE;
			end
		endcase
	end

endmodule
