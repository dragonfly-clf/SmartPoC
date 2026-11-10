5.7. Unsupported Design for Deflationary Token

**ID** IDX-007

**Target** MasterChef

**Category** Advanced Smart Contract Vulnerability

**CWE** CWE-840: Business Logic Errors

**Risk** **Severity: Info**

**Impact: None**

**Likelihood: None**

**Status** **Resolved**
LuckyLion team has resolved this issue as suggested in commit
```
       5aa5780d15ce4b471d49abb3cba09ac7203975f2.

#### 5.7.1. Description

```
In MasterChef contract, the users can deposit their tokens to acquire rewards ($LUCKY). The deposited
tokens can be a normal token or LP token depending on the pools added by the contract owner.

However, in the deposit() function, an issue could arise when the pool uses a deflationary token (the token
that reduces the circulating supply itself when it is transferred).

This means the _amount that the user deposits will be reduced due to the deflationary mechanism, but the
contract recognizes it as the full amount as in line 299.

**Masterchef.sol**
```
 287 function deposit(uint256 _pid, uint256 _amount) public nonReentrant {
 288 PoolInfo storage pool = poolInfo[_pid];
 289 UserInfo storage user = userInfo[_pid][msg.sender];
 290 require(pool.farmStartDate <= block.timestamp,"unable to deposit before the
   farm starts.");
 291 //can not harvest(deposit 0) before the harvestTimestamp.
 292 if (!canHarvest(_pid) && _amount==0){
 293 require(pool.harvestTimestamp <= block.timestamp,"can not harvest
   before the harvestTimestamp" ); //newly added
 294 }
 295 updatePool(_pid);
 296 payOrLockupPendingLucky(_pid);
 297 if (_amount > 0) {
 298 pool.lpToken.safeTransferFrom(address(msg.sender), address(this),
   _amount);
 299 user.amount = user.amount.add(_amount);

```
( ) 26

|ID|IDX-007|
|---|---|
|Target|MasterChef|
|Category|Advanced Smart Contract Vulnerability|
|CWE|CWE-840: Business Logic Errors|
|Risk|Severity: Info Impact: None Likelihood: None|
|Status|Resolved LuckyLion team has resolved this issue as suggested in commit 5aa5780d15ce4b471d49abb3cba09ac7203975f2.|

|287 288 289 290 291 292 293 294 295 296 297 298 299|function deposit(uint256 _pid, uint256 _amount) public nonReentrant { PoolInfo storage pool = poolInfo[_pid]; UserInfo storage user = userInfo[_pid][msg.sender]; require(pool.farmStartDate <= block.timestamp,"unable to deposit before the farm starts."); //can not harvest(deposit 0) before the harvestTimestamp. if (!canHarvest(_pid) && _amount==0){ require(pool.harvestTimestamp <= block.timestamp,"can not harvest before the harvestTimestamp" ); //newly added } updatePool(_pid); payOrLockupPendingLucky(_pid); if (_amount > 0) { pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount); user.amount = user.amount.add(_amount);|
|---|---|


-----

Public

________
```
 300 }
 301 user.rewardDebt = user.amount.mul(pool.accLuckyPerShare).div(1e12);
 302 emit Deposit(msg.sender, _pid, _amount);
 303 }

```
The failure of recognizing the token amount could lead to the following scenarios:

**Scenario 1: Unable to withdraw staking tokens**

Assuming that there is a pool in the MasterChef contract which receives a deflationary token ($TOKEN) with
10% burn rate when the token is transferred.

Currently, there is only User A who stakes $TOKEN to the $TOKEN pool in the MasterChef contract.

**Holder** **Balance**

User A 100

Total $TOKEN in the MasterChef contract: 90

User B deposits 100 $TOKEN to the $TOKEN pool in the MasterChef contract. The MasterChef contract will
receive 90 $TOKEN since $TOKEN is 10% deduction from the deflationary mechanism, in this case 10
$TOKEN.

**Holder** **Balance**

User A 100

User B 100

Total $TOKEN in the MasterChef contract: 180

User B then withdraws 100 $TOKEN from the MasterChef contract. The MasterChef contract will validate
whether the withdrawn _amount exceeds the user.amount.

**Masterchef.sol**
```
 306 function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {
 307 PoolInfo storage pool = poolInfo[_pid];
 308 UserInfo storage user = userInfo[_pid][msg.sender];
 309 require(user.amount >= _amount, "withdraw: not good");
 310 updatePool(_pid);
 311 payOrLockupPendingLucky(_pid);
 312 if (_amount > 0) {
 313 user.amount = user.amount.sub(_amount);
 314 pool.lpToken.safeTransfer(address(msg.sender), _amount);
 315 }

```
( ) 27

|300 301 302 303|} user.rewardDebt = user.amount.mul(pool.accLuckyPerShare).div(1e12); emit Deposit(msg.sender, _pid, _amount); }|
|---|---|

|Holder|Balance|
|---|---|
|User A|100|

|Holder|Balance|
|---|---|
|User A|100|
|User B|100|

|306 307 308 309 310 311 312 313 314 315|function withdraw(uint256 _pid, uint256 _amount) public nonReentrant { PoolInfo storage pool = poolInfo[_pid]; UserInfo storage user = userInfo[_pid][msg.sender]; require(user.amount >= _amount, "withdraw: not good"); updatePool(_pid); payOrLockupPendingLucky(_pid); if (_amount > 0) { user.amount = user.amount.sub(_amount); pool.lpToken.safeTransfer(address(msg.sender), _amount); }|
|---|---|


-----

Public

________
```
 316 user.rewardDebt = user.amount.mul(pool.accLuckyPerShare).div(1e12);
 317 emit Withdraw(msg.sender, _pid, _amount);
 318 }

```
Since User B deposited 100 $TOKEN and the balance of $TOKEN in the contract is greater than 100, User B is
allowed to withdraw 100 $TOKEN.

**Holder** **Balance**

User A 100

User B 0

Total $TOKEN in the MasterChef contract: 80

As a result, if User A decides to withdraw 100 $TOKEN, this transaction will be reverted since the balance in
the contract is insufficient.

**Scenario 2: Reward Calculation Exploit**

Assuming that there is a pool in the MasterChef contract which receives a deflationary token ($TOKEN) with
10% burn rate when the token is transferred.

Currently, there are several users who stake $TOKEN to the $TOKEN pool in the MasterChef contract with a
total supply of 100 $TOKEN.

User A deposits 100 $TOKEN to the contract, and the contract receives 90 $TOKEN due to the deflationary
mechanism, resulting in a total supply of 190 $TOKEN.

After that, User A withdraws 100 $TOKEN from staking, the MasterChef contract will then calculate the
rewards as in line 337.

**Masterchef.sol**
```
 333 function payOrLockupPendingLucky(uint256 _pid) internal {
 334 PoolInfo storage pool = poolInfo[_pid];
 335 UserInfo storage user = userInfo[_pid][msg.sender];
 336
 337 uint256 pending =
   user.amount.mul(pool.accLuckyPerShare).div(1e12).sub(user.rewardDebt);
 338 if (canHarvest(_pid)) {
 339 if (pending > 0 || user.rewardLockedUp > 0) {
 340 uint256 totalRewards = pending.add(user.rewardLockedUp);
 341
 342 // reset lockup
 343 totalLockedUpRewards =
   totalLockedUpRewards.sub(user.rewardLockedUp);

```
( ) 28

|316 317 318|user.rewardDebt = user.amount.mul(pool.accLuckyPerShare).div(1e12); emit Withdraw(msg.sender, _pid, _amount); }|
|---|---|

|Holder|Balance|
|---|---|
|User A|100|
|User B|0|

|333 334 335 336 337 338 339 340 341 342 343|function payOrLockupPendingLucky(uint256 _pid) internal { PoolInfo storage pool = poolInfo[_pid]; UserInfo storage user = userInfo[_pid][msg.sender]; uint256 pending = user.amount.mul(pool.accLuckyPerShare).div(1e12).sub(user.rewardDebt); if (canHarvest(_pid)) { if (pending > 0 || user.rewardLockedUp > 0) { uint256 totalRewards = pending.add(user.rewardLockedUp); // reset lockup totalLockedUpRewards = totalLockedUpRewards.sub(user.rewardLockedUp);|
|---|---|


-----

Public

________
```
 344 user.rewardLockedUp = 0;
 345
 346 // send rewards
 347 safeLuckyTransfer(msg.sender, totalRewards);
 348 emit RewardPaid(msg.sender,totalRewards);
 349 }
 350 } else if (pending > 0) {
 351 user.rewardLockedUp = user.rewardLockedUp.add(pending);
 352 totalLockedUpRewards = totalLockedUpRewards.add(pending);
 353 emit RewardLockedUp(msg.sender, _pid, pending);
 354 }
 355 }

```
During the calculation, the reward is affected by the total amount of $TOKEN (lpSupply) as in line 218.

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
 229 //1st case, reward for dev will exceed Lucky's totalSupply so we limit the
   minting amount to syrup.
 230 if (luckyRewardForDev.add(lucky.totalSupply()) > lucky.cap() ) {
 231 uint256 remainingReward = lucky.cap().sub(lucky.totalSupply());
 232 //in case that remainingReward > capped reward for dev.
 233 if (remainingReward.add(accumulatedRewardForDev) > capRewardForDev) {
 234 uint256 lastRemainingRewardForDev =
   capRewardForDev.sub(accumulatedRewardForDev);
 235 lucky.mint(devAddress,lastRemainingRewardForDev);
 236 accumulatedRewardForDev =
   accumulatedRewardForDev.add(lastRemainingRewardForDev);
 237 //the rest is minted to users.
 238 lucky.mint(address(syrup),lucky.cap().sub(lucky.totalSupply()));

```
( ) 29

|344 345 346 347 348 349 350 351 352 353 354 355|user.rewardLockedUp = 0; // send rewards safeLuckyTransfer(msg.sender, totalRewards); emit RewardPaid(msg.sender,totalRewards); } } else if (pending > 0) { user.rewardLockedUp = user.rewardLockedUp.add(pending); totalLockedUpRewards = totalLockedUpRewards.add(pending); emit RewardLockedUp(msg.sender, _pid, pending); } }|
|---|---|

|213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238|function updatePool(uint256 _pid) public { PoolInfo storage pool = poolInfo[_pid]; if (block.number <= pool.lastRewardBlock) { return; } uint256 lpSupply = pool.lpToken.balanceOf(address(this)); if (lpSupply == 0 || pool.allocPoint == 0) { pool.lastRewardBlock = block.number; return; } uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number); uint256 luckyReward = multiplier.mul(luckyPerBlock).mul(pool.allocPoint).div(totalAllocPoint); //new one // check at final to mint exact lucky to complete the round 9 million and 100 millions totalsupply uint256 luckyRewardForDev = luckyReward.mul(devMintingRatio).div(10000); //logic to prevent the minting exceeds the capped totalsupply //1st case, reward for dev will exceed Lucky's totalSupply so we limit the minting amount to syrup. if (luckyRewardForDev.add(lucky.totalSupply()) > lucky.cap() ) { uint256 remainingReward = lucky.cap().sub(lucky.totalSupply()); //in case that remainingReward > capped reward for dev. if (remainingReward.add(accumulatedRewardForDev) > capRewardForDev) { uint256 lastRemainingRewardForDev = capRewardForDev.sub(accumulatedRewardForDev); lucky.mint(devAddress,lastRemainingRewardForDev); accumulatedRewardForDev = accumulatedRewardForDev.add(lastRemainingRewardForDev); //the rest is minted to users. lucky.mint(address(syrup),lucky.cap().sub(lucky.totalSupply()));|
|---|---|


-----

Public

________

|239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276|} //normal case that dev's caped reward has not been reached yet, but the totalSupply of Lucky is reached. else { lucky.mint(devAddress, remainingReward); //track the token that is minted to dev. accumulatedRewardForDev = accumulatedRewardForDev.add(remainingReward); } } //supply cap was not reached and capRewardForDevev still has room to mint for. else { //capRewardForDev is reached. if (luckyRewardForDev.add(accumulatedRewardForDev) > capRewardForDev) { uint256 lastRemainingRewardForDev = capRewardForDev.sub(accumulatedRewardForDev); lucky.mint(devAddress,lastRemainingRewardForDev); //track the token that is minted to dev. accumulatedRewardForDev = accumulatedRewardForDev.add(lastRemainingRewardForDev); //mint the left portion of dev to the pools. lucky.mint(address(syrup),luckyRewardForDev .sub(lastRemainingRewardForDev)); if (luckyReward.add(lucky.totalSupply()) > lucky.cap() ){ lucky.mint(address(syrup),lucky.cap() .sub(lucky.totalSupply())); } else { lucky.mint(address(syrup),luckyReward); } } else { lucky.mint(devAddress,luckyRewardForDev); accumulatedRewardForDev = accumulatedRewardForDev.add(luckyRewardForDev); if (luckyReward.add(lucky.totalSupply()) > lucky.cap() ){ lucky.mint(address(syrup),lucky.cap() .sub(lucky.totalSupply())); } else{|
|---|---|


( ) 30


-----

Public

________
```
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
Since the MasterChef contract registers the user.amount of User A as 100 $TOKEN, the withdrawn $TOKEN
amount will be 100, resulting in reducing the total amount of $TOKEN in the contract to 90 $TOKEN.

Hence, the value of pool.accLuckyPerShare can be increased dramatically by manipulating the total
amount of $TOKEN (lpSupply) to be as low as possible.

User A can repeatedly execute withdraw() and deposit() functions to drain the $TOKEN in the contract
until it is as low as possible, for example, 1 wei, causing accLuckyPerShare state to be overly inflated, so the
users can claim an exceedingly large amount of reward ($LUCK) from the contract.

However, since only LP tokens are planned to be used in MasterChef pools, there is no direct impact for this
issue.

#### 5.7.2. Remediation

Inspex suggests modifying the logic of the deposit() function to validate the amount of the received token
from the user instead of using the value of _amount parameter directly.

**Masterchef.sol**
```
 287 function deposit(uint256 _pid, uint256 _amount) public nonReentrant {
 288 PoolInfo storage pool = poolInfo[_pid];
 289 UserInfo storage user = userInfo[_pid][msg.sender];
 290 require(pool.farmStartDate <= block.timestamp,"unable to deposit before the
   farm starts.");
 291 //can not harvest(deposit 0) before the harvestTimestamp.
 292 if (!canHarvest(_pid) && _amount==0){
 293 require(pool.harvestTimestamp <= block.timestamp,"can not harvest
   before the harvestTimestamp" ); //newly added
 294 }
 295 updatePool(_pid);
 296 payOrLockupPendingLucky(_pid);
 297 if (_amount > 0) {
 298 uint256 currentBal = pool.lpToken.balanceOf(address(this));
 299 pool.lpToken.safeTransferFrom(address(msg.sender), address(this),
   _amount);
 300 uint256 receivedAmount = pool.lpToken.balanceOf(address(this)) 
```
( ) 31

|277 278 279 280 281 282 283 284|lucky.mint(address(syrup),luckyReward); } } } pool.accLuckyPerShare = pool.accLuckyPerShare.add(luckyReward.mul(1e12).div(lpSupply)); pool.lastRewardBlock = block.number; }|
|---|---|

|287 288 289 290 291 292 293 294 295 296 297 298 299 300|function deposit(uint256 _pid, uint256 _amount) public nonReentrant { PoolInfo storage pool = poolInfo[_pid]; UserInfo storage user = userInfo[_pid][msg.sender]; require(pool.farmStartDate <= block.timestamp,"unable to deposit before the farm starts."); //can not harvest(deposit 0) before the harvestTimestamp. if (!canHarvest(_pid) && _amount==0){ require(pool.harvestTimestamp <= block.timestamp,"can not harvest before the harvestTimestamp" ); //newly added } updatePool(_pid); payOrLockupPendingLucky(_pid); if (_amount > 0) { uint256 currentBal = pool.lpToken.balanceOf(address(this)); pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount); uint256 receivedAmount = pool.lpToken.balanceOf(address(this)) -|
|---|---|


-----

Public

________

|301 302 303 304 305|currentBal; user.amount = user.amount.add(receivedAmount); } user.rewardDebt = user.amount.mul(pool.accLuckyPerShare).div(1e12); emit Deposit(msg.sender, _pid, _amount); }|
|---|---|


( ) 32


-----

Public

________

### 