#### BC - Blacklists Addresses

**Criticality** critical

**Location** contract.sol#L672, L676

**Status** Unresolved

##### Description

The contract owner has the authority to stop addresses from transactions. The
owner may take advantage of it by calling the updateIsBlacklisted and
bulkIsBlacklisted functions.

|Criticality|critical|
|---|---|
|Location|contract.sol#L672, L676|
|Status|Unresolved|


**function updateIsBlacklisted(address account, bool state) external onlyOwner {**

_isBlacklisted[account] = state;
}


**function bulkIsBlacklisted(address[] memory accounts, bool state) external onlyOwner {**

for (uint256 i = 0; i < accounts.length; i++) {

_isBlacklisted[account] = state;
}
}


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
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L13|Divide before Multiply Operation|Unresolved|


-----

