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


endmodule
