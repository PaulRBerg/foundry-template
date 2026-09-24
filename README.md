# Foundry Template [![Open in Gitpod][gitpod-badge]][gitpod] [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gitpod]: https://gitpod.io/#https://github.com/PaulRBerg/foundry-template
[gitpod-badge]: https://img.shields.io/badge/Gitpod-Open%20in%20Gitpod-FFB45B?logo=gitpod
[gha]: https://github.com/PaulRBerg/foundry-template/actions
[gha-badge]: https://github.com/PaulRBerg/foundry-template/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

A Foundry-based template for developing Solidity smart contracts, with sensible defaults. Dependencies are managed as
Node.js packages via [Bun](https://bun.sh) rather than git submodules, and the template ships preconfigured with Forge
Std, OpenZeppelin Contracts, Prettier, and Solhint.

## What's Inside

- [Forge](https://github.com/foundry-rs/foundry/tree/master/crates/forge): compile, test, fuzz, format, and deploy smart
  contracts
- [Forge Std](https://github.com/foundry-rs/forge-std): collection of helpful contracts and utilities for testing
- [Bun](https://bun.sh): manage Foundry dependencies as Node.js packages instead of git submodules
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts): library of secure, community-vetted
  smart contracts (pre-installed)
- [Prettier](https://github.com/prettier/prettier): code formatter for non-Solidity files
- [Solhint](https://github.com/protofire/solhint): linter for Solidity code

## Links

- [Use this template](https://github.com/PaulRBerg/foundry-template/generate)
- [Foundry Book](https://getfoundry.sh)
- [Writing Tests](https://getfoundry.sh/forge/testing)

## Related Projects

- [foundry-rs/forge-template](https://github.com/foundry-rs/forge-template)
- [refcell/femplate](https://github.com/refcell/femplate)
- [cleanunicorn/ethereum-smartcontract-template](https://github.com/cleanunicorn/ethereum-smartcontract-template)
- [FrankieIsLost/forge-template](https://github.com/FrankieIsLost/forge-template)

## Contributing

Contributions are welcome. See [`AGENTS.md`](AGENTS.md) for the development workflow, commands, and conventions.

## License

This project is licensed under MIT — see the [LICENSE](LICENSE.md) file for details.
