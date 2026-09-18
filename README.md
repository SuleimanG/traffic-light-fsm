# Traffic Light Controller (FSM)

This project implements the traffic light controller FSM from *Digital Design and Computer Architecture, RISC-V Edition* by Sarah L. Harris and David Harris (Chapter 3, Sequential Logic Design). The FSM specification and state encoding approach follow the textbook's example; the RTL implementation, testbenches, and verification are my own work.

---

## Design Concept

Two intersecting streets, each with a traffic sensor and a light:

- **Inputs:** `T_A`, `T_B` — traffic sensors on each street (1 = traffic present)
- **Outputs:** `L_A[1:0]`, `L_B[1:0]` — light state for each street (red / yellow / green)
- **Control:** `CLK`, `Reset`

The controller is a 4-state Moore FSM (see state diagram below) that cycles each street through green → yellow → red while the other street does the opposite, advancing based on the traffic sensors.

---

## Black-box view

<img src="docs/diagrams/black_box.drawio.svg" width="500">



---

## State transition diagram

<img src="docs/diagrams/State_Transition_Diagram.drawio.svg" width="600">


On `Reset`, the FSM enters `S0` (`L_A` green, `L_B` red). Each clock cycle, the FSM either holds its current state or advances, based on the traffic sensors:

- **`S0` → `S0`** while `T_A` is asserted (traffic still present on Academic Ave.)
- **`S0` → `S1`** on `T̄_A` (street clears, `L_A` advances to yellow)
- **`S1` → `S2`** after the yellow-duration counter expires (`done` asserted)
- **`S2` → `S2`** while `T_B` is asserted
- **`S2` → `S3`** on `T̄_B`
- **`S3` → `S0`** after the yellow-duration counter expires (`done` asserted)
---

## Architecture

The design is split hierarchically:

- `next_state_logic` — combinational; computes next state from current state, `T_A`/`T_B`, and `done` (yellow-timer expiration)
- `state_register` — sequential; holds current state, clocked on `CLK`, asynchronous `RESET`
- `output_logic` — combinational; computes `L_A`/`L_B` from current state
- `counter` — sequential; parameterized (`YELLOW_DURATION`) timer that asserts `done` after the configured number of cycles while the FSM sits in a yellow state (`S1`/`S3`)
- `traffic_light_fsm` — instantiates and wires the above four

---

## Simulation

**Try it yourself:** [EDA Playground (Synopsys VCS)](https://edaplayground.com/x/pRL_)

---

## Tools
- EDA Playground with Synopsys VCS 2025.06 (primary; see link above for a runnable simulation)
- Icarus Verilog (`-g2012` for SystemVerilog support) + GTKWave for local simulation and waveform viewing
- draw.io for diagrams
    
  

