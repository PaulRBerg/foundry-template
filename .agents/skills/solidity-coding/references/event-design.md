# Event Design

Design events so indexers (The Graph, Ponder, Envio, custom pipelines) can rebuild state without extra RPC calls.

## Contents

- [Principles](#principles)
- [Indexed Parameters](#indexed-parameters)
- [Naming](#naming)
- [Parameters](#parameters)
- [Common Patterns](#common-patterns)
- [Gas](#gas)
- [Anti-Patterns](#anti-patterns)

## Principles

1. Emit an event for every state change, including admin and configuration changes.
2. Include every value an indexer needs, so it never calls the contract to reconstruct state.
3. Emit after the state change, and emit one event per item in batch operations.

```solidity
// Bad: the indexer must call the contract for details.
event Deposit(uint256 indexed positionId);

// Good: all queryable data is in the event.
event Deposit(
    uint256 indexed positionId,
    address indexed owner,
    IERC20 indexed token,
    uint128 amount,
    uint40 unlockTime
);
```

## Indexed Parameters

Non-anonymous events allow three indexed parameters (topic 0 is the event selector); anonymous events allow four.

- Index filterable identifiers: entity IDs and addresses such as owner, recipient, and token.
- Do not index amounts, timestamps, or booleans; they are rarely filtered and not selective.
- Indexed `string`, `bytes`, arrays, and structs are stored as their keccak256 hash, so the original value is
  unrecoverable from the log. Leave them unindexed, or emit both forms.

## Naming

| Pattern                 | Example                      | Use for                   |
| ----------------------- | ---------------------------- | ------------------------- |
| `{Action}` or verb form | `Deposit`, `Withdraw`        | Primary user actions      |
| `{Action}{Entity}`      | `CreatePosition`             | Actions on a named entity |
| `{Entity}{Action}ed`    | `PositionClosed`             | Status changes            |
| `{Entity}{Property}Set` | `PositionTransferabilitySet` | Property updates          |
| `Set{Property}`         | `SetFee`                     | Admin configuration       |

Pick one pattern per project and apply it consistently.

## Parameters

| Parameter          | Purpose                  | Indexed                     |
| ------------------ | ------------------------ | --------------------------- |
| Entity ID          | Identify the entity      | Yes                         |
| Actor              | Who triggered the action | Yes, if several are allowed |
| Relevant addresses | Token, recipient         | Yes, for the primary ones   |
| Amounts            | Values changed           | No                          |
| Timestamps         | When relevant            | No                          |

- Include derived values when they save indexers a computation, such as the remaining balance after a withdrawal.
- Prefer flat parameters over structs, which complicate ABI decoding in indexers.
- Include a type or model discriminator when one event covers several variants, so indexers can branch without
  re-indexing.

## Common Patterns

Status changes carry both states:

```solidity
event StatusChanged(uint256 indexed positionId, Status oldStatus, Status newStatus);
```

NFT metadata changes follow ERC-4906:

```solidity
event MetadataUpdate(uint256 _tokenId);
event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
```

## Gas

A `LOG` costs 375 gas, plus 375 per topic and 8 per byte of data, plus memory expansion. When one action carries a lot
of rarely queried data, split it into a primary event and a details event keyed by the same ID.

## Anti-Patterns

| Anti-pattern        | Problem                        | Fix                              |
| ------------------- | ------------------------------ | -------------------------------- |
| Missing events      | Indexers cannot track state    | Emit for every state change      |
| Insufficient data   | Indexers need RPC calls        | Include all relevant values      |
| Over-indexing       | Wasted gas, useless filters    | Index only filterable fields     |
| Indexed strings     | Value lost to hashing          | Leave dynamic types unindexed    |
| Struct parameters   | Harder decoding                | Use flat parameters              |
| Inconsistent naming | Confusing schemas and handlers | Apply one naming pattern overall |
