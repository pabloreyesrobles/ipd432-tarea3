`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/08/2022 06:45:46 PM
// Design Name:
// Module Name: fsm_main_ctrl
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
fsm_main_ctrl FSM_MAIN_CTRL
(
  .clk(),
  .reset(),
  .cmd_flag(),
  .op_fsm_done(),
  .tx_done(),
  .core_lock(),
  .op_fsm_enable(),
  .tx_enable()
);
------------------------------------------*/

module fsm_main_ctrl(
	input logic clk,
	input logic reset,
	input logic cmd_flag,
	input logic [2:0] cmd,
	input logic op_fsm_done,
	input logic tx_done,
	output logic core_lock,
	output logic op_fsm_enable,
	output logic tx_enable
    );

	typedef enum logic [1:0] {IDLE, OP, TX} state;
	localparam WRITE_CMD = 3'd1;
	state pr_state, nx_state;

	always_ff @ (posedge clk) begin
		if(reset) pr_state <= IDLE;
		else pr_state <= nx_state;
	end

	always_comb begin
		nx_state = IDLE;
		core_lock = 1'b0;
		op_fsm_enable = 1'b0;
		tx_enable = 1'b0;
		case (pr_state)
			IDLE: if(cmd_flag) nx_state = OP;

			OP:	begin
				core_lock = 1'b1;
				op_fsm_enable = 1'b1;
				if(op_fsm_done) begin
					if (cmd == WRITE_CMD) nx_state = IDLE;
					else nx_state = TX;
				end 
				else nx_state = OP;
			end

			TX:	begin
				core_lock = 1'b1;
				tx_enable = 1'b1;
				if(tx_done) nx_state = IDLE;
				else nx_state = TX;
			end
		endcase
	end





endmodule
