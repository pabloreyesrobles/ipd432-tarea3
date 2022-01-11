`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/06/2022 11:35:51 PM
// Design Name:
// Module Name: op_module
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
op_module #(
  .N_INPUTS(),
  .I_WIDTH()
)
OP_MOD
(
  .cmd(),
  .enable(),
  .bram_sel(),
  .A(),
  .B(),
  .out()
);
------------------------------------------*/

module op_module#(
  parameter N_INPUTS = 1024,
  parameter I_WIDTH = 8,
  parameter CMD_WIDTH = 3,
  parameter CYCLES_WAIT = 11
  )
  (
  	input logic clk,
  	input logic reset,
    input logic [CMD_WIDTH-1:0] cmd,
    input logic enable,
    input logic bram_sel,
    input logic [N_INPUTS-1:0][I_WIDTH-1:0] A,
    input logic [N_INPUTS-1:0][I_WIDTH-1:0] B,
    output logic [N_INPUTS-1:0][I_WIDTH*3-1:0] out,
	output logic op_done
  );

  // 3 BYTES FIX
  logic [N_INPUTS-1:0][I_WIDTH*3 -1 :0 ] AP, BP;
  genvar j;
  generate
    for(j = 0; j < N_INPUTS; j++) begin
      assign AP[j] = {8'd0, A[j], 8'd0};
      assign BP[j] = {8'd0, B[j], 8'd0};
    end
  endgenerate

  // DONE FLAG COUNTER
  localparam  COUNTER_WIDTH = $clog2(CYCLES_WAIT);
  logic [COUNTER_WIDTH-1:0] counter;


  enum logic [CMD_WIDTH-1:0]{WRITE = 3'd1, READ = 3'd2, SUM = 3'd3, AVG = 3'd4, MAN = 3'd5} commands;
  logic [N_INPUTS-1:0][I_WIDTH-1:0] man_values;
  logic [N_INPUTS-1:0][I_WIDTH*3-1:0] sum,result;
  logic [17:0] man_result;
  logic adder_enable;

  genvar i;
  generate
    for(i = 0; i < N_INPUTS; i = i + 1) begin
      always_comb begin
        man_values[i] = 'd0;
        sum[i] = AP[i] + BP[i];
        case (cmd)
          READ: begin
            if(bram_sel) result[i] = BP[i];
            else result[i] = AP[i];
          end
          SUM: result[i] = sum[i];
          AVG: result[i] = (sum[i]>>1);
          MAN: begin
            if(A[i] >= B[i]) man_values[i] = A[i] - B[i];
            else man_values[i] = B[i] - A[i];
			if(i == N_INPUTS-1) result[N_INPUTS-1] = {6'd0, man_result};
			else result[i] = 'd0;
          end
          default: result[i] = 'd0;
        endcase
      end
    end
  endgenerate

  // TEMP ENABLE
//  always_comb begin
//    if(enable) out = result;
//    else out = 'd0;
//  end



// ADDER TREE COMBINACIONAL

  // adder_tree #(
  // 	.INPUTS(N_INPUTS),
  // 	.INPUT_WIDTH(I_WIDTH)
  // )
  // ADD_TREE
  // (
  // 	.enable(1'b1),
  // 	.input_bus(man_values),
  // 	.output_bus(man_result)
  // );

//----------------------------
// ADDER TREE PIPELINED
  adder_tree_ff #(
  .INPUTS(N_INPUTS),
  .INPUT_WIDTH(I_WIDTH)
  )
  ADD_TREE_FF
  (
  .clk(clk),
  .reset(reset),
  .enable(enable),
  .input_bus(man_values),
  .output_bus(man_result)
  );
//----------------------------
  always_ff @ (posedge clk) begin
	  if(reset) counter <= 'd0;
	  else begin
		  if(enable) begin
		  	if(counter == CYCLES_WAIT-1) counter <= 'd0;
			else counter <= counter + 'd1;
			//out <= result;
		  end
		  else counter <= 'd0;
	  end
  end

  always_comb begin
	if(enable) begin
		if(counter == CYCLES_WAIT-1) op_done = 1'b1;
		else op_done = 1'b0;
	end
	else op_done = 1'b0;
  end

  //FLOP RESULT
  always_ff @ (posedge clk) begin
    if(reset) out <= 'd0;
    else begin
      if(op_done) out <= result;
      else out <= out;
    end
  end

endmodule
