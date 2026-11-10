// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZOUTBREAK.sol";

contract MockUniswapV2Factory {
    address public pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockUniswapV2Pair {}

contract ZOUTBREAKPrivilegeEscalationTest is Test {
    ZOUTBREAK token;
    
    address deployer = address(0x01);
    address MaliciousActor = address(0x03);
    address oldCEO;
    address mockPair;
    MockUniswapV2Factory mockFactory;
    MockUniswapV2Router mockRouter;

    function setUp() public {
        mockPair = address(new MockUniswapV2Pair());
        mockFactory = new MockUniswapV2Factory(mockPair);
        mockRouter = new MockUniswapV2Router(address(mockFactory), address(0x456));
        vm.etch(0x10ED43C718714eb63d5aA57B78B54704E256024E, address(mockRouter).code);

        vm.startPrank(deployer);
        token = new ZOUTBREAK();
        vm.stopPrank();
        oldCEO = token.A13__CEO_Address();
    }

    function test_CSO_CanArbitrarilyChangeCEO() public {
        // Pre-trigger state capture
        console.log("--- BEFORE-Trigger State ---");
        address currentCEO = token.A13__CEO_Address();
        bool deployerExemptBefore = token.A20__Check_if_Account_is_Excluded_from_Paying_Fees(currentCEO);
        bool maliciousExemptBefore = token.A20__Check_if_Account_is_Excluded_from_Paying_Fees(MaliciousActor);
        console.log("CEO Address Before: %s", currentCEO);
        console.log("Old CEO Fee Exempt Before Change: %s", deployerExemptBefore);
        console.log("Malicious Address Fee Exempt Before Change: %s", maliciousExemptBefore);

        // Trigger action
        console.log("--- Trigger: F26__CEO_Change__By_Chief_Security_Officer ---");
        vm.prank(deployer);
        token.F26__CEO_Change__By_Chief_Security_Officer(MaliciousActor);

        // Post-trigger state capture
        console.log("--- AFTER-Trigger State ---");
        address newCEO = token.A13__CEO_Address();
        bool deployerExemptAfter = token.A20__Check_if_Account_is_Excluded_from_Paying_Fees(currentCEO);
        bool maliciousExemptAfter = token.A20__Check_if_Account_is_Excluded_from_Paying_Fees(MaliciousActor);
        console.log("CEO Address After: %s", newCEO);
        console.log("Old CEO Fee Exempt After Change: %s", deployerExemptAfter);
        console.log("New CEO Fee Exempt After Change: %s", maliciousExemptAfter);

        // Final verification
        bool changedSuccessfully = (newCEO == MaliciousActor);
        bool exemptionAdded = maliciousExemptAfter;
        bool exemptionRemoved = !deployerExemptAfter;
        bool exploitationSuccess = changedSuccessfully && exemptionAdded && exemptionRemoved;

        assertEq(newCEO, MaliciousActor, "CEO not changed to malicious actor");
        assertTrue(maliciousExemptAfter, "Malicious actor should be fee exempt");
        assertFalse(deployerExemptAfter, "Previous CEO still has fee exemption");

        // Print final verdict
        if (exploitationSuccess) {
            console.log("Vulnerability Exists: CEO address changed improperly and fee exemptions modified arbitrarily");
        } else {
            console.log("Vulnerability not Exist: CEO change and fee exemption modifications failed");
        }
    }

    function test_OldCEO_LosesFeesExemption() public {
        // Pre-trigger state capture
        console.log("--- BEFORE-Trigger State ---");
        bool oldCEOExemptBefore = token.A20__Check_if_Account_is_Excluded_from_Paying_Fees(oldCEO);
        console.log("Old CEO Fee Exempt Status Before Change: %s", oldCEOExemptBefore);

        // Trigger action
        console.log("--- Trigger: F26__CEO_Change__By_Chief_Security_Officer ---");
        vm.prank(deployer);
        token.F26__CEO_Change__By_Chief_Security_Officer(MaliciousActor);

        // Post-trigger state capture
        console.log("--- AFTER-Trigger State ---");
        bool oldCEOExemptAfter = token.A20__Check_if_Account_is_Excluded_from_Paying_Fees(oldCEO);
        console.log("Old CEO Fee Exempt Status After Change: %s", oldCEOExemptAfter);

        // Final verification
        bool exploitationSuccess = (oldCEOExemptBefore && !oldCEOExemptAfter);
        
        assertFalse(
            oldCEOExemptAfter,
            "Vulnerability not Exist: Previous CEO still has fee exemption"
        );

        // Print final verdict
        if (exploitationSuccess) {
            console.log("Vulnerability Exists: Old CEO improperly lost fee exemption");
        } else {
            console.log("Vulnerability not Exist: Fee exemption status unchanged or incorrect");
        }
    }
}