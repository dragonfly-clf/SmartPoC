// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZOUTBREAK.sol";

contract ZOUTBREAKSecurityTest is Test {
    ZOUTBREAK token;
    address owner = makeAddr("Owner");
    address chiefSecurityOfficer = makeAddr("ChiefSecurityOfficer");
    address regularUser = makeAddr("RegularUser");
    
    // Mocked addresses
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address factory;
    address weth;
    address pair;

    function setUp() public {
        // Create mock addresses
        factory = makeAddr("MockFactory");
        weth = makeAddr("MockWETH");
        pair = makeAddr("MockPair");
        
        // Mock router calls
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(factory)
        );
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(weth)
        );
        
        // Mock factory createPair call
        vm.mockCall(
            factory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(pair)
        );

        vm.startPrank(owner);
        token = new ZOUTBREAK();
        token.F03__Enable_Public_Trading();

        // Transfer initial tokens to participants
        uint256 decimals = token.decimals();
        uint256 amount = 1000 * 10 ** decimals;
        token.transfer(chiefSecurityOfficer, amount);
        token.transfer(regularUser, amount);
        
        // Transfer CSO role
        token.F27__CSO_Change__By_Chief_Security_Officer(chiefSecurityOfficer);
        
        vm.stopPrank();
    }

    function test_ChiefSecurityOfficerCanTrade() public {
        uint256 amount = 100 * 10 ** token.decimals();
        uint256 initialBalanceRegular = token.balanceOf(regularUser);
        uint256 initialBalanceCSO = token.balanceOf(chiefSecurityOfficer);

        console2.log("--- BEFORE-Trigger (CSO transfer) ---");
        console2.log("RegularUser balance:", initialBalanceRegular);
        console2.log("CSO balance:", initialBalanceCSO);

        console2.log("--- Trigger: CSO begins transfer to regularUser ---");
        vm.prank(chiefSecurityOfficer);
        token.transfer(regularUser, amount);
        console2.log("--- AFTER-Trigger (CSO transfer) ---");

        uint256 afterBalanceRegular = token.balanceOf(regularUser);
        uint256 afterBalanceCSO = token.balanceOf(chiefSecurityOfficer);
        console2.log("RegularUser balance:", afterBalanceRegular);
        console2.log("CSO balance:", afterBalanceCSO);

        // Check balance changes
        bool vulnerabilityExists = (afterBalanceRegular == initialBalanceRegular + amount) && 
                                  (afterBalanceCSO == initialBalanceCSO - amount);

        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: CSO successfully completed transaction");
        } else {
            console2.log("Vulnerability not Exist: CSO transaction failed");
        }

        assertEq(
            afterBalanceRegular,
            initialBalanceRegular + amount,
            "CSO trade should be allowed due to vulnerability"
        );
    }

    function test_RegularUserCanTrade() public {
        uint256 amount = 50 * 10 ** token.decimals();
        uint256 initialBalanceCSO = token.balanceOf(chiefSecurityOfficer);
        uint256 initialBalanceRegular = token.balanceOf(regularUser);
        
        console2.log("--- BEFORE-Trigger (RegularUser transfer) ---");
        console2.log("CSO balance:", initialBalanceCSO);
        console2.log("RegularUser balance:", initialBalanceRegular);
        
        console2.log("--- Trigger: RegularUser begins transfer to CSO ---");
        vm.prank(regularUser);
        token.transfer(chiefSecurityOfficer, amount);
        console2.log("--- AFTER-Trigger (RegularUser transfer) ---");
        
        uint256 afterBalanceCSO = token.balanceOf(chiefSecurityOfficer);
        uint256 afterBalanceRegular = token.balanceOf(regularUser);
        console2.log("CSO balance:", afterBalanceCSO);
        console2.log("RegularUser balance:", afterBalanceRegular);
        
        // Check balance changes
        bool normalBehavior = (afterBalanceCSO == initialBalanceCSO + amount) && 
                             (afterBalanceRegular == initialBalanceRegular - amount);
        
        if (normalBehavior) {
            console2.log("Vulnerability not Exist: Regular user transfer completed, normal behavior");
        } else {
            console2.log("Vulnerability Exists: Unexpected transaction failure");
        }

        assertEq(
            afterBalanceCSO,
            initialBalanceCSO + amount,
            "Regular user should be able to trade"
        );
    }
}