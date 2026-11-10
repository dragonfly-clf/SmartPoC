5.3. Improper Reward Calculation (_withUpdate)

**ID** IDX-003

**Target** MasterChef

**Category** Advanced Smart Contract Vulnerability

**CWE** CWE-840: Business Logic Errors

**Risk** **Severity: Medium**

**Impact: Medium**
The $LUCKY reward miscalculation can lead to an unfair $LUCKY token distribution to the
users.

**Likelihood: Medium**
The add() and the set() functions can only be called by the contract owner, but it is
possible that the totalAllocPoint state will be changed without setting the
```
       _withUpdate parameter to true .

```
**Status** **Resolved**
LuckyLion team has resolved this issue as suggested in commit
```
       5aa5780d15ce4b471d49abb3cba09ac7203975f2.

#### 5.3.1. Description

```
The totalAllocPoint variable is used to determine the portion that each pool would get from the total
reward minted, so it is one of the main factors used in the rewards calculation. Therefore, whenever the
```
totalAllocPoint variable is modified without updating the pending reward first, the reward of each pool

```
will be incorrectly calculated.

In the add() and set() functions shown below, if _withUpdate is set to false, the totalAllocPoint
variable will be modified without updating the rewards (massUpdatePools()).

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

```
( ) 17

|ID|IDX-003|
|---|---|
|Target|MasterChef|
|Category|Advanced Smart Contract Vulnerability|
|CWE|CWE-840: Business Logic Errors|
|Risk|Severity: Medium Impact: Medium The $LUCKY reward miscalculation can lead to an unfair $LUCKY token distribution to the users. Likelihood: Medium The add() and the set() functions can only be called by the contract owner, but it is possible that the totalAllocPoint state will be changed without setting the _withUpdate parameter to true .|
|Status|Resolved LuckyLion team has resolved this issue as suggested in commit 5aa5780d15ce4b471d49abb3cba09ac7203975f2.|

|128 129 130 131 132 133 134|function add(uint256 _allocPoint, IERC20 _lpToken, uint256 _harvestIntervalInMinutes,uint256 _farmStartIntervalInMinutes, bool _withUpdate) public onlyOwner { uint256 _harvestTimestampInUnix = block.timestamp + (_harvestIntervalInMinutes *60); //*60 to convert from minutes to second. uint256 _farmStartTimestampInUnix = block.timestamp + (_farmStartIntervalInMinutes *60); if (_withUpdate) { massUpdatePools(); } uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;|
|---|---|


-----

Public

________
```
 135 totalAllocPoint = totalAllocPoint.add(_allocPoint);
 136 poolInfo.push(PoolInfo({
 137 lpToken: _lpToken,
 138 allocPoint: _allocPoint,
 139 lastRewardBlock: lastRewardBlock,
 140 accLuckyPerShare: 0,
 141 harvestTimestamp: _harvestTimestampInUnix,
 142 farmStartDate : _farmStartTimestampInUnix
 143 }));
 144 emit PoolAdded(_lpToken,_allocPoint,_harvestTimestampInUnix,
   _farmStartTimestampInUnix);
 145 }
 146
 147 // Update the given pool's lucky allocation point. Can only be called by the
   owner.
 148 function set(uint256 _pid, uint256 _allocPoint, uint256
   _harvestIntervalInMinutes,uint256 _farmStartIntervalInMinutes, bool
   _withUpdate) public onlyOwner {
 149 uint256 _harvestTimestampInUnix = block.timestamp +
   (_harvestIntervalInMinutes *60); //*60 to convert from minutes to second.
 150 uint256 _farmStartTimestampInUnix = block.timestamp +
   (_farmStartIntervalInMinutes *60);
 151 if (_withUpdate) {
 152 massUpdatePools();
 153 }
 154 totalAllocPoint =
   totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
 155 poolInfo[_pid].allocPoint = _allocPoint;
 156 poolInfo[_pid].harvestTimestamp = _harvestTimestampInUnix;
 157 poolInfo[_pid].farmStartDate = _farmStartTimestampInUnix;
 158 emit PoolSet(_pid,_allocPoint,_harvestTimestampInUnix,
   _farmStartTimestampInUnix);
 159 }

```
**For example:**

Assuming that on block 1000000, luckyPerBlock is 5 $LUCKY per block, totalAllocPoint is 5000, and
```
allocPoint of pool id 0 is 500.

```
**Block** **Action**

1000000 All pools’ rewards are updated

1100000 A new pool is added using the add() function, causing the totalAllocPoint to be changed
from 5000 to 10000

1200000 The pools’ rewards are updated once again.

( ) 18

|135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159|totalAllocPoint = totalAllocPoint.add(_allocPoint); poolInfo.push(PoolInfo({ lpToken: _lpToken, allocPoint: _allocPoint, lastRewardBlock: lastRewardBlock, accLuckyPerShare: 0, harvestTimestamp: _harvestTimestampInUnix, farmStartDate : _farmStartTimestampInUnix })); emit PoolAdded(_lpToken,_allocPoint,_harvestTimestampInUnix, _farmStartTimestampInUnix); } // Update the given pool's lucky allocation point. Can only be called by the owner. function set(uint256 _pid, uint256 _allocPoint, uint256 _harvestIntervalInMinutes,uint256 _farmStartIntervalInMinutes, bool _withUpdate) public onlyOwner { uint256 _harvestTimestampInUnix = block.timestamp + (_harvestIntervalInMinutes *60); //*60 to convert from minutes to second. uint256 _farmStartTimestampInUnix = block.timestamp + (_farmStartIntervalInMinutes *60); if (_withUpdate) { massUpdatePools(); } totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint); poolInfo[_pid].allocPoint = _allocPoint; poolInfo[_pid].harvestTimestamp = _harvestTimestampInUnix; poolInfo[_pid].farmStartDate = _farmStartTimestampInUnix; emit PoolSet(_pid,_allocPoint,_harvestTimestampInUnix, _farmStartTimestampInUnix); }|
|---|---|

|Block|Action|
|---|---|
|1000000|All pools’ rewards are updated|
|1100000|A new pool is added using the add() function, causing the totalAllocPoint to be changed from 5000 to 10000|
|1200000|The pools’ rewards are updated once again.|


-----

Public

________

From current logic, the total rewards allocated to the pool id 0 during block 1000000 to 1200000 is equal to
50,000 $LUCKY, calculated using the following equation:

**Block** **Total** **Total** **Total $LUCKY per block for pool 0** **Total pool 0**
**Reward** **Allocation** **(luckyPerBlock*pool0allocPoint/** **$LUCKY Reward**

**Block** **Point** **totalAllocPoint)**

1000000 - 1200000 200000 10,000 0.25 $LUCKY per block 50,000 $LUCKY

However, the rewards should be calculated by accounting for the original totalAllocPoint value during
the period when it is not yet updated as follows:

**Block** **Total** **Total** **Total $LUCKY per block for pool 0** **Total pool 0**
**Reward** **Allocation** **(luckyPerBlock*pool0allocPoint/** **$LUCKY Reward**

**Block** **Point** **totalAllocPoint)**

1000000 - 1100000 100000 5,000 0.5 $LUCKY per block 50,000 $LUCKY

1100000 - 1200000 100000 10,000 0.25 $LUCKY per block 25,000 $LUCKY

The correct total $LUCKY reward is 75,000 $LUCKY, which is different from the miscalculated reward by 25,000
$LUCKY.

#### 5.3.2. Remediation

Inspex suggests removing the _withUpdate variable in the add() and set() functions and always calling
the massUpdatePools() function before updating totalAllocPoint variable as shown in the following
example:

**Masterchef.sol**
```
 128 function add(uint256 _allocPoint, IERC20 _lpToken, uint256
   _harvestIntervalInMinutes,uint256 _farmStartIntervalInMinutes, bool
   _withUpdate) public onlyOwner {
 129 uint256 _harvestTimestampInUnix = block.timestamp +
   (_harvestIntervalInMinutes *60); //*60 to convert from minutes to second.
 130 uint256 _farmStartTimestampInUnix = block.timestamp +
   (_farmStartIntervalInMinutes *60);
 131 massUpdatePools();
 132 uint256 lastRewardBlock = block.number > startBlock ? block.number :
   startBlock;
 133 totalAllocPoint = totalAllocPoint.add(_allocPoint);
 134 poolInfo.push(PoolInfo({
 135 lpToken: _lpToken,
 136 allocPoint: _allocPoint,
 137 lastRewardBlock: lastRewardBlock,
 138 accLuckyPerShare: 0,

```
( ) 19

|Block|Total Reward Block|Total Allocation Point|Total $LUCKY per block for pool 0 (luckyPerBlock*pool0allocPoint/ totalAllocPoint)|Total pool 0 $LUCKY Reward|
|---|---|---|---|---|
|1000000 - 1200000|200000|10,000|0.25 $LUCKY per block|50,000 $LUCKY|

|Block|Total Reward Block|Total Allocation Point|Total $LUCKY per block for pool 0 (luckyPerBlock*pool0allocPoint/ totalAllocPoint)|Total pool 0 $LUCKY Reward|
|---|---|---|---|---|
|1000000 - 1100000|100000|5,000|0.5 $LUCKY per block|50,000 $LUCKY|
|1100000 - 1200000|100000|10,000|0.25 $LUCKY per block|25,000 $LUCKY|

|128 129 130 131 132 133 134 135 136 137 138|function add(uint256 _allocPoint, IERC20 _lpToken, uint256 _harvestIntervalInMinutes,uint256 _farmStartIntervalInMinutes, bool _withUpdate) public onlyOwner { uint256 _harvestTimestampInUnix = block.timestamp + (_harvestIntervalInMinutes *60); //*60 to convert from minutes to second. uint256 _farmStartTimestampInUnix = block.timestamp + (_farmStartIntervalInMinutes *60); massUpdatePools(); uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock; totalAllocPoint = totalAllocPoint.add(_allocPoint); poolInfo.push(PoolInfo({ lpToken: _lpToken, allocPoint: _allocPoint, lastRewardBlock: lastRewardBlock, accLuckyPerShare: 0,|
|---|---|


-----

Public

________

|139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155|harvestTimestamp: _harvestTimestampInUnix, farmStartDate : _farmStartTimestampInUnix })); emit PoolAdded(_lpToken,_allocPoint,_harvestTimestampInUnix, _farmStartTimestampInUnix); } // Update the given pool's lucky allocation point. Can only be called by the owner. function set(uint256 _pid, uint256 _allocPoint, uint256 _harvestIntervalInMinutes,uint256 _farmStartIntervalInMinutes, bool _withUpdate) public onlyOwner { uint256 _harvestTimestampInUnix = block.timestamp + (_harvestIntervalInMinutes *60); //*60 to convert from minutes to second. uint256 _farmStartTimestampInUnix = block.timestamp + (_farmStartIntervalInMinutes *60); massUpdatePools(); totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint); poolInfo[_pid].allocPoint = _allocPoint; poolInfo[_pid].harvestTimestamp = _harvestTimestampInUnix; poolInfo[_pid].farmStartDate = _farmStartTimestampInUnix; emit PoolSet(_pid,_allocPoint,_harvestTimestampInUnix, _farmStartTimestampInUnix); }|
|---|---|


( ) 20


-----

Public

________

### 