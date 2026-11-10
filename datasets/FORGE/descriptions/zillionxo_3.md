#### BC - Blacklists Addresses

**Criticality** critical

**Location** contract.sol#L760,764

**Status** Unresolved

##### Description

The contract owner has the authority to stop addresses from transactions. The
owner may take advantage of it by calling the blacklistAddress function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L760,764|
|Status|Unresolved|


function updateIsBlacklisted(address account, bool state) external onlyOwner {

**_isBlacklisted[account] = state;**
}

function bulkIsBlacklisted(address[] memory accounts, bool state) external onlyOwner {

for (uint256 i = 0; i < accounts.length; i++) {

**_isBlacklisted[accounts[i]] = state;**
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
|⬤|ZD|Zero Division|Unresolved|
|⬤|STC|Succeeded Transfer Check|Unresolved|
|⬤|SPC|Solidity Precision Concern|Unresolved|
|⬤|CO|Code Optimization|Unresolved|
|⬤|MC|Missing Check|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L03|Redundant Statements|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L11|Unnecessary Boolean equality|Unresolved|
|⬤|L13|Divide before Multiply Operation|Unresolved|


-----

