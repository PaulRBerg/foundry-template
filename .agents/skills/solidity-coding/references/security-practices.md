# Security Practices

Security rules for Solidity contracts. CEI and `SafeERC20` basics live in `SKILL.md`.

## Contents

- [Access Control](#access-control)
- [Reentrancy](#reentrancy)
- [Delegate Calls](#delegate-calls)
- [Arithmetic](#arithmetic)
- [Input Validation](#input-validation)
- [External Calls and Hooks](#external-calls-and-hooks)
- [Token Integrations](#token-integrations)
- [Signatures](#signatures)
- [Oracles](#oracles)
- [State Transitions](#state-transitions)
- [Account Abstraction (EIP-7702, ERC-4337)](#account-abstraction-eip-7702-erc-4337)

## Access Control

- Use two-step transfers for critical roles (`Ownable2Step`) and role-based access (`AccessControl`) when several
  privileged actors exist.
- Grant the least privilege each role needs, and emit an event for every privileged change.
- Never gate logic on `tx.origin`.

## Reentrancy

- CEI is the first defense. Add a guard when a function makes several external calls or shares state with other entry
  points: OpenZeppelin `ReentrancyGuard`, or `ReentrancyGuardTransient` on Cancun or later.
- Consider read-only reentrancy: view functions that other protocols read (prices, balances) can expose inconsistent
  state mid-call.

## Delegate Calls

Contracts that must not run in another contract's context can reject delegate calls by comparing `address(this)` with an
immutable set in the constructor:

```solidity
address private immutable ORIGINAL = address(this);

modifier noDelegateCall() {
    _preventDelegateCall();
    _;
}

function _preventDelegateCall() private view {
    if (address(this) != ORIGINAL) revert Errors.DelegateCall();
}
```

## Arithmetic

- Use `unchecked` only when overflow is provably impossible: incrementing counters, subtracting a previously added
  amount, or a difference whose minuend is guaranteed to be at least the subtrahend.
- Multiply before dividing; use `Math.mulDiv` for full-precision `a * b / c`.
- Round in the protocol's favor: down on amounts paid out, up on amounts owed.
- Prefer `>=` over `==` for depletion or completion checks to tolerate unforeseen state.

## Input Validation

- Centralize repeated checks in modifiers or private functions (`notNull(id)`, `notZero(amount)`).
- Reject the zero address where it would burn funds or lock a role.
- Bound amounts, durations, fees, and array lengths.

## External Calls and Hooks

- Require the admin to allowlist hook targets before calling them.
- Validate that a hook returns the expected selector and revert with a specific error otherwise.
- Call hooks after state changes.
- When calling untrusted targets with low-level calls, cap forwarded gas and copied return data to prevent griefing and
  return bombs.
- When accepting contract addresses, validate the expected interface via ERC-165 `supportsInterface` when the target
  implements it.

## Token Integrations

Decide which token behaviors the protocol supports and document the rest as unsupported:

| Behavior                     | Mitigation                                                   |
| ---------------------------- | ------------------------------------------------------------ |
| Missing boolean return       | `SafeERC20`                                                  |
| Approval race or USDT quirk  | `forceApprove`                                               |
| Fee-on-transfer              | Credit the balance delta, not the requested amount           |
| Rebasing                     | Track shares, or declare unsupported                         |
| Blocklists and pauses (USDC) | Avoid push payments that can brick shared flows; prefer pull |
| Decimals other than 18       | Read `decimals()`; never assume 18                           |
| Transfer hooks (ERC-777)     | CEI plus a reentrancy guard                                  |

## Signatures

- Sign typed data with EIP-712 domains that include `chainId` and the verifying contract.
- Include a nonce and a deadline; consume the nonce before external calls.
- Recover with OpenZeppelin `ECDSA` (rejects malleable signatures) and support contract signers via `SignatureChecker`
  (ERC-1271).

## Oracles

- Reject stale prices using the feed's update timestamp and heartbeat.
- Reject non-positive answers and normalize feed decimals.
- On L2s, check the sequencer uptime feed before trusting prices.

## State Transitions

1. Mark irreversible changes explicitly, e.g. `isCancelable = false`.
2. Update related state atomically in the same function.
3. Document the invariants that must hold across transitions, and test them.

## Account Abstraction (EIP-7702, ERC-4337)

Since EIP-7702, an EOA can delegate to contract code, so "caller is an EOA" is no longer a security property.

| Risk                               | Mitigation                                              |
| ---------------------------------- | ------------------------------------------------------- |
| `msg.sender == tx.origin` checks   | Remove them; rely on signatures or access control       |
| `extcodesize == 0` as an EOA check | Remove it; delegated EOAs have code                     |
| Delegated EOAs receiving callbacks | Treat every recipient as a potential contract with code |
| Smart-account signers              | Verify via ERC-1271 `isValidSignature`                  |

For upgradeable contracts, read `upgrades-and-versioning.md`.
