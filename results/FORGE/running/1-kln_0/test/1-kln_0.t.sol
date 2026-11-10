// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KLingToken.sol";

contract ValidMockSigner {
    function isValidSignature(bytes32, bytes memory) external pure returns (bytes4) {
        return bytes4(0x1626ba7e); // ERC-1271 magic value
    }
}

contract KLingTokenTest is Test {
    KLingToken token;
    address owner = address(0x1);
    address user = address(0x3);
    bytes32 private constant SIGNATURE_PERMIT_TYPEHASH = 
        keccak256("Claim(address user,uint256 amount,uint256 slot,uint256 deadline)");

    function setUp() public {
        vm.startPrank(owner);
        token = new KLingToken(address(this));
        vm.stopPrank();
    }
    
    function testDirectMintingByOwner() public {
        console.log("--- START: testDirectMintingByOwner ---");
        
        // Record initial state
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 userBalanceBefore = token.balanceOf(user);
        console.log("BEFORE-Trigger State:");
        console.log("  Total supply:      ", totalSupplyBefore);
        console.log("  User balance:      ", userBalanceBefore);
        console.log("");

        // Record and log the trigger action
        uint256 mintAmount = 1000e18;
        console.log("--- TRIGGER: Owner minting tokens ---");
        vm.prank(owner);
        token.mint(user, mintAmount);
        
        // Record and log post-trigger state
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 userBalanceAfter = token.balanceOf(user);
        console.log("\nAFTER-Trigger State:");
        console.log("  Total supply:      ", totalSupplyAfter);
        console.log("  User balance:      ", userBalanceAfter);
        console.log("");

        // Calculate and display token inflation
        uint256 supplyIncrease = totalSupplyAfter - totalSupplyBefore;
        uint256 balanceIncrease = userBalanceAfter - userBalanceBefore;
        console.log("Token Inflation Results:");
        console.log("  Total supply increase: ", supplyIncrease);
        console.log("  User balance increase: ", balanceIncrease);
        
        // Verify vulnerability and print final verdict
        if (supplyIncrease == mintAmount && balanceIncrease == mintAmount) {
            console.log("Vulnerability Exists: Owner can directly mint tokens causing arbitrary token inflation");
        } else {
            console.log("Vulnerability not Exist: Token inflation not observed in state changes");
        }
        console.log("--- END ---\n");
    }
    
    function testSignerMintingViaClaim() public {
        console.log("--- START: testSignerMintingViaClaim ---");
        
        // Deploy and configure mock signer that implements ERC-1271
        ValidMockSigner mockSigner = new ValidMockSigner();
        vm.startPrank(owner);
        token.signerAddressUpdate(address(mockSigner));
        token.claimStateUpdate(true);
        vm.stopPrank();
        
        // Set claim parameters
        uint256 claimAmount = 2000e18;
        uint256 deadline = block.timestamp + 1 days;
        bytes memory dummySignature = hex"1234";
        
        // Build claim parameters
        bytes memory params = abi.encode(
            dummySignature,
            user,
            claimAmount,
            uint256(0),
            deadline
        );
        
        // Record and log initial state
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 userBalanceBefore = token.balanceOf(user);
        console.log("BEFORE-Trigger State:");
        console.log("  Total supply:      ", totalSupplyBefore);
        console.log("  User balance:      ", userBalanceBefore);
        console.log("");

        // Record and log the trigger action
        console.log("--- TRIGGER: User claiming tokens ---");
        vm.prank(user);
        token.claim(params);
        
        // Record and log post-trigger state
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 userBalanceAfter = token.balanceOf(user);
        console.log("\nAFTER-Trigger State:");
        console.log("  Total supply:      ", totalSupplyAfter);
        console.log("  User balance:      ", userBalanceAfter);
        console.log("");

        // Calculate and display token inflation
        uint256 supplyIncrease = totalSupplyAfter - totalSupplyBefore;
        uint256 balanceIncrease = userBalanceAfter - userBalanceBefore;
        console.log("Token Inflation Results:");
        console.log("  Total supply increase: ", supplyIncrease);
        console.log("  User balance increase: ", balanceIncrease);
        
        // Verify vulnerability and print final verdict
        if (supplyIncrease == claimAmount && balanceIncrease == claimAmount) {
            console.log("Vulnerability Exists: Signer can mint arbitrary tokens via claim mechanism");
        } else {
            console.log("Vulnerability not Exist: Token inflation through claim not observed");
        }
        console.log("--- END ---\n");
    }
}