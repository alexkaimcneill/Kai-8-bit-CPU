# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

async def load_memory(dut, data):
    dut._log.info("Loading memory")

    for i in range(len(data)):
        dut.ui_in.value = 0x80 | i
        await ClockCycles(dut.clk, 1)
        dut.ui_in.value = data[i]
        await ClockCycles(dut.clk, 1)
    dut._log.info("Memory loaded")



@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    data = [0b00000000,
            0b00000001,
            0b00000010,
            0b00100011,
            0b00000100,
            0b00000101,
            0b00000110,
            0b00000111]

    await load_memory(dut, data)
    # dut.rst_n.value = 0
    # await ClockCycles(dut.clk, 10)
    # dut.rst_n.value = 1
    await ClockCycles(dut.clk, 8)



    # assert dut.dut.acc.value == 26



    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
