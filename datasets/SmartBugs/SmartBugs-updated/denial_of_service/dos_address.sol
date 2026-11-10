pragma solidity ^0.8.26;

contract DosGas {
    address[] creditorAddresses;
    bool win = false;
    uint public totalCredits;
    mapping(address => uint) public creditCount;
    uint public constant CREDIT_THRESHOLD = 1500;

    event CreditAdded(address indexed creditor, uint count);
    event CreditsEmptied();

    function emptyCreditors() public {
        if(creditorAddresses.length > CREDIT_THRESHOLD) {
            creditorAddresses = new address[](0);
            win = true;
            totalCredits = 0;
            emit CreditsEmptied();
        }
    }

    function addCreditors() public returns (bool) {
        for(uint i = 0; i < 350; i++) {
            creditorAddresses.push(msg.sender);
        }
        creditCount[msg.sender] += 350;
        totalCredits += 350;
        emit CreditAdded(msg.sender, 350);
        return true;
    }

    function iWin() public view returns (bool) {
        return win;
    }

    function numberCreditors() public view returns (uint) {
        return creditorAddresses.length;
    }

    function getMyCredits() public view returns (uint) {
        return creditCount[msg.sender];
    }
}