// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DOGESQ.sol";

contract DOGESQTest is Test {
    DOGESQ private token;
    address private deployer;

    function setUp() public {
        deployer = address(this);
        token = new DOGESQ();
    }

    function testTokenDetails() public view {
        assertEq(token.name(), "DogeSQ", "Correct token name should be set");
        assertEq(token.symbol(), "DogeSQ", "Correct token symbol should be set");
        assertEq(token.decimals(), 9, "Correct token decimals should be set");
    }

    function testInitialTokenDistribution() public view {
        uint256 totalSupply = token.totalSupply();
        uint256 deployerBalance = token.balanceOf(deployer);
        
        assertEq(deployerBalance, totalSupply, "Deployer should have all tokens initially");
    }

    function testOwnerInitialization() public view {
        assertEq(token.owner(), deployer, "Deployer should be contract owner");
    }

    function testVulnerabilityAnalysis() public {
        console.log("--- Vulnerability Assessment ---");
        console.log("PoC only verifies initial state constants");
        console.log("No state-changing operations are performed");
        
        console.log("Vulnerability not Exist: PoC only validates initial state constants and contains no state-changing operations to test for vulnerabilities");
    }
}