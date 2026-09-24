# Gas Optimization

Measure before and after every optimization (`forge snapshot --diff`, `forge test --gas-report`), and keep readability
unless the saving is material on a hot path.

## Contents

- [Storage](#storage)
- [Types and Packing](#types-and-packing)
- [Transient Storage](#transient-storage)
- [Functions](#functions)
- [Loops](#loops)
- [Compiler Settings](#compiler-settings)
- [L2 Considerations](#l2-considerations)
- [Libraries](#libraries)
- [Anti-Patterns](#anti-patterns)

## Storage

Reference costs (post-Berlin): cold `SLOAD` 2,100; warm `SLOAD` 100; cold `SSTORE` zero to non-zero 22,100; cold
`SSTORE` non-zero to non-zero 5,000.

| Technique                | Rule                                                                            |
| ------------------------ | ------------------------------------------------------------------------------- |
| Cache reads              | Read a storage value once into a local when it is used more than once           |
| Single-field writes      | Write `_entries[id].field = value` directly instead of copying the whole struct |
| Avoid zero to non-zero   | Design state to minimize zero-to-non-zero transitions                           |
| Mappings over arrays     | Mapping reads skip the array length `SLOAD` used for bounds checks              |
| Constants and immutables | Use them for values known at compile or deploy time; they cost no `SLOAD`       |
| Bitmaps                  | Track many booleans as bits: 256 flags per slot                                 |

## Types and Packing

| Type      | Typical use                         | Size     |
| --------- | ----------------------------------- | -------- |
| `uint256` | Standalone variables, loop counters | 32 bytes |
| `uint128` | Token amounts (two per slot)        | 16 bytes |
| `uint40`  | Timestamps                          | 5 bytes  |
| `address` | Accounts and contracts              | 20 bytes |
| `bool`    | Flags                               | 1 byte   |

Order struct fields and state variables so small types share 32-byte slots, and annotate packed slots with comments
showing byte usage. Verify the result with `forge inspect <Contract> storageLayout`.

## Transient Storage

EIP-1153 transient storage (`TSTORE`/`TLOAD`, 100 gas each) resets at the end of the transaction. It requires an EVM
version of Cancun or later; check the effective value with `forge config | grep evm_version`.

Use it for reentrancy locks, callback context, flash-loan accounting, and other transaction-scoped flags. Prefer, in
order:

1. OpenZeppelin `ReentrancyGuardTransient` for reentrancy locks.
2. `transient` state variables of value types (solc 0.8.28+):

   ```solidity
   bool private transient _locked;
   ```

3. OpenZeppelin `TransientSlot` or inline assembly for custom layouts. Inline assembly accepts only literal number
   constants, so a `keccak256(...)` constant cannot appear in `tstore`/`tload`; hardcode the precomputed slot or use
   `TransientSlot`.

Clear transient values explicitly when a contract may be called several times in one transaction, such as through
multicall or account-abstraction bundles.

## Functions

| Technique            | Rule                                                                                  |
| -------------------- | ------------------------------------------------------------------------------------- |
| `calldata` params    | Use `calldata` for read-only external array and struct parameters                     |
| Custom errors        | Use them instead of revert strings                                                    |
| Short-circuit order  | `&&`: cheap or likely-false first; `\|\|`: cheap or likely-true first                 |
| Cache external calls | Store repeated external call results in locals                                        |
| Modifier helpers     | Call a private function from a modifier to avoid duplicating its body in bytecode     |
| `payable` admin fns  | Saves a small `msg.value` check but can trap ETH; use only when the trade-off is fine |

## Loops

Since solc 0.8.22, the compiler makes the increment unchecked for loops of the form `for (uint256 i; i < n; ++i)` when
the body does not modify `i`, so a manual `unchecked { ++i; }` is unnecessary.

- Cache a storage array's length before the loop; `calldata` and `memory` lengths are cheap.
- Omit `= 0` when initializing counters.

## Compiler Settings

| Setting                  | Effect                                                                     |
| ------------------------ | -------------------------------------------------------------------------- |
| Low `optimizer_runs`     | Smaller bytecode and cheaper deployment                                    |
| High `optimizer_runs`    | Cheaper runtime for frequently called contracts, larger bytecode           |
| `via_ir = true`          | Cross-function optimizations; slower compilation and different bytecode    |
| `bytecode_hash = "none"` | Drops the metadata hash, making bytecode deterministic across environments |

## L2 Considerations

- On rollups, the fee includes an L1 data component. EIP-4844 blobs made it much cheaper, so measure on the target chain
  before trading computation for calldata.
- Read L1 fee data from chain precompiles only when needed: Arbitrum `ArbGasInfo` (`0x...6C`) and the OP Stack
  `GasPriceOracle` (`0x420000000000000000000000000000000000000F`).

## Libraries

[Solady](https://github.com/Vectorized/solady) is cheaper than OpenZeppelin for hot paths (`SafeTransferLib`,
`FixedPointMathLib`, `LibString`, `SSTORE2`). Prefer OpenZeppelin where gas is not critical and familiarity and audit
history matter more.

## Anti-Patterns

1. Optimizing prematurely at the expense of readability.
2. Using small integer types for standalone variables.
3. Optimizing view functions that are only called offchain.
4. Rewriting audited library code in assembly for marginal savings.
