// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KLingToken.sol";

contract MockToken {
    mapping(address => uint256) public balanceOf;
    
    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract KLingTokenPrivilegeTest is Test {
    KLingToken token;
    MockToken mockToken;
    address deployer = makeAddr("deployer");
    address recipient = makeAddr("recipient");
    address attacker = makeAddr("attacker");
    
    uint256 initialEthBalance = 10 ether;
    uint256 initialMockTokenBalance = 1000e18;

    function setUp() public {
        // Deploy token contract with proper owner
        vm.startPrank(deployer);
        token = new KLingToken(deployer); // Deployer is both owner and signer
        mockToken = new MockToken(); // Deploy mock token contract
        vm.stopPrank();

        // Fund token contract with ETH
        vm.deal(address(token), initialEthBalance);
        
        // Fund token contract with mock tokens
        mockToken.mint(address(token), initialMockTokenBalance);
        
        // Ensure contract has the expected balances
        assertEq(address(token).balance, initialEthBalance);
        assertEq(mockToken.balanceOf(address(token)), initialMockTokenBalance);
    }

    // Test ETH transfer vulnerability
    function testAdminEmergencyEthTransfer() public {
        console.log("------ [TEST] ETH Emergency Transfer Vulnerability ------");
        uint256 initialRecipientBalance = recipient.balance;
        uint256 initialContractEth = address(token).balance;
        uint256 stolenAmount = 5 ether;

        console.log("[PRE] Contract ETH balance: ", initialContractEth);
        console.log("[PRE] Recipient's ETH balance: ", initialRecipientBalance);
        console.log("---> Triggering adminEmergency ETH transfer");
        
        // Simulate owner compromise by performing unauthorized transfer
        vm.prank(deployer);
        token.adminEmergency(address(0), recipient, stolenAmount);
        
        uint256 postContractEth = address(token).balance;
        uint256 postRecipientBalance = recipient.balance;
        
        console.log("[POST] Contract ETH balance: ", postContractEth);
        console.log("[POST] Recipient's ETH balance: ", postRecipientBalance);

        // Calculate differential changes
        uint256 contractLoss = initialContractEth - postContractEth;
        uint256 recipientGain = postRecipientBalance - initialRecipientBalance;
        bool ethVulnerable = (contractLoss == stolenAmount) && 
                            (recipientGain == stolenAmount);

        console.log("Contract ETH loss:", contractLoss);
        console.log("Recipient ETH gain:", recipientGain);
        
        if (ethVulnerable) {
            console.log("RESULT: Vulnerability Exists - Successfully diverted ETH funds");
        } else {
            console.log("RESULT: Vulnerability not Exist - ETH funds remain secure");
        }

        // Original assertions (should pass if vulnerable)
        assertEq(recipient.balance, initialRecipientBalance + stolenAmount, "ETH theft not detected");
        assertEq(address(token).balance, initialEthBalance - stolenAmount, "Contract ETH not depleted");
    }

    // Test token transfer vulnerability
    function testAdminEmergencyTokenTransfer() public {
        console.log("------ [TEST] Token Emergency Transfer Vulnerability ------");
        uint256 initialRecipientToken = mockToken.balanceOf(recipient);
        uint256 initialContractToken = mockToken.balanceOf(address(token));
        uint256 stolenAmount = 500e18;

        console.log("[PRE] Contract token balance: ", initialContractToken);
        console.log("[PRE] Recipient's token balance: ", initialRecipientToken);
        console.log("---> Triggering adminEmergency token transfer");
        
        // Simulate owner compromise by performing unauthorized transfer
        vm.prank(deployer);
        token.adminEmergency(address(mockToken), recipient, stolenAmount);

        uint256 postContractToken = mockToken.balanceOf(address(token));
        uint256 postRecipientToken = mockToken.balanceOf(recipient);
        
        console.log("[POST] Contract token balance: ", postContractToken);
        console.log("[POST] Recipient's token balance: ", postRecipientToken);

        // Calculate differential changes
        uint256 tokenContractLoss = initialContractToken - postContractToken;
        uint256 tokenRecipientGain = postRecipientToken - initialRecipientToken;
        bool tokenVulnerable = (tokenContractLoss == stolenAmount) && 
                            (tokenRecipientGain == stolenAmount);

        console.log("Contract token loss:", tokenContractLoss);
        console.log("Recipient token gain:", tokenRecipientGain);
        
        if (tokenVulnerable) {
            console.log("RESULT: Vulnerability Exists - Successfully diverted ERC20 funds");
        } else {
            console.log("RESULT: Vulnerability not Exist - Token funds remain secure");
        }

        // Original assertions (should pass if vulnerable)
        assertEq(
            mockToken.balanceOf(recipient),
            initialRecipientToken + stolenAmount,
            "Token theft not detected"
        );
        assertEq(
            mockToken.balanceOf(address(token)),
            initialMockTokenBalance - stolenAmount,
            "Contract tokens not depleted"
        );
    }

    // Test that non-owners cannot exploit vulnerability
    function testAttackerCannotCallAdminEmergency() public {
        uint256 initialContractBalance = address(token).balance;
        
        // Attacker tries to call privileged function
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.adminEmergency(address(0), attacker, initialContractBalance);
        
        // Verify funds are safe
        assertEq(address(token).balance, initialContractBalance, "Funds should be safe");
    }
}