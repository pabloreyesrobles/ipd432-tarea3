module piso_test ();    
  localparam MEM_SIZE = 8;
  logic clk, write_enable, shift;
  logic [MEM_SIZE - 1:0] [7:0] data_in;
  logic [7:0] data_out;

  piso_reg #(
    .MEM_SIZE(MEM_SIZE)
  )
  mem_test
  (
    .clk,
    .write_enable,
    .shift,
    .data_in,
    .data_out
  );

  always #1 clk <= ~clk; // generate a clock  
  initial begin
    clk = 1'b0;
    write_enable = 1'b0;
    shift = 1'b0;

    for (int i = 0; i < MEM_SIZE; i = i + 1) begin
      data_in[i] = i;
    end

    #1 write_enable = 1'b1;
    #2 write_enable = 1'b0;

    for (int i = 0; i < MEM_SIZE; i = i + 1) begin      
      #1 shift = 1'b1;
      #2 shift = 1'b0;
    end
  end

endmodule
