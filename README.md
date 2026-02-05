# SilentDrainTrap

A Drosera trap that detects **slow, stealthy treasury drains** that evade
traditional “large transfer” or “single-event” alerts.

## Why This Matters

Most exploits do not drain funds in one transaction.
Attackers often:
- drip funds slowly
- split withdrawals
- avoid thresholds

SilentDrainTrap detects **cumulative erosion over time**.

---

## How It Works

1. `collect()` samples the SAFE’s ERC-20 balance each block.
2. Drosera provides a rolling window of samples.
3. `shouldRespond()` compares the oldest and newest sample.
4. If balance drops more than a configured percentage:
   - the trap fires once (edge-triggered)
   - a responder emits an on-chain alert

---

## Detection Logic

- Uses **basis points (BPS)** — token-decimal agnostic
- Windowed comparison (not since genesis)
- Falling-edge trigger only
- Resistant to noise and spam

---

## Files

- `SilentDrainTrap.sol` — Drosera trap
- `SilentDrainResponder.sol` — alert emitter
- `drosera.toml` — deployment config

---

## Deployment Steps

### 1. Set Addresses

In `SilentDrainTrap.sol`:
```solidity
address public constant TOKEN = 0x...;
address public constant SAFE  = 0x...;
