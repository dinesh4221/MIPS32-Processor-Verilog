# MIPS32-Processor-Verilog

## Overview
This Verilog module implements a 5-stage pipelined MIPS32 processor that can execute a subset of MIPS instructions efficiently while handling pipeline hazards.

##  Core Components
- Instruction Fetch (IF): Retrieves instructions from memory.
- Instruction Decode (ID): Decodes instructions and reads register values.
- Execute (EX): Performs arithmetic/logical operations via the ALU.
- Memory Access (MEM): Handles data memory read/write.
- Write Back (WB): Writes results back to the register file.

## Block Diagram
![Image](https://github.com/user-attachments/assets/5381e222-8cc4-4ed0-bad5-1f6448ec2d54)

## Simulation Results
<img width="1031" height="302" alt="Image" src="https://github.com/user-attachments/assets/87291aee-d3bf-4698-90e0-824440d64986" />

## Ouput Waveform
<img width="1152" height="313" alt="Image" src="https://github.com/user-attachments/assets/229a6d24-bc69-47a9-93dc-620c4b0b18fe" />
