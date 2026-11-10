#### BC - Blacklisted Contracts

**Criticality** critical

**Location** contract.sol#L543

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the blacklistAddress function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L543|

```
function addToBlackList(address[] calldata addresses) external onlyOwner {
  for (uint256 i; i < addresses.length; ++i) {
    _isBlacklisted[addresses[i]] = true;
    emit IsBlackListed(addresses[i], true);
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

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|TSD|Total Supply Diversion|Unresolved|
|⬤|STC|Succeeded Transfer Check|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L05|Unused State Variable|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L14|Uninitialized Variables in Local Scope|Unresolved|


-----

