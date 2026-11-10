// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/moonship.sol";

contract MockPair {
    function sync() external {}
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(new MockPair());
    }
}

contract MockRouter {
    MockFactory private _factory;
    address public immutable WETH;
    
    constructor() public {
        _factory = new MockFactory();
        WETH = address(0xE);
    }
    
    function factory() external view returns (address) {
        return address(_factory);
    }
}

contract MaliciousActor {
    MoonShip public token;
    uint256 public reentered;
    
    constructor(MoonShip _token) public {
        token = _token;
    }
    
    receive() external payable {
        try token.claimBNBReward() {
            reentered = 2;
        } catch Error(string memory reason) {
            if (keccak256(abi.encodePacked(reason)) == keccak256(abi.encodePacked("ReentrancyGuard: reentrant call"))) {
                reentered = 1;
            } else {
                reentered = 3;
            }
        } catch {
            reentered = 4;
        }
    }
    
    function initiateMaliciousClaim() external {
        token.claimBNBReward();
    }
}

contract ReentrancyTester is Test {
    MoonShip token;
    uint256 constant TOKEN_BALANCE = 10 ether;
    MaliciousActor maliciousActor;
    MockRouter public router;
    
    function setUp() public {
        router = new MockRouter();
        token = new MoonShip(payable(address(router)));
        
        // Fund token contract with BNB for rewards
        payable(address(token)).transfer(100 ether);
        
        // Activate contract BEFORE transfers to set reward parameters
        token.activateContract();
        
        maliciousActor = new MaliciousActor(token);
        
        // Transfer tokens after activation to ensure proper claim date setup
        token.transfer(address(maliciousActor), TOKEN_BALANCE);
    }
    
    function testRewardClaimReentrancy() public {
        uint256 rewardCycle = token.getRewardCycleBlock();
        
        // Advance time beyond next available claim date
        vm.warp(block.timestamp + rewardCycle + 1);
        
        console.log("--- BEFORE-Trigger ---");
        uint256 reenteredBefore = maliciousActor.reentered();
        console.log("Reentered state before: %s", reenteredBefore);
        
        console.log("\n--- Trigger: Calling initiateMaliciousClaim ---");
        vm.startPrank(address(maliciousActor), address(maliciousActor));
        maliciousActor.initiateMaliciousClaim();
        vm.stopPrank();
        
        console.log("\n--- AFTER-Trigger ---");
        uint256 reenteredAfter = maliciousActor.reentered();
        console.log("Reentered state after: %s", reenteredAfter);

        // Vulnerability assessment
        if (reenteredAfter == 1) {
            console.log("\nVulnerability not Exist: Reentrancy guard correctly blocked attack and released lock");
        } else if (reenteredAfter == 2) {
            console.log("\nVulnerability Exists: Reentrancy succeeded - vulnerability exposed");
        } else if (reenteredAfter == 0) {
            console.log("\nVulnerability Exists: Reentrancy attempt not triggered");
        } else {
            console.log("\nVulnerability Exists: Unexpected reentered state value (%s)", reenteredAfter);
        }
    }
}