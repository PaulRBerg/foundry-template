---
name: solidity-coding
description:
  Write and modify production Solidity contracts in Foundry projects. Use when writing a contract, implementing a
  function, adding errors, events, or structs, designing contract architecture, optimizing gas, hardening security,
  planning upgrades, or working in src/.
---

# Solidity Coding

Write Solidity that compiles under the project's pinned toolchain, follows its conventions, and passes its lint gate.

## Ground Rules

- Read `foundry.toml`, `remappings.txt`, and the nearest `AGENTS.md` before writing code. The pinned `solc` and
  `evm_version` decide which features exist: transient storage and `mcopy` need `evm_version = "cancun"` or later, and
  `transient` state variables also need solc 0.8.28 or later.
- Treat the defaults below as fallbacks. Existing code and repository instructions win; match the surrounding file when
  they disagree.
- Let `forge fmt`, Solhint, and Prettier own formatting. Run them instead of hand-formatting.

## References

- [references/security-practices.md](references/security-practices.md): read when a change touches access control,
  external calls, hooks, `unchecked` arithmetic, token integrations, signatures, oracles, or account abstraction.
- [references/gas-optimization.md](references/gas-optimization.md): read when optimizing gas, packing storage, using
  transient storage, or choosing between OpenZeppelin and Solady.
- [references/event-design.md](references/event-design.md): read when adding or changing events, especially ones that
  indexers consume.
- [references/upgrades-and-versioning.md](references/upgrades-and-versioning.md): read when writing upgradeable
  contracts, changing storage layout, or shipping a new version beside a deployed one.
- [references/onchain-metadata.md](references/onchain-metadata.md): read when implementing `tokenURI` or onchain
  JSON/SVG metadata.

## Conventions

### Naming

| Element                                 | Convention                 | Example                |
| --------------------------------------- | -------------------------- | ---------------------- |
| Contract, library, struct, enum, event  | PascalCase                 | `TokenVault`           |
| Interface                               | `I` + PascalCase           | `ITokenVault`          |
| Function, variable, parameter           | camelCase                  | `withdrawableAmountOf` |
| Constant, immutable                     | SCREAMING_SNAKE_CASE       | `MAX_FEE`              |
| Internal or private function, state var | Leading underscore         | `_balances`, `_update` |
| Custom error                            | `{Contract}_{Description}` | `TokenVault_Overdraw`  |
| Type namespace library                  | Domain name                | `Vault.Position`       |

### Imports

1. Use named imports only: `import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";`.
2. Put remapped package imports first, then a blank line, then relative local imports.
3. Sort each group alphabetically by path.

### Layout

Grow a larger project into this shape; keep a small one flat until a directory has content:

```
src/
├── TokenVault.sol    # Entry-point contracts
├── abstracts/        # Base contracts in the inheritance chain (state, shared logic)
├── interfaces/       # Public APIs; the full NatSpec lives here
├── libraries/        # Errors.sol, math and helper libraries
└── types/            # Structs, enums, and namespace libraries (e.g. DataTypes.sol)
```

### Inheritance

List parents alphabetically when C3 linearization allows it. When one parent derives from another, list the most
base-like first, or the compiler rejects the linearization.

### Sections and Ordering

Group contract members under section headers, omitting empty sections, in this order:

1. STATE VARIABLES
2. CONSTRUCTOR
3. MODIFIERS
4. USER-FACING READ-ONLY FUNCTIONS
5. USER-FACING STATE-CHANGING FUNCTIONS
6. INTERNAL READ-ONLY FUNCTIONS
7. INTERNAL STATE-CHANGING FUNCTIONS
8. PRIVATE READ-ONLY FUNCTIONS
9. PRIVATE STATE-CHANGING FUNCTIONS

Headers use this shape; the [`headers`](https://github.com/transmissions11/headers) CLI generates them when installed
(`headers "CONSTRUCTOR"`):

```solidity
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/
```

Order signature keywords as visibility, mutability, `virtual`, `override`, then custom modifiers, with guards such as
`nonReentrant` first.

### NatSpec

Put full NatSpec in the interface and use `/// @inheritdoc IContract` in the implementation. Document every public and
external function in this order, separating blocks with `///` lines:

```solidity
    /// @notice Withdraws `amount` from the position to `to`.
    ///
    /// @dev Emits a {Withdraw} event.
    ///
    /// Notes:
    /// - Anyone may call this function, but only the position owner receives the tokens.
    ///
    /// Requirements:
    /// - `amount` must not exceed the withdrawable amount.
    ///
    /// @param positionId The ID of the position to withdraw from.
    /// @param to The address receiving the tokens.
    /// @param amount The amount to withdraw, denoted in units of the token's decimals.
    /// @return withdrawnAmount The amount withdrawn.
```

Document structs with `@param` for each field and errors with `/// @notice Thrown when ...`.

### Errors

- Use custom errors, never revert strings.
- Define one error per failure mode; never merge conditions that deserve different errors into one check.
- Include parameters that help debugging, such as the requested and the available value.
- Multi-contract projects keep errors in `src/libraries/Errors.sol` (`library Errors`), grouped under one section per
  contract, and revert with `revert Errors.TokenVault_Overdraw(...)`. Single-contract projects may declare errors in the
  interface.

```solidity
/// @notice Thrown when trying to withdraw more than the withdrawable amount.
error TokenVault_Overdraw(uint256 positionId, uint128 amount, uint128 withdrawableAmount);
```

### Checks-Effects-Interactions

1. **Checks**: validate inputs and state; revert on failure.
2. **Effects**: write all state before any external call.
3. **Interactions**: make external calls (token transfers, hooks) last.
4. **Protocol invariant** (optional): `assert` a post-interaction invariant only when it is cheap to verify (the FREI-PI
   pattern).

Emit events after the state changes they describe.

### Tokens and Low-Level Calls

- Move ERC-20 tokens through OpenZeppelin `SafeERC20` (`safeTransfer`, `safeTransferFrom`, `forceApprove`).
- Use low-level calls only for targets that may not implement the expected interface; check `success` and
  `returndata.length` before decoding.
- Prefer `memory` copies for repeated reads of a struct and `storage` references for writes.

### Types

Default to `uint256`. Use smaller types only where they pack into a shared slot, such as `uint128` amounts and `uint40`
timestamps. Standalone small types cost extra gas for masking.

## Common Tasks

- **Add a function**: declare it with full NatSpec in the interface, implement it with `@inheritdoc` in the matching
  section, apply guard modifiers, follow CEI, and emit an event for every state change.
- **Add an error**: follow [Errors](#errors) and add a test that expects its selector and arguments.
- **Add a struct**: define it under `types/` (or the interface for small projects), order fields to pack slots, and
  document each field.
- **Add an event**: read [references/event-design.md](references/event-design.md) first.

## Stack Too Deep

Bundle locals into a memory struct named `{FunctionName}Vars`, defined in `types/` when shared or next to the function
otherwise:

```solidity
/// @dev Needed to avoid Stack Too Deep.
struct TokenURIVars {
    address token;
    uint128 depositedAmount;
    string symbol;
}
```

Enabling `via_ir = true` also resolves most cases, but it changes the bytecode and slows compilation; make it a
deliberate project-wide choice, not a local fix.

## Contract Size

Deployed bytecode must stay under the EIP-170 limit of 24,576 bytes. Check with `forge build --sizes` under the
production profile. When a contract exceeds it:

1. Move logic into `external`/`public` library functions, which are called via `DELEGATECALL` instead of being inlined
   like `internal` ones; each call costs slightly more gas.
2. Split responsibilities across contracts, such as a separate descriptor or periphery contract.
3. Route repeated modifier bodies through private functions.
4. Remove dead code and lower `optimizer_runs` for rarely called contracts.

## Completion

Finish only when:

- `forge build` succeeds, plus `forge build --sizes` when the change could affect size.
- The repository's lint gate passes for touched files; in this template that is `forge fmt --check <files>` and
  `bun solhint <files>` (or `bun run full-check`).
- New behavior has tests, or the report names the missing coverage.

Report the exact commands and results, and any convention or checklist item left open.
