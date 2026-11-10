5.8. Improper Function Visibility

**ID** IDX-008

**Target** Masterchef
SyrupBar

**Category** Smart Contract Best Practice

**CWE** CWE-710: Improper Adherence to Coding Standards

**Risk** **Severity: Info**

**Impact: None**

**Likelihood: None**

**Status** **Resolved**
LuckyLion team has resolved this issue as suggested in commit
```
       5aa5780d15ce4b471d49abb3cba09ac7203975f2.

#### 5.8.1. Description

```
Functions with public visibility copy calldata to memory when being executed, while external functions can
read directly from calldata. Memory allocation uses more resources (gas) than reading directly from calldata.

For example, the following source code shows that the add() function of the MasterChef contract is set to
public and it is never called from any internal function.

**Masterchef.sol**
```
 128 function add(uint256 _allocPoint, IERC20 _lpToken, uint256
   _harvestIntervalInMinutes,uint256 _farmStartIntervalInMinutes, bool
   _withUpdate) public onlyOwner {
 129 uint256 _harvestTimestampInUnix = block.timestamp +
   (_harvestIntervalInMinutes *60); //*60 to convert from minutes to second.
 130 uint256 _farmStartTimestampInUnix = block.timestamp +
   (_farmStartIntervalInMinutes *60);
 131 if (_withUpdate) {
 132 massUpdatePools();
 133 }
 134 uint256 lastRewardBlock = block.number > startBlock ? block.number :
   startBlock;
 135 totalAllocPoint = totalAllocPoint.add(_allocPoint);
 136 poolInfo.push(PoolInfo({
 137 lpToken: _lpToken,
 138 allocPoint: _allocPoint,
 139 lastRewardBlock: lastRewardBlock,
 140 accLuckyPerShare: 0,

```
( ) 33

|ID|IDX-008|
|---|---|
|Target|Masterchef SyrupBar|
|Category|Smart Contract Best Practice|
|CWE|CWE-710: Improper Adherence to Coding Standards|
|Risk|Severity: Info Impact: None Likelihood: None|
|Status|Resolved LuckyLion team has resolved this issue as suggested in commit 5aa5780d15ce4b471d49abb3cba09ac7203975f2.|

|128 129 130 131 132 133 134 135 136 137 138 139 140|function add(uint256 _allocPoint, IERC20 _lpToken, uint256 _harvestIntervalInMinutes,uint256 _farmStartIntervalInMinutes, bool _withUpdate) public onlyOwner { uint256 _harvestTimestampInUnix = block.timestamp + (_harvestIntervalInMinutes *60); //*60 to convert from minutes to second. uint256 _farmStartTimestampInUnix = block.timestamp + (_farmStartIntervalInMinutes *60); if (_withUpdate) { massUpdatePools(); } uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock; totalAllocPoint = totalAllocPoint.add(_allocPoint); poolInfo.push(PoolInfo({ lpToken: _lpToken, allocPoint: _allocPoint, lastRewardBlock: lastRewardBlock, accLuckyPerShare: 0,|
|---|---|