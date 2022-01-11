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
    output logic shift_0,
    output logic shift_1,
    output logic done
  );

  typedef enum logic [3:0] {IDLE, TX_1, WAIT_1, SHIFT_1, TX_2, WAIT_2, SHIFT_2, TX_3, WAIT_3, SHIFT, DONE} state;
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
    shift_0 = 1'b0;
    shift_1 = 1'b0;
    case (pr_state)
      IDLE: if(enable) nx_state = TX_1;

      TX_1: begin
        tx_start = 1'b1;
        nx_state = WAIT_1;
      end

      WAIT_1: begin
        if(tx_busy) nx_state = WAIT_1;
        else nx_state = SHIFT_1;
      end

      SHIFT_1: begin
        nx_state = TX_2;
        shift_0 = 1'b1;
      end

      TX_2: begin
        tx_start = 1'b1;
        nx_state = WAIT_2;
      end

      WAIT_2: begin
        if(tx_busy) nx_state = WAIT_2;
        else nx_state = SHIFT_2;
      end

      SHIFT_2: begin
        nx_state = TX_3;
        shift_0 = 1'b1;
      end

      TX_3: begin
        tx_start = 1'b1;
        nx_state = WAIT_3;
      end

      WAIT_3: begin
        if(tx_busy) nx_state = WAIT_3;
        else nx_state = SHIFT;
      end

      SHIFT: begin
        shift_1 = 1'b1;
        if (max_address) nx_state = DONE;
        else begin
          nx_state = TX_1;
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
    .enable(shift_1),
    .clear(done),
    .max_address(max_address)
  );

endmodule
