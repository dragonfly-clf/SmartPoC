// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

contract MinimalBetSwamp is Test {
    string private _name = "MinimalBetSwamp";
    string private _symbol = "MBETS";
    uint8 private _decimals = 9;
    address private _vault;
    address private _owner;
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function setVault(address vault_) external onlyOwner {
        _vault = vault_;
    }

    function vault() public view returns (address) {
        return _vault;
    }

    function mint(address account_, uint256 amount_) external onlyVault {
        _mint(account_, amount_);
    }

    function _mint(address account_, uint256 amount_) internal {
        _totalSupply += amount_;
        _balances[account_] += amount_;
        emit Transfer(address(0), account_, amount_);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    modifier onlyVault() {
        require(msg.sender == _vault, "Not vault");
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BetSwampMintTest is Test {
    MinimalBetSwamp token;
    address owner = address(0x1);
    address vaultAddr = address(0x2);
    address vaultUser = address(0x3);
    address hacker = address(0x4);

    function setUp() public {
        vm.startPrank(owner);
        token = new MinimalBetSwamp();
        token.setVault(vaultAddr);
        vm.stopPrank();
    }

    function testVaultCanMintArbitraryAmount() public {
        uint256 mintAmount = 1_000_000 * (10 ** 9);
        
        console.log("\n--- BEFORE-Trigger Mint ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 vaultUserBalanceBefore = token.balanceOf(vaultUser);
        console.log("Total Supply Before: %s", totalSupplyBefore);
        console.log("VaultUser Balance Before: %s", vaultUserBalanceBefore);
        
        console.log("--- Trigger Mint ---");
        vm.prank(vaultAddr);
        token.mint(vaultUser, mintAmount);
        console.log("Minted %s tokens to %s", mintAmount, vaultUser);
        
        console.log("--- AFTER-Trigger Mint ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 vaultUserBalanceAfter = token.balanceOf(vaultUser);
        console.log("Total Supply After: %s", totalSupplyAfter);
        console.log("VaultUser Balance After: %s", vaultUserBalanceAfter);
        
        uint256 supplyDiff = totalSupplyAfter - totalSupplyBefore;
        uint256 balanceDiff = vaultUserBalanceAfter - vaultUserBalanceBefore;
        bool vulnerabilityExists = (supplyDiff == mintAmount) && (balanceDiff == mintAmount);
        
        console.log("\n\t=== Differential Validation ===");
        console.log("\tSupply Change: %s | Expected: %s", supplyDiff, mintAmount);
        console.log("\tBalance Change: %s | Expected: %s", balanceDiff, mintAmount);
        console.log("\tVulnerability Status: %s", vulnerabilityExists ? "EXPLOITED" : "MITIGATED");
        
        vulnerabilityExists 
            ? console.log("Vulnerability Exists: Vault can mint arbitrary tokens causing hyperinflation")
            : console.log("Vulnerability not Exist: Mint limits are enforced");
    }

    function testMassiveInflation() public {
        uint256 massiveMintAmount = 10_000_000 * (10 ** 9);
        
        console.log("\n--- BEFORE-Trigger Mint ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 vaultUserBalanceBefore = token.balanceOf(vaultUser);
        console.log("Total Supply Before: %s", totalSupplyBefore);
        console.log("VaultUser Balance Before: %s", vaultUserBalanceBefore);
        
        console.log("--- Trigger Mint ---");
        vm.prank(vaultAddr);
        token.mint(vaultUser, massiveMintAmount);
        console.log("Minted %s tokens to %s", massiveMintAmount, vaultUser);
        
        console.log("--- AFTER-Trigger Mint ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 vaultUserBalanceAfter = token.balanceOf(vaultUser);
        console.log("Total Supply After: %s", totalSupplyAfter);
        console.log("VaultUser Balance After: %s", vaultUserBalanceAfter);
        
        uint256 supplyDiff = totalSupplyAfter - totalSupplyBefore;
        uint256 balanceDiff = vaultUserBalanceAfter - vaultUserBalanceBefore;
        bool vulnerabilityExists = (supplyDiff == massiveMintAmount) && (balanceDiff == massiveMintAmount);
        
        console.log("\n\t=== Differential Validation ===");
        console.log("\tSupply Change: %s | Expected: %s", supplyDiff, massiveMintAmount);
        console.log("\tBalance Change: %s | Expected: %s", balanceDiff, massiveMintAmount);
        console.log("\tVulnerability Status: %s", vulnerabilityExists ? "EXPLOITED" : "MITIGATED");
        
        vulnerabilityExists 
            ? console.log("Vulnerability Exists: Vault can mint massive tokens causing hyperinflation")
            : console.log("Vulnerability not Exist: Mint limits are enforced");
    }

    function testNonVaultCannotMint() public {
        uint256 mintAmount = 1_000 * (10 ** 9);
        vm.prank(hacker);
        vm.expectRevert("Not vault");
        token.mint(vaultUser, mintAmount);
    }

    function testArbitraryTokenInflationByVault() public {
        uint256[] memory mintAmounts = new uint256[](5);
        mintAmounts[0] = 100_000 * (10 ** 9);
        mintAmounts[1] = 1_000_000 * (10 ** 9);
        mintAmounts[2] = 10_000_000 * (10 ** 9);
        mintAmounts[3] = 100_000_000 * (10 ** 9);
        mintAmounts[4] = 1_000_000_000 * (10 ** 9);

        bool vulnerabilityExists = true;
        uint256 cumulativeSupplyBefore = token.totalSupply();
        console.log("\n=== Start Arbitrary Inflation Test ===");

        for (uint256 i = 0; i < mintAmounts.length; i++) {
            console.log("\n--- Operation %s BEFORE-Trigger ---", i);
            uint256 totalSupplyBefore = token.totalSupply();
            uint256 vaultUserBalanceBefore = token.balanceOf(vaultUser);
            console.log("Total Supply Before: %s", totalSupplyBefore);
            console.log("VaultUser Balance Before: %s", vaultUserBalanceBefore);

            console.log("--- Trigger Mint %s ---", i);
            vm.prank(vaultAddr);
            token.mint(vaultUser, mintAmounts[i]);

            console.log("--- Operation %s AFTER-Trigger ---", i);
            uint256 totalSupplyAfter = token.totalSupply();
            uint256 vaultUserBalanceAfter = token.balanceOf(vaultUser);
            console.log("Total Supply After: %s", totalSupplyAfter);
            console.log("VaultUser Balance After: %s", vaultUserBalanceAfter);
            
            uint256 supplyDiff = totalSupplyAfter - totalSupplyBefore;
            uint256 balanceDiff = vaultUserBalanceAfter - vaultUserBalanceBefore;
            bool operationSuccess = (supplyDiff == mintAmounts[i]) && (balanceDiff == mintAmounts[i]);
            
            console.log("> Mint Validation: %s | Amount: %s", operationSuccess ? "SUCCESS" : "FAIL", mintAmounts[i]);
            console.log("\tSupply Change: %s | Balance Change: %s", supplyDiff, balanceDiff);
            
            if (!operationSuccess) {
                vulnerabilityExists = false;
                console.log("Vulnerability MITIGATED at mint %s", i);
            }
        }

        uint256 totalInflation = token.totalSupply() - cumulativeSupplyBefore;
        console.log("\n=== Final Inflation Validation ===");
        console.log("Total Inflation: %s tokens minted", totalInflation);

        vulnerabilityExists 
            ? console.log("Vulnerability Exists: Vault can execute arbitrary sequential mints")
            : console.log("Vulnerability not Exist: Mint limits detected during operations");
    }
}