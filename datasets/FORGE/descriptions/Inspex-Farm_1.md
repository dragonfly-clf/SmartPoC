5.2. Improper Reward Calculation (Duplicated LP Token)

**ID** IDX-002

**Target** MasterChef

**Category** Advanced Smart Contract Vulnerability

**CWE** CWE-840: Business Logic Errors

**Risk** **Severity: Medium**

**Impact: Medium**
The $LUCKY reward miscalculation can lead to an unfair $LUCKY token distribution to the
users.

**Likelihood: Medium**
It is possible that the contract owner will add or migrate a new pool that uses the same
token as another pool since there is no restriction.

**Status** **Resolved**
LuckyLion team has resolved this issue as suggested in commit
```
       5aa5780d15ce4b471d49abb3cba09ac7203975f2.

#### 5.2.1. Description

```
In the MasterChef contract, a new staking pool can be added using the add() function. The staking token
for the new pool is defined using the _lpToken variable; however, there is no additional checking whether
the _lpToken is already used in other pools or not.

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

```
( ) 12

|ID|IDX-002|
|---|---|
|Target|MasterChef|
|Category|Advanced Smart Contract Vulnerability|
|CWE|CWE-840: Business Logic Errors|
|Risk|Severity: Medium Impact: Medium The $LUCKY reward miscalculation can lead to an unfair $LUCKY token distribution to the users. Likelihood: Medium It is possible that the contract owner will add or migrate a new pool that uses the same token as another pool since there is no restriction.|
|Status|Resolved LuckyLion team has resolved this issue as suggested in commit 5aa5780d15ce4b471d49abb3cba09ac7203975f2.|

|128 129 130 131 132 133 134 135 136 137 138 139|function add(uint256 _allocPoint, IERC20 _lpToken, uint256 _harvestIntervalInMinutes,uint256 _farmStartIntervalInMinutes, bool _withUpdate) public onlyOwner { uint256 _harvestTimestampInUnix = block.timestamp + (_harvestIntervalInMinutes *60); //*60 to convert from minutes to second. uint256 _farmStartTimestampInUnix = block.timestamp + (_farmStartIntervalInMinutes *60); if (_withUpdate) { massUpdatePools(); } uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock; totalAllocPoint = totalAllocPoint.add(_allocPoint); poolInfo.push(PoolInfo({ lpToken: _lpToken, allocPoint: _allocPoint, lastRewardBlock: lastRewardBlock,|
|---|---|


-----

Public

________
```
 140 accLuckyPerShare: 0,
 141 harvestTimestamp: _harvestTimestampInUnix,
 142 farmStartDate : _farmStartTimestampInUnix
 143 }));
 144 emit
   PoolAdded(_lpToken,_allocPoint,_harvestTimestampInUnix,_farmStartTimestampInUni
   x);
 145 }

```
There is also the migrate() function that can change lpToken without checking if they are duplicates.

**Masterchef.sol**
```
 201 function migrate(uint256 _pid) public {
 202 require(address(migrator) != address(0), "migrate: no migrator");
 203 PoolInfo storage pool = poolInfo[_pid];
 204 IERC20 lpToken = pool.lpToken;
 205 uint256 bal = lpToken.balanceOf(address(this));
 206 lpToken.safeApprove(address(migrator), bal);
 207 IERC20 newLpToken = migrator.migrate(lpToken);
 208 require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
 209 pool.lpToken = newLpToken;
 210 }

```
In the updatePool() function, the balance of pool.lpToken in the contract is used as a denominator to
calculate pool.accLuckyPerShare.

**Masterchef.sol**
```
 213 function updatePool(uint256 _pid) public {
 214 PoolInfo storage pool = poolInfo[_pid];
 215 if (block.number <= pool.lastRewardBlock) {
 216 return;
 217 }
 218 uint256 lpSupply = pool.lpToken.balanceOf(address(this));
 219 if (lpSupply == 0 || pool.allocPoint == 0) {
 220 pool.lastRewardBlock = block.number;
 221 return;
 222 }
 223 uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
 224 uint256 luckyReward =
   multiplier.mul(luckyPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
 225 //new one
 226 // check at final to mint exact lucky to complete the round 9 million and
   100 millions totalsupply
 227 uint256 luckyRewardForDev = luckyReward.mul(devMintingRatio).div(10000);
 228 //logic to prevent the minting exceeds the capped totalsupply
     //1st case, reward for dev will exceed Lucky's totalSupply so we limit the

```
( ) 13

|140 141 142 143 144 145|accLuckyPerShare: 0, harvestTimestamp: _harvestTimestampInUnix, farmStartDate : _farmStartTimestampInUnix })); emit PoolAdded(_lpToken,_allocPoint,_harvestTimestampInUnix,_farmStartTimestampInUni x); }|
|---|---|

|201 202 203 204 205 206 207 208 209 210|function migrate(uint256 _pid) public { require(address(migrator) != address(0), "migrate: no migrator"); PoolInfo storage pool = poolInfo[_pid]; IERC20 lpToken = pool.lpToken; uint256 bal = lpToken.balanceOf(address(this)); lpToken.safeApprove(address(migrator), bal); IERC20 newLpToken = migrator.migrate(lpToken); require(bal == newLpToken.balanceOf(address(this)), "migrate: bad"); pool.lpToken = newLpToken; }|
|---|---|

|213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228|function updatePool(uint256 _pid) public { PoolInfo storage pool = poolInfo[_pid]; if (block.number <= pool.lastRewardBlock) { return; } uint256 lpSupply = pool.lpToken.balanceOf(address(this)); if (lpSupply == 0 || pool.allocPoint == 0) { pool.lastRewardBlock = block.number; return; } uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number); uint256 luckyReward = multiplier.mul(luckyPerBlock).mul(pool.allocPoint).div(totalAllocPoint); //new one // check at final to mint exact lucky to complete the round 9 million and 100 millions totalsupply uint256 luckyRewardForDev = luckyReward.mul(devMintingRatio).div(10000); //logic to prevent the minting exceeds the capped totalsupply //1st case, reward for dev will exceed Lucky's totalSupply so we limit the|
|---|---|


-----

Public

________

|229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266|minting amount to syrup. if (luckyRewardForDev.add(lucky.totalSupply()) > lucky.cap() ) { uint256 remainingReward = lucky.cap().sub(lucky.totalSupply()); //in case that remainingReward > capped reward for dev. if (remainingReward.add(accumulatedRewardForDev) > capRewardForDev) { uint256 lastRemainingRewardForDev = capRewardForDev.sub(accumulatedRewardForDev); lucky.mint(devAddress,lastRemainingRewardForDev); accumulatedRewardForDev = accumulatedRewardForDev.add(lastRemainingRewardForDev); //the rest is minted to users. lucky.mint(address(syrup),lucky.cap().sub(lucky.totalSupply())); } //normal case that dev's caped reward has not been reached yet, but the totalSupply of Lucky is reached. else { lucky.mint(devAddress, remainingReward); //track the token that is minted to dev. accumulatedRewardForDev = accumulatedRewardForDev.add(remainingReward); } } //supply cap was not reached and capRewardForDevev still has room to mint for. else { //capRewardForDev is reached. if (luckyRewardForDev.add(accumulatedRewardForDev) > capRewardForDev) { uint256 lastRemainingRewardForDev = capRewardForDev.sub(accumulatedRewardForDev); lucky.mint(devAddress,lastRemainingRewardForDev); //track the token that is minted to dev. accumulatedRewardForDev = accumulatedRewardForDev.add(lastRemainingRewardForDev); //mint the left portion of dev to the pools. lucky.mint(address(syrup),luckyRewardForDev .sub(lastRemainingRewardForDev)); if (luckyReward.add(lucky.totalSupply()) > lucky.cap() ){ lucky.mint(address(syrup),lucky.cap() .sub(lucky.totalSupply())); } else { lucky.mint(address(syrup),luckyReward); } }|
|---|---|


( ) 14


-----

Public

________
```
 267
 268 else {
 269
 270 lucky.mint(devAddress,luckyRewardForDev);
 271 accumulatedRewardForDev =
   accumulatedRewardForDev.add(luckyRewardForDev);
 272
 273 if (luckyReward.add(lucky.totalSupply()) > lucky.cap() ){
 274 lucky.mint(address(syrup),lucky.cap()
   .sub(lucky.totalSupply()));
 275 }
 276 else{
 277 lucky.mint(address(syrup),luckyReward);
 278 }
 279
 280 }
 281 }
 282 pool.accLuckyPerShare =
   pool.accLuckyPerShare.add(luckyReward.mul(1e12).div(lpSupply));
 283 pool.lastRewardBlock = block.number;
 284 }

```
When the owner of MasterChef adds a pool with the same lpToken as another pool, the lpToken value is
counted from all pools using the same lpToken, resulting in a higher value of denominator (lpSupply) than
it should be.

#### 5.2.2. Remediation

Inspex suggests validating the _lpToken address in add() and migrate() functions to prevent duplicated
```
_lpToken when adding a new pool as shown in the following example:

```
**Masterchef.sol**
```
  77 mapping(address => bool) public isAddedPool;

```
**Masterchef.sol**
```
 128 function add(uint256 _allocPoint, IERC20 _lpToken, uint256
   _harvestIntervalInMinutes,uint256 _farmStartIntervalInMinutes, bool
   _withUpdate) public onlyOwner {
 129 require(!isAddedPool[address(_lpToken)], "add: Duplicated LP Token");
 130 uint256 _harvestTimestampInUnix = block.timestamp +
   (_harvestIntervalInMinutes *60); //*60 to convert from minutes to second.
 131 uint256 _farmStartTimestampInUnix = block.timestamp +
   (_farmStartIntervalInMinutes *60);
 132 if (_withUpdate) {
 133 massUpdatePools();
 134 }

```
( ) 15

|267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284|else { lucky.mint(devAddress,luckyRewardForDev); accumulatedRewardForDev = accumulatedRewardForDev.add(luckyRewardForDev); if (luckyReward.add(lucky.totalSupply()) > lucky.cap() ){ lucky.mint(address(syrup),lucky.cap() .sub(lucky.totalSupply())); } else{ lucky.mint(address(syrup),luckyReward); } } } pool.accLuckyPerShare = pool.accLuckyPerShare.add(luckyReward.mul(1e12).div(lpSupply)); pool.lastRewardBlock = block.number; }|
|---|---|

|77|mapping(address => bool) public isAddedPool;|
|---|---|

|128 129 130 131 132 133 134|function add(uint256 _allocPoint, IERC20 _lpToken, uint256 _harvestIntervalInMinutes,uint256 _farmStartIntervalInMinutes, bool _withUpdate) public onlyOwner { require(!isAddedPool[address(_lpToken)], "add: Duplicated LP Token"); uint256 _harvestTimestampInUnix = block.timestamp + (_harvestIntervalInMinutes *60); //*60 to convert from minutes to second. uint256 _farmStartTimestampInUnix = block.timestamp + (_farmStartIntervalInMinutes *60); if (_withUpdate) { massUpdatePools(); }|
|---|---|


-----

Public

________
```
 135
   startBlock;
 136
 137
 138
 139
 140
 141
 142
 143
 144
 145
 146
 147 }

```
**Masterchef.sol**

|135 136 137 138 139 140 141 142 143 144 145 146 147|uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock; totalAllocPoint = totalAllocPoint.add(_allocPoint); poolInfo.push(PoolInfo({ lpToken: _lpToken, allocPoint: _allocPoint, lastRewardBlock: lastRewardBlock, accLuckyPerShare: 0, harvestTimestamp: _harvestTimestampInUnix, farmStartDate : _farmStartTimestampInUnix })); emit PoolAdded(_lpToken,_allocPoint,_harvestTimestampInUnix, _farmStartTimestampInUnix); isAddedPool[address(_lpToken)] = true; }|
|---|---|

|201 202 203 204 205 206 207 208 209 210 211 212 213 214 215|function migrate(uint256 _pid) public { require(address(migrator) != address(0), "migrate: no migrator"); PoolInfo storage pool = poolInfo[_pid]; IERC20 lpToken = pool.lpToken; uint256 bal = lpToken.balanceOf(address(this)); lpToken.safeApprove(address(migrator), bal); IERC20 newLpToken = migrator.migrate(lpToken); require(!isAddedPool[address(newLpToken)], "migrate: Duplicated LP Token"); require(bal == newLpToken.balanceOf(address(this)), "migrate: bad"); isAddedPool[address(pool.lpToken)] = false; pool.lpToken = newLpToken; isAddedPool[address(pool.lpToken)] = true; }|
|---|---|


( ) 16


-----

Public

________

### 