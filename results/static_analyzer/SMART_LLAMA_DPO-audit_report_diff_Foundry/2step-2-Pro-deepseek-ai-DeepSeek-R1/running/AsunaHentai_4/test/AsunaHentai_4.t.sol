// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AsunaHentai.sol";

contract AsunaHentaiPrivilegeTest is Test {
    AsunaHentai token;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Mock router and factory calls
        address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = address(0xFaC7Abc0d5375a214421e98001001FaC7);
        address mockPair = address(0xD1480d0A0DAa6c80009901234);
        address mockWETH = address(0x000000000000000000000000000000000000dEaD);
        
        // Mock router factory()
        vm.mockCall(
            routerAddr,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(mockFactory)
        );
        
        // Mock router WETH()
        vm.mockCall(
            routerAddr,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair() for any arguments
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(mockPair)
        );
        
        token = new AsunaHentai();
        vm.stopPrank();
    }

    function test_lockAndUnlock() public {
        // 检查初始所有权
        console.log("--- BEFORE lock ---");
        address initialOwner = token.owner();
        console.log("Initial owner:", initialOwner);

        // 锁定合约
        console.log("--- Trigger lock ---");
        vm.prank(owner);
        token.lock(1 days);
        
        // 验证锁定后状态
        console.log("--- AFTER lock ---");
        address lockedOwner = token.owner();
        console.log("Owner after lock:", lockedOwner);
        assertEq(lockedOwner, address(0), "Contract should be locked after owner calls lock()");

        // 尝试提前解锁
        console.log("--- Trigger early unlock attempt ---");
        vm.prank(owner);
        vm.expectRevert("Contract is locked until 7 days");
        token.unlock();

        // 推进时间超过锁定时间
        console.log("--- Advance time ---");
        vm.warp(block.timestamp + 1 days + 1 seconds);
        
        // 验证解锁前状态
        console.log("--- BEFORE unlock ---");
        address preUnlockOwner = token.owner();
        console.log("Owner before unlock:", preUnlockOwner);

        // 正常解锁
        console.log("--- Trigger unlock ---");
        vm.prank(owner);
        token.unlock();
        
        // 验证所有权恢复
        console.log("--- AFTER unlock ---");
        address finalOwner = token.owner();
        console.log("Owner after unlock:", finalOwner);
        assertEq(finalOwner, owner, "Owner should be reestablished after successful unlock");
        
        console.log("Vulnerability not Exist: Lock/unlock functions operate as designed");
    }

    function test_unauthorizedUnlockAttempt() public {
        // 锁定合约
        vm.prank(owner);
        token.lock(1 days);
        
        // 推进时间超过锁定时间
        vm.warp(block.timestamp + 1 days + 1 seconds);
        
        // 验证攻击前状态
        console.log("--- BEFORE unlock attempt ---");
        address preUnlockOwner = token.owner();
        console.log("Owner before unlock attempt:", preUnlockOwner);

        // 尝试非法解锁
        console.log("--- Trigger unauthorized unlock ---");
        vm.prank(attacker);
        vm.expectRevert("You don't have permission to unlock");
        token.unlock();

        // 验证攻击后状态
        console.log("--- AFTER unlock attempt ---");
        address postUnlockOwner = token.owner();
        console.log("Owner after unlock attempt:", postUnlockOwner);
        
        // 比较状态变化
        if (postUnlockOwner == owner) {
            console.log("Vulnerability Exists: Unauthorized unlock changed ownership");
        } else {
            console.log("Vulnerability not Exist: Unauthorized unlock prevented");
        }
    }

    function test_lockedContractFunctionality() public {
        // 检查初始所有权
        console.log("--- BEFORE lock ---");
        address initialOwner = token.owner();
        console.log("Initial owner:", initialOwner);

        // 锁定合约
        console.log("--- Trigger lock ---");
        vm.prank(owner);
        token.lock(365 days);

        // 验证锁定后状态
        console.log("--- AFTER lock ---");
        address lockedOwner = token.owner();
        console.log("Owner after lock:", lockedOwner);
        assertEq(lockedOwner, address(0), "Contract should be locked");

        // 检查合约功能受限
        console.log("--- Attempt restricted function ---");
        vm.expectRevert("Ownable: caller is not the owner");
        token.excludeFromFee(address(0x123));
        
        console.log("Vulnerability not Exist: Restricted functions blocked as intended");
    }
}