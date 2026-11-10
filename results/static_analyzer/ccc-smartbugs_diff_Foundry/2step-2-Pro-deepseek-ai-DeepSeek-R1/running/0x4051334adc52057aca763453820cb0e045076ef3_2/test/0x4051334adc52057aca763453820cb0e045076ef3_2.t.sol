// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/0x4051334adc52057aca763453820cb0e045076ef3.sol";

contract MockERC20 {
    function transferFrom(address, address, uint256) public pure returns (bool) {
        return true;
    }
}

contract AirdropDenialOfServiceTest is Test {
    airdrop public airdropContract;
    MockERC20 public mockToken;
    
    function setUp() public {
        airdropContract = new airdrop();
        mockToken = new MockERC20();
    }

    function testTransferWithLargeArrayReverts() public {
        address from = address(this);
        address tokenAddress = address(mockToken);
        uint tokenAmount = 1;

        // Create array large enough to cause out-of-gas
        uint count = 1500;
        address[] memory recipients = new address[](count);
        for (uint i = 0; i < recipients.length; i++) {
            recipients[i] = address(uint160(1000 + i));
        }

        console2.log("--- BEFORE-Trigger State ---");
        uint totalAirdropsBefore = airdropContract.totalAirdrops();
        uint totalTokensDistributedBefore = airdropContract.totalTokensDistributed();
        console2.log("totalAirdrops before:", totalAirdropsBefore);
        console2.log("totalTokensDistributed before:", totalTokensDistributedBefore);

        console2.log("--- Trigger Transfer ---");
        // Execute transfer with gas limit (simulating block gas limit)
        uint gasLimit = 30_000_000;
        vm.expectRevert();
        airdropContract.transfer{gas: gasLimit}(from, tokenAddress, recipients, tokenAmount);

        console2.log("--- AFTER-Trigger State ---");
        uint totalAirdropsAfter = airdropContract.totalAirdrops();
        uint totalTokensDistributedAfter = airdropContract.totalTokensDistributed();
        console2.log("totalAirdrops after:", totalAirdropsAfter);
        console2.log("totalTokensDistributed after:", totalTokensDistributedAfter);

        // Verify state variables unchanged after reverted call
        assertEq(totalAirdropsAfter, totalAirdropsBefore, "totalAirdrops should remain the same");
        assertEq(totalTokensDistributedAfter, totalTokensDistributedBefore, "totalTokensDistributed should remain the same");
        
        console2.log("Vulnerability Exists: Transfer function reverts due to high gas use on large arrays causing DoS");
    }

    function testNormalTransferSucceeds() public {
        address from = address(this);
        address tokenAddress = address(mockToken);
        uint tokenAmount = 1;

        // Create small recipients array
        uint count = 10;
        address[] memory recipients = new address[](count);
        for (uint i = 0; i < recipients.length; i++) {
            recipients[i] = address(uint160(1000 + i));
        }

        // Execute transfers (should succeed)
        airdropContract.transfer(from, tokenAddress, recipients, tokenAmount);

        // Verify state updates
        (uint airdropCount, ) = airdropContract.getUserStats(address(this));
        assertEq(airdropCount, 1, "Airdrop count should increment");
    }
}