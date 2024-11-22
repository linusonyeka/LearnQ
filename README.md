# LearnQ - Decentralized Educational Platform

LearnQ is a revolutionary blockchain-based educational platform that incentivizes learning through token rewards. Students can earn LEARN tokens by completing courses and helping others in their educational journey.

## Overview

LearnQ leverages blockchain technology to create a transparent and rewarding educational environment. The platform uses Clarity smart contracts on the Stacks blockchain to manage course completion tracking and token distribution.

## Core Features

- **Course Management**: Create, update, and manage educational courses with associated reward amounts
- **Progress Tracking**: Track student progress through courses on-chain
- **Token Rewards**: Automatically distribute LEARN tokens upon course completion
- **Transparent System**: All educational achievements and rewards are publicly verifiable
- **Course Activation Control**: Flexibility to activate/deactivate courses as needed

## Smart Contract Functions

### Administrative Functions

- `create-course`: Create a new course with specified reward amount
  - Parameters: course-id (uint), title (string-utf8), reward (uint)
  - Only contract owner can create courses

- `update-course`: Update existing course details
  - Parameters: course-id (uint), new-title (optional string-utf8), new-reward (optional uint)
  - Allows independent updating of title and reward amounts
  - Only contract owner can update courses

- `toggle-course-status`: Activate or deactivate courses
  - Parameters: course-id (uint)
  - Only contract owner can toggle course status
  - Prevents new enrollments in deactivated courses

### Student Functions

- `complete-course`: Mark a course as completed for the calling user
  - Parameters: course-id (uint)
  - Can only be called once per course per user
  - Only works for active courses

- `claim-reward`: Claim tokens for completed courses
  - Parameters: course-id (uint)
  - Requires course completion verification
  - Prevents double-claiming of rewards

### Read-Only Functions

- `get-course`: Get course details including activation status
- `get-user-progress`: Check progress for specific user and course
- `get-balance`: Check token balance for any address

## Token Economics

- Token Name: LEARN
- Token Symbol: LRN
- Distribution: Tokens are minted upon course completion
- Reward Limits:
  - Minimum: 1 token
  - Maximum: 1,000,000 tokens
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

## Error Handling

The contract includes comprehensive error handling:
- `err-owner-only (u100)`: Unauthorized access to admin functions
- `err-not-found (u101)`: Course or progress record not found
- `err-already-exists (u102)`: Duplicate course creation or completion
- `err-insufficient-balance (u103)`: Token balance issues
- `err-invalid-input (u104)`: Invalid parameter values
- `err-inactive-course (u105)`: Attempting to complete deactivated course
- `err-no-changes (u106)`: Update attempt with no actual changes

## Security Considerations

- Owner-only functions for course management
- Double-claiming prevention mechanisms
- Progress verification before rewards
- Balance checks for token operations
- Course activation controls
- Input validation for all operations

## Future Enhancements

1. Peer Review System
2. Community Governance
3. Course Creator Rewards
4. Achievement NFTs
5. Cross-chain Integration
6. Advanced Course Prerequisites
7. Dynamic Reward Adjustments
8. Multi-language Support

## Best Practices

When interacting with the contract:
- Always verify course status before student enrollment
- Maintain proper record-keeping of course updates
- Monitor token distribution patterns
- Regular auditing of course completions

## Contributing

We welcome contributions! Please see our contributing guidelines for more details.
