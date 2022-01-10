`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/08/2022 07:09:59 PM
// Design Name:
// Module Name: sim_two_fsm_ctrl
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


module sim_two_fsm_ctrl();

	logic clk, reset, cmd_flag;
	logic op_done,write_done, op_enable, write_enable, tx_done,core_lock, tx_enable;
	logic [2:0] cmd;

	// INTERCONNECTION
	logic op_fsm_done, op_fsm_enable;

	// MAIN FSM
	fsm_main_ctrl FSM_MAIN_CTRL
	(
	  .clk(clk),
	  .reset(reset),
	  .cmd_flag(cmd_flag),
	  .op_fsm_done(op_fsm_done),
	  .tx_done(tx_done),
	  .core_lock(core_lock),
	  .op_fsm_enable(op_fsm_enable),
	  .tx_enable(tx_enable)
	);

	// OPERATIONS FSM
	fsm_op_ctrl #(
	  .CMD_WIDTH(3)
	)
	FSM_OP_CTRL
	(
	  .clk(clk),
	  .reset(reset),
	  .enable(op_fsm_enable),
	  .op_done(op_done),
	  .write_done(write_done),
	  .cmd(cmd),
	  .write_enable(write_enable),
	  .op_enable(op_enable),
	  .module_done(op_fsm_done)
	);

	always #5 clk = ~clk;
	initial begin
		clk = 1'b0;
		reset = 1'b1;
		cmd_flag = 1'b0;
		tx_done = 1'b0;
		op_done = 1'b0;
		write_done = 1'b0;
		#10
		reset = 1'b0;
		cmd = 'd2;
		#10
		cmd_flag = 1'b1;
		#30
		op_done = 1'b1;
		#30
		tx_done = 1'b1;

	end
endmodule
