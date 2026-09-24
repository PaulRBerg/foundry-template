# Gas Benchmarking

Measure gas with Forge's built-in tools and compare against a committed baseline.

## Contents

- [Snapshots](#snapshots)
- [Gas Reports](#gas-reports)
- [Section Snapshots](#section-snapshots)
- [Workflow](#workflow)
- [Reference Costs](#reference-costs)
- [Best Practices](#best-practices)

## Snapshots

```bash
forge snapshot                        # Write .gas-snapshot
forge snapshot --snap <file>          # Write to another file
forge snapshot --diff [<file>]        # Compare against a baseline
forge snapshot --check [<file>]       # Fail if gas differs from the baseline
FOUNDRY_PROFILE=<prod-profile> forge snapshot --snap .gas-snapshot-<profile>
```

Output: `test_Withdraw() (gas: 42156)` for concrete tests; `testFuzz_Withdraw(uint128) (runs: 256, μ: 45123, ~: 44892)`
for fuzz tests, where `μ` is the mean and `~` the median.

## Gas Reports

```bash
forge test --gas-report                            # Per-function min, avg, median, max, calls
forge test --gas-report --match-contract Vault     # Narrow the report
forge test --gas-report --json                     # Machine-readable output
```

`gas_reports = ["*"]` in `foundry.toml` selects which contracts appear. Add `--isolate` to run each top-level call as a
separate transaction, which makes per-call costs (cold access, refunds) match production.

## Section Snapshots

Record gas for exact code sections; Forge writes results to `snapshots/<ContractName>.json`, which can be committed and
diffed:

```solidity
vm.startSnapshotGas("withdraw");
vault.withdraw(id, amount);
uint256 gasUsed = vm.stopSnapshotGas();

vault.deposit(amount);
vm.snapshotGasLastCall("deposit");
```

For ad-hoc measurement, subtract `gasleft()` around the call, log it with `console2.log`, and optionally
`assertLt(gasUsed, BUDGET, "gas budget")`.

## Workflow

1. Capture a baseline: `forge snapshot --snap .gas-snapshot-before`.
2. Make the change.
3. Compare: `forge snapshot --diff .gas-snapshot-before`.
4. Report material changes in a table:

   ```markdown
   | Function | Before | After  | Diff  |
   | -------- | ------ | ------ | ----- |
   | withdraw | 34,567 | 32,100 | -7.1% |
   ```

In CI, `forge snapshot --check` fails on any gas change; run it as a warning or regenerate the snapshot in the same
commit as the change.

## Reference Costs

| Operation                    | Approximate gas |
| ---------------------------- | --------------- |
| `SSTORE` cold, 0 → non-0     | 22,100          |
| `SSTORE` cold, non-0 → non-0 | 5,000           |
| `SSTORE` warm, non-0 → non-0 | 2,900           |
| `SLOAD` cold                 | 2,100           |
| `SLOAD` warm                 | 100             |
| `TSTORE` / `TLOAD`           | 100             |
| `LOG` base / per topic       | 375 / 375       |
| ERC-20 transfer              | ~30,000–60,000  |

Opcode details: [evm.codes](https://www.evm.codes/). Profile production transactions with Tenderly or Phalcon.

## Best Practices

1. Commit the baseline snapshot to track history.
2. Benchmark with the production optimizer profile.
3. Use concrete tests for stable numbers; fuzz results vary with inputs.
4. Keep dedicated gas tests (e.g. `tests/gas/`) apart from functional tests.
