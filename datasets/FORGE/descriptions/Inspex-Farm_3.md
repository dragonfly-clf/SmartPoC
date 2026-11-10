5.4. Centralized Control of State Variable

**ID** IDX-004

**Target** MasterChef

**Category** General Smart Contract Vulnerability

**CWE** CWE-710: Improper Adherence to Coding Standard

**Risk** **Severity: Medium**

**Impact: Medium**
The controlling authorities can change the critical state variables to gain additional profit.
Thus, it is unfair to the other users.

**Likelihood: Medium**
These functions can only be called by the contract owner; however, there is nothing to
restrict the changes from being done by the owner.

**Status** **Resolved**
LuckyLion team has resolved this issue by implementing a timelock mechanism. The
```
       MasterChef contract is owned by the Timelock contract with 7 days delay and 2 days

```
minimum delay.
```
       Timelock contract with 2 days minimum delay:

```
[https://bscscan.com/address/0x4b6c8959a41475347226d51f37ec9a1e09f39a92#code](https://bscscan.com/address/0x4b6c8959a41475347226d51f37ec9a1e09f39a92#code)
```
       MasterChef contract:

```
[https://bscscan.com/address/0xb6fe67c8a28d50c50f65fdb5847ee4477c550568#code](https://bscscan.com/address/0xb6fe67c8a28d50c50f65fdb5847ee4477c550568#code)

Ownership transfer of MasterChef to Timelock contract:
[https://bscscan.com/tx/0xb54a48f780f6912f283b0113dfbb9fbef4d0f9e421bc532bb9c41a4](https://bscscan.com/tx/0xb54a48f780f6912f283b0113dfbb9fbef4d0f9e421bc532bb9c41a43cc15140f#eventlog)
[3cc15140f#eventlog](https://bscscan.com/tx/0xb54a48f780f6912f283b0113dfbb9fbef4d0f9e421bc532bb9c41a43cc15140f#eventlog)

Platform users should monitor the execution of functions in the timelock and act
accordingly.

#### 5.4.1. Description

Critical state variables can be updated any time by the controlling authorities. Changes in these variables can
cause impacts to the users, so the users should accept or be notified before these changes are effective.

However, as the contract is not yet deployed, there is potentially no constraint to prevent the authorities
from modifying these variables without notifying the users.

( ) 21

|ID|IDX-004|
|---|---|
|Target|MasterChef|
|Category|General Smart Contract Vulnerability|
|CWE|CWE-710: Improper Adherence to Coding Standard|
|Risk|Severity: Medium Impact: Medium The controlling authorities can change the critical state variables to gain additional profit. Thus, it is unfair to the other users. Likelihood: Medium These functions can only be called by the contract owner; however, there is nothing to restrict the changes from being done by the owner.|
|Status|Resolved LuckyLion team has resolved this issue by implementing a timelock mechanism. The MasterChef contract is owned by the Timelock contract with 7 days delay and 2 days minimum delay. Timelock contract with 2 days minimum delay: https://bscscan.com/address/0x4b6c8959a41475347226d51f37ec9a1e09f39a92#code MasterChef contract: https://bscscan.com/address/0xb6fe67c8a28d50c50f65fdb5847ee4477c550568#code Ownership transfer of MasterChef to Timelock contract: https://bscscan.com/tx/0xb54a48f780f6912f283b0113dfbb9fbef4d0f9e421bc532bb9c41a4 3cc15140f#eventlog Platform users should monitor the execution of functions in the timelock and act accordingly.|


-----

Public

________

The controllable privileged state update functions are as follows:

**File** **Contract** **Function** **Modifier**

Masterchef.sol (L:128) MasterChef add() onlyOwner

Masterchef.sol (L:148) MasterChef set() onlyOwner

Masterchef.sol (L:196) MasterChef setMigrator() onlyOwner

Masterchef.sol (L:363) MasterChef setDevAddress() onlyOwner

Masterchef.sol (L:369) MasterChef updateLuckyPerBlock() onlyOwner

Ownable.sol (L:53) MasterChef renounceOwnership() onlyOwner

Ownable.sol (L:61) MasterChef transferOwnership() onlyOwner

Please note that the Ownable contract is inherited from the OpenZeppelin's library.

#### 5.4.2. Remediation

In the ideal case, the critical state variables should not be modifiable to keep the integrity of the smart
contract. However, if modifications are needed, Inspex suggests limiting the use of these functions via the
following options:

   - Implementing a community-run governance to control the use of these functions
   - Using a Timelock contract to delay the changes for a sufficient amount of time

( ) 22

|File|Contract|Function|Modifier|
|---|---|---|---|
|Masterchef.sol (L:128)|MasterChef|add()|onlyOwner|
|Masterchef.sol (L:148)|MasterChef|set()|onlyOwner|
|Masterchef.sol (L:196)|MasterChef|setMigrator()|onlyOwner|
|Masterchef.sol (L:363)|MasterChef|setDevAddress()|onlyOwner|
|Masterchef.sol (L:369)|MasterChef|updateLuckyPerBlock()|onlyOwner|
|Ownable.sol (L:53)|MasterChef|renounceOwnership()|onlyOwner|
|Ownable.sol (L:61)|MasterChef|transferOwnership()|onlyOwner|


-----

Public

________

### 