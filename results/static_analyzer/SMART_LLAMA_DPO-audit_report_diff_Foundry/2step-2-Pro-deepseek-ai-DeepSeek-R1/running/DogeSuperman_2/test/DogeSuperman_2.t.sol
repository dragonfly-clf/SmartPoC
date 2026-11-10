// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DogeSuperman.sol";

contract DogeSupermanTest is Test {
    DogeSuperman token;
    address constant OWNER = 0xE536307a914BCE3dc231F8ca30e5e19D72F460fb;
    address constant TEST_TOKEN = address(0xDEAD);
    address constant MALICIOUS_ROUTER = address(0xBEEF);
    address constant MALICIOUS_FACTORY = address(0xCAFE);
    address constant MALICIOUS_PAIR = address(0xFACE);
    address constant MOCK_WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public {
        // Mock hardcoded router address calls
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E), // Original router address
            abi.encodeWithSignature("factory()"),
            abi.encode(address(this))
        );
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2))
        );
        
        // Mock factory.createPair response
        vm.mockCall(
            address(this),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MALICIOUS_PAIR)
        );

        // Deploy token as owner
        vm.startPrank(OWNER);
        token = new DogeSuperman();
        vm.stopPrank();
    }

    function testRouterChangeVulnerability() public {
        console.log("--- BEFORE-Trigger Router and Pair ---");
        address routerBefore = address(token.uniswapV2Router());
        address pairBefore = token.uniswapV2Pair();
        console.log("Original Router Address:", routerBefore);
        console.log("Original Pair Address:", pairBefore);

        vm.startPrank(OWNER);
        console.log("--- Trigger set_New_Router_and_Make_Pair ---");
        
        // Mock malicious router calls
        vm.mockCall(
            MALICIOUS_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(MALICIOUS_FACTORY)
        );
        vm.mockCall(
            MALICIOUS_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0))
        );
        
        // Mock factory.createPair response
        vm.mockCall(
            MALICIOUS_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MALICIOUS_PAIR)
        );

        token.set_New_Router_and_Make_Pair(MALICIOUS_ROUTER);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Router and Pair ---");
        address routerAfter = address(token.uniswapV2Router());
        address pairAfter = token.uniswapV2Pair();
        console.log("Post-Action Router Address:", routerAfter);
        console.log("Post-Action Pair Address:", pairAfter);

        bool routerChanged = (routerAfter == MALICIOUS_ROUTER);
        bool pairChanged = (pairAfter == MALICIOUS_PAIR);
        console.log("Router Changed to Malicious:", routerChanged);
        console.log("Pair Changed to Malicious:", pairChanged);
        
        if(routerChanged && pairChanged) {
            console.log("Vulnerability Exists: Malicious router/pair setup successful");
        } else {
            console.log("Vulnerability not Exist: Router/pair change failed");
        }
    }

    function testOwnTokenRemoval() public {
        console.log("--- BEFORE-Trigger Random Removal ---");
        uint256 balBefore = token.balanceOf(address(token));
        console.log("Contract Token Balance before:", balBefore);

        vm.startPrank(OWNER);
        console.log("--- Trigger remove_Random_Tokens ---");
        vm.expectRevert("Can not remove native token");
        token.remove_Random_Tokens(address(token), OWNER, 100 ether);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Random Removal ---");
        uint256 balAfter = token.balanceOf(address(token));
        console.log("Contract Token Balance after:", balAfter);
        
        if(balAfter == balBefore) {
            console.log("Vulnerability not Exist: Own token removal prevented (balance unchanged)");
        } else {
            console.log("Vulnerability Exists: Own token removal succeeded");
        }
    }

    function testPairChangeVulnerability() public {
        console.log("--- BEFORE-Trigger Pair Change ---");
        address pairBefore = token.uniswapV2Pair();
        console.log("Original Pair Address:", pairBefore);

        vm.startPrank(OWNER);
        console.log("--- Trigger set_New_Pair_Address ---");
        token.set_New_Pair_Address(MALICIOUS_PAIR);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Pair Change ---");
        address pairAfter = token.uniswapV2Pair();
        console.log("Post-Action Pair Address:", pairAfter);
        
        if(pairAfter == MALICIOUS_PAIR) {
            console.log("Vulnerability Exists: Pair changed successfully");
        } else {
            console.log("Vulnerability not Exist: Pair change failed");
        }
    }
    
    // Mock function (caller address must match mocked target)
    function createPair(address, address) external pure returns (address) {
        return MALICIOUS_PAIR;
    }
}