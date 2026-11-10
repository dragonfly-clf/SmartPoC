// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YeetFlokiToken.sol";

contract MockRouter {
    MockFactory public factoryContract;
    address public immutable weth;
    
    constructor() {
        factoryContract = new MockFactory();
        weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
    
    function factory() external view returns (address) {
        return address(factoryContract);
    }
    
    function WETH() external view returns (address) {
        return weth;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
}

contract YeetFlokiTokenFeeTest is Test {
    YeetFlokiToken token;
    address owner = address(0x1);
    
    function setUp() public {
        vm.startPrank(owner);
        MockRouter mockRouter = new MockRouter();
        token = new YeetFlokiToken(address(mockRouter));
        vm.stopPrank();
    }

    function testTaxManipulation() public {
        uint256 excessFee = 26;
        
        console.log("--- BEFORE-Trigger Taxes ---");
        (uint256 rfiBefore, uint256 devBefore, uint256 liquidityBefore, uint256 burnBefore) = token.taxes();
        console.log("Pre-trigger taxes:");
        console.log("  rfi:    %s", rfiBefore);
        console.log("  dev:    %s", devBefore);
        console.log("  liquid: %s", liquidityBefore);
        console.log("  burn:   %s", burnBefore);

        console.log("--- Trigger setTaxes(26) ---");
        vm.prank(owner);
        token.setTaxes(excessFee, excessFee, excessFee, excessFee);
        
        console.log("--- AFTER-Trigger Taxes ---");
        (uint256 rfiAfter, uint256 devAfter, uint256 liquidityAfter, uint256 burnAfter) = token.taxes();
        console.log("Post-trigger taxes:");
        console.log("  rfi:    %s", rfiAfter);
        console.log("  dev:    %s", devAfter);
        console.log("  liquid: %s", liquidityAfter);
        console.log("  burn:   %s", burnAfter);
        
        bool allSetToExcess = (rfiAfter == excessFee) &&
                              (devAfter == excessFee) &&
                              (liquidityAfter == excessFee) &&
                              (burnAfter == excessFee);
        
        if (allSetToExcess) {
            console.log("VULN VERDICT: Taxes successfully set beyond 25%% threshold");
            console.log("Vulnerability Exists: Owner can bypass tax safety limits");
        } else {
            console.log("VULN VERDICT: Taxes not set to unsafe 26%% values");
            console.log("Vulnerability not Exist: Contract prevents unsafe tax settings");
        }
    }
}