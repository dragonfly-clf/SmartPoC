// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RewardToken.sol";

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }

    function createPair(address, address) external pure returns (address) {
        return address(0);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0);
    }
}

contract TestToken is RewardToken {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 supply_,
        uint8 decimals_,
        address rewardToken_,
        uint256 rewardsFee_,
        uint256 minTokens_,
        uint256[] memory fees_,
        address marketingWalletAddress_,
        address router_,
        address addr_
    ) RewardToken(
        name_,
        symbol_,
        supply_,
        decimals_,
        rewardToken_,
        rewardsFee_,
        minTokens_,
        fees_,
        marketingWalletAddress_,
        router_,
        addr_
    ) {}

    function externalMint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}

contract RewardTokenTest is Test {
    TestToken token;
    address owner = makeAddr("owner");
    address receiver = makeAddr("receiver");
    uint256 initialSupply = 1000 * 1e18;
    
    MockFactory factory;
    MockRouter router;

    function setUp() public {
        vm.startPrank(owner);
        address weth = address(0x1);
        factory = new MockFactory();
        router = new MockRouter(address(factory), weth);
        
        uint256[] memory fees = new uint256[](3);
        fees[0] = 1;  
        fees[1] = 1;  
        fees[2] = 0; 

        token = new TestToken(
            "TestToken", 
            "TT", 
            initialSupply, 
            18, 
            address(0x2),
            2,
            10,
            fees,
            address(0x3),
            address(router),
            owner
        );
        vm.stopPrank();
    }

    function test_MintCausesOverflow() public {
        // Record original balance
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 originalBalance = token.balanceOf(owner);
        console.log("Owner original balance:", originalBalance);
        
        // Calculate problematic mint amount
        uint256 amountToMint = type(uint256).max - originalBalance + 1;
        
        // Attempt overflow mint (expected to revert)
        console.log("--- Trigger Mint (should cause revert) ---");
        vm.expectRevert();
        token.externalMint(owner, amountToMint);
        
        // Check balance after mint attempt
        console.log("--- AFTER-Trigger Mint ---");
        uint256 newBalance = token.balanceOf(owner);
        console.log("Owner new balance:", newBalance);
        
        // Compare results
        console.log("--- Comparison Result ---");
        if (originalBalance != newBalance) {
            console.log("Vulnerability Exists: Owner balance changed despite revert, indicating state corruption");
            console.log("Vulnerability Exists: Balance changed despite revert (potential overflow occurred)");
        } else {
            console.log("Vulnerability not Exist: Contract correctly reverts without state changes");
        }
    }
}