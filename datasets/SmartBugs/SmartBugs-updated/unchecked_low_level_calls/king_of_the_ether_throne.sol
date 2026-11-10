pragma solidity ^0.8.26;

contract KingOfTheEtherThrone {

    struct Monarch {
        address etherAddress;
        string name;
        uint claimPrice;
        uint coronationTimestamp;
    }

    address wizardAddress;

    modifier onlywizard { if (msg.sender == wizardAddress) _; }

    uint constant startingClaimPrice = 100000000000000000;
    uint constant claimPriceAdjustNum = 3;
    uint constant claimPriceAdjustDen = 2;
    uint constant wizardCommissionFractionNum = 1;
    uint constant wizardCommissionFractionDen = 100;

    uint public currentClaimPrice;
    Monarch public currentMonarch;
    Monarch[] public pastMonarchs;

    constructor() {
        wizardAddress = msg.sender;
        currentClaimPrice = startingClaimPrice;
        currentMonarch = Monarch(
            wizardAddress,
            "[Vacant]",
            0,
            block.timestamp
        );
    }

    function numberOfMonarchs() public view returns (uint n) {
        return pastMonarchs.length;
    }

    event ThroneClaimed(
        address usurperEtherAddress,
        string usurperName,
        uint newClaimPrice
    );

    fallback() external payable {
        claimThrone(string(msg.data));
    }

    function claimThrone(string memory name) public payable {
        uint valuePaid = msg.value;

        if (valuePaid < currentClaimPrice) {
            payable(msg.sender).transfer(valuePaid);
            return;
        }

        if (valuePaid > currentClaimPrice) {
            uint excessPaid = valuePaid - currentClaimPrice;
            payable(msg.sender).transfer(excessPaid);
            unchecked { valuePaid = valuePaid - excessPaid; }
        }

        uint wizardCommission = (valuePaid * wizardCommissionFractionNum) / wizardCommissionFractionDen;
        uint compensation = valuePaid - wizardCommission;

        if (currentMonarch.etherAddress != wizardAddress) {
            payable(currentMonarch.etherAddress).transfer(compensation);
        }

        pastMonarchs.push(currentMonarch);
        currentMonarch = Monarch(
            msg.sender,
            name,
            valuePaid,
            block.timestamp
        );

        uint rawNewClaimPrice = currentClaimPrice * claimPriceAdjustNum / claimPriceAdjustDen;
        if (rawNewClaimPrice < 10000000000000000) {
            currentClaimPrice = rawNewClaimPrice;
        } else if (rawNewClaimPrice < 100000000000000000) {
            currentClaimPrice = 100000000000000 * (rawNewClaimPrice / 100000000000000);
        } else if (rawNewClaimPrice < 1000000000000000000) {
            currentClaimPrice = 10000000000000000 * (rawNewClaimPrice / 10000000000000000);
        } else if (rawNewClaimPrice < 10000000000000000000) {
            currentClaimPrice = 100000000000000000 * (rawNewClaimPrice / 100000000000000000);
        } else if (rawNewClaimPrice < 100000000000000000000) {
            currentClaimPrice = 1000000000000000000 * (rawNewClaimPrice / 1000000000000000000);
        } else if (rawNewClaimPrice < 1000000000000000000000) {
            currentClaimPrice = 10000000000000000000 * (rawNewClaimPrice / 10000000000000000000);
        } else if (rawNewClaimPrice < 10000000000000000000000) {
            currentClaimPrice = 100000000000000000000 * (rawNewClaimPrice / 100000000000000000000);
        } else {
            currentClaimPrice = rawNewClaimPrice;
        }

        emit ThroneClaimed(currentMonarch.etherAddress, currentMonarch.name, currentClaimPrice);
    }

    function sweepCommission(uint amount) public onlywizard {
        payable(wizardAddress).transfer(amount);
    }

    function transferOwnership(address newOwner) public onlywizard {
        wizardAddress = newOwner;
    }
}