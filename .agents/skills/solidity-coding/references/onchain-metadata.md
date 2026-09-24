# Onchain Metadata

Generate `tokenURI` JSON and SVG fully onchain.

## Architecture

Put metadata generation in a separate descriptor contract that the NFT contract calls. The NFT stays under the size
limit, and an admin can swap the descriptor without redeploying the NFT.

```
src/
├── NFTDescriptor.sol       # Implements tokenURI; composes JSON and SVG
└── libraries/
    ├── NFTSVG.sol          # Builds the complete SVG from a params struct
    └── SVGElements.sol     # Reusable SVG pieces: cards, circles, text
```

Emit ERC-4906 `BatchMetadataUpdate` when the descriptor changes, so marketplaces refresh cached metadata.

## Techniques

| Technique                                | Purpose                                         |
| ---------------------------------------- | ----------------------------------------------- |
| OpenZeppelin `Base64.encode`             | Encode JSON and SVG as data URIs                |
| OpenZeppelin `Strings`                   | Convert numbers and addresses to strings        |
| `{FunctionName}Vars` memory struct       | Avoid Stack Too Deep in `tokenURI`              |
| Scoped `solhint-disable max-line-length` | Allow long SVG string literals                  |
| Low-level `staticcall` for `symbol()`    | Tolerate tokens that return `bytes32` or revert |

## Return Format

```
data:application/json;base64,{base64(JSON)}

JSON = {
  "attributes": [...],
  "description": "...",
  "external_url": "...",
  "image": "data:image/svg+xml;base64,{base64(SVG)}",
  "name": "..."
}
```

Escape user-controlled strings, such as token symbols, before embedding them in JSON or SVG.
