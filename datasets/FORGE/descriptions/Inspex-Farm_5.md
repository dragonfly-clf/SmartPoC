5.6. Insufficient Logging for Privileged Functions

**ID** IDX-006

**Target** MasterChef

**Category** Advanced Smart Contract Vulnerability

**CWE** CWE-778: Insufficient Logging

**Risk** **Severity: Very Low**

**Impact: Low**
Privileged functions' executions cannot be monitored easily by the users.

**Likelihood: Low**
It is not likely that the execution of the privileged functions will be a malicious action.

**Status** **Resolved**
LuckyLion team has resolved this issue as suggested in commit
```
       5aa5780d15ce4b471d49abb3cba09ac7203975f2.

#### 5.6.1. Description

```
Privileged functions that are executable by the controlling parties are not logged properly by emitting events.
Without events, it is not easy for the public to monitor the execution of those privileged functions, allowing
the controlling parties to perform actions that cause big impacts on the platform.

For example, the owner can modify the migrator address by executing setMigrator() function in the
```
MasterChef contract, and no event is emitted.

```
**Masterchef.sol**
```
 363 function setMigrator(IMigratorChef _migrator) public onlyOwner {
 364 migrator = _migrator;
 365 }

```
The privileged functions without sufficient logging are as follows:

**File** **Contract** **Function** **Modifier**

Masterchef.sol (L:196) MasterChef setMigrator() onlyOwner

Masterchef.sol (L:363) MasterChef setDevAddress() onlyOwner

#### 5.6.2. Remediation

Inspex suggests emitting events for the execution of privileged functions, for example:

( ) 24

|ID|IDX-006|
|---|---|
|Target|MasterChef|
|Category|Advanced Smart Contract Vulnerability|
|CWE|CWE-778: Insufficient Logging|
|Risk|Severity: Very Low Impact: Low Privileged functions' executions cannot be monitored easily by the users. Likelihood: Low It is not likely that the execution of the privileged functions will be a malicious action.|
|Status|Resolved LuckyLion team has resolved this issue as suggested in commit 5aa5780d15ce4b471d49abb3cba09ac7203975f2.|

|363 364 365|function setMigrator(IMigratorChef _migrator) public onlyOwner { migrator = _migrator; }|
|---|---|

|File|Contract|Function|Modifier|
|---|---|---|---|
|Masterchef.sol (L:196)|MasterChef|setMigrator()|onlyOwner|
|Masterchef.sol (L:363)|MasterChef|setDevAddress()|onlyOwner|


-----

Public

________

**Masterchef.sol**

|363 364 365 366 367|event SetMigrator(IMigratorChef _oldmigrator, IMigratorChef _migrator); function setMigrator(IMigratorChef _migrator) public onlyOwner { emit SetMigrator(migrator, _migrator); migrator = _migrator; }|
|---|---|


( ) 25


-----

Public

________

### 