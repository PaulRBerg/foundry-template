# AGENTS.md

Foundry-based template for developing Solidity smart contracts. Dependencies are managed as Node.js packages (via Bun)
and remapped through `remappings.txt` instead of git submodules.

## Toolchain

- `solc` is pinned to `0.8.29` (`auto_detect_solc = false`) with EVM target `shanghai`: Cancun opcodes such as transient
  storage and `mcopy` are unavailable.
- Pinned versions live in `package.json` (Forge Std, OpenZeppelin Contracts, Prettier, Solhint) and `foundry.toml`
  (compiler, optimizer, fuzz, formatter).

## Commands

- `bun install` — install dependencies; required before building because `forge-std` lives in `node_modules`.
- `bun run full-check` — the CI lint gate: `forge fmt --check`, Solhint over `{script,src,tests}/**/*.sol`, and Prettier
  over `**/*.{json,md,yml}`. `bun run full-write` auto-fixes formatting (Solhint findings need manual fixes).
- `forge build --sizes` — the CI build step.
- `FOUNDRY_PROFILE=ci forge test` — reproduce CI's 10,000 fuzz runs and verbosity 4; plain `forge test` uses 1,000.
- `forge script script/Deploy.s.sol --broadcast --fork-url http://localhost:8545` — deploy `Foo` to a local node with
  the `BaseScript` broadcaster.
- `forge script script/DeployBrowser.s.sol --broadcast --fork-url http://localhost:8545 --browser` — deploy through a
  browser wallet connected at `localhost:9545`.

## Code Style

- `forge fmt` (`[fmt]` in `foundry.toml`), Solhint (`.solhint.json`), Prettier (`.prettierrc.yml`), and `.editorconfig`
  own formatting and lint rules; run the tools instead of hand-formatting.
- Every Solidity file carries an SPDX header; pragma is `>=0.8.29` for contracts and `>=0.8.29 <0.9.0` for tests and
  scripts.
- Import Forge Std through its `src/` directory (`forge-std/src/Test.sol`), because the remapping points at the package
  root.

## Conventions

- **Tests** live in `tests/` (not Foundry's default `test/`). Name cases `test_*` (unit), `testFuzz_*` (fuzz), and
  `testFork_*` (fork); inherit Forge Std's `Test`.
- **Block timestamp**: the `default` profile pins `block.timestamp` to `1_738_368_000` (Feb 1, 2025); do not assume
  wall-clock time.
- **Fork tests**: read `API_KEY_ALCHEMY` (used by the `mainnet` RPC alias) and silently pass when it is unset. CI
  provides the key and a weekly-rotating `FOUNDRY_FUZZ_SEED` to limit RPC usage.
- **Scripts**: inherit `BaseScript` and use its `broadcast` modifier. The broadcaster is `$ETH_FROM`, else derived from
  `$MNEMONIC`, else a test mnemonic so scripts compile without env vars. Browser-wallet scripts (`DeployBrowser.s.sol`)
  inherit Forge Std's `Script` directly and call `vm.startBroadcast()` without an address.
- **Adding dependencies**: `bun install <pkg>` (or `bun install github:user/repo#tag`), then add
  `name/=node_modules/name/` to `remappings.txt`. Do not use git submodules.
- **Env vars** (see `.env.example`): `API_KEY_ALCHEMY`, `API_KEY_ETHERSCAN` (mainnet verification only), `MNEMONIC`,
  `FOUNDRY_PROFILE`; `ETH_FROM` optionally overrides the broadcaster. `ROUTEMESH_API_KEY` is a placeholder no config
  reads.

## Agent Skills

Project skills live in `.agents/skills/`, with relative Claude Code symlinks in `.claude/skills/`:

- `solidity-coding` — contract conventions, NatSpec, errors, security, gas, events, and upgrades.
- `foundry-testing` — concrete, fuzz, fork, and invariant tests, bulloak BTT specs, scripts, and gas benchmarking.

Update the skills whenever this file's toolchain, directory, or naming conventions change.

## Template Bootstrap

`.github/workflows/use-template.yml` runs on the first push to a repository created from this template: it runs
`.github/scripts/rename.sh`, deletes `FUNDING.yml`, the script, and itself, then amends and force-pushes. The script
rewrites `name`, `description`, and `author` in `package.json` with `jq`, and rewrites `PaulRBerg/foundry-template` only
on README.md lines matching `gitpod` or `gha`. Keep those fields and badge reference lines intact when editing either
file.

## Contribution Workflow

- Default branch: `main`.
- CI (`.github/workflows/ci.yml`) runs on pushes to `main`, all pull requests, and manual dispatch under the `ci`
  profile. `lint` (`bun run full-check`) and `build` (`forge build --sizes`) run in parallel; `test` (`forge test`) runs
  after both pass.
- Before opening a PR, run `bun run full-check` and `forge test`.
