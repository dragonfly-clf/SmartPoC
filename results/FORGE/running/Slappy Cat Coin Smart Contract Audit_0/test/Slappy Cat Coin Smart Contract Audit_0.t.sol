// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SlappyCat.sol";

contract FailingERC20 {
    mapping(address => uint256) public balanceOf;
    
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
    
    function mint(address account, uint256 amount) external {
        balanceOf[account] = amount;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x789);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }
}

contract SlappyCatTest is Test {
    SlappyCat token;
    FailingERC20 failingToken;
    address owner = address(1);
    address constant TESTNET_ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address mockFactory;
    address mockWETH = address(0x456);
    
    function setUp() public {
        // Set up test environment with chain ID 97 (Testnet)
        vm.chainId(97);
        
        // Deploy mock factory
        mockFactory = address(new MockFactory());
        
        // Create and deploy mock router at the testnet router address
        MockRouter mockRouter = new MockRouter(mockFactory, mockWETH);
        bytes memory mockRouterCode = address(mockRouter).code;
        vm.etch(TESTNET_ROUTER, mockRouterCode);

        // Deploy contracts
        vm.startPrank(owner);
        token = new SlappyCat();
        failingToken = new FailingERC20();
        failingToken.mint(address(token), 100 ether);
        vm.stopPrank();
    }

    function test_ClaimStuckTokensFailsSilently() public {
        // Capture state BEFORE transaction
        console.log("--- BEFORE-Trigger Operation ---");
        uint256 contractBalanceBefore = failingToken.balanceOf(address(token));
        uint256 ownerBalanceBefore = failingToken.balanceOf(owner);
        console.log("Contract token balance (before):", contractBalanceBefore);
        console.log("Owner token balance (before):", ownerBalanceBefore);

        // Execute critical operation
        console.log("");
        console.log("--- Trigger Operation: claimStuckTokens ---");
        vm.prank(owner);
        token.claimStuckTokens(address(failingToken));

        // Capture state AFTER transaction
        console.log("");
        console.log("--- AFTER-Trigger Operation ---");
        uint256 contractBalanceAfter = failingToken.balanceOf(address(token));
        uint256 ownerBalanceAfter = failingToken.balanceOf(owner);
        console.log("Contract token balance (after):", contractBalanceAfter);
        console.log("Owner token balance (after):", ownerBalanceAfter);

        // Differential validation
        console.log("");
        console.log("--- Differential Analysis ---");
        bool contractUnchanged = contractBalanceAfter == contractBalanceBefore;
        bool ownerUnchanged = ownerBalanceAfter == ownerBalanceBefore;
        console.log("Contract balance unchanged?", contractUnchanged ? "YES" : "NO");
        console.log("Owner balance unchanged?", ownerUnchanged ? "YES" : "NO");
        
        // Final vulnerability determination
        console.log("");
        if (contractUnchanged && ownerUnchanged) {
            console.log("Vulnerability Exists: Failed transfer didn't revert transaction");
        } else {
            console.log("Vulnerability not Exist: Balances changed unexpectedly");
        }

        // Assert existing verifications
        assertEq(contractBalanceAfter, 100 ether, "Contract should retain tokens");
        assertEq(ownerBalanceAfter, 0, "Owner shouldn't receive tokens");
    }
}