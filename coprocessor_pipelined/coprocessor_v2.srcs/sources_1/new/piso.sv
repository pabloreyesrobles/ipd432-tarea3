module piso_reg #(
  parameter MEM_SIZE = 1024
)
(
  input logic clk,
  input logic reset,
  input logic write_enable,
  input logic shift_0,
  input logic shift_1,
  input logic [MEM_SIZE-1:0] [23:0] data_in,
  output logic [7:0] data_out
);

logic [MEM_SIZE-1:0] [23:0] buff;
logic [1:0] cnt;

genvar i;
generate
  for (i = 0; i < MEM_SIZE; i = i + 1) begin
    always_ff @(posedge clk) begin
      if (write_enable) buff[i] <= data_in[i];
      else buff[i] <= buff[i];

      if (shift_1) begin
        if (i == 0) buff[i] <= 24'd0;
        else buff[i] <= buff[i - 1];
      end
    end
  end
endgenerate

always_ff @(posedge clk) begin
  if (~reset) cnt <= 0;

  if (shift_1) begin
    cnt <= 0;
  end
  if (shift_0) begin
    cnt <= cnt + 1;
  end
end


always_comb begin
  if(cnt == 'd2) data_out = buff[MEM_SIZE - 1][23:16];
  else if (cnt == 'd1) data_out = buff[MEM_SIZE - 1][15:8];
  else data_out = buff[MEM_SIZE - 1][7:0];

end

endmodule
