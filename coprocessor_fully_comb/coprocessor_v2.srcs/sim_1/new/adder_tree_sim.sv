`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/28/2021 02:48:57 AM
// Design Name:
// Module Name: adder_tree_sim
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


module adder_tree_sim();
  localparam  INPUTS = 1024;
  localparam  INPUT_WIDTH = 8;
  localparam  O_DATA_WIDTH = 8 + $clog2(INPUTS);
  logic [INPUTS-1:0][INPUT_WIDTH-1:0] ins;
  logic [INPUTS-1:0][INPUT_WIDTH-1:0] buffer;
  logic [O_DATA_WIDTH-1:0] out;
  logic clk;
  //assign ins = {8'd2,8'd10,8'd9,8'd27,8'd1,8'd9,8'd27};
  adder_tree #(
    .INPUTS(INPUTS),
    .INPUT_WIDTH(INPUT_WIDTH)
  )
  ADD_TREE
  (
    .enable(1'b1),
    .input_bus(ins),
    .output_bus(out)
  );
  genvar i;
  generate
    for (i = 0;  i < 1024 ; i++) begin
      assign buffer[i] = 'd255;
    end
  endgenerate
  always #1 clk = ~clk;
  initial begin
    clk = 0;
    ins = 'd0;
    #20 ins = buffer;
  end
endmodule
