5.1. Token Draining Using migrate() Function

**ID** IDX-001

**Target** MasterChef

**Category** Advanced Smart Contract Vulnerability

**CWE** CWE-284: Improper Access Control

**Risk** **Severity: High**

**Impact: High**
The owner of the MasterChef contract can steal all lpToken from the contract.

**Likelihood: Medium**
Only the contract owner can set the migrator address; however, there is no restriction to
prevent the owner from performing this attack.

**Status** **Resolved**
**Nov 1, 2021:**
LuckyLion team has resolved this issue by implementing a Shield contract without the
```
       setMigrator() function and transferring the ownership of the MasterChef contract to

```
the Shield contract that is owned by a Timelock contract.
```
       Timelock contract with 7 days delay:

```
[https://bscscan.com/address/0x4b6c8959a41475347226d51f37ec9a1e09f39a92#code](https://bscscan.com/address/0x4b6c8959a41475347226d51f37ec9a1e09f39a92#code)
```
       Shield contract:

```
[https://bscscan.com/address/0xf6d883b0da58171642a27062b096f655f663c4f1#code](https://bscscan.com/address/0xf6d883b0da58171642a27062b096f655f663c4f1#code)

Ownership transfer of MasterChef to Shield contract:
[https://bscscan.com/tx/0xe41ee13e98e31531262796951353ccd57a54ec7f1b19bcbfbddb8](https://bscscan.com/tx/0xe41ee13e98e31531262796951353ccd57a54ec7f1b19bcbfbddb8b6eea944be3#eventlog)
[b6eea944be3#eventlog](https://bscscan.com/tx/0xe41ee13e98e31531262796951353ccd57a54ec7f1b19bcbfbddb8b6eea944be3#eventlog)

**Sep 21, 2021:**
LuckyLion team has decided to keep this functionality and mitigated this issue by
implementing a timelock mechanism. The MasterChef contract is owned by the
```
       Timelock contract with 7 days delay and 2 days minimum delay.
       Timelock contract with 2 days minimum delay:

```
[https://bscscan.com/address/0x4b6c8959a41475347226d51f37ec9a1e09f39a92#code](https://bscscan.com/address/0x4b6c8959a41475347226d51f37ec9a1e09f39a92#code)
```
       MasterChef contract:

```
[https://bscscan.com/address/0xb6fe67c8a28d50c50f65fdb5847ee4477c550568#code](https://bscscan.com/address/0xb6fe67c8a28d50c50f65fdb5847ee4477c550568#code)

Ownership transfer of MasterChef to Timelock contract:
[https://bscscan.com/tx/0xb54a48f780f6912f283b0113dfbb9fbef4d0f9e421bc532bb9c41a4](https://bscscan.com/tx/0xb54a48f780f6912f283b0113dfbb9fbef4d0f9e421bc532bb9c41a43cc15140f#eventlog)

( ) 10

|ID|IDX-001|
|---|---|
|Target|MasterChef|
|Category|Advanced Smart Contract Vulnerability|
|CWE|CWE-284: Improper Access Control|
|Risk|Severity: High Impact: High The owner of the MasterChef contract can steal all lpToken from the contract. Likelihood: Medium Only the contract owner can set the migrator address; however, there is no restriction to prevent the owner from performing this attack.|
|Status|Resolved Nov 1, 2021: LuckyLion team has resolved this issue by implementing a Shield contract without the setMigrator() function and transferring the ownership of the MasterChef contract to the Shield contract that is owned by a Timelock contract. Timelock contract with 7 days delay: https://bscscan.com/address/0x4b6c8959a41475347226d51f37ec9a1e09f39a92#code Shield contract: https://bscscan.com/address/0xf6d883b0da58171642a27062b096f655f663c4f1#code Ownership transfer of MasterChef to Shield contract: https://bscscan.com/tx/0xe41ee13e98e31531262796951353ccd57a54ec7f1b19bcbfbddb8 b6eea944be3#eventlog Sep 21, 2021: LuckyLion team has decided to keep this functionality and mitigated this issue by implementing a timelock mechanism. The MasterChef contract is owned by the Timelock contract with 7 days delay and 2 days minimum delay. Timelock contract with 2 days minimum delay: https://bscscan.com/address/0x4b6c8959a41475347226d51f37ec9a1e09f39a92#code MasterChef contract: https://bscscan.com/address/0xb6fe67c8a28d50c50f65fdb5847ee4477c550568#code Ownership transfer of MasterChef to Timelock contract: https://bscscan.com/tx/0xb54a48f780f6912f283b0113dfbb9fbef4d0f9e421bc532bb9c41a4|


-----

Public

________

[3cc15140f#eventlog](https://bscscan.com/tx/0xb54a48f780f6912f283b0113dfbb9fbef4d0f9e421bc532bb9c41a43cc15140f#eventlog)

Platform users should monitor the execution of functions in the timelock and act
accordingly.

#### 5.1.1. Description

In the MasterChef contract, the setMigrator() function can be used by the contract owner to set the
```
migrator address.

```
**Masterchef.sol**
```
 196 function setMigrator(IMigratorChef _migrator) public onlyOwner {
 197 migrator = _migrator;
 198 }

```
The migrate() function can be called by anyone. When the migrate() function is called, the MasterChef
contract will allow the migrator to spend all lpToken balance in the contract.

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
The contract owner can steal all lpToken in the contract by setting the migrator address to a malicious
address and use transferFrom() function to transfer all lpToken from MasterChef to any address.

#### 5.1.2. Remediation

Inspex suggests removing the migration mechanism from the MasterChef contract.

However, if the migration is needed, Inspex suggests mitigating this issue by implementing a timelock
mechanism with a sufficient length of time to delay the changes. This allows the platform users to monitor
the timelock and be notified of the potential changes being done on the smart contracts.

( ) 11

|Col1|3cc15140f#eventlog Platform users should monitor the execution of functions in the timelock and act accordingly.|
|---|---|

|196 197 198|function setMigrator(IMigratorChef _migrator) public onlyOwner { migrator = _migrator; }|
|---|---|

|201 202 203 204 205 206 207 208 209 210|function migrate(uint256 _pid) public { require(address(migrator) != address(0), "migrate: no migrator"); PoolInfo storage pool = poolInfo[_pid]; IERC20 lpToken = pool.lpToken; uint256 bal = lpToken.balanceOf(address(this)); lpToken.safeApprove(address(migrator), bal); IERC20 newLpToken = migrator.migrate(lpToken); require(bal == newLpToken.balanceOf(address(this)), "migrate: bad"); pool.lpToken = newLpToken; }|
|---|---|


-----

Public

________

### 