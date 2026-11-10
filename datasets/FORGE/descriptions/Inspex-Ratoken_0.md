5.1. Improper Ownership Locking Mechanism

**ID** IDX-001

**Target** Token

**Category** Advanced Smart Contract Vulnerability

**CWE** CWE-840: Business Logic Errors

**Risk** **Severity: High**

**Impact: High**
The previous contract owner can reclaim the ownership of the contract when the
ownership is transferred to another address or renounced, giving that address the ability
to perform privileged actions again.

**Likelihood: Medium**
Only the contract owner can perform this action; however, there is no restriction to
prevent the owner from abusing this flaw.

**Status** **Resolved**
Ratoken team has resolved this issue as suggested and deployed the fixed version to
[0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet.](https://bscscan.com/address/0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195)

#### 5.1.1. Description

The Token contract inherits a custom Ownable contract with an ownership locking mechanism. The contract
owner can execute the lock() function to temporarily transfer the ownership of the contract to zero address
for a duration specified in the time parameter. The address of the owner is saved in the _previousOwner
state variable to be used later.

**Token.sol**
```
 522 //Locks the contract for owner for the amount of time provided
 523 function lock(uint256 time) public virtual onlyOwner {
 524 _previousOwner = _owner;
 525 _owner = address(0);
 526 _lockTime = block.timestamp + time;
 527 emit OwnershipTransferred(_owner, address(0));
 528 }

```
After a duration of time has passed, the address stored in the _previousOwner state variable can call the
```
unlock() function to reclaim the ownership of the contract.

```
( ) 9

|ID|IDX-001|
|---|---|
|Target|Token|
|Category|Advanced Smart Contract Vulnerability|
|CWE|CWE-840: Business Logic Errors|
|Risk|Severity: High Impact: High The previous contract owner can reclaim the ownership of the contract when the ownership is transferred to another address or renounced, giving that address the ability to perform privileged actions again. Likelihood: Medium Only the contract owner can perform this action; however, there is no restriction to prevent the owner from abusing this flaw.|
|Status|Resolved Ratoken team has resolved this issue as suggested and deployed the fixed version to 0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet.|

|522 523 524 525 526 527 528|//Locks the contract for owner for the amount of time provided function lock(uint256 time) public virtual onlyOwner { _previousOwner = _owner; _owner = address(0); _lockTime = block.timestamp + time; emit OwnershipTransferred(_owner, address(0)); }|
|---|---|


-----

Public

________

**Token.sol**
```
 530 //Unlocks the contract for owner when _lockTime is exceeds
 531 function unlock() public virtual {
 532 require(_previousOwner == msg.sender, "You don't have permission to unlock
   the token contract");
 533 require(block.timestamp > _lockTime, "Contract is locked until 7 days");
 534 emit OwnershipTransferred(_owner, _previousOwner);
 535 _owner = _previousOwner;
 536 }

```
However, the _previousOwner state variable is not cleared in the unlock() function, this allows the address
stored in the _previousOwner state variable to reclaim the ownership even when the ownership has been
renounced or transferred to another address.

As an example, assuming the contract owner is wallet A, the attacking steps can be as follows:

1. Wallet A executes the lock() function to store the address of wallet A in the _previousOwner state
variable.
2. Wallet A executes the unlock() function to reclaim the contract ownership.
3. Wallet A renounces the ownership or transfers the ownership to another address. At the current state,
the users will see that the owner of the contract is not wallet A, and may trust that privileged
functions cannot be executed by wallet A anymore.
4. Wallet A executes the unlock() function, transferring the ownership back to wallet A.

#### 5.1.2. Remediation

Inspex suggests clearing the _previousOwner state variable at the end of the unlock() function to prevent
it from being executed multiple times, for example:

**Token.sol**
```
 530 //Unlocks the contract for owner when _lockTime is exceeds
 531 function unlock() public virtual {
 532 require(_previousOwner == msg.sender, "You don't have permission to unlock
 533 the token contract");
 534 require(block.timestamp > _lockTime, "Contract is locked until 7 days");
 535 emit OwnershipTransferred(_owner, _previousOwner);
 536 _owner = _previousOwner;
 537 _previousOwner = address(0);
   }

```
( ) 10

|530 531 532 533 534 535 536|//Unlocks the contract for owner when _lockTime is exceeds function unlock() public virtual { require(_previousOwner == msg.sender, "You don't have permission to unlock the token contract"); require(block.timestamp > _lockTime , "Contract is locked until 7 days"); emit OwnershipTransferred(_owner, _previousOwner); _owner = _previousOwner; }|
|---|---|

|530 531 532 533 534 535 536 537|//Unlocks the contract for owner when _lockTime is exceeds function unlock() public virtual { require(_previousOwner == msg.sender, "You don't have permission to unlock the token contract"); require(block.timestamp > _lockTime , "Contract is locked until 7 days"); emit OwnershipTransferred(_owner, _previousOwner); _owner = _previousOwner; _previousOwner = address(0); }|
|---|---|


-----

Public

________

### 