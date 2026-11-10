// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

contract DRIVENFeeTest is Test {
    FeeTestContract token;
    address owner = address(0x1234567);
    address marketingAddress = address(0xABCDEF);

    function setUp() public {
        vm.startPrank(owner);
        token = new FeeTestContract(owner);
        vm.stopPrank();
    }

    function test_FeeCanExceed25Percent() public {
        uint256 excessiveFee = 3000; // 30% exceeds 25% limit
        
        console.log("--- BEFORE-Trigger MarketFee ---");
        uint256 initialFee = token.marketFee();
        console.log("Initial market fee:", initialFee);

        console.log("--- Trigger setMarketFee ---");
        vm.prank(owner);
        token.setMarketFee(excessiveFee);

        console.log("--- AFTER-Trigger MarketFee ---");
        uint256 finalFee = token.marketFee();
        console.log("Final market fee:", finalFee);

        bool changed = (finalFee != initialFee);
        bool exceededLimit = (finalFee > 2500); // 25% threshold
        
        console.log("State changed?", changed ? "YES" : "NO");
        console.log("Exceeded 25%% limit?", exceededLimit ? "YES" : "NO");
        
        if (changed && exceededLimit) {
            console.log("Vulnerability Exists: Market fee exceeded 25% limit after manipulation");
        } else {
            console.log("Vulnerability not Exist: Market fee change respects constraints");
        }
    }
}

contract FeeTestContract {
    address private _owner;
    uint256 private _marketFee;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    constructor(address owner_) {
        _owner = owner_;
    }

    function setMarketFee(uint256 marketfee) public onlyOwner {
        _marketFee = marketfee;
    }

    function marketFee() public view returns (uint256) {
        return _marketFee;
    }
}