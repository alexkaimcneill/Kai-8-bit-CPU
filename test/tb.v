`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

`ifndef COCOTB_SIM
  reg [7:0] program_data [0:9];
  integer i;

  task write_external_byte;
    input [4:0] address;
    input [7:0] value;
    begin
      @(negedge clk);
      ui_in = {3'b100, address};
      @(negedge clk);
      ui_in = value;
    end
  endtask

  initial begin
    clk    = 0;
    rst_n  = 0;
    ena    = 1;
    ui_in  = 0;
    uio_in = 0;

    program_data[0] = 8'hA6; // LOADI 6
    program_data[1] = 8'h08; // ADD memory[8]
    program_data[2] = 8'h29; // MULT memory[9]
    program_data[3] = 8'hC3; // JUMP 3
    program_data[4] = 8'h00;
    program_data[5] = 8'h00;
    program_data[6] = 8'h00;
    program_data[7] = 8'h00;
    program_data[8] = 8'h07;
    program_data[9] = 8'h03;

    #20 rst_n = 1;
    for (i = 0; i < 10; i = i + 1)
      write_external_byte(i, program_data[i]);

    @(posedge clk);
    @(posedge clk);
    #1;
    if (uo_out !== 8'd6)
      $fatal(1, "Expected accumulator 6, got %0d", uo_out);

    @(posedge clk);
    #1;
    if (uo_out !== 8'd13)
      $fatal(1, "Expected accumulator 13, got %0d", uo_out);

    @(posedge clk);
    #1;
    if (uo_out !== 8'd39)
      $fatal(1, "Expected accumulator 39, got %0d", uo_out);

    $finish;
  end
  always #5 clk = ~clk;
`endif


  tt_um_alexkaimcneill_kai_8bitCPU dut (

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

endmodule