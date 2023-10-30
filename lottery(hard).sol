// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LotteryPool {
    address public gavin;
    address[] public participants;
    address public previousWinner;
    mapping(address => uint256) public gamesWon;
    uint256 public earnings;
    uint256 public poolBalance;
    uint8 private constant MAX_PARTICIPANTS = 5;
    uint256 private constant ENTRY_FEE_PERCENTAGE = 10;

    constructor() {
        gavin = msg.sender;
    }

    modifier onlyGavin() {
        require(msg.sender == gavin, "Only Gavin can access this function");
        _;
    }

    function enter() external payable {
        require(msg.sender != gavin, "Gavin cannot participate");
        require(!(isParticipant(msg.sender)), "Already a participant");
        uint256 totalAmount = (1 ether / 10) +
            (gamesWon[msg.sender] * (1 ether / 100));
        uint256 entryFee = (totalAmount * ENTRY_FEE_PERCENTAGE) / 100;
        uint256 remainingAmount = totalAmount - entryFee;
        require(msg.value == totalAmount, "Incorrect amount sent");

        earnings += entryFee;
        payable(gavin).transfer(entryFee);
        poolBalance += remainingAmount;
        participants.push(msg.sender);

        if (participants.length == MAX_PARTICIPANTS) {
            uint256 winnerIndex = uint256(
                keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
            ) % MAX_PARTICIPANTS;
            previousWinner = participants[winnerIndex];
            gamesWon[previousWinner]++;
            payable(previousWinner).transfer(poolBalance);
            poolBalance = 0;
            delete participants;
        }
    }

    function withdraw() external {
        require(participants.length < MAX_PARTICIPANTS, "Pool is full");
        require(msg.sender != gavin, "Gavin cannot participate");
        require(isParticipant(msg.sender), "You are not in the pool");

        //uint256 withdrawAmount = (1 ether / 10) + (gamesWon[msg.sender] * (1 ether / 100));
        //payable(msg.sender).transfer(withdrawAmount);
        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == msg.sender) {
                participants.pop();
            }
        }
    }

    function viewParticipants()
        external
        view
        returns (address[] memory, uint256)
    {
        return (participants, participants.length);
    }

    function viewPreviousWinner() external view returns (address) {
        require(previousWinner != address(0), "No winner yet");
        return previousWinner;
    }

    function getGamesWon(address player) external view returns (uint256) {
        return gamesWon[player];
    }

    function viewEarnings() external view onlyGavin returns (uint256) {
        return earnings;
    }

    function viewPoolBalance() external view returns (uint256) {
        return poolBalance;
    }

    function isParticipant(address player) private view returns (bool) {
        for (uint8 i = 0; i < participants.length; i++) {
            if (participants[i] == player) {
                return true;
            }
        }
        return false;
    }
}
