# Cheatcodes and Forge Std Helpers

The authoritative list is `src/Vm.sol` in the installed Forge Std (`node_modules/forge-std/src/Vm.sol` in this template,
`lib/forge-std/src/Vm.sol` in submodule setups). Read it when a cheatcode's signature or deprecation status matters; the
[Foundry cheatcode docs](https://getfoundry.sh/reference/cheatcodes/overview) explain behavior.

## Quick Reference

| Area         | Cheatcode or helper                                                            | Effect                                          |
| ------------ | ------------------------------------------------------------------------------ | ----------------------------------------------- |
| Time         | `vm.warp(ts)`, `skip(s)`, `rewind(s)`                                          | Set or move `block.timestamp`                   |
| Blocks       | `vm.roll(n)`                                                                   | Set `block.number`                              |
| Caller       | `vm.prank(a)`, `vm.startPrank(a)`, `vm.stopPrank()`                            | Set `msg.sender` for one or all following calls |
| Reverts      | `vm.expectRevert(bytes)`, `vm.expectRevert(selector)`                          | Expect the next call to revert                  |
| Events       | `vm.expectEmit({ emitter: a })` then `emit Event(...)`                         | Expect the next call to emit a matching event   |
| Calls        | `vm.expectCall(callee, data)`                                                  | Expect a call during the next action            |
| Mocks        | `vm.mockCall(callee, data, ret)`, `vm.clearMockedCalls()`                      | Stub return data                                |
| Balances     | `vm.deal(a, wei)`, `deal(token, a, amount)`                                    | Set ETH or ERC-20 balances                      |
| Storage      | `vm.store(target, slot, value)`, `vm.load(target, slot)`                       | Write or read raw slots                         |
| Addresses    | `makeAddr(name)`, `vm.label(a, name)`                                          | Create labeled addresses for readable traces    |
| Environment  | `vm.envOr(name, default)`                                                      | Read an env var with a fallback                 |
| Forks        | `vm.createSelectFork(alias, block)`, `vm.selectFork(id)`, `vm.rollFork(block)` | Create and switch forks                         |
| Fuzzing      | `bound(x, min, max)`, `vm.assume(cond)`                                        | Constrain inputs; prefer `bound`                |
| State        | `vm.snapshotState()`, `vm.revertToState(id)`                                   | Save and restore EVM state                      |
| Gas sections | `vm.startSnapshotGas(name)`, `vm.stopSnapshotGas()`                            | Record gas for a code section                   |

`vm.snapshot()` and `vm.revertTo()` are deprecated aliases of `vm.snapshotState()` and `vm.revertToState()`.

## Patterns

### Persistent Caller

```solidity
function setMsgSender(address sender) internal {
    vm.stopPrank();
    vm.startPrank(sender);
}
```

### Event Assertion

```solidity
vm.expectEmit({ emitter: address(vault) });
emit IVault.Deposit({ positionId: id, owner: alice, amount: amount });
vault.deposit(amount); // The action comes after the expectation.
```

### Revert Assertion

```solidity
vm.expectRevert(abi.encodeWithSelector(Errors.Vault_Overdraw.selector, id, amount, available));
vault.withdraw(id, amount);
```

`vm.expectRevert` applies to the next external call only, so compute arguments and prepare calldata before it.
