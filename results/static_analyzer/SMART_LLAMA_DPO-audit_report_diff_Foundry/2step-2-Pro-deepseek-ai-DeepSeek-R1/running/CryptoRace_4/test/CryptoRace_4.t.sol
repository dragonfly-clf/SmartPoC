// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CryptoRace.sol";

contract PrivilegeEscalationTest is Test {
    CryptoRace cryptoRace;
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    
    function setUp() public {
        // Mock router calls during CryptoRace deployment
        address routerAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        // Mock router.factory() to return a valid factory address
        vm.mockCall(
            routerAddress,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(address(0xABCD))
        );
        
        // Mock router.WETH() to return a valid WBNB address
        vm.mockCall(
            routerAddress,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(address(0x1234))
        );
        
        // Mock factory.createPair() to return a valid pair address
        address mockFactoryAddress = address(0xABCD);
        vm.mockCall(
            mockFactoryAddress,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(address(0x1111))
        );
        
        // Deploy CryptoRace contract
        vm.startPrank(deployer);
        cryptoRace = new CryptoRace();
        vm.stopPrank();
    }

    function test_swap_settings_unauthorized_change() public {
        console.log("--- BEFORE-Trigger Call ---");
        console.log("Access control state: Intact");
        
        console.log("--- Trigger Unauthorized Call ---");
        vm.prank(attacker);
        vm.expectRevert("!AUTHORIZED");
        cryptoRace.setSwapBackSettings(true, 1000);
        
        console.log("--- AFTER-Trigger Call ---");
        console.log("Access control state: Intact");
        console.log("Vulnerability not Exist: Unauthorized call reverted as expected, access control enforced");
    }
}