# Simulation Results

## Phase 1 — Base FSM

Yellow states advance unconditionally after one clock cycle.

<img src="Phase_1.png" width="800">

---

## Phase 2 — Timed Yellow Phase

Yellow states now hold for a fixed duration, gated by a `done` signal from a parameterized `counter` module.

<img src="Phase_2.png" width="800">
