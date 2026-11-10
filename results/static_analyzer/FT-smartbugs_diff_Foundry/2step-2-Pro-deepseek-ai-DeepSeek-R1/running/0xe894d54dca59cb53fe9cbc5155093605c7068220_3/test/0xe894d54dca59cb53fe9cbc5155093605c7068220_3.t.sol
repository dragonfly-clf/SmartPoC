// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe894d54dca59cb53fe9cbc5155093605c7068220.sol";

contract MockToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return true;
    }
}

contract GasLimitTest is Test {
    airDrop airdrop;
    MockToken token;
    address _from;

    function setUp() public {
        token = new MockToken();
        airdrop = new airDrop();
        _from = address(this);
    }

    function testTransferFailsWithLargeArray() public {
        uint256 recipientCount = 100000; // 足够大的数组以超出gas限制
        address[] memory recipients = new address[](recipientCount);

        console.log("--- BEFORE-Trigger State ---");
        // 获取空投合约初始状态值
        uint totalDropsBefore = airdrop.totalDrops();
        uint totalTokensDistributedBefore = airdrop.totalTokensDistributed();
        uint userDropCountBefore = airdrop.userDropCount(address(this));
        console.log("Initial totalDrops:", totalDropsBefore);
        console.log("Initial totalTokensDistributed:", totalTokensDistributedBefore);
        console.log("Initial userDropCount:", userDropCountBefore);

        console.log("--- Trigger Transfer (expect revert) ---");
        // 预期操作会因gas不足而回滚
        vm.expectRevert();
        airdrop.transfer(_from, address(token), recipients, 1, 18);

        console.log("--- AFTER-Trigger State ---");
        // 获取操作后状态值
        uint totalDropsAfter = airdrop.totalDrops();
        uint totalTokensDistributedAfter = airdrop.totalTokensDistributed();
        uint userDropCountAfter = airdrop.userDropCount(address(this));
        console.log("Final totalDrops:", totalDropsAfter);
        console.log("Final totalTokensDistributed:", totalTokensDistributedAfter);
        console.log("Final userDropCount:", userDropCountAfter);

        // 状态验证
        bool stateUnchanged = 
            (totalDropsBefore == totalDropsAfter) &&
            (totalTokensDistributedBefore == totalTokensDistributedAfter) &&
            (userDropCountBefore == userDropCountAfter);
        
        if (stateUnchanged) {
            console.log("Vulnerability Exists: Transaction reverted and state unchanged, indicating gas limit DoS vulnerability.");
        } else {
            console.log("Vulnerability not Exist: State changed unexpectedly after revert.");
        }
    }
}