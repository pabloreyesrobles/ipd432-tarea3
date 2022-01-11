module sipo_reg #(
  parameter MEM_SIZE = 1024
)
(
  input logic clk,
  input logic write_enable,
  input logic [7:0] data_in,
  output logic [MEM_SIZE-1:0] [7:0] data_out
);

logic [MEM_SIZE-1:0] [7:0] buff;

genvar i;
generate
  for (i = 0; i < MEM_SIZE; i = i + 1) begin
    always_ff @(posedge clk) begin
      if (write_enable) begin
        if (i == 0) buff[0] <= data_in[7:0];
        else if (i > 0) buff[i] <= buff[i - 1];
        else buff <= buff;
      end
    end
  end
endgenerate

assign data_out = buff;

endmodule
