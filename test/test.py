# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, Timer

async def load_memory(dut, data):
    dut._log.info("Loading memory")

    for i in range(len(data)):
        await FallingEdge(dut.clk)
        dut.ui_in.value = 0x80 | i
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        dut.ui_in.value = data[i]
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")

    dut._log.info("Memory loaded")



@cocotb.test()
async def test_add_and_mult(dut):
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1

    data = [
        0xA6,  # LOADI 6
        0x08,  # ADD memory[8]
        0x29,  # MULT memory[9]
        0xC3,  # JUMP 3 (stop advancing through uninitialized memory)
        0x00,
        0x00,
        0x00,
        0x00,
        0x07,  # memory[8] = 7
        0x03,  # memory[9] = 3
    ]

    await load_memory(dut, data)
    dut.ui_in.value = 0

    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert int(dut.uo_out.value) == 6

    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert int(dut.uo_out.value) == 13

    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert int(dut.uo_out.value) == 39
