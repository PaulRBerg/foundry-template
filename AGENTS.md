# AGENTS.md

Foundry-based template for developing Solidity smart contracts. Dependencies are managed as Node.js packages (via Bun)
and remapped through `remappings.txt` instead of git submodules.

## Stack

- **Solidity** `0.8.29` (pragma `>=0.8.29`), EVM target `shanghai`, optimizer on (10,000 runs)
- **Foundry** (`forge`) — compile, test, fuzz, format, deploy
- **Forge Std** `v1.9.7` — test and scripting framework
- **OpenZeppelin Contracts** `5.3.0` — pre-installed contract library
- **Bun** — dependency manager (deps installed as Node.js packages, remapped in `remappings.txt`)
- **Prettier** `3.5` — formatter for JSON/Markdown/YAML
- **Solhint** `5.1` — Solidity linter

## Commands

### Forge

- `forge build` — compile contracts
- `forge build --sizes` — compile and print contract sizes (CI build step)
- `forge test` — run the test suite
- `forge test -vvv` — run tests with `console2` logs shown
- `forge test --gas-report` — run tests with a gas report
- `forge coverage` — generate a coverage report
- `forge fmt` — format Solidity
- `forge fmt --check` — check Solidity formatting without writing
- `forge clean` — delete `out/` and `cache/`
- `forge config` — print the resolved Foundry config
- `forge script script/Deploy.s.sol --broadcast --fork-url http://localhost:8545` — deploy `Foo` to a local node
  (requires `MNEMONIC` or `ETH_FROM`)
- `forge script script/DeployBrowser.s.sol --broadcast --fork-url http://localhost:8545 --browser` — deploy `Foo` to a
  local node (requires you to connect your wallet at localhost:9545)

### Bun scripts (`package.json`)

- `bun install` — install Node.js dependencies (add a matching entry to `remappings.txt` afterward)
- `bun run build` — `forge build`
- `bun run test` — `forge test`
- `bun run clean` — `rm -rf cache out`
- `bun run forge-check` — `forge fmt --check`
- `bun run forge-write` — `forge fmt`
- `bun run solhint-check` — Solhint over `{script,src,tests}/**/*.sol`
- `bun run prettier:check` — Prettier check over `**/*.{json,md,yml}`
- `bun run prettier:write` — Prettier write over `**/*.{json,md,yml}`
- `bun run full-check` — `forge-check` + `solhint-check` + `prettier:check` (the CI lint gate)
- `bun run full-write` — `forge-write` + `prettier:write` (auto-fix formatting)

## Project Structure

- `src/` — contracts under development (`Foo.sol` is the example)
- `tests/` — Foundry tests (configured via `test = "tests"` in `foundry.toml`)
- `script/` — deployment scripts; `Base.s.sol` defines `BaseScript` (broadcaster setup + `broadcast` modifier)
- `out/`, `cache/` — build artifacts and forge cache (gitignored)
- `node_modules/` — dependencies, mapped to import paths in `remappings.txt`
- Config: `foundry.toml`, `remappings.txt`, `.solhint.json`, `.prettierrc.yml`, `.editorconfig`, `.env.example`

## Code Style

- **Solidity** — formatted by `forge fmt` (`[fmt]` in `foundry.toml`): 120-char lines, 4-space indent, double quotes,
  bracket spacing, long int types (`uint256`, not `uint`), thousands underscores, multiline function headers, wrapped
  comments.
- **Solhint** (`.solhint.json`) — extends `solhint:recommended`; compiler `>=0.8.29`; max line length 120; explicit
  function visibility (constructors exempt); `one-contract-per-file`, `not-rely-on-time`, and `no-console` disabled.
- **Non-Solidity** — Prettier (`.prettierrc.yml`): `printWidth` 120, `trailingComma: all`, Markdown `proseWrap: always`.
- **EditorConfig** — LF endings, UTF-8, final newline, trim trailing whitespace; 2-space default, 4-space for `.sol`,
  1-space for `.tree`.
- Every file carries an SPDX header; pragma is `>=0.8.29` for contracts and `>=0.8.29 <0.9.0` for tests and scripts.

## Conventions

- **Test naming**: `test_*` (unit), `testFuzz_*` (fuzz), `testFork_*` (fork). Test contracts inherit `forge-std`'s
  `Test`; `setUp()` runs before each case.
- **Fuzz runs**: 1,000 under the `default` profile, 10,000 under `ci`.
- **Fork tests**: read `API_KEY_ALCHEMY` and silently pass when it is unset.
- **Scripts**: inherit `BaseScript`; the broadcaster is taken from `$ETH_FROM`, else derived from `$MNEMONIC` (falls
  back to a test mnemonic so scripts compile without env vars).
- **Adding dependencies**: `bun install <pkg>` (or `bun install github:user/repo`), then add `name=node_modules/name` to
  `remappings.txt`. Do not use git submodules.
- **Env vars** (see `.env.example`): `API_KEY_ALCHEMY`, `API_KEY_ETHERSCAN`, `API_KEY_INFURA`, `MNEMONIC`,
  `FOUNDRY_PROFILE`; `ETH_FROM` optionally overrides the broadcaster.
- **Profiles**: `default` and `ci` (10k fuzz runs, verbosity 4), selected via `FOUNDRY_PROFILE`.
- **RPC + Etherscan**: endpoints for mainnet, sepolia, arbitrum, avalanche, base, bnb_smart_chain, gnosis_chain,
  optimism, polygon, and localhost are defined in `foundry.toml`.

## Contribution Workflow

- Default branch: `main`.
- CI (`.github/workflows/ci.yml`) runs on every push/PR to `main` under the `ci` profile: lint (`bun run full-check`) →
  build (`forge build --sizes`) → test (`forge test`).
- Before opening a PR, run `bun run full-check` (or `bun run full-write` to auto-fix) and `forge test`.
