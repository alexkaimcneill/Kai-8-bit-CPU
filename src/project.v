/*
 * Copyright (c) 2026 Alex McNeill
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_alexkaimcneill_kai_8bitCPU(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  //memory
  reg [7:0] memory [31:0]; //16 bytes of memory
  reg [7:0] acc;
  reg [4:0] pc; //5-bit program counter
  reg       loading; //stores if CPU is loading external data into memory
  reg [4:0] load_index; //index for loading external data into memory

  wire [4:0] operand = memory[pc][4:0]; // 5-bit instruction data
  wire [2:0] opcode = memory[pc][7:5];
  
  localparam [2:0]
  ADD   = 3'b000,
  MULT  = 3'b001,
  NOR = 3'b010,
  STORE = 3'b011,
  LOADM = 3'b100, //load to accumulator from memory
  LOADI = 3'b101, //load to accumulator from index
  JUMP  = 3'b110,
  BEQ   = 3'b111;

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      pc <= 0;
      acc <= 0;
      loading <= 0;
      load_index <= 0;
    end
    else if (loading)
    begin
      memory[load_index] <= ui_in;
      loading <= 0;
    end
    else if (ui_in[7] == 1)
    begin
      load_index <= ui_in[4:0];
      loading <= 1;
    end
    else
    begin
      case (opcode)
        ADD: acc <= acc + memory[operand];
        MULT: acc <= acc * memory[operand];
        NOR: acc <= ~(acc | memory[operand]);
        STORE: memory[operand] <= acc;
        LOADM: acc <= memory[operand];
        LOADI: acc <= {3'b000, operand};
        JUMP: pc <= operand;
        BEQ: if (acc == 8'b00000000) pc <= operand;
      endcase

      if (opcode != JUMP)
      begin
        if ((opcode != BEQ) || (acc != 8'b00000000))
          pc <= pc + 1;
      end
    end
  end

  assign uo_out = acc;
  assign uio_out = 8'b0;
  assign uio_oe = 8'b0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in, 1'b0};

endmodule