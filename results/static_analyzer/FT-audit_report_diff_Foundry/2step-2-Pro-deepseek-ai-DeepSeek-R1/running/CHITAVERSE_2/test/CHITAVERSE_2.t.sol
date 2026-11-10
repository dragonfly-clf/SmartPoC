// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CHITAVERSE.sol";

contract MockWETH {
    function deposit() public payable {}
    function transfer(address, uint256) public pure returns (bool) { return true; }
}

contract MockPair {
    function initialize(address, address) external {}
}

contract MockFactory {
    address private immutable pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address public factory;
    address public WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function initialize(address _factory) public {
        factory = _factory;
    }
}

contract CHITAVERSE_SafeMathUnderflowTest is Test {
    CHITAVERSE token;
    address owner = address(this);
    address user1 = address(0x1337);
    address user2 = address(0x1338);
    
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    MockPair mockPair;

    function setUp() public {
        // Mock WBNB
        MockWETH mockWBNB = new MockWETH();
        vm.etch(WBNB_ADDRESS, address(mockWBNB).code);
        
        // Create mock router at fixed address
        mockPair = new MockPair();
        MockFactory mockFactory = new MockFactory(address(mockPair));
        MockRouter mockRouter = new MockRouter();
        bytes memory routerCode = address(mockRouter).code;
        vm.etch(ROUTER_ADDRESS, routerCode);
        MockRouter(ROUTER_ADDRESS).initialize(address(mockFactory));
        
        // Deploy token contract
        token = new CHITAVERSE();
        
        // Configure token
        token.setTxLimit(type(uint256).max);
        token.cooldownEnabled(false, 0);
        token.setSwapBackSettings(false, 0);
        token.setIsFeeExempt(owner, false); // Ensure owner not exempt
        
        // Get pair address and launch token
        address pairAddress = token.pair();
        token.transfer(pairAddress, 1e18); // Triggers launch
        
        // Skip blocks to exit initial fee period
        vm.roll(block.number + 6);
        
        // Distribute test funds
        uint256 totalSupply = token.totalSupply();
        token.transfer(user1, totalSupply / 3);
    }

    function test_SafeMathSubtractionUnderflow() public {
        console.log("--- BEFORE-Trigger FeeSetting ---");
        console.log("Current fees: [Reflection, Liquidity, Marketing, FeeDenominator]");
        
        console.log("--- Trigger FeeSetting ---");
        token.setFees(50, 50, 50, 100); // 250% total fees
        
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 user1Balance = token.balanceOf(user1);
        uint256 user2Balance = token.balanceOf(user2);
        console.log("User1 balance:", user1Balance);
        console.log("User2 balance:", user2Balance);
        
        console.log("--- Trigger Transfer (Expect Underflow) ---");
        vm.prank(user1);
        vm.expectRevert("SafeMath: subtraction overflow");
        token.transfer(user2, user1Balance);
        
        console.log("--- AFTER-Trigger Transfer ---");
        console.log("Underflow revert detected as expected");
        
        console.log("Vulnerability Exists: SafeMath subtraction overflow occurs with fee settings > 100%");
    }
}