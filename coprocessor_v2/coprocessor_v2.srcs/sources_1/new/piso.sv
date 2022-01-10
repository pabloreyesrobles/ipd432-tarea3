module piso_reg #(
  parameter MEM_SIZE = 1024
)
(
  input clk,
  input write_enable,
  input shift,
  input [MEM_SIZE-1:0] [7:0] data_in,
  output [7:0] data_out
);

logic [MEM_SIZE-1:0] [7:0] buff;

genvar i;
generate
  for (i = 0; i < MEM_SIZE; i = i + 1) begin
    always_ff @(posedge clk) begin
      if (write_enable) buff[i] <= data_in[i];
      else buff[i] <= buff[i];

      if (shift) begin
        if (i == 0) buff[i] <= 8'd0;
        else buff[i] <= buff[i - 1];
      end
    end
  end
endgenerate

assign data_out = buff[MEM_SIZE - 1];

logic [7:0] dummy;
assign dummy = 8'b0;

ila_0 ILA_1 (
  .clk(clk), // input wire clk

  .probe0(write_enable), // input wire [0:0]  probe0  
  .probe1(shift), // input wire [0:0]  probe1 
  .probe2(1'b0), // input wire [0:0]  probe2 
  .probe3(1'b0), // input wire [0:0]  probe3 
  .probe4(1'b0), // input wire [0:0]  probe4 
  .probe5(1'b0), // input wire [0:0]  probe5 
  .probe6(dummy), // input wire [7:0]  probe6 
  .probe7(data_in[1023]), // input wire [7:0]  probe7 
  .probe8(buff[1023]), // input wire [7:0]  probe8 
  .probe9(data_out) // input wire [7:0]  probe9
);

endmodule