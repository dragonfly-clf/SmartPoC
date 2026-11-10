pragma solidity ^0.8.26;

contract DosOneFunc {
    address[] listAddresses;
    uint public totalParticipants;
    uint public arrayResetCount;
    mapping(address => uint) public participantContributions;
    
    event ArrayFilled(address indexed participant, uint newLength);
    event ArrayReset(uint resetCount);

    constructor() {}

    function ifillArray() public returns (bool) {
        if (listAddresses.length < 1500) {
            unchecked {
                for (uint i = 0; i < 350; i++) {
                    listAddresses.push(msg.sender);
                }
            }
            totalParticipants++;
            participantContributions[msg.sender] += 350;
            emit ArrayFilled(msg.sender, listAddresses.length);
            return true;
        } else {
            listAddresses = new address[](0);
            arrayResetCount++;
            emit ArrayReset(arrayResetCount);
            return false;
        }
    }

    function getParticipantStats(address participant) public view returns (uint contributions, uint currentArraySize) {
        return (participantContributions[participant], listAddresses.length);
    }
}