# Branching Tree Technique (BTT)

Specify concrete tests as bulloak `.tree` files, scaffold them into Solidity, and keep both in sync. Full bulloak
documentation: <https://github.com/alexfertel/bulloak/blob/main/README.md>.

## Contents

- [Files and Names](#files-and-names)
- [Tree Syntax](#tree-syntax)
- [Writing Good Trees](#writing-good-trees)
- [Implementing Tests](#implementing-tests)
- [Examples](#examples)
- [Commands](#commands)

## Files and Names

1. Put each function's tree in a kebab-case directory: `createPosition` lives in `create-position/`. Group by contract
   one level up when a suite covers several contracts, e.g. `tests/integration/concrete/vault/create-position/`.
2. Name the tree `{functionName}.tree`; bulloak writes `{functionName}.t.sol` beside it.
3. For a single tree, the root is the test contract name: `{FunctionName}_Integration_Concrete_Test`.
4. For several functions in one file, make each root `Contract::function`, all sharing the same contract name, e.g.
   `Foo::hashPair` and `Foo::min`. Bulloak prefixes the generated tests with the function name.

## Tree Syntax

```
CreatePosition_Integration_Concrete_Test
├── when delegate call
│  └── it should revert
└── when no delegate call
   ├── when amount zero
   │  └── it should revert
   └── when amount not zero
      ├── it should create the position
      └── it should emit {CreatePosition} event
```

| Keyword | Meaning                                           |
| ------- | ------------------------------------------------- |
| `when`  | Condition on input, caller, or time               |
| `given` | Precondition on contract state                    |
| `it`    | Action to assert (leaf); its children describe it |

- `when` and `given` are interchangeable to bulloak; a condition with nested conditions becomes a modifier.
- Draw branches with `├──` and `└──`, and continue parents with `│`. Child symbols align with the tail of the parent's
  connector: indent by 3 spaces, not 4.
- Omit trailing periods; `--format-descriptions` (`-F`) capitalizes and punctuates the generated comments.
- Wrap event names in braces: `it should emit {Transfer} and {MetadataUpdate} events`.

## Writing Good Trees

1. **Order guards first**, matching the implementation's check order: delegate call, existence (`given null`), state,
   caller, input validation, then business logic.
2. **Use short, consistent terms**: `given null` / `given not null`, `when caller {role}`, `when amount {condition}`.
3. **Group related conditions** under a shared parent:

   ```
   └── when withdrawal address not zero
      ├── when withdrawal address not owner
      │  ├── when caller sender
      │  ├── when caller unknown
      │  └── when caller recipient
      └── when withdrawal address owner
         └── ...
   ```

4. **Enumerate every side effect** in the happy-path leaf:

   ```
   └── it should make the withdrawal
      ├── it should reduce the position balance by the withdrawn amount
      ├── it should update the position state
      └── it should emit {Transfer}, {Withdraw} and {MetadataUpdate} events
   ```

## Implementing Tests

| Generated pattern             | Meaning                   |
| ----------------------------- | ------------------------- |
| `test_RevertWhen_{Condition}` | Reverts on input          |
| `test_RevertGiven_{State}`    | Reverts on state          |
| `test_When{Condition}`        | Success under a condition |
| `test_Given{State}`           | Success under a state     |

1. Keep the generated leaf comments (`// It should revert.`) as the first lines of each test.
2. Stack the path's modifiers on each test. Modifiers are often empty and only document the path; ones that change state
   (warps, callers) belong in a shared modifiers contract when you scaffold with `-m`.
3. Never add a modifier matching the test's own name; the name already encodes that condition:

   ```solidity
   // Wrong: whenWithdrawAmountNotZero duplicates the test name.
   function test_WhenWithdrawAmountNotZero() external whenWithdrawalAddressNotZero whenWithdrawAmountNotZero { }

   // Correct.
   function test_WhenWithdrawAmountNotZero() external whenWithdrawalAddressNotZero { }
   ```

4. Use shared revert helpers for repeated guard branches, such as `expectRevert_DelegateCall(callData)`.

## Examples

### Flat Tree

```
Sum_Integration_Concrete_Test
├── when a is zero
│  └── it should return b
└── when b is zero
   └── it should return a
```

Generates `test_WhenAIsZero()` and `test_WhenBIsZero()`, implemented as:

```solidity
function test_WhenAIsZero() external view {
    // It should return b.
    assertEq(math.sum(0, 5), 5, "sum");
}
```

### Nested Branches

```
Clamp_Integration_Concrete_Test
├── when a is zero
│  └── it should revert
└── when a is not zero
   ├── when a not exceed 10
   │  └── it should return a
   └── when a exceeds 10
      └── it should return 10
```

Generates `test_RevertWhen_AIsZero()`, plus `test_WhenANotExceed10()` and `test_WhenAExceeds10()`, both with the
`whenAIsNotZero` modifier.

### Several Functions in One File

```
Foo::hashPair
├── when a is zero
│  └── it should revert
└── when a is not zero
   └── it should hash

Foo::min
└── when equal
   └── it should return a
```

Generates contract `Foo` with `test_HashPair_RevertWhen_AIsZero()`, `test_HashPair_WhenAIsNotZero()`, and
`test_Min_WhenEqual()`.

### Duplicate Branch Names

```
Pick_Integration_Concrete_Test
├── when a is zero
│  └── when b is zero
│     └── it should return 0
└── when a is not zero
   └── when b is zero
      └── it should return 1
```

Bulloak disambiguates the second test by appending its parent: `test_WhenBIsZero()` and
`test_WhenBIsZero_WhenAIsNotZero()`.

## Commands

| Command                                                       | Effect                                                                |
| ------------------------------------------------------------- | --------------------------------------------------------------------- |
| `bulloak scaffold -w -F -s '<pragma>' <tree>`                 | Write a new `.t.sol`; skips existing files                            |
| `bulloak scaffold ... -m <tree>`                              | Reference modifiers without emitting them (shared modifiers contract) |
| `bulloak scaffold -wf ... <tree>`                             | Overwrite an existing `.t.sol`, discarding implemented bodies         |
| `bulloak check [-m] [--format-descriptions] <trees...>`       | Verify that tests match the trees                                     |
| `bulloak check --fix [-m] [--format-descriptions] <trees...>` | Insert missing tests and modifiers in place                           |

- `-s` sets the pragma, which otherwise defaults to `0.8.0`; pass the project's test pragma, e.g.
  `-s '>=0.8.29 <0.9.0'`.
- Pass `check` the same `-m` and `--format-descriptions` flags used to scaffold; `check` rejects the `-F` short form
  that `scaffold` accepts. Without `--format-descriptions`, `--fix` writes lowercase comments without periods.
- `--fix` does not format its insertions; run `forge fmt` afterwards. If it crashes (bulloak 0.9 can panic with `-m` on
  nested trees), add the missing functions by hand from the warnings.
- Pass multiple trees or a glob such as `tests/**/*.tree` to check a whole suite.
