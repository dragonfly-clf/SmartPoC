// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbaa3de6504690efb064420d89e871c27065cdd52.sol";

contract VaultProxyTest is Test {
    VaultProxy directDeployedVault;
    VaultProxy factoryDeployedVault;
    VaultFactory vaultFactory;

    function setUp() public {
        // Create factory contract
        vaultFactory = new VaultFactory();
    }

    // Test direct EOA deployment triggers deposit
    function testDirectDeploymentCallsDeposit() public {
        vm.deal(address(this), 1 ether);
        directDeployedVault = new VaultProxy{value: 0.3 ether}();
        assertEq(address(directDeployedVault).balance, 0.3 ether, "Balance mismatch");
    }

    // Test factory deployment skips deposit
    function testFactoryDeploymentSkipsDeposit() public {
        vm.deal(address(this), 1 ether);
        console.log("--- BEFORE-Trigger Deployment ---");
        console.log("Vault has not been deployed. State: N/A");

        console.log("--- Trigger Deployment ---");
        // Deploy via factory with value
        factoryDeployedVault = vaultFactory.createVault{value: 0.3 ether}();
        console.log("Vault deployed at %s with balance %s", address(factoryDeployedVault), address(factoryDeployedVault).balance);

        console.log("--- AFTER-Trigger Deployment ---");
        // Query key state variables
        uint256 userCount = factoryDeployedVault.userCount();
        uint256 totalDeposits = factoryDeployedVault.totalDeposits();
        uint256 depositAmount = factoryDeployedVault.Deposits(address(this));

        console.log("State Variables After Deployment:");
        console.log("userCount: ", userCount);
        console.log("totalDeposits: ", totalDeposits);
        console.log("Deposits(address(this)): ", depositAmount);
        console.log("Actual Contract Balance: ", address(factoryDeployedVault).balance);

        // Vulnerability exists if state remains unchanged despite ETH deposit
        bool vulnerableState = (userCount == 0) && 
                               (totalDeposits == 0) && 
                               (depositAmount == 0) && 
                               (address(factoryDeployedVault).balance == 0.3 ether);

        // Original balance check (keep existing verification)
        assertEq(address(factoryDeployedVault).balance, 0.3 ether, "ETH should be in vault");

        // Final vulnerability verdict
        if (vulnerableState) {
            console.log("Vulnerability Exists: Contract balance updated but state variables unchanged");
        } else {
            console.log("Vulnerability not Exist: State variables updated correctly");
        }
    }
}

contract VaultFactory {
    function createVault() public payable returns (VaultProxy) {
        return new VaultProxy{value: msg.value}();
    }
}