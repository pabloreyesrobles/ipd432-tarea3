`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/28/2021 02:24:50 AM
// Design Name:
// Module Name: adder_tree
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
adder_tree #(
.INPUTS(),
.INPUT_WIDTH()
)
ADD_TREE
(
.enable(),
.input_bus(),
.output_bus()
);
------------------------------------------*/

module adder_tree #(
  // To be modified
  parameter INPUTS = 1024,
  parameter INPUT_WIDTH = 8,
  // Can be overwritten, but not recomended
  parameter N_STAGES = $clog2(INPUTS),
  parameter PWIDTH = 2**N_STAGES,
  parameter N_SUMS = PWIDTH-1,
  parameter ODATA_WIDTH = INPUT_WIDTH + N_STAGES
  )
  (
    //input logic clk,
    //input logic reset,
    input logic enable,
    input logic [INPUTS-1:0][INPUT_WIDTH-1:0] input_bus,
    output logic [ODATA_WIDTH-1:0] output_bus
  );
  // [INTERNAL BUS]
  logic [N_STAGES:0][PWIDTH-1:0][ODATA_WIDTH-1:0] data;

  genvar stage, adder;
  generate
    for(stage=0; stage <= N_STAGES; stage++) begin
      localparam  ST_OUT_NUM = PWIDTH >> stage;
      //localparam  ST_WIDTH = INPUT_WIDTH + stage;
      if(stage == 'd0) begin
        for(adder=0; adder < ST_OUT_NUM; adder++) begin
          always_comb begin
            if(adder < INPUTS) begin
              data[stage][adder] = input_bus[adder];
              //data[stage][adder][ODATA_WIDTH-1:ST_WIDTH] = 'd0;
            end
            else begin
              data[stage][adder] = 'd0;
            end
          end
        end
      end
      else begin
        for(adder = 0; adder < ST_OUT_NUM; adder++) begin
          always_comb begin
            data[stage][adder] = data[stage-1][adder*2] + data[stage-1][adder*2 +1];
          end
        end
      end
    end
  endgenerate

  always_comb begin
    if(enable) output_bus = data[N_STAGES][0];
    else output_bus = 'd0;
  end
  //assign output_bus = data[N_STAGES][0];

endmodule
