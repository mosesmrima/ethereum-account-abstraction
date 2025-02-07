# MinimalAccount: Account Abstraction in Ethereum

## Overview
This project implements a minimal smart contract wallet that supports account abstraction on Ethereum using the [ERC-4337](https://eips.ethereum.org/EIPS/eip-4337) standard. It is built using Solidity and tested with Foundry. The contract allows a user to execute transactions and validate operations via an EntryPoint contract.
This project was part of my learning journey to master advanced foundry, [Cyfrin Updraft](https://updraft.cyfrin.io/courses/advanced-foundry)

## Features
- Implements the `IAccount` interface from ERC-4337.
- Uses `Ownable` from OpenZeppelin for ownership management.
- Supports validating user operations using ECDSA signatures.
- Allows external transaction execution by the owner or the EntryPoint.
- Handles missing account funds for gas payments.

## Smart Contract
### `MinimalAccount.sol`
This contract extends `IAccount` and `Ownable` to manage account abstraction:

- **Constructor**: Initializes the contract with the EntryPoint address.
- **Modifiers**:
  - `requireFromEntryPoint()`: Ensures only the EntryPoint contract can call certain functions.
  - `requireFromEntryPointOrOwner()`: Restricts access to the EntryPoint or the account owner.
- **Functions**:
  - `execute()`: Executes a transaction to a specified address.
  - `validateUserOp()`: Validates user operations using ECDSA signatures.
  - `_validateSignature()`: Internal function for signature verification.
  - `_payAccountFunds()`: Handles gas payments if required.
  - `getEntryPoint()`: Returns the EntryPoint contract address.

## Setup
### Prerequisites
Ensure you have Foundry installed. If not, install it using:
```sh
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Clone the Repository
```sh
git clone https://github.com/mosesmrima/ethereum-account-abstraction
cd ethereum-account-abstraction
```

### Install Dependencies
```sh
forge install
```

### Compile the Contract
```sh
forge build
```

### Run Tests
```sh
forge test
```

## Deployment
### Using Foundry
1. Configure your environment variables in `.env`.
2. Deploy the contract:
   ```sh
   forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
   ```

## License
This project is licensed under the MIT License.


