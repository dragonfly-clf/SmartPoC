// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract CoinTokenTaxFeeTest is Test {
    CoinToken token;
    
    address deployer = address(0x100);
    address marketingAddress = address(0x200);
    address lpPool = address(0x300);
    address uniswapRouter;
    address mockWETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Valid WETH address
    uint256 initialSupply = 1000000 * 10**9;
    uint256 initialEth = 1 ether;

    function setUp() public {
        address mockFactory = address(new MockFactory());
        uniswapRouter = address(new MockRouter(mockFactory, mockWETH));
        
        vm.deal(deployer, initialEth);
        vm.prank(deployer);
        token = new CoinToken{value: initialEth}(
            "TestToken", 
            "TT", 
            initialSupply / 10**9,
            1, 
            1, 
            1,
            marketingAddress,
            uniswapRouter,
            lpPool
        );
    }

    function testFeeManipulation() public {
        uint256[] memory testTaxes = new uint256[](4);
        testTaxes[0] = 25;
        testTaxes[1] = 99;
        testTaxes[2] = 100;
        testTaxes[3] = 1000;

        for (uint256 i = 0; i < testTaxes.length; i++) {
            uint256 newFee = testTaxes[i];

            console.log("--- BEFORE-Trigger: TaxFee value ---");
            uint256 preTaxFee = token._taxFee();
            console.log("Pre-set _taxFee:", preTaxFee);

            console.log("--- Trigger setTaxFee(%s) ---", newFee);
            vm.prank(deployer);
            token.setTaxFee(newFee);

            console.log("--- AFTER-Trigger: TaxFee value ---");
            uint256 postTaxFee = token._taxFee();
            console.log("Post-set _taxFee:", postTaxFee);

            bool changed = postTaxFee != preTaxFee;
            bool matchesTarget = postTaxFee == newFee;
            console.log("State changed:", changed ? "YES" : "NO");
            console.log("Matches target:", matchesTarget ? "YES" : "NO");
        }

        // Final verification
        uint256 finalTaxFee = token._taxFee();
        bool vulnerabilityExists = (finalTaxFee == 1000);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Tax fee can be arbitrarily manipulated");
        } else {
            console.log("Vulnerability not Exist: Tax fee remains unchanged");
        }
    }

    function testNonOwnerAccess() public {
        address attacker = address(0x666);
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxFee(5);
    }
}

contract MockRouter {
    address public factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return 0x000000000000000000000000000000000000dEaD; // Return dead address
    }
}