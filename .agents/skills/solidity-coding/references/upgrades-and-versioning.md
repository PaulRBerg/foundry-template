# Upgrades and Versioning

Choose between immutable versioned deployments and upgradeable proxies, and change deployed systems without breaking
users or storage.

## Contents

- [Choose a Strategy](#choose-a-strategy)
- [Versioning](#versioning)
- [Upgradeable Contracts](#upgradeable-contracts)
- [Storage Layout](#storage-layout)
- [Migrating Between Immutable Versions](#migrating-between-immutable-versions)
- [Testing](#testing)

## Choose a Strategy

| Strategy                     | Use when                                                                 |
| ---------------------------- | ------------------------------------------------------------------------ |
| Immutable, parallel versions | Trust minimization matters; users can migrate at their own pace          |
| UUPS proxy                   | Upgrades are required; upgrade logic lives in the implementation (lean)  |
| Transparent proxy            | Upgrades are required; the admin must be separated from the user surface |

Immutable deployments keep old versions working: frontends and SDKs route each entity to the version that created it.

## Versioning

| Bump  | When                                                                 |
| ----- | -------------------------------------------------------------------- |
| Major | Removed or changed functions, events, errors, or storage layout      |
| Minor | Added functions, events, or errors (backward compatible)             |
| Patch | Bug fixes and gas optimizations without interface or storage changes |

Changing any function, event, or error signature changes its selector, so it is breaking for integrators and indexers.
Keep error signatures stable across versions when behavior is unchanged, and use a new error for new behavior.

Expose versions for interface detection with ERC-165:

```solidity
function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
    return interfaceId == type(ITokenVaultV2).interfaceId || super.supportsInterface(interfaceId);
}
```

## Upgradeable Contracts

- Inherit from `@openzeppelin/contracts-upgradeable` and replace constructors with `initialize` functions guarded by
  `initializer`; use `reinitializer(n)` for upgrade-time initialization.
- Call `_disableInitializers()` in the implementation's constructor so nobody can initialize it directly.
- Never use `selfdestruct` or `delegatecall` to arbitrary targets in an implementation.
- In OpenZeppelin 5, UUPS exposes only `upgradeToAndCall(newImplementation, data)`; pass empty `data` for a plain
  upgrade. Authorize it by overriding `_authorizeUpgrade`.
- In OpenZeppelin 5, `TransparentUpgradeableProxy` deploys its own `ProxyAdmin`; transfer that admin's ownership instead
  of deploying one.
- Consider the [OpenZeppelin Foundry Upgrades](https://github.com/OpenZeppelin/openzeppelin-foundry-upgrades) plugin to
  validate layouts during deploy and upgrade scripts. It requires `ffi` and build info.

## Storage Layout

1. Never remove, reorder, or retype existing variables; deprecate them in place.
2. Append new variables only at the end of their storage region.
3. Prefer ERC-7201 namespaced storage (the OpenZeppelin 5 default) over inherited `__gap` arrays; when a codebase
   already uses gaps, shrink the gap by exactly the slots each new variable consumes.
4. Compare layouts before every upgrade:

   ```bash
   forge inspect OldImpl storageLayout --json > old-layout.json
   forge inspect NewImpl storageLayout --json > new-layout.json
   diff old-layout.json new-layout.json
   ```

## Migrating Between Immutable Versions

| Pattern             | How                                                                                 |
| ------------------- | ----------------------------------------------------------------------------------- |
| Parallel deployment | Deploy V2 beside V1; route new activity to V2; V1 keeps working                     |
| Migration function  | V2 verifies ownership in V1, settles or cancels there, recreates the entity in V2   |
| Adapter             | Wrap V1 behind the V2 interface; revert with a specific error for unsupported calls |

A migration function must follow CEI across both versions, emit an event linking the old and new IDs, and never leave
value stranded in V1.

## Testing

- Fork-test upgrades and migrations against the deployed contracts at a pinned block.
- Assert that every stored field survives the upgrade or migration, and that entities left on the old version still
  work.
- Run the upgrade through the same script used in production.
