// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/APTD.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xabcdefabcdefabcdefabcdefabcdefabcdefab);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory) {
        factory = _factory;
        WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }

    // V1 function that uses deprecated return structure
    function swapExactTokensForETH(
        uint, /*amountIn*/
        uint, /*amountOutMin*/
        address[] calldata, /*path*/
        address, /*to*/
        uint /*deadline*/
    ) external pure returns (uint[] memory amounts) {
        amounts = new uint256[](2);
        amounts[0] = 1 ether;
        amounts[1] = 1 ether;
    }
}

contract APTDTest is Test {
    APTD aptd;
    address constant owner = address(0x7c8999dC9a822c1f0Df42023113EDB4FDd543266);
    address constant deployer = 0x22ba8aAb4c60Ac95e61CFC41dF8d2675aeb87C0b;
    address constant user = address(0x1234567890123456789012345678901234567890);
    address constant realRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock router and factory
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Replace real router code with mock that implements only V1 functions
        vm.etch(realRouter, address(mockRouter).code);
        
        // Deploy APTD contract
        vm.startPrank(deployer);
        aptd = new APTD();
        
        // Configure contract settings
        aptd.tradingStatus(true);
        vm.stopPrank();
    }

    function testRouterVersionIncompatibility() public {
        vm.startPrank(deployer);
        // Set realistic swap threshold (uses token's base unit)
        aptd.setSwapBackSettings(true, 1e13);
        
        // Transfer manageable amount to meet swap threshold
        aptd.transfer(address(aptd), 1e13);
        vm.stopPrank();

        console.log("--- BEFORE-Trigger: Balances ---");
        uint256 contractBalanceBefore = aptd.balanceOf(address(aptd));
        uint256 userBalanceBefore = aptd.balanceOf(user);
        console.log("Contract balance: %s", contractBalanceBefore);
        console.log("User balance: %s", userBalanceBefore);

        console.log("--- Trigger Transfer ---");
        // Attempt transfer to trigger swap
        vm.startPrank(deployer);
        (bool success, ) = address(aptd).call(
            abi.encodeWithSignature("transfer(address,uint256)", user, 1e12)
        );
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger: Balances ---");
        uint256 contractBalanceAfter = aptd.balanceOf(address(aptd));
        uint256 userBalanceAfter = aptd.balanceOf(user);
        console.log("Contract balance: %s", contractBalanceAfter);
        console.log("User balance: %s", userBalanceAfter);

        string memory result = success ? "SUCCEEDED" : "REVERTED";
        console.log("Transfer result: %s", result);
        
        // Vulnerability verdict
        if (!success) {
            console.log("Vulnerability Exists: Transfer reverted due to router incompatibility");
        } else {
            console.log("Vulnerability not Exist: Swap executed without reverting");
        }
        
        // Conditional test case failure
        assertTrue(!success, "Transfer should have reverted");
    }
}