# MIPS32-Processor-Verilog

## Overview
This Verilog module implements a 5-stage pipelined MIPS32 processor that can execute a subset of MIPS instructions efficiently while handling pipeline hazards.

##  Core Components
- Instruction Fetch (IF): Retrieves instructions from memory.
- Instruction Decode (ID): Decodes instructions and reads register values.
- Execute (EX): Performs arithmetic/logical operations via the ALU.
- Memory Access (MEM): Handles data memory read/write.
- Write Back (WB): Writes results back to the register file.

## Simulation Results
