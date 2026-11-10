#### BC - Blacklists Addresses

**Criticality** critical

**Location** contract.sol#L1030

**Status** Unresolved

##### Description

The contract owner has the authority to stop addresses from transactions. The
owner may take advantage of it by enabling IPinkAntiBot interface.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1030|
|Status|Unresolved|


**function _transfer(**

**address from,**
**address to,**
**uint256 amount**
**) internal override {**

**super._beforeTokenTransfer(from, to, amount);**
**require(from != address(0), "ERC20: transfer from the zero address");**
**require(to != address(0), "ERC20: transfer to the zero address");**
**if (antiBotEnabled) {**

**pinkAntiBot.onPreTransferCheck(from, to, amount);**
**}**


##### Recommendation

The contract should initialize the pinkAntiBot with the trusted Pinksale antibot
address. It should not allow changes after the initialization.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

⬤ Critical ⬤

**Severity** **Code** **Description**

⬤ US Untrusted Source

⬤ STC Succeeded Transfer Check

⬤ BLC Business Logic Concern

⬤ CR Code Repetition

⬤ L04 Conformance to Solidity Naming
Conventions

⬤ L07 Missing Events Arithmetic

⬤ L09 Dead Code Elimination

⬤ L13 Divide before Multiply Operation

