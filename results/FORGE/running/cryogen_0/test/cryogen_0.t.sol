// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BABYTOKEN.sol";

contract MockERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
    }
    
    function balanceOf(address) external view returns (uint256) {
        return 0;
    }
}

contract MockUniswapV2Router {
    address public factory;
    address public WETH;
    
    constructor() {
        factory = address(this);
        WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
    
    function createPair(address, address) external pure returns (address pair) {
        pair = address(0xDEADBEEF);
    }
}

contract MockUniswapV2Pair {
    function sync() external {}
}

contract BabyTokenTest is Test {
    BABYTOKEN token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
    uint256 initialSupply = 1000000 * 10**18;
    uint256 transferAmount = 500 * 10**18;
    
    MockUniswapV2Router mockRouter;
    address mockRewardToken;
    MockUniswapV2Pair mockPair;
    
    function setUp() public {
        // Deploy mock contracts
        mockRouter = new MockUniswapV2Router();
        mockPair = new MockUniswapV2Pair();
        mockRewardToken = address(new MockERC20("Reward", "RWRD"));
        
        address[4] memory addrs = [
            owner,                   // [0] owner
            mockRewardToken,         // [1] rewardToken
            address(mockRouter),     // [2] router
            address(0x3000)          // [3] marketing wallet
        ];
        
        vm.startPrank(owner);
        token = new BABYTOKEN();
        token.initialize(
            addrs,
            "TestToken",
            "TEST",
            initialSupply,
            0,   // tokenRewardsFee (0% for testing)
            0,   // liquidityFee (0% for testing)
            0,   // marketingFee (0% for testing)
            10 * 10**18 // min token balance for dividends
        );
        vm.stopPrank();
        
        // Set automated market maker pair
        vm.prank(owner);
        token.setAutomatedMarketMakerPair(address(mockPair), true);
        
        // Exclude test accounts from fees
        vm.startPrank(owner);
        token.excludeFromFees(user1, true);
        token.excludeFromFees(user2, true);
        vm.stopPrank();
        
        // Distribute tokens
        vm.prank(owner);
        token.transfer(user1, 1000 * 10**18);
    }

    function testBlacklistBlocksTransfers() public {
        console.log("==== Initial State ====");
        uint256 user1Initial = token.balanceOf(user1);
        uint256 user2Initial = token.balanceOf(user2);
        console.log("user1 initial balance:", user1Initial);
        console.log("user2 initial balance:", user2Initial);
        
        // First transfer (pre-blacklist)
        console.log("\n--- EXECUTING VALID TRANSFER (pre-blacklist) ---");
        uint256 preBlacklistUser2Balance = token.balanceOf(user2);
        vm.prank(user1);
        token.transfer(user2, transferAmount);
        uint256 postFirstTransferBalance = token.balanceOf(user2);
        uint256 firstDelta = postFirstTransferBalance - preBlacklistUser2Balance;
        
        console.log("user2 balance before transfer:", preBlacklistUser2Balance);
        console.log("user2 balance after transfer:", postFirstTransferBalance);
        console.log("Balance delta (should be 500e18):", firstDelta);
        assertEq(firstDelta, transferAmount, "First transfer failed");
        
        // Blacklist user1
        console.log("\n--- EXECUTING BLACKLIST OPERATION ---");
        vm.prank(owner);
        token.blacklistAddress(user1, true);
        console.log("Blacklisted user1");
        
        // Attempt to transfer after blacklist
        console.log("\n--- ATTEMPTING BLOCKED TRANSFER (post-blacklist) ---");
        uint256 preSecondTransferBalance = token.balanceOf(user2);
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(user2, transferAmount);
        uint256 postSecondTransferBalance = token.balanceOf(user2);
        uint256 secondDelta = postSecondTransferBalance - preSecondTransferBalance;
        
        console.log("user2 balance before transfer:", preSecondTransferBalance);
        console.log("user2 balance after transfer:", postSecondTransferBalance);
        console.log("Balance delta (should be 0):", secondDelta);
        
        // Final verdict
        bool vulnerabilityExists = (secondDelta == 0);
        console.log("\n==== Vulnerability Verification ====");
        console.log("Initial transfer succeeded:", firstDelta == transferAmount);
        console.log("Blacklist blocked transfer:", vulnerabilityExists);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Blacklist function successfully blocked transfers");
        } else {
            console.log("Vulnerability not Exist: Blacklist function failed to block transfers");
        }
    }
}