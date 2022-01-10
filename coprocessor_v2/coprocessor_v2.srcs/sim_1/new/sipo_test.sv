module sipo_test ();    
  localparam MEM_SIZE = 1024;
  logic clk, write_enable;
  logic [7:0] data_in;
  logic [MEM_SIZE - 1:0] [7:0] data_out;

  sipo_reg #(
    .MEM_SIZE(MEM_SIZE)
  )
  mem_test
  (
    .clk,
    .write_enable,
    .data_in,
    .data_out
  );

  always #1 clk <= ~clk; // generate a clock  
  initial begin
    clk = 1'b0;
    write_enable = 1'b0;

    for (int i = 0; i < MEM_SIZE; i = i + 1) begin      
      data_in = i;
      #1 write_enable = 1'b1;
      #2 write_enable = 1'b0;
      #5;
    end
  end

endmodule
