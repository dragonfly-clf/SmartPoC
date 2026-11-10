// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/Mobsterblox.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public factory;
    address public immutable WETH;
    
    constructor() {
        factory = address(new MockFactory());
        WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract MobsterbloxFeeTest is Test {
    Mobsterblox token;
    address owner = address(0x1);
    address devWallet = address(0x2);
    address tokenOwner = address(0x3);
    address service = address(0x4);
    address router;

    function setUp() public {
        router = address(new MockRouter());
        
        token = new Mobsterblox(
            "TestToken",     // _NAME
            "TT",            // _SYMBOL
            18,              // _DECIMALS
            1_000_000,       // _supply
            1,               // _txFee (1%)
            1,               // _lpFee (1%)
            1,               // _DexFee (1%)
            router,          // routerAddress
            devWallet,       // feeaddress
            tokenOwner,      // tokenOwner
            service          // service
        );
        
        // Transfer ownership to test owner
        vm.prank(tokenOwner);
        token.transferOwnership(owner);
    }

    function testSetTaxFeeAboveLimit() public {
        console2.log("--- Trigger Action ---");
        console2.log("Calling setTaxFeePercent(26) as owner");
        
        vm.prank(owner);
        try token.setTaxFeePercent(26) {
            console2.log("Result: Function executed without revert!");
            console2.log("Final Verdict: Vulnerability Exists - Fee can be set above 25% limit");
        } catch Error(string memory reason) {
            console2.log("Result: Reverted with reason: %s", reason);
            console2.log("Final Verdict: Vulnerability not Exist - Reverted as expected");
        } catch {
            console2.log("Result: Reverted without reason string");
            console2.log("Final Verdict: Vulnerability not Exist - Reverted as expected");
        }
    }

    function testSetDevFeeAboveLimit() public {
        console2.log("--- Trigger Action ---");
        console2.log("Calling setDevFeePercent(26) as owner");
        
        vm.prank(owner);
        try token.setDevFeePercent(26) {
            console2.log("Result: Function executed without revert!");
            console2.log("Final Verdict: Vulnerability Exists - Fee can be set above 25% limit");
        } catch Error(string memory reason) {
            console2.log("Result: Reverted with reason: %s", reason);
            console2.log("Final Verdict: Vulnerability not Exist - Reverted as expected");
        } catch {
            console2.log("Result: Reverted without reason string");
            console2.log("Final Verdict: Vulnerability not Exist - Reverted as expected");
        }
    }

    function testSetLiquidityFeeAboveLimit() public {
        console2.log("--- Trigger Action ---");
        console2.log("Calling setLiquidityFeePercent(26) as owner");
        
        vm.prank(owner);
        try token.setLiquidityFeePercent(26) {
            console2.log("Result: Function executed without revert!");
            console2.log("Final Verdict: Vulnerability Exists - Fee can be set above 25% limit");
        } catch Error(string memory reason) {
            console2.log("Result: Reverted with reason: %s", reason);
            console2.log("Final Verdict: Vulnerability not Exist - Reverted as expected");
        } catch {
            console2.log("Result: Reverted without reason string");
            console2.log("Final Verdict: Vulnerability not Exist - Reverted as expected");
        }
    }
}