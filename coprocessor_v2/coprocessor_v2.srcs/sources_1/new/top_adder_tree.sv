`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/06/2022 01:34:21 AM
// Design Name:
// Module Name: top_adder_tree
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


module top_adder_tree#(
    parameter INPUTS = 7,
    parameter INPUT_WIDTH = 8,
    parameter O_DATA_WIDTH = 8 + $clog2(INPUTS)
)(
    input logic [INPUT_WIDTH-1:0] ins,
    output logic [O_DATA_WIDTH-1:0] out
);
  adder_tree #(
    .INPUTS(INPUTS),
    .INPUT_WIDTH(INPUT_WIDTH)
  )
  ADD_TREE
  (
    .input_bus(ins),
    .output_bus(out)
  );
endmodule
