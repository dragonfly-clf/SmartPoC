// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoneyCore.sol";
import "../src/MoneyCore.sol";

contract MoneyStateInconsistencyTest is Test {
    MoneyCore public moneyCore;
    MoneyCtrl public moneyCtrl;
    
    address public constant INITIAL_ACCOUNT = address(0x100);
    address public constant UPDATED_ACCOUNT = address(0x200);
    address public constant USER = address(0x300);
    address public signerServer;
    
    uint256 public constant INITIAL_BALANCE = 1000 ether;
    uint256 public constant WITHDRAW_AMOUNT = 100 ether;
    bytes32 public CONTROL_ROLE;

    function computeRole(string memory roleName) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(roleName));
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function getSignature(uint256 nonce, uint256 timestamp) public view returns (bytes memory) {
        bytes memory message = abi.encodePacked(
            uint256(uint160(address(moneyCore))),
            uint256(uint160(USER)),
            WITHDRAW_AMOUNT,
            nonce,
            uint256(1),
            timestamp
        );
        bytes32 ethSignedMsg = toEthSignedMessageHash(keccak256(message));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, ethSignedMsg);
        return abi.encodePacked(r, s, v);
    }

    function setUp() public {
        // Deploy contracts
        moneyCore = new MoneyCore(INITIAL_BALANCE, INITIAL_ACCOUNT);
        moneyCtrl = new MoneyCtrl(address(moneyCore));
        
        // Compute roles
        CONTROL_ROLE = computeRole("CONTROL_ROLE");

        // Setup signer
        signerServer = vm.addr(1);  // Test account #1 signs

        // Setup control permissions
        vm.startPrank(moneyCore.owner());
        moneyCore.grantRole(CONTROL_ROLE, address(moneyCtrl)); 
        // Grant test contract the CONTROL_ROLE
        moneyCore.grantRole(CONTROL_ROLE, address(this));
        moneyCtrl.setSignServerAddress(signerServer);
        vm.stopPrank();

        // Fund operational account
        vm.prank(moneyCore.owner());
        moneyCore.transfer(INITIAL_ACCOUNT, INITIAL_BALANCE);
    }
    
    function testStateInconsistencyCausesWithdrawalFailure() public {
        // Change account without transferring funds
        vm.prank(moneyCore.owner());
        moneyCore.setAccount(UPDATED_ACCOUNT);
        
        // Prepare withdrawal data
        uint256 nonce = 0;
        uint256 timestamp = block.timestamp;
        bytes memory signature = getSignature(nonce, timestamp);
        
        console.log("--- Initial State BEFORE Withdraw ---");
        uint256 initialBefore = moneyCore.balanceOf(INITIAL_ACCOUNT);
        uint256 updatedBefore = moneyCore.balanceOf(UPDATED_ACCOUNT);
        uint256 userBefore = moneyCore.balanceOf(USER);
        address currentAccountBefore = moneyCore.getAccount();
        
        console.log("Initial Account Balance:", initialBefore);
        console.log("Updated Account Balance:", updatedBefore);
        console.log("USER Account Balance:", userBefore);
        console.log("Current Account Address:", currentAccountBefore);
        
        console.log("--- Trigger Withdrawal Attempt ---");
        vm.prank(USER);
        vm.expectRevert("Withdraw failed, reason: amount not enough");
        moneyCtrl.withDraw(
            1,
            WITHDRAW_AMOUNT,
            timestamp,
            signature
        );
        
        console.log("--- Final State AFTER Withdraw ---");
        uint256 initialAfter = moneyCore.balanceOf(INITIAL_ACCOUNT);
        uint256 updatedAfter = moneyCore.balanceOf(UPDATED_ACCOUNT);
        uint256 userAfter = moneyCore.balanceOf(USER);
        address currentAccountAfter = moneyCore.getAccount();
        
        console.log("Initial Account Balance:", initialAfter);
        console.log("Updated Account Balance:", updatedAfter);
        console.log("USER Account Balance:", userAfter);
        console.log("Current Account Address:", currentAccountAfter);
        
        // Verify state consistency
        bool balancesUnchanged = 
            initialBefore == initialAfter && 
            updatedBefore == updatedAfter && 
            userBefore == userAfter;
            
        bool accountUnchanged = currentAccountBefore == currentAccountAfter;
        
        console.log("--- Comparison Verdict ---");
        console.log("Balances unchanged?:", balancesUnchanged ? "YES" : "NO");
        console.log("Account unchanged?:", accountUnchanged ? "YES" : "NO");
        
        // Final vulnerability verdict
        if(balancesUnchanged && accountUnchanged) {
            console.log("Vulnerability Exists: State remains unchanged due to withdrawal failure caused by account-state inconsistency");
        } else {
            console.log("Vulnerability not Exist: State changed unexpectedly during failed withdrawal");
        }
        
        // Original balance assertions
        assertEq(initialAfter, INITIAL_BALANCE, "Funds not moved");
        assertEq(updatedAfter, 0, "New account shouldn't have balance");
    }
}