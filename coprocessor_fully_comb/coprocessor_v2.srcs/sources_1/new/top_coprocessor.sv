`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/07/2021 10:03:40 PM
// Design Name:
// Module Name: top_coprocessor
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


module top_coprocessor(
  input logic CLK50MHZ,
  input logic CPU_RESETN,
  input logic UART_TXD_IN,
  output logic UART_RXD_OUT,
  output logic [1:0] JA,
  output logic [6:0] CAT,
  output logic [7:0] AN
  );

  localparam  CMD_WIDTH = 3;
  localparam  MEMORY_DEPTH = 1024;
  localparam  ADDRESS_WIDTH = $clog2(MEMORY_DEPTH);
  localparam  WAIT_READ_CYCLES = 3;

  // Logic
  logic rx_ready, core_lock, cmd_flag, bram_sel, tx_busy, write_enable_a, write_enable_b, tx_start, out_shift, out_write;
  logic [7:0] rx_data, tx_data, write_data_a, write_data_b;
  logic [MEMORY_DEPTH - 1:0] [23:0] out_data;
  logic [MEMORY_DEPTH -1 : 0] [7:0] read_data_a, read_data_b;
  logic [CMD_WIDTH-1:0] cmd_dec;
  logic shift_byte;

  //---------------------------------------------------------------[CMD-DECODER]

  cmd_decoder #(
  .CMD_WIDTH(CMD_WIDTH)
  )
  CMD
  (
    .clk(CLK50MHZ),
    .reset(CPU_RESETN),
    .rx_ready(rx_ready),
    .rx_data(rx_data),
    .core_lock(core_lock),
    .cmd_flag(cmd_flag),
    .cmd_dec(cmd_dec),
    .bram_sel(bram_sel)
  );

  //---------------------------------------------------------------[COPROCESSOR]
  coprocessor #(
    .CMD_WIDTH(CMD_WIDTH),
    .MEMORY_DEPTH(MEMORY_DEPTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .WAIT_READ_CYCLES(WAIT_READ_CYCLES)
  )
  CORE_CORE
  (
    .clk(CLK50MHZ),
    .reset(CPU_RESETN),
    .cmd_flag(cmd_flag),
    .cmd_dec(cmd_dec),
    .bram_sel(bram_sel),
    .rx_data(rx_data),
    .rx_ready(rx_ready),
    .tx_busy(tx_busy),
    .read_data_a(read_data_a),
    .read_data_b(read_data_b),
    .write_enable_a(write_enable_a),
    .write_data_a(write_data_a),
    .write_enable_b(write_enable_b),
    .write_data_b(write_data_b),
    .tx_start(tx_start),
    .core_lock(core_lock),
    .out_data(out_data),
    .out_write(out_write),
    .out_shift(out_shift),
    .shift_byte(shift_byte),
    .CAT(CAT),
    .AN(AN)
  );
  //----------------------------------------------------------------------[UART]
  // UART MODULE
  uart_basic#(
    .CLK_FREQUENCY(100000000),
    .BAUD_RATE(115200)
  )
    UART(
    .clk(CLK50MHZ),
    .reset(~CPU_RESETN),
    .rx(UART_TXD_IN),
    .rx_data(rx_data),
    .rx_ready(rx_ready),
    .tx(UART_RXD_OUT),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_busy(tx_busy)
  );

  //--------------------------------------------------------------------[MEMORY]
  // MEMORY LOGIC
  // MEMORY MODULE A
  sipo_reg #(
    .MEM_SIZE(MEMORY_DEPTH)
  )
  SIPOA
  (
    .clk(CLK50MHZ),
    .write_enable(write_enable_a),
    .data_in(write_data_a),
    .data_out(read_data_a)
  );

  // MEMORY MODULE B
  sipo_reg #(
    .MEM_SIZE(MEMORY_DEPTH)
  )
  SIPOB
  (
    .clk(CLK50MHZ),
    .write_enable(write_enable_b),
    .data_in(write_data_b),
    .data_out(read_data_b)
  );

  // mem_data, shift & write_done to be defined
  piso_reg #(
    .MEM_SIZE(MEMORY_DEPTH)
  )
  PISO
  (
    .clk(CLK50MHZ),
    .reset(CPU_RESETN),
    .write_enable(out_write),
    .shift_0(shift_byte),
    .shift_1(out_shift),
    .data_in(out_data),
    .data_out(tx_data)
  );

  assign JA[0] = UART_TXD_IN;
  assign JA[1] = UART_RXD_OUT;

  logic [7:0] cmd_8bit;


  always_ff @(posedge CLK50MHZ) begin
    if (~CPU_RESETN) cmd_8bit <= 8'd0;
    else cmd_8bit[CMD_WIDTH - 1:0] <= cmd_dec[CMD_WIDTH - 1:0];
  end


endmodule
