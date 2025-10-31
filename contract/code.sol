// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DecentralizedVoting
 * @dev A secure decentralized voting system with proposal creation and voter management
 */
contract DecentralizedVoting {
    
    // Structs
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedProposalId;
        uint256 weight;
    }
    
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        address proposer;
    }
    
    // State variables
    address public admin;
    uint256 public proposalCount;
    
    mapping(address => Voter) public voters;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public proposalVotes;
    
    // Events
    event VoterRegistered(address indexed voter);
    event ProposalCreated(uint256 indexed proposalId, string description, address indexed proposer);
    event VoteCast(address indexed voter, uint256 indexed proposalId);
    event ProposalExecuted(uint256 indexed proposalId);
    
    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "You are not a registered voter");
        _;
    }
    
    modifier proposalExists(uint256 _proposalId) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Proposal does not exist");
        _;
    }
    
    modifier votingActive(uint256 _proposalId) {
        require(block.timestamp >= proposals[_proposalId].startTime, "Voting has not started yet");
        require(block.timestamp <= proposals[_proposalId].endTime, "Voting has ended");
        _;
    }
    
    constructor() {
        admin = msg.sender;
        voters[admin].isRegistered = true;
        voters[admin].weight = 1;
    }
    
    /**
     * @dev Register a new voter
     * @param _voter Address of the voter to register
     */
    function registerVoter(address _voter) external onlyAdmin {
        require(!voters[_voter].isRegistered, "Voter already registered");
        require(_voter != address(0), "Invalid address");
        
        voters[_voter].isRegistered = true;
        voters[_voter].weight = 1;
        voters[_voter].hasVoted = false;
        
        emit VoterRegistered(_voter);
    }
    
    /**
     * @dev Register multiple voters at once
     * @param _voters Array of voter addresses to register
     */
    function registerVotersBatch(address[] calldata _voters) external onlyAdmin {
        for (uint256 i = 0; i < _voters.length; i++) {
            if (!voters[_voters[i]].isRegistered && _voters[i] != address(0)) {
                voters[_voters[i]].isRegistered = true;
                voters[_voters[i]].weight = 1;
                voters[_voters[i]].hasVoted = false;
                emit VoterRegistered(_voters[i]);
            }
        }
    }
    
    /**
     * @dev Create a new proposal
     * @param _description Description of the proposal
     * @param _votingDuration Duration of voting period in seconds
     */
    function createProposal(string calldata _description, uint256 _votingDuration) 
        external 
        onlyRegisteredVoter 
        returns (uint256) 
    {
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(_votingDuration > 0, "Voting duration must be greater than 0");
        
        proposalCount++;
        
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            voteCount: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + _votingDuration,
            executed: false,
            proposer: msg.sender
        });
        
        emit ProposalCreated(proposalCount, _description, msg.sender);
        
        return proposalCount;
    }
    
    /**
     * @dev Cast a vote for a proposal
     * @param _proposalId ID of the proposal to vote for
     */
    function vote(uint256 _proposalId) 
        external 
        onlyRegisteredVoter 
        proposalExists(_proposalId)
        votingActive(_proposalId)
    {
        require(!proposalVotes[_proposalId][msg.sender], "You have already voted on this proposal");
        
        Voter storage sender = voters[msg.sender];
        proposalVotes[_proposalId][msg.sender] = true;
        
        proposals[_proposalId].voteCount += sender.weight;
        
        emit VoteCast(msg.sender, _proposalId);
    }
    
    /**
     * @dev Get proposal details
     * @param _proposalId ID of the proposal
     */
    function getProposal(uint256 _proposalId) 
        external 
        view 
        proposalExists(_proposalId)
        returns (
            uint256 id,
            string memory description,
            uint256 voteCount,
            uint256 startTime,
            uint256 endTime,
            bool executed,
            address proposer,
            bool isActive
        ) 
    {
        Proposal memory p = proposals[_proposalId];
        bool active = block.timestamp >= p.startTime && block.timestamp <= p.endTime;
        
        return (
            p.id,
            p.description,
            p.voteCount,
            p.startTime,
            p.endTime,
            p.executed,
            p.proposer,
            active
        );
    }
    
    /**
     * @dev Check if an address has voted on a specific proposal
     * @param _proposalId ID of the proposal
     * @param _voter Address of the voter
     */
    function hasVotedOnProposal(uint256 _proposalId, address _voter) 
        external 
        view 
        returns (bool) 
    {
        return proposalVotes[_proposalId][_voter];
    }
    
    /**
     * @dev Get winning proposal (highest vote count)
     */
    function getWinningProposal() external view returns (uint256 winningProposalId) {
        uint256 winningVoteCount = 0;
        
        for (uint256 i = 1; i <= proposalCount; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalId = i;
            }
        }
    }
    
    /**
     * @dev Get total number of registered voters
     */
    function getVoterInfo(address _voter) 
        external 
        view 
        returns (
            bool isRegistered,
            uint256 weight
        ) 
    {
        return (
            voters[_voter].isRegistered,
            voters[_voter].weight
        );
    }
    
    /**
     * @dev Change admin (transfer ownership)
     * @param _newAdmin Address of the new admin
     */
    function changeAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
    
    /**
     * @dev Delegate voting weight to another voter
     * @param _to Address to delegate to
     */
    function delegate(address _to) external onlyRegisteredVoter {
        require(_to != msg.sender, "Cannot delegate to yourself");
        require(voters[_to].isRegistered, "Delegate must be a registered voter");
        
        Voter storage sender = voters[msg.sender];
        require(sender.weight > 0, "You have no weight to delegate");
        
        voters[_to].weight += sender.weight;
        sender.weight = 0;
    }
}
