`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/08/2021 06:15:06 PM
// Design Name:
// Module Name: tx_control
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


module tx_control #(
    parameter MEMORY_DEPTH = 8,
    parameter ADDRESS_WIDTH = 3
  )
  (
    input logic clk,
    input logic reset,
    input logic enable,
    input logic tx_busy,
    output logic tx_start,
    output logic shift,
    output logic done
  );

  typedef enum logic [2:0] {IDLE, TX, WAIT, SHIFT, DONE} state;
  state pr_state, nx_state;
  logic max_address;

  always_ff @ (posedge clk) begin
    if(reset) pr_state <= IDLE;
    else pr_state <= nx_state;
  end

  always_comb begin
    nx_state = IDLE;
    tx_start = 1'b0;
    done = 1'b0;
    shift = 1'b0;
    case (pr_state)
      IDLE: if(enable) nx_state = TX;

      TX: begin
        tx_start = 1'b1;
        nx_state = WAIT;;
      end

      WAIT: begin
        if (tx_busy) nx_state = WAIT;
        else nx_state = SHIFT;
      end

      SHIFT: begin
        if (max_address) nx_state = DONE;
        else begin
          nx_state = TX;
          shift = 1'b1;
        end
      end

      DONE: begin
        done = 1'b1;
        nx_state = IDLE;
      end
    endcase
  end

  address_counter #(
    .MEMORY_DEPTH(MEMORY_DEPTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
  )
  WRITE_ADDRESS
  (
    .clk(clk),
    .reset(reset),
    .enable(shift),
    .clear(done),
    .max_address(max_address)
  );

endmodule
