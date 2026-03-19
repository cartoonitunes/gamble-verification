# Gamble Contract — Bytecode Verification

This repository contains the source code and verification proof for the `Gamble` contract deployed on Ethereum mainnet on September 15, 2015.

## Contract Details

| Field | Value |
|---|---|
| **Address** | `0xaf5558b1b834be59b9ff94e05c17bae9257c9bf1` |
| **Deployer** | `0x5ed8cee6b63b1c6afce3ad7c92f4fd7e1b8fad9f` |
| **Creation TX** | `0x604e2948673db9ca570f8f83dbcfde79ae83d8d4d0e85854fca6e3d0b052b115` |
| **Block** | 235,543 |
| **Date** | 2015-09-15 00:37:21 UTC |
| **Language** | Serpent |
| **Compiler** | Serpent commit `fd9b0b6` (2015-09-06) |

## Verification Result

**EXACT MATCH** — The full 1,136-byte creation transaction input compiled from `gamble.se` is byte-for-byte identical to the on-chain creation data.

The deployed runtime (1,114 bytes) matches the first 1,114 bytes of the compiled runtime. The remaining 4 bytes (`5b6000f3`) in the creation tx are an unreachable dead-code epilogue that Serpent emits but the init code does not deploy — standard behavior for this era of Serpent.

```
Creation TX input:  1136 bytes  ← EXACT MATCH ✅
Deployed runtime:   1114 bytes  ← EXACT MATCH ✅ (first 1114 of 1118 compiled bytes)
```

## Source

`gamble.se` is from the `dapp-bin` repository, commit `d94b22e`. It implements a provably-fair on-chain gambling contract where:

- The house pre-commits to a seed hash (`set_curseed`)
- Players place bets with their own keys (`bet`)
- When the house reveals the seed, random outcomes are determined by `sha3(seed || player_key) / DIVCONST`
- Winners receive payouts automatically during seed reveal

## Compiler Notes

**Serpent commit `fd9b0b6`** (September 6, 2015) was used. Key version-specific behaviors:

1. **`send()` gas stipend = 5000** — pre-EIP-150, Serpent used `~call 5000` for `send()` (visible as `PUSH2 0x1388 CALL` = `611388f1` in bytecode)
2. **`bytes32` function arguments** — supported with "Non-standard argument type" warning
3. **Typed event parameters** — `event Bet(bettor:address, value:uint256, prob_milli:uint256)` generates ABI-compatible keccak topic hashes
4. **`~div` for unsigned division** — needed to match target's `DIV` opcode (vs signed `SDIV` in later versions)

## Reproduce

Requires Docker.

```bash
./verify.sh
```

Expected output:
```
✅ CREATION TX MATCH: compiled == on-chain creation bytecode
✅ RUNTIME MATCH: compiled runtime matches on-chain deployed bytecode
```

## Files

| File | Description |
|---|---|
| `gamble.se` | Original Serpent source code |
| `expected-runtime.hex` | On-chain deployed bytecode |
| `expected-creation.hex` | On-chain creation TX input |
| `compiled.hex` | Compiled output from `fd9b0b6` |
| `verify.sh` | Reproducible verification script |
