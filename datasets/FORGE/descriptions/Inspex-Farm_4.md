5.5. Design Flaw in massUpdatePools() Function

**ID** IDX-005

**Target** MasterChef

**Category** General Smart Contract Vulnerability

**CWE** CWE-400: Uncontrolled Resource Consumption

**Risk** **Severity: Low**

**Impact: Medium**
The massUpdatePools() function will eventually be unusable due to excessive gas usage.

**Likelihood: Low**
It is very unlikely that the poolInfo size will be raised until the massUpdatePools()
function is unusable.

**Status** **Acknowledged**
​LuckyLion team has acknowledged this issue. The team has prepared a testing process on
the local network (environment with the same settings as the main network) which has
the same number of pools as the mainnet, so this problem can be proactively prevented.

#### 5.5.1. Description

The massUpdatePools() function executes the updatePool() function, which is a state modifying function
for all added pools as shown below:

**Masterchef.sol**
```
 189 function massUpdatePools() public {
 190 uint256 length = poolInfo.length;
 191 for (uint256 pid = 0; pid < length; ++pid) {
 192 updatePool(pid);
 193 }
 194 }

```
With the current design, the added pools cannot be removed. They can only be disabled by setting the
```
pool.allocPoint to 0. Even if a pool is disabled, the updatePool() function for this pool is still called.

```
Therefore, if new pools continue to be added to this contract, the poolInfo.length will continue to grow
and this function will eventually be unusable due to excessive gas usage.

#### 5.5.2. Remediation

Inspex suggests making the contract capable of removing unnecessary or ended pools to reduce the loop
round in the massUpdatePools() function.

( ) 23

|ID|IDX-005|
|---|---|
|Target|MasterChef|
|Category|General Smart Contract Vulnerability|
|CWE|CWE-400: Uncontrolled Resource Consumption|
|Risk|Severity: Low Impact: Medium The massUpdatePools() function will eventually be unusable due to excessive gas usage. Likelihood: Low It is very unlikely that the poolInfo size will be raised until the massUpdatePools() function is unusable.|
|Status|Acknowledged ​LuckyLion team has acknowledged this issue. The team has prepared a testing process on the local network (environment with the same settings as the main network) which has the same number of pools as the mainnet, so this problem can be proactively prevented.|

|189 190 191 192 193 194|function massUpdatePools() public { uint256 length = poolInfo.length; for (uint256 pid = 0; pid < length; ++pid) { updatePool(pid); } }|
|---|---|


-----

Public

________

### 