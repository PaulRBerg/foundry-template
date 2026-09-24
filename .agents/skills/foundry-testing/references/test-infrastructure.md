# Test Infrastructure

Shared scaffolding for suites that outgrow a single test file. Build only the pieces the suite needs.

## Contents

- [Layout](#layout)
- [Base Test](#base-test)
- [Users](#users)
- [Constants and Defaults](#constants-and-defaults)
- [Modifiers](#modifiers)
- [Fuzzers](#fuzzers)
- [Mocks](#mocks)
- [Integration Base and Revert Helpers](#integration-base-and-revert-helpers)

## Layout

```
tests/
├── Base.t.sol              # Deploys contracts, creates users, sets approvals
├── integration/
│   ├── Integration.t.sol   # Creates default entities and revert helpers
│   ├── concrete/           # BTT trees and tests, one directory per function
│   └── fuzz/
├── fork/
├── invariant/
│   ├── handlers/
│   └── stores/
├── mocks/                  # One mock per scenario
└── utils/                  # Constants, Defaults, Modifiers, Fuzzers, Assertions
```

## Base Test

Set up in this order:

1. Call the parent `setUp`.
2. Deploy tokens, mocks, and helpers.
3. Deploy and configure the defaults contract.
4. Deploy the contracts under test.
5. Create users, fund them, and approve the contracts under test.
6. Grant roles and permissions.
7. Label contracts with `vm.label`.
8. Set the default caller and warp to a realistic time.

## Users

Keep users in a struct with fixed roles:

| User         | Role                                            |
| ------------ | ----------------------------------------------- |
| `admin`      | Holds privileged roles                          |
| `alice`      | Generic third party                             |
| `eve`        | Malicious actor for unauthorized calls          |
| `operator`   | Approved operator for permission tests          |
| Domain roles | E.g. `sender` and `recipient` for the main flow |

## Constants and Defaults

Name constants by kind:

| Pattern       | Use                         | Example             |
| ------------- | --------------------------- | ------------------- |
| `*_TIME`      | Absolute timestamps         | `START_TIME`        |
| `*_DURATION`  | Relative durations          | `CLIFF_DURATION`    |
| `*_AMOUNT`    | Token amounts (18 decimals) | `DEPOSIT_AMOUNT`    |
| `*_AMOUNT_6D` | Token amounts (6 decimals)  | `DEPOSIT_AMOUNT_6D` |
| `WARP_*`      | Time-warp targets           | `WARP_26_PERCENT`   |
| `*_COUNT`     | Counts and sizes            | `MAX_COUNT`         |

A `Defaults` contract returns ready-made parameter structs built from constants, users, and tokens set during `setUp`,
so tests never assemble default parameters by hand.

## Modifiers

Centralize BTT modifiers in one `Modifiers` contract:

- Empty modifiers document a tree path.
- Setup modifiers change state, such as warping time or switching the caller.
- Parameterized modifiers take arguments for flexible setup.

Switch callers with a `setMsgSender` helper instead of scattered `vm.prank` calls.

## Fuzzers

- Write typed bound helpers, such as `boundUint128` and `boundUint40`, that wrap `_bound` and cast.
- Bound in dependency order: independent parameters first.
- Fuzz arrays so that ordered fields stay ordered, e.g. strictly increasing timestamps.
- Keep required non-zero fields non-zero, e.g. the first amount in an array.

## Mocks

Place mocks in `tests/mocks/`, one per scenario, named by behavior:

| Suffix                  | Behavior                     |
| ----------------------- | ---------------------------- |
| `*Good`                 | Happy path                   |
| `*Reverting`            | Reverts                      |
| `*InvalidSelector`      | Returns the wrong selector   |
| `*Reentrant`            | Reenters the caller          |
| `*InterfaceIDIncorrect` | Reports the wrong ERC-165 ID |
| `*InterfaceIDMissing`   | Does not implement ERC-165   |

## Integration Base and Revert Helpers

- Create default entities in `setUp` (e.g. `initializeDefaultEntities()`) and store their IDs in a struct.
- Reserve a sentinel ID that is never created for null-entity tests (e.g. `nullId = 1729`).
- Add helpers for repeated guard tests, such as `expectRevert_DelegateCall(callData)` and `expectRevert_Null(callData)`,
  plus custom `assertEq` overloads for project structs.
