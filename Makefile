all: remove install build

# Todo armarlo custom!
test:;

# Clean the repo
clean  :; forge clean


# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf .node_modules && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install-defi :; forge install foundry-rs/forge-std --no-commit && forge install https://github.com/vectorized/solady --no-commit && forge install https://github.com/smartcontractkit/chainlink-brownie-contracts@v1.1.0 --no-commit forge install https://github.com/pyth-network/pyth-sdk-solidity --no-commit
install-nfts :; forge install foundry-rs/forge-std --no-commit && forge install https://github.com/vectorized/solady --no-commit 
# TODO armar el de upgradeable
# TODO ver porque pingo no me funca el make invariant y el make unit ??
install-upgradeable:; forge install foundry-rs/forge-std --no-commit 
install-math:; forge install foundry-rs/forge-std --no-commit && forge install --no-commit PaulRBerg/prb-math@release-v4 

# Tests
coverage-report:; forge coverage --report lcov

## Coverage of contracts (mocks and scripts)
coverage :; forge coverage --nmp test/ &&  forge coverage --nmp script/ && forge coverage --nmp test/invariants/
invariant:; forge test --mp test/invariants/

unit:; forge test --mp test/unit/


lint :; npm run lint:sol && npm run prettier:check

# Update Dependencies
update:; forge update

build:; forge build
