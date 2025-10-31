🗳️ Decentralized Voting System

A Decentralized Voting System built on the Ethereum blockchain using Solidity.
This project ensures transparency, security, and immutability in the voting process by leveraging smart contracts, eliminating the need for a centralized authority.

🚀 Features

Decentralized & Transparent: All votes are recorded on the blockchain.

Secure: Prevents double voting and ensures voter authenticity.

Immutable: Once recorded, votes cannot be altered.

Admin Controls: Only the admin can start, stop, and manage elections.

Accessible: Anyone can view the results in real time.

🧱 Tech Stack
Technology	Description
Solidity	Smart contract language
Ethereum / Hardhat / Remix IDE	Blockchain environment
MetaMask	Wallet for interacting with blockchain
JavaScript / React (optional)	Frontend interface
Web3.js / Ethers.js	Blockchain communication library
📂 Project Structure
Decentralized-Voting-System/
│
├── contracts/
│   └── Voting.sol              # Main Solidity smart contract
│
├── scripts/
│   └── deploy.js               # Deployment script (Hardhat)
│
├── test/
│   └── Voting.test.js          # Unit tests for the contract
│
├── frontend/                   # Optional frontend app (React)
│
├── hardhat.config.js           # Hardhat configuration
├── package.json
└── README.md

⚙️ Smart Contract Overview
Voting.sol

Main functionalities:

Admin Functions

startElection(string[] memory candidateNames)

endElection()

Voter Functions

registerVoter(address voterAddress)

vote(uint candidateId)

View Functions

getCandidates()

getVotes(uint candidateId)

🧩 How to Run the Project
1. Clone the repository
git clone https://github.com/v83484493-lgtm/Dcentralized_Voting_System.git

2. Install dependencies
npm install

3. Compile the contract
npx hardhat compile

4. Deploy to local blockchain (Hardhat network)
npx hardhat node
npx hardhat run scripts/deploy.js --network localhost

5. Interact with the contract

Use Remix IDE or frontend UI.

Connect MetaMask to your network.

💻 Example Usage

Admin deploys the contract.

Admin starts an election with candidate names.

Users register and vote using their wallet.

Admin ends the election.

Results can be viewed publicly.

🔒 Security Considerations

Prevents double voting using voter mapping.

Restricts election control to admin only.

Validates voter registration before allowing votes.

🧠 Future Enhancements

🪪 Anonymous voting using zero-knowledge proofs (ZK-SNARKs)

🌐 Multi-election support

📱 Mobile DApp integration

🧾 On-chain identity verification
