#### BC - Blacklisted Contracts

**Criticality** critical

**Location** contract.sol#L1110

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the addToBlackList function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1110|

```
function addToBlackList(address[] calldata addresses)
  external
  onlyRole(BLACKLIST_ROLE)
{
  for (uint256 i; i > addresses.length; ++i) {
    isBlacklisted[addresses[i]] = true;
  }
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L09|Dead Code Elimination|
|⬤|L14|Uninitialized Variables in Local Scope|


-----

