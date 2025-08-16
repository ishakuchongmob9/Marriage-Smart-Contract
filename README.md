# 💍 Marriage Smart Contract

A comprehensive Clarity smart contract for managing marriages, proposals, and relationships on the Stacks blockchain.

## ✨ Features

- 💝 **Marriage Proposals**: Send romantic proposals with ring value deposits
- 💒 **Marriage Registration**: Register marriages with optional prenuptial agreements
- 📜 **Marriage Certificates**: Generate blockchain-verified marriage certificates
- 💰 **Shared Assets**: Manage joint financial assets between spouses
- 📋 **Prenuptial Agreements**: Set custom terms and conditions
- 💔 **Divorce Processing**: Handle divorce requests with asset splitting
- 🎉 **Anniversary Celebrations**: Earn rewards for marriage milestones
- 👥 **User Profiles**: Track relationship status and marriage history

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Node.js and npm for testing

### Installation

```bash
git clone <repository-url>
cd Marriage-Smart-Contract
npm install
```

### Testing

```bash
clarinet check
npm test
```

## 📖 Usage

### Creating a Profile

```clarity
(contract-call? .Marriage-Smart-Contract create-profile "Your Name")
```

### Proposing Marriage

```clarity
(contract-call? .Marriage-Smart-Contract propose-marriage 
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 
  "Will you marry me?" 
  u5000000)
```

### Accepting a Proposal

```clarity
(contract-call? .Marriage-Smart-Contract accept-proposal 
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Marriage with Prenup

```clarity
(contract-call? .Marriage-Smart-Contract marry-with-prenup 
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 
  "50/50 split of all assets" 
  u10000000)
```

### Managing Shared Assets

```clarity
;; Add assets to marriage
(contract-call? .Marriage-Smart-Contract add-shared-assets u2000000)

;; Withdraw shared assets (splits equally)
(contract-call? .Marriage-Smart-Contract withdraw-shared-assets u1000000)
```

### Requesting Divorce

```clarity
(contract-call? .Marriage-Smart-Contract request-divorce 
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 
  "Irreconcilable differences" 
  u60)
```

### Anniversary Celebrations

```clarity
(contract-call? .Marriage-Smart-Contract celebrate-anniversary)
```

## 🔍 Read-Only Functions

### Check Marriage Status

```clarity
(contract-call? .Marriage-Smart-Contract is-married 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Get User Profile

```clarity
(contract-call? .Marriage-Smart-Contract get-user-profile 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Get Marriage Details

```clarity
(contract-call? .Marriage-Smart-Contract get-marriage 
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ8)
```

### Get Contract Statistics

```clarity
(contract-call? .Marriage-Smart-Contract get-marriage-stats)
```

## 💰 Fees and Economics

- **Marriage Fee**: 1 STX (adjustable by contract owner)
- **Minimum Ring Value**: 0.1 STX for proposals
- **Anniversary Rewards**: 
  - Year 1: 0.1 STX each
  - Years 2-5: 0.5 STX each
  - Years 6-10: 1 STX each
  - 10+ Years: 2 STX each

## 🛡️ Security Features

- ✅ Prevents self-marriage
- ✅ Prevents bigamy (one marriage at a time)
- ✅ Secure asset management
- ✅ Owner-only administrative functions
- ✅ Emergency pause functionality

## 📋 Contract Functions

### Public Functions

| Function | Description |
|----------|-------------|
| `create-profile` | Create user profile with display name |
| `propose-marriage` | Send marriage proposal with ring deposit |
| `accept-proposal` | Accept a received marriage proposal |
| `reject-proposal` | Reject proposal and return ring value |
| `marry-with-prenup` | Direct marriage with prenuptial terms |
| `request-divorce` | Request divorce with asset split terms |
| `approve-divorce` | Approve spouse's divorce request |
| `add-shared-assets` | Add STX to shared marriage assets |
| `withdraw-shared-assets` | Withdraw shared assets (50/50 split) |
| `celebrate-anniversary` | Claim anniversary rewards |
| `add-witness-to-certificate` | Add witness to marriage certificate |
| `renew-vows` | Update prenup terms and reset anniversary |

### Administrative Functions

| Function | Description |
|----------|-------------|
| `update-marriage-fee` | Change marriage registration fee |
| `emergency-pause-marriage` | Pause specific marriage |
| `resume-marriage` | Resume paused marriage |
| `withdraw-contract-fees` | Withdraw collected fees |

## 🏗️ Development

### Project Structure

```
├── contracts/
│   └── Marriage-Smart-Contract.clar
├── tests/
├── settings/
├── Clarinet.toml
└── README.md
```

### Running Tests

```bash
npm install
npm test
```

### Deployment

Deploy to testnet or mainnet using Clarinet:

```bash
clarinet deployments generate --testnet
clarinet deployments apply --testnet
```

## 📝 License

MIT License - see LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

---

Made with ❤️ on the Stacks blockchain
