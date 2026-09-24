# Invariant Test Patterns

Stateful fuzzing: Foundry calls handler functions in random sequences and checks every `invariant_*` function after each
call.

## Contents

- [Architecture](#architecture)
- [Handlers](#handlers)
- [Stores](#stores)
- [Invariant Contract](#invariant-contract)
- [Invariant Categories](#invariant-categories)
- [Configuration](#configuration)

## Architecture

```
tests/invariant/
├── handlers/
│   ├── BaseHandler.sol     # Shared modifiers and call counters
│   └── VaultHandler.sol    # One handler per contract or actor set
├── stores/
│   └── Store.sol           # Ghost state for assertions
└── Invariant.t.sol
```

## Handlers

Handlers wrap protocol calls with bounded inputs so that most calls reach meaningful state.

```solidity
abstract contract BaseHandler is StdCheats, StdUtils {
    mapping(string func => uint256 calls) public calls;
    uint256 public totalCalls;

    modifier adjustTimestamp(uint256 timeJumpSeed) {
        skip(_bound(timeJumpSeed, 2 minutes, 40 days));
        _;
    }

    modifier instrument(string memory name) {
        calls[name]++;
        totalCalls++;
        _;
    }
}
```

```solidity
function withdraw(
    uint256 timeJumpSeed,
    uint256 indexSeed,
    uint128 amount
)
    external
    instrument("withdraw")
    adjustTimestamp(timeJumpSeed)
{
    uint256 count = store.idCount();
    if (count == 0) return; // Skip instead of reverting when preconditions fail.

    uint256 id = store.ids(_bound(indexSeed, 0, count - 1));
    uint128 withdrawable = vault.withdrawableAmountOf(id);
    if (withdrawable == 0) return;

    amount = uint128(_bound(amount, 1, withdrawable));
    vm.prank(store.owners(id));
    vault.withdraw(id, amount);
    store.recordWithdrawal(id, amount);
}
```

| Rule                                | Reason                                |
| ----------------------------------- | ------------------------------------- |
| Return early on unmet preconditions | Keeps runs from dying on reverts      |
| Bound every fuzzed input            | Reaches valid states                  |
| Instrument calls                    | Shows the call distribution           |
| Record ghost state after each call  | Gives invariants an independent truth |

## Stores

Stores hold ghost state that invariants compare against the protocol:

```solidity
contract Store {
    uint256[] public ids;
    mapping(uint256 id => address) public owners;
    mapping(uint256 id => uint256) public withdrawn;

    function idCount() external view returns (uint256) {
        return ids.length;
    }

    function pushId(uint256 id, address owner) external {
        ids.push(id);
        owners[id] = owner;
    }

    function recordWithdrawal(uint256 id, uint256 amount) external {
        withdrawn[id] += amount;
    }
}
```

Expose array lengths through a function: the public getter of an array returns one element and has no `.length`.

## Invariant Contract

```solidity
contract Invariant_Test is Base_Test {
    VaultHandler internal handler;
    Store internal store;

    function setUp() public override {
        Base_Test.setUp();
        store = new Store();
        handler = new VaultHandler(vault, store);

        targetContract(address(handler)); // Fuzz only the handler.
        excludeSender(address(handler));
        excludeSender(address(store));
        excludeSender(address(vault));
    }

    function invariant_WithdrawnLteDeposited() external view {
        uint256 count = store.idCount();
        for (uint256 i; i < count; ++i) {
            uint256 id = store.ids(i);
            assertLe(store.withdrawn(id), vault.depositedAmountOf(id), "withdrawn > deposited");
        }
    }
}
```

Use `targetSelector` to restrict which handler functions run, and `afterInvariant()` for end-of-run checks.

## Invariant Categories

| Category    | Example                                                |
| ----------- | ------------------------------------------------------ |
| Solvency    | Contract balance ≥ sum of liabilities                  |
| Accounting  | Aggregate amount == sum(deposits) - sum(withdrawals)   |
| Monotonic   | A withdrawn amount never decreases                     |
| Transitions | Only valid status transitions occur; terminal is final |
| Bounds      | deposited ≥ streamed ≥ withdrawn                       |
| Non-zero    | Required fields are never zero                         |

For transition invariants, store each entity's previous status, compare it with the current one, then update it.

## Configuration

```toml
[invariant]
  depth = 50
  fail_on_revert = false
  runs = 256
```

| Setting          | Meaning                                                               |
| ---------------- | --------------------------------------------------------------------- |
| `runs`           | Number of call sequences                                              |
| `depth`          | Calls per sequence                                                    |
| `fail_on_revert` | `true` fails on any handler revert; use it once handlers never revert |
