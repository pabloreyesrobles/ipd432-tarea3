`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/10/2022 05:40:45 PM
// Design Name:
// Module Name: sim_pipeline_adder
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


module sim_pipeline_adder();
  localparam  INPUTS = 1024;
  localparam  INPUT_WIDTH = 8;
  localparam  N_STAGES = $clog2(INPUTS);
  localparam  O_DATA_WIDTH = INPUT_WIDTH + N_STAGES;
  logic clk, reset, enable;
  logic [INPUTS-1:0][INPUT_WIDTH-1:0] data_in;
  logic [O_DATA_WIDTH-1:0] data_out;

  adder_tree_ff #(
  .INPUTS(INPUTS),
  .INPUT_WIDTH(INPUT_WIDTH)
  )
  ADD_TREE
  (
  .clk(clk),
  .reset(reset),
  .enable(enable),
  .input_bus(data_in),
  .output_bus(data_out)
  );

  genvar i;
  generate
    for(i = 0; i < INPUTS; i++) begin
      assign data_in[i] = 'd10;
    end
  endgenerate

  always #5 clk = ~clk;
  initial begin
    clk = 1'b0;
    reset = 1'b0;
    enable = 1'b0;
    #10
    reset = 1'b1;
    #10
    reset  =1'b0;
    #20
    enable = 1'b1;
  end
endmodule
