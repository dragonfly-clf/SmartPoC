#### BC - Blacklists Addresses

**Criticality** medium

**Location** contract.sol#L1081

**Status** Unresolved

##### Description

The contract owner has the authority to stop addresses from transactions. The
owner may take advantage of it by calling the ManageBot function.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1081|
|Status|Unresolved|

```
function ManageBot (address account, bool isBlacklisted) private onlyOwner {
  _blacklist[account] = isBlacklisted;
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|PTRP|Potential Transfer Revert Propagation|Unresolved|
|⬤|RSML|Redundant SafeMath Library|Unresolved|
|⬤|BLC|Business Logic Concern|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L05|Unused State Variable|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L13|Divide before Multiply Operation|Unresolved|
|⬤|L15|Local Scope Variable Shadowing|Unresolved|


-----

