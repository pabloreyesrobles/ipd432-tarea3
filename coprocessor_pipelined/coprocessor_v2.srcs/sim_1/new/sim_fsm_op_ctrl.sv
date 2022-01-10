`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/08/2022 06:28:06 PM
// Design Name:
// Module Name: sim_fsm_op_ctrl
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


module sim_fsm_op_ctrl();
	localparam   CMD_WIDTH = 3;
	logic clk, reset, enable, op_done, write_done;
	logic write_enable, op_enable, module_done;
	logic [CMD_WIDTH-1:0] cmd;

	fsm_op_ctrl #(
	  .CMD_WIDTH(3)
	)
	FSM_OP_CTRL
	(
	  .clk(clk),
	  .reset(reset),
	  .enable(enable),
	  .op_done(op_done),
	  .write_done(write_done),
	  .cmd(cmd),
	  .write_enable(write_enable),
	  .op_enable(op_enable),
	  .module_done(module_done)
	);

	always #5 clk = ~clk;
	initial begin
		clk = 1'b0;
		reset = 1'b1;
		enable = 1'b0;
		op_done = 1'b0;
		write_done = 1'b0;
		cmd = 'd1;
		#10
		reset = 1'b0;
		#10
		enable = 1'b1;
		#20
		write_done = 1'b1;
	end

endmodule
