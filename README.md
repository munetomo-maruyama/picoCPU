# Simple CPU "picoCPU"

## The Essence of Chip Design: CPU Logic Design

The ultimate path in logic design is to build your own CPU. In this section, we define the "picoCPU"—a CPU with a simple instruction set—explain how to write its RTL in the hardware description language SystemVerilog, and trace its behavior through logic simulation. The CPU we are designing here is an 8-bit processor with only four instructions, specifically optimized for "LED blinking" (L-Chika) tasks.

## picoCPU Instruction Set Architecture (ISA)

This section explains the Instruction Set Architecture of the picoCPU. The internal CPU resources visible to the programmer are called the "Programmer's Model," and the model for the picoCPU is shown in Figure 1. It consists only of a 6-bit Program Counter (PC) and an 8-bit "A" register for data storage. The memory for this CPU is a 64-byte space addressable by a 6-bit address, where both instructions and data reside in the same space. After a reset, the PC is initialized to 0, and execution begins from the instruction at address 0.

<img src="doc/image/picocpu_resource.png" width="400" alt="picoCPU Programmer's Model">

*Figure 1: picoCPU Programmer's Model*

The instruction set is shown in Table 1. Each instruction is an 8-bit code where the upper 2 bits represent the opcode (indicating the operation) and the lower 6 bits represent the operand (indicating the target of the process).

*   **ADD**: Adds the lower 6 bits of the instruction code (sign-extended) to the A register.
*   **JNZ (Jump if Not Zero)**: If the A register is not zero, the lower 6 bits of the instruction code are transferred to the PC to perform a jump. If the A register is zero, it proceeds to the next instruction without jumping.
*   **LDA (Load A)**: Reads data from the memory address specified by the lower 6 bits and stores it in the A register.
*   **STA (Store A)**: Writes the contents of the A register into the memory address specified by the lower 6 bits.

### Table 1: picoCPU Instruction Set

| Instruction | Opcode (2 bits) | Operand (6 bits) | Description |
| :--- | :--- | :--- | :--- |
| **ADD** | 00 | Immediate | A = A + SignExt(Imm) |
| **JNZ** | 01 | Target Address | if (A != 0) PC = Target |
| **LDA** | 10 | Memory Address | A = Memory[Addr] |
| **STA** | 11 | Memory Address | Memory[Addr] = A |


