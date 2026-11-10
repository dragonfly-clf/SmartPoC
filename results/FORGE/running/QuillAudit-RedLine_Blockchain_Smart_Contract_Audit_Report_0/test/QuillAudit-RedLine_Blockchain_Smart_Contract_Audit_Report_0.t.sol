// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

contract VulnerableDiamondDexToken {
    string public constant name = "VulnerableDexToken";
    string public constant symbol = "VDT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        uint256 currentAllowance = allowance[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: insufficient allowance");
        allowance[sender][msg.sender] = currentAllowance - amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        uint256 senderBalance = balanceOf[sender];
        require(senderBalance >= amount, "ERC20: insufficient balance");
        balanceOf[sender] = senderBalance - amount;
        balanceOf[recipient] += amount;
    }
}

contract DiamondDexTokenTransferTest is Test {
    VulnerableDiamondDexToken token;
    address owner = address(0xA);
    address alice = address(0xB);
    address bob = address(0xC);
    
    uint256 constant INITIAL_BALANCE = 1000 ether;

    function setUp() public {
        token = new VulnerableDiamondDexToken(INITIAL_BALANCE * 10);
        
        // Distribute initial funds
        token.transfer(alice, INITIAL_BALANCE);
        token.transfer(bob, INITIAL_BALANCE);
    }

    function testTransferToZeroAddressBurnsTokens() public {
        uint256 amount = 500 ether;
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 zeroBalanceBefore = token.balanceOf(address(0));
        
        console.log("--- BEFORE-Trigger Transfer ---");
        console.log("Alice's balance:", aliceBalanceBefore);
        console.log("Zero address balance:", zeroBalanceBefore);
        
        console.log("--- Trigger: Alice transfers to zero address ---");
        vm.prank(alice);
        token.transfer(address(0), amount);
        
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 zeroBalanceAfter = token.balanceOf(address(0));
        console.log("--- AFTER-Trigger Transfer ---");
        console.log("Alice's balance:", aliceBalanceAfter);
        console.log("Zero address balance:", zeroBalanceAfter);

        uint256 aliceDiff = aliceBalanceBefore - aliceBalanceAfter;
        uint256 zeroDiff = zeroBalanceAfter - zeroBalanceBefore;
        console.log("Alice balance difference:", aliceDiff);
        console.log("Zero address balance difference:", zeroDiff);
        
        bool burnedTokens = (aliceDiff == amount) && (zeroDiff == amount);
        if (burnedTokens) {
            console.log("Vulnerability Exists: Transfer to zero address successfully burns tokens");
        } else {
            console.log("Vulnerability not Exist: Transfer to zero address did not burn tokens as expected");
        }

        // Original assertions maintained
        assertEq(
            token.balanceOf(alice),
            aliceBalanceBefore - amount,
            "Alice's balance not decreased"
        );
        assertEq(
            token.balanceOf(address(0)),
            zeroBalanceBefore + amount,
            "Zero address didn't receive tokens"
        );
    }

    function testTransferFromToZeroAddressBurnsTokens() public {
        uint256 amount = 300 ether;
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 zeroBalanceBefore = token.balanceOf(address(0));
        
        console.log("--- BEFORE-Trigger TransferFrom ---");
        console.log("Alice's balance:", aliceBalanceBefore);
        console.log("Zero address balance:", zeroBalanceBefore);
        
        // Set allowance
        vm.prank(alice);
        token.approve(bob, amount);
        
        console.log("--- Trigger: Bob transfers from Alice to zero address ---");
        vm.prank(bob);
        token.transferFrom(alice, address(0), amount);
        
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 zeroBalanceAfter = token.balanceOf(address(0));
        console.log("--- AFTER-Trigger TransferFrom ---");
        console.log("Alice's balance:", aliceBalanceAfter);
        console.log("Zero address balance:", zeroBalanceAfter);

        uint256 aliceDiff = aliceBalanceBefore - aliceBalanceAfter;
        uint256 zeroDiff = zeroBalanceAfter - zeroBalanceBefore;
        console.log("Alice balance difference:", aliceDiff);
        console.log("Zero address balance difference:", zeroDiff);
        
        bool burnedTokens = (aliceDiff == amount) && (zeroDiff == amount);
        if (burnedTokens) {
            console.log("Vulnerability Exists: TransferFrom to zero address successfully burns tokens");
        } else {
            console.log("Vulnerability not Exist: TransferFrom to zero address did not burn tokens as expected");
        }

        // Original assertions maintained
        assertEq(
            token.balanceOf(alice),
            aliceBalanceBefore - amount,
            "Alice's balance not decreased"
        );
        assertEq(
            token.balanceOf(address(0)),
            zeroBalanceBefore + amount,
            "Zero address didn't receive tokens"
        );
    }
}