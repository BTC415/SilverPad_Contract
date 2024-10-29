# SilverPad_Contract

A decentralized ICO (Initial Coin Offering) platform built on Ethereum using Hardhat, featuring a secure token launch system with built-in safety mechanisms.

## Features

- **Token Launch Management**
  - Configurable ICO parameters (softcap, hardcap, duration)
  - Token price and supply management
  - Built-in safety checks and validations

- **Investment Handling**
  - Secure investment processing
  - Investor and contributor tracking
  - Investment history recording

- **Safety Mechanisms**
  - Reentrancy protection
  - Address validation
  - Cap validation
  - Token supply verification

- **Distribution System**
  - Automated fee distribution
  - Support for listing partners
  - DAO integration
  - Funds management

## Key Components

### Token Structure
- Name
- Symbol
- Decimals
- Price
- Total Supply
- Token Address

### ICO Parameters
- Start Time
- End Time
- Soft Cap
- Hard Cap
- Project URI

### Role Management
- Contract Owner
- Listing Partner
- DAO Address
- Fund Raised Address

## Smart Contract Functions

### Core Functions
- Token purchase management
- Token availability checking
- ETH conversion calculations
- Distribution handling
- Refund processing

### View Functions
- `maxTokenAmountToPurchase()`
- `tokensFullyCharged()`
- `tokensAvailable()`
- `minEthAvailable()`
- `tokensAvailableByEth()`
- `ethByTokens()`

## Security Features
- ReentrancyGuard implementation
- SafeERC20 usage
- Multiple validation modifiers
- State management checks

## Events
- FeeDistributed: Tracks fee distribution after successful ICO
- Invest: Records investment transactions
- FundsAllRefund: Logs refund operations

## Development

```bash
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.ts
```

## Deployment
```bash
npx hardhat run scripts/deploy.ts
```

## Dependencies
- OpenZeppelin Contracts
- Hardhat
- ERC20 Standard

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.