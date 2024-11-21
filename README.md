# LearnQ - Decentralized Educational Platform

LearnQ is a revolutionary blockchain-based educational platform that incentivizes learning through token rewards. Students can earn LEARN tokens by completing courses and helping others in their educational journey.

## Overview

LearnQ leverages blockchain technology to create a transparent and rewarding educational environment. The platform uses Clarity smart contracts on the Stacks blockchain to manage course completion tracking and token distribution.

## Core Features

- **Course Management**: Create and manage educational courses with associated reward amounts
- **Progress Tracking**: Track student progress through courses on-chain
- **Token Rewards**: Automatically distribute LEARN tokens upon course completion
- **Transparent System**: All educational achievements and rewards are publicly verifiable

## Smart Contract Functions

### Administrative Functions

- `create-course`: Create a new course with specified reward amount
  - Parameters: course-id (uint), title (string-utf8), reward (uint)
  - Only contract owner can create courses

### Student Functions

- `complete-course`: Mark a course as completed for the calling user
  - Parameters: course-id (uint)
  - Can only be called once per course per user

- `claim-reward`: Claim tokens for completed courses
  - Parameters: course-id (uint)
  - Requires course completion verification

### Read-Only Functions

- `get-course`: Get course details
- `get-user-progress`: Check progress for specific user and course
- `get-balance`: Check token balance for any address

## Token Economics

- Token Name: LEARN
- Token Symbol: LRN
- Distribution: Tokens are minted upon course completion
- Use Cases:
  - Access premium content
  - Participate in platform governance
  - Reward other students for help

## Technical Requirements

- Clarity Smart Contract
- Stacks Blockchain
- Web3 wallet (e.g., Hiro Wallet)

## Development Setup

1. Install Clarinet for local development:
```bash
curl -L https://github.com/hirosystems/clarinet/releases/download/v1.0.0/clarinet-linux-x64.tar.gz | tar xz
```

2. Initialize project:
```bash
clarinet new learnq
cd learnq
```

3. Deploy contract:
```bash
clarinet deploy
```

## Security Considerations

- Owner-only functions for course creation
- Double-claiming prevention
- Progress verification before rewards
- Balance checks for token operations

## Future Enhancements

1. Peer Review System
2. Community Governance
3. Course Creator Rewards
4. Achievement NFTs
5. Cross-chain Integration

## Contributing

We welcome contributions! Please see our contributing guidelines for more details.

