![Verilog](https://img.shields.io/badge/Verilog%2FSystemVerilog-FFFFFF?style=for-the-badge&color=FFBF00)
![ModelSim](https://img.shields.io/badge/ModelSim-white?style=for-the-badge&color=428475)
![Digital Design](https://img.shields.io/badge/Digital%20Design-white?style=for-the-badge&color=4647AE)
![RTL](https://img.shields.io/badge/RTL-white?style=for-the-badge&color=FF6A1C)

# Digital System Design: Course Assignments Archive

A collection of five basic hands-on projects from my *Digital System Design* course, written in Verilog / SystemVerilog and verified in ModelSim. The projects move from RTL coding style and structural-vs-behavioral comparisons, through parameterized and FSM-based designs, to timing analysis of a synchronous circuit. Each folder is self-contained and includes its own sources, testbench, and report.

## Projects at a Glance

| # | Project | Focus |
|---|---------|-------|
| 1 | [Bidirectional Register File Design](#1-bidirectional-register-file-design) | Structural vs. RTL, tri-state `inout` bus |
| 2 | [Procedural and Continuous Assignments](#2-procedural-and-continuous-assignments) | Blocking vs. non-blocking, simulation–synthesis mismatch |
| 3 | [Parameterized LFSR Design](#3-parameterized-lfsr-design) | `generate`, `function`, `task` |
| 4 | [Serial Transceiver Moore FSM](#4-serial-transceiver-moore-fsm) | `typedef enum`, 3-block FSM style |
| 5 | [Timing Analysis for a Sequential Circuit](#5-timing-analysis-for-a-sequential-circuit) | Setup/hold, skew, slack, critical path |

---

## 1. Bidirectional Register File Design

A 4-bit register file with a bidirectional `inout` data bus, implemented twice; once **structurally** (`reg_4bit`, `tri_buf_4bit`, `decoder_2to4` and `mux4_4bit` modules wired together) and once as a single **RTL** module, in order to compare the two design styles on the same specification.

Both versions share one testbench and follow the same tri-state protocol: the testbench drives the bus during writes, releases it (`z`) during reads, and the DUT drives it; unknown addresses (`x`) propagate through the mux as `x`.

**What I explored:**
- Trade-offs between structural and RTL implementations: code length, readability, ease of modification, and simulation efficiency on a design this small.
- Trade-offs between structural and RTL implementations: code length, readability, ease of modification, and simulation efficiency on a design this small.

📁 [`./Bidirectional Register File Design/`](./Bidirectional%20Register%20File%20Design/)

---

## 2. Procedural and Continuous Assignments

A 4-bit up/down counter with synchronous load, enable, and asynchronous active-low reset, plus a 7-segment decoder. Starting from a correct baseline (continuous `assign` for combinational logic, non-blocking `<=` in the sequential `always` block), I introduced three deliberate bugs and analyzed each one against the Verilog event scheduler.

**What I explored:**
- **Blocking vs. non-blocking in a sequential block**: The blocking version simulates one cycle "behind" the non-blocking version; synthesis produces the same flip-flops either way, which is exactly the simulation–synthesis mismatch that makes the style dangerous.
- **Missing sensitivity list**: A combinational `always` block without `@(*)` enters an infinite zero-delay loop at time 0 and never advances the simulation; adding `always @(*)` restores correct behavior.
- **Mixing blocking and non-blocking**: The same two statements in a different order produce either a correct counter or an unintended pipeline, again with identical synthesized hardware.

📁 [`./Procedural and Continuous Assignments/`](./Procedural%20and%20Continuous%20Assignments/)

---

## 3. Parameterized LFSR Design

A parameterized Fibonacci LFSR with configurable width and tap positions, written to exercise Verilog constructs that support scalable, reusable code rather than fixed-width implementations.

<p align="center">
  <img src="https://github.com/user-attachments/assets/1df134ea-e1d9-4b7d-81a6-60147c949fa7"
       alt="instr list"
       width="600"/>
   <br>
   <sub>Figure 1 — The Circuitry Schematic of an LFSR (Image from <a href="https://www.ti.com/lit/an/scta036a/scta036a.pdf">a TI doc</a>)</sub>
</p>

**What I explored:**
- `generate-for` versus manually unrolled code, and `generate-if` versus `generate-case` for tap selection.
- `function` versus `task`, and where each is appropriate in synthesizable RTL.
- The synthesis implications of each construct — what maps to hardware and what is elaborated away.

📁 [`./Parametrized LFSR Design/`](./Parametrized%20LFSR%20Design/)

---

## 4. Serial Transceiver Moore FSM

A UART-style serial transmitter and receiver, both implemented as Moore FSMs in SystemVerilog. The TX emits a start bit, data bits LSB-first, and a stop bit; the RX detects the frame and reconstructs the data with its own Moore FSM.

<p align="center">
  <img src="https://github.com/user-attachments/assets/40570fc4-441e-4cfe-95b5-d3cc6f036bb3"
       alt="instr list"
       width="500"/>
   <br>
   <sub>Figure 2 — FSM diagram for the TX side</sub>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/98fcddaf-099c-422b-8c79-ad57a12a18bc"
       alt="instr list"
       width="500"/>
   <br>
   <sub>Figure 3 — FSM diagram for the RX side</sub>
</p>

**What I explored:**
- `typedef enum` for readable state encoding instead of raw parameters or `localparam` bit patterns.
- The standard **3-block FSM style**: State register, next-state logic, output logic, and how it keeps control logic clear and reviewable.
- Matching TX and RX state machines against a shared frame specification.

📁 [`./Serial Transceiver Moore FSM/`](./Serial%20Transceiver%20Moore%20FSM/)

---

## 5. Timing Analysis for a Sequential Circuit

A timing study on a pre-designed sequential circuit. The RTL is given; the work is the analysis; identifying the critical path, deriving the minimum clock period, and verifying the predictions in ModelSim.

<p align="center">
  <img src="https://github.com/user-attachments/assets/3e5c0dd8-b318-4e43-a622-1e4dfd91b143"
       alt="instr list"
       width="600"/>
   <br>
   <sub>Figure 4 — Block diagram for the module under test</sub>
</p>

**What I explored:**
- Clock-to-Q delay, propagation delay, setup time, hold time, clock skew, and slack.
- How the critical path sets the minimum clock period, and how positive versus negative skew can cause setup or hold violations.
- Confirming manual timing analysis against simulation by shrinking the clock period and injecting skew until violations appear, then correcting the design.

📁 [`./Timing Analysis for a Sequential Circuit/`](./Timing%20Analysis%20for%20a%20Sequential%20Circuit/)

