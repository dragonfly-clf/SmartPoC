#### BC - Blacklists Addresses

**Criticality** medium

**Location** contract.sol#L1098

**Status** Unresolved

##### Description

The contract owner has the authority to stop addresses from transactions. The
owner may take advantage of it by calling the blacklistAddress function.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1098|
|Status|Unresolved|


**function blacklistAddress(address account, bool value) external onlyOwner{**

**_isBlacklisted[account] = value;**
**}**


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
|⬤|L01|Public Function could be Declared External|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L05|Unused State Variable|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L14|Uninitialized Variables in Local Scope|Unresolved|


-----

