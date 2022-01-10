module top_sipo 
(
  input   logic CLK50MHZ,
  input   logic CPU_RESETN,
  input   logic UART_TXD_IN,
  output  logic UART_RXD_OUT,
  output logic [1:0] JA,
  output logic [6:0] CAT,
  output logic [7:0] AN
);
  localparam MEM_SIZE = 1024;
  localparam ADDRESS_WIDTH = $clog2(MEM_SIZE);

  logic rx_ready, tx_busy, write_enable, write_done, tx_start, shift, tx_done, tx_enable;
  logic [7:0] rx_data, tx_data;

  logic [MEM_SIZE - 1:0] [7:0] mem_data;

  sipo_reg #(
    .MEM_SIZE(MEM_SIZE)
  )
  sipo_mem
  (
    .clk(CLK50MHZ),
    .write_enable(write_enable),
    .data_in(rx_data),
    .data_out(mem_data)
  );

  piso_reg #(
    .MEM_SIZE(MEM_SIZE)
  )
  piso_mem
  (
    .clk(CLK50MHZ),
    .write_enable(write_done),
    .shift(shift),
    .data_in(mem_data),
    .data_out(tx_data)
  );

  uart_basic #(
    .CLK_FREQUENCY(100000000),
    .BAUD_RATE(115200)
  )
  uart
  (
    .clk(CLK50MHZ),
    .reset(~CPU_RESETN),
    .rx(UART_TXD_IN),
    .rx_data(rx_data),
    .rx_ready(rx_ready),
    .tx(UART_RXD_OUT),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_busy(tx_busy)
  );

  // Memory write control
  write_control #(
    .MEMORY_DEPTH(MEM_SIZE),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
  )
  write_controller
  (
    .clk(CLK50MHZ),
    .reset(~CPU_RESETN),
    .enable(1'b1),
    .rx_ready(rx_ready),
    .write_enable(write_enable),
    .done(write_done)
  );

  tx_control TX_CONTROL(
    .clk(CLK50MHZ),
    .reset(CPU_RESETN),
    .enable(tx_enable),
    .tx_busy(tx_busy),
    .tx_start(tx_start),
    .done(tx_done)
  );

  logic [ADDRESS_WIDTH - 1:0] cnt;
  typedef enum logic [2:0] {IDLE, TX, STALL, SHIFT} state;
  state pr_state, nx_state;

  always_ff @(posedge CLK50MHZ) begin
    if (~CPU_RESETN) begin
      pr_state <= IDLE;
      cnt <= 0;
    end
    else pr_state <= nx_state;

    if (pr_state == SHIFT) cnt <= cnt + 1;
    if (cnt >= MEM_SIZE) cnt <= 0;
  end

  always_comb begin
    tx_enable = 1'b0;
    shift = 1'b0;
    nx_state = IDLE;
    case (pr_state)
      IDLE: begin
        if (write_done) nx_state = TX;
      end

      TX: begin
        nx_state = STALL;
        tx_enable = 1'b1;
      end

      STALL: begin
        nx_state = STALL;
        if (tx_done) nx_state = SHIFT;
      end

      SHIFT: begin
        if (cnt >= MEM_SIZE - 1) nx_state = IDLE;
        else begin
            nx_state = TX;
            shift = 1'b1;
        end
      end

    endcase

  end

endmodule