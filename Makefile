-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil deployMood

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops@0.2.2 --no-commit && forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit 

# Deploy to sepolia

deploy-sepolia:
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url ${SEPOLIA_RPC_URL} --account default --broadcast --verify  --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif


deployMood:
	@forge script script/DeployMood.s.sol:DeployMood $(NETWORK_ARGS)

# deployMintContract:
# 	@forge script script/MintBasicNft.s.sol:MintBasicNft $(NETWORK_ARGS)


# Verify constract

# verify:; @forge verify-contract 0x8ddf391bc9641498de976d41b0f29848fad9d4c0 src/Raffle.sol:Raffle --etherscan-api-key ${ETHERSCAN_API_KEY} --rpc-url ${SEPOLIA_RPC_URL} --show-standard-json-input > json.json