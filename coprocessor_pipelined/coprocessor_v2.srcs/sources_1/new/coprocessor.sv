`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/07/2021 06:45:21 PM
// Design Name:
// Module Name: coprocessor
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


module coprocessor #(
    parameter CMD_WIDTH = 3,
    parameter MEMORY_DEPTH = 8,
    parameter ADDRESS_WIDTH = 3,
    parameter WAIT_READ_CYCLES = 3
  )
  (
    input logic clk,
    input logic reset,
    input logic cmd_flag,
    input logic [CMD_WIDTH-1:0] cmd_dec,
    input logic bram_sel,
    input logic [7:0] rx_data,
    input logic rx_ready,
    input logic tx_busy,
    input logic [MEMORY_DEPTH - 1:0] [7:0] read_data_a,
    input logic [MEMORY_DEPTH - 1:0] [7:0] read_data_b,
    output logic write_enable_a,
    output logic [7:0] write_data_a,
    output logic write_enable_b,
    output logic [7:0] write_data_b,
    output logic tx_start,
    output logic core_lock,
    output logic [MEMORY_DEPTH - 1:0] [23:0] out_data,
    output logic out_write,
    output logic out_shift,
    output logic shift_byte,
    output logic [6:0] CAT,
    output logic [7:0] AN
  );
  // Operation definition
  enum logic [CMD_WIDTH-1:0] {WRITE_CMD = 3'd1, READ_CMD = 3'd2, SUM_CMD = 3'd3, AVG_CMD = 3'd4, MAN_CMD = 3'd5, EUC_CMD = 3'd6} commands;

  // Main FSM
  // typedef enum logic [2:0] {IDLE, OP_SEL, WRITE,READ, OP, INVALID} state;
  // state current_state, next_state;
  // Outputs
  logic write_enable, write_done, read_block_enable, read_done, tx_done, tx_enable;
  logic op_done, op_fsm_enable, op_fsm_done, op_enable;

  logic man_done, man_conv_bcd, man_done_bcd;
  logic [23:0] man_bcd_out;
  logic [31:0] seven_seg_data;

  assign out_write = op_fsm_done;
  assign man_done = (cmd_dec == MAN_CMD) & out_write;

  fsm_main_ctrl MAIN_CTRL (
    .clk(clk),
    .reset(~reset),
    .cmd_flag(cmd_flag),
    .cmd(cmd_dec),
    .op_fsm_done(op_fsm_done),
    .tx_done(tx_done),
    .core_lock(core_lock),
    .op_fsm_enable(op_fsm_enable),
    .tx_enable(tx_enable)
  );

  fsm_op_ctrl #(
	  .CMD_WIDTH(CMD_WIDTH)
	)
  OP_CTRL
	(
    .clk(clk),
    .reset(~reset),
    .enable(op_fsm_enable),
    .op_done(op_done),
    .write_done(write_done),
    .cmd(cmd_dec),
    .write_enable(write_enable),
    .op_enable(op_enable),
    .module_done(op_fsm_done)
  );

  //------------------------------------------------------------------[OP LOGIC]
  logic read_flag, next_read;

  op_module #(
    .N_INPUTS(MEMORY_DEPTH),
    .CMD_WIDTH(CMD_WIDTH)
  )
  OP_MOD
  (
  	.clk(clk),
  	.reset(~reset),
    .cmd(cmd_dec),
    .enable(op_enable), // may change
    .bram_sel(bram_sel),
    .A(read_data_a),
    .B(read_data_b),
    .out(out_data),
  	.op_done(op_done)
  );

  // -------------------------------------------------------------------[Memory]
  // Memory logic
  logic common_write_enable;

  // Memory write control
  write_control #(
    .MEMORY_DEPTH(MEMORY_DEPTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
  )
  COMMON_WRITE_CONTROL
  (
    .clk(clk),
    .reset(~reset),
    .enable(write_enable),
    .rx_ready(rx_ready),
    .write_enable(common_write_enable),
    .done(write_done)
  );

  tx_control #(
    .MEMORY_DEPTH(MEMORY_DEPTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
  )
  TX_CTRL
  (
    .clk(clk),
    .reset(~reset),
    .enable(tx_enable),
    .tx_busy(tx_busy),
    .tx_start(tx_start),
    .shift_0(shift_byte),
    .shift_1(out_shift),
    .done(tx_done)
  );

  // Memory Write block selector

  always_comb begin
    if(bram_sel) begin
      // Enable block B
      write_enable_b = common_write_enable;
      write_data_b = rx_data;
      // Disable block A
      write_enable_a = 1'b0;
      write_data_a = 8'd0;
    end
    else begin
      //Enable block A
      write_enable_a = common_write_enable;
      write_data_a = rx_data;
      // Disable block B
      write_enable_b = 1'b0;
      write_data_b = 8'd0;
    end
  end

  always_ff @(posedge clk) begin
    if (~reset) seven_seg_data <= 32'hCCCCCCCC;

    if (man_done) man_conv_bcd <= 1'b1;
    else man_conv_bcd <= 1'b0;

    if (man_done_bcd) begin
      seven_seg_data[23:0] <= man_bcd_out;
      seven_seg_data[31:24] <= 'hCC;
    end
  end

  Binary_to_BCD #(
    .INPUT_WIDTH(24),
    .DECIMAL_DIGITS(6)
  )
  man_bcd
  (
    .i_Clock(clk),
    .i_Binary(out_data[MEMORY_DEPTH - 1]),
    .i_Start(man_conv_bcd),
    .o_BCD(man_bcd_out),
    .o_DV(man_done_bcd)
  );

  seven_seg_controller #(
    .CLK_FREQUENCY('d50_000_000)
  )
  seven_seg_mod
  (
    .clk,
    .resetN(reset),
    .data(seven_seg_data),
    .cat_out(CAT),
    .an_out(AN)
  );

  // logic [7:0] cmd_8bit;

  // always_ff @(posedge clk) begin
  //   if (~reset) cmd_8bit <= 8'd0;
  //   else cmd_8bit[CMD_WIDTH - 1:0] <= cmd_dec[CMD_WIDTH - 1:0];
  // end

  // ila_0 ILA_0 (
  //   .clk(clk), // input wire clk

  //   .probe0(cmd_flag), // input wire [0:0]  probe0
  //   .probe1(core_lock), // input wire [0:0]  probe1
  //   .probe2(op_done), // input wire [0:0]  probe2
  //   .probe3(bram_sel), // input wire [0:0]  probe3
  //   .probe4(tx_enable), // input wire [0:0]  probe4
  //   .probe5(tx_done), // input wire [0:0]  probe5
  //   .probe6(rx_data), // input wire [7:0]  probe6
  //   .probe7(tx_data), // input wire [7:0]  probe7
  //   .probe8(read_data_a[1023]), // input wire [7:0]  probe8
  //   .probe9(out_data[1023]) // input wire [7:0]  probe9
  // );


endmodule
