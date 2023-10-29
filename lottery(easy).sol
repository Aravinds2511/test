// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LotteryPool {
    address[] public participants;
    address public previousWinner;
    uint public numberOfParticipants;
    uint public poolSize = 5;
    uint public entryFee = 0.1 ether;

    // For participants to enter the pool
    function enter() public payable {
        require(msg.value == entryFee, "Incorrect ether amount sent");
        require(numberOfParticipants < poolSize, "Pool is full");
        require(
            !isParticipant(msg.sender),
            "You are already a participant in the current pool"
        );

        participants.push(msg.sender);
        numberOfParticipants++;

        if (numberOfParticipants == poolSize) {
            pickWinner();
        }
    }

    function pickWinner() private {
        require(numberOfParticipants == poolSize, "Pool is not full yet");

        uint winnerIndex = random() % poolSize;
        address winner = participants[winnerIndex];
        payable(winner).transfer(address(this).balance);
        previousWinner = winner;

        // Reset participants and number of participants for the next round
        delete participants;
        numberOfParticipants = 0;
    }

    function random() private view returns (uint) {
        return
            uint(
                keccak256(
                    abi.encodePacked(
                        block.prevrandao,
                        block.timestamp,
                        participants
                    )
                )
            );
    }

    function isParticipant(address addr) private view returns (bool) {
        for (uint i = 0; i < participants.length; i++) {
            if (participants[i] == addr) {
                return true;
            }
        }
        return false;
    }

    // To view participants in current pool
    function viewParticipants() public view returns (address[] memory, uint) {
        return (participants, numberOfParticipants);
    }

    // To view winner of last lottery
    function viewPreviousWinner() public view returns (address) {
        require(
            previousWinner != address(0),
            "No lottery has been completed yet"
        );
        return previousWinner;
    }
}
