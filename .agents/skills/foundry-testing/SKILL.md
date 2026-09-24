---
name: foundry-testing
description:
  Write and debug Foundry tests and Solidity scripts. Use when writing unit, fuzz, fork, or invariant tests, writing
  bulloak BTT .tree specs (Branching Tree Technique), using cheatcodes, benchmarking gas, measuring coverage, writing
  deploy scripts, or working in tests/ or script/.
---

# Foundry Testing

Write Foundry tests and scripts that pass, pin down the specified behavior, and follow the project's conventions.

## Ground Rules

- Read `foundry.toml` (`test` and `script` directories, fuzz runs, profiles, `block_timestamp`), `remappings.txt`, the
  nearest `AGENTS.md`, and one or two neighboring tests before writing. Existing layout, base contracts, and helpers win
  over the defaults below.
- Import Forge Std through the project's remapping; in this template that is `forge-std/src/Test.sol`.
- Keep tests deterministic: derive times from `block.timestamp`, which this template pins in `foundry.toml`, and pin
  fork block numbers.

## References

- [references/btt.md](references/btt.md): read before writing or changing a `.tree` spec or a BTT-generated test.
- [references/cheat-codes.md](references/cheat-codes.md): read when using `vm` cheatcodes or Forge Std helpers beyond
  `prank`, `warp`, and `expectRevert`.
- [references/test-infrastructure.md](references/test-infrastructure.md): read when a suite outgrows one file and needs
  a shared base test, users, constants, defaults, modifiers, mocks, or revert helpers.
- [references/invariant-patterns.md](references/invariant-patterns.md): read when writing invariant tests, handlers, or
  stores.
- [references/gas-benchmarking.md](references/gas-benchmarking.md): read when measuring, snapshotting, or comparing gas.

## Test Types

| Type               | Function prefix                            | Location in larger suites     |
| ------------------ | ------------------------------------------ | ----------------------------- |
| Concrete (unit)    | `test_`                                    | `tests/integration/concrete/` |
| Fuzz               | `testFuzz_`                                | `tests/integration/fuzz/`     |
| Fork               | `testFork_` (or `testForkFuzz_` if fuzzed) | `tests/fork/`                 |
| Invariant          | `invariant_`                               | `tests/invariant/`            |
| Deployment scripts | `run`                                      | `script/*.s.sol`              |

Small projects keep one flat file per contract, such as `tests/Foo.t.sol`. Add the directory split when the suite grows.

## Writing Tests

1. Test one behavior per function. Name reverts `test_RevertWhen_{Condition}` (input) or `test_RevertGiven_{State}`
   (state), and successes `test_When{Condition}` or `test_Given{State}`.
2. Arrange shared state in `setUp` or modifiers; never rely on test execution order.
3. Set expectations before the call: `vm.expectRevert`, `vm.expectEmit`, and `vm.expectCall` precede the action.
4. Expect every event, with all parameters, in at least one test.
5. Expect custom errors with their arguments:
   `vm.expectRevert(abi.encodeWithSelector(Errors.TokenVault_Overdraw.selector, id, amount, available))`.
6. Assert state after the action, and give every assertion a description: `assertEq(actual, expected, "balance")`.
7. Create users with `makeAddr("alice")` and label deployed contracts with `vm.label` for readable traces.
8. Use named constants instead of hardcoded values, especially for parameters with validation constraints.

## BTT Specs

Specify concrete tests as [bulloak](https://github.com/alexfertel/bulloak) `.tree` files when the project uses the
Branching Tree Technique or the user asks for it. Install bulloak with `cargo install bulloak` if it is missing.

1. Write `{functionName}.tree` in a kebab-case directory, e.g. `tests/integration/concrete/create-position/`.
2. Scaffold a new test: `bulloak scaffold -w -F -s '<pragma>' <file.tree>`. Add `-m` (`--skip-modifiers`) when modifiers
   live in a shared contract. `-w` never overwrites an existing `.t.sol`; add `-f` only to deliberately replace one,
   which discards implemented bodies.
3. Add imports, inheritance, and setup, then implement each test body.
4. Verify alignment with `bulloak check <file.tree>`, passing the same `-m` and `-F` (`--format-descriptions`) flags
   used to scaffold. `bulloak check --fix` with those flags inserts missing tests; run `forge fmt` on the file and
   review the diff.

Tree syntax, naming rules, and examples are in [references/btt.md](references/btt.md).

## Fuzz Tests

1. Constrain inputs with `bound(x, min, max)` rather than `vm.assume`; each rejection wastes a run, and too many fail
   the test.
2. Bound independent parameters first, then dependent ones from the already-bound values.
3. Never hardcode a parameter that has validation constraints; bound it into the valid range.
4. Exclude special addresses with Forge Std helpers such as `assumeNotZeroAddress`, `assumeNotPrecompile`, and
   `assumeNotForgeAddress`.
5. Document the fuzzed scenario in the test's NatSpec.

```solidity
cliffDuration = bound(cliffDuration, 0, MAX_DURATION - 1);
totalDuration = bound(totalDuration, cliffDuration + 1, MAX_DURATION);
```

## Fork Tests

1. Fork through an RPC alias from `foundry.toml` at a pinned block:
   `vm.createSelectFork({ urlOrAlias: "mainnet", blockNumber: 21_000_000 })`. Pinned blocks are also cached locally.
2. Follow the project's policy for missing RPC keys; this template's fork tests return early when `API_KEY_ALCHEMY` is
   unset.
3. Fund users with `deal(address(token), user, amount)`, and pass `adjust = true` when the test depends on
   `totalSupply`.
4. Handle token quirks: `assumeNotBlacklisted(token, user)` for USDC and USDT, `forceApprove` for USDT, and balance
   deltas for fee-on-transfer tokens.

## Invariant Tests

Target handler contracts only, bound every input inside handlers, track ghost state in stores, and exclude protocol
contracts as senders. Read [references/invariant-patterns.md](references/invariant-patterns.md) before writing one.

## Scripts

1. Inherit the project's base script (this template's `BaseScript` in `script/Base.s.sol`), apply its `broadcast`
   modifier to `run`, and return the deployed contracts.
2. Take the broadcaster from `$ETH_FROM` or `$MNEMONIC`; never hardcode or log private keys.
3. Deploy deterministically with `new Foo{ salt: SALT }(...)` through Foundry's CREATE2 deployer. The address depends on
   the salt, the init code (including constructor arguments), and compiler settings such as `bytecode_hash`.
4. Read chain-dependent inputs from environment variables or per-chain config; never hardcode them.
5. Simulate without `--broadcast` first, then broadcast with `--rpc-url <alias> --broadcast`, adding `--verify` when
   explorer keys are configured.
6. Test a script by instantiating it in a test and asserting on the contracts `run` returns.

## Running and Debugging

```bash
forge test --match-path 'tests/integration/concrete/**'   # By path
forge test --match-contract Invariant_Test                 # By contract
forge test --match-test test_WhenCallerOwner -vvvv         # One test with traces
forge test --rerun                                         # Only the failures from the last run
forge test --match-test testFuzz_ --fuzz-runs 10000        # More fuzz runs
FOUNDRY_PROFILE=ci forge test                              # CI profile (this template: 10,000 fuzz runs)
forge test --debug --match-test test_Foo                   # Interactive debugger for one test
forge coverage --report lcov                               # Coverage; add --ir-minimum on Stack Too Deep
forge inspect <Contract> storageLayout                     # Storage layout
```

| Verbosity | Shows                                               |
| --------- | --------------------------------------------------- |
| `-vv`     | Logs for all tests                                  |
| `-vvv`    | Traces for failing tests                            |
| `-vvvv`   | Traces for all tests, setup traces for failures     |
| `-vvvvv`  | Traces and setup traces for all tests, with storage |

Debugging tips: log with `console2` (`forge-std/src/console2.sol`), isolate with `--match-test`, compare state with
`vm.snapshotState()` and `vm.revertToState(id)`, and check unexpected costs with `--gas-report`.

## Completion

Finish only when:

- The new or changed tests pass with a narrow `forge test --match-path <path>` or `--match-test <name>` run, repeated
  under the CI profile when fuzz or invariant tests changed.
- `bulloak check` passes for every changed `.tree` file.
- The repository's lint gate passes for touched files; in this template that is `forge fmt --check <files>` and
  `bun solhint <files>`.

Report the exact commands and results.
