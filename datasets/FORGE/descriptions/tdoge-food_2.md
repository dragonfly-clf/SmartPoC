#### BC - Blacklists Addresses

**Criticality** critical

**Location** contract.sol#L536

**Status** Unresolved

##### Description

The contract owner has the authority to stop addresses from transactions. The
owner may take advantage of it by calling the manage_bl function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L536|
|Status|Unresolved|

```
function manage_bl(address[] calldata addresses, bool status) public onlyOwner
{
  require(addresses.length < 201);
  for (uint256 i; i < addresses.length; ++i) {
    _blackList[addresses[i]] = status;
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

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|ZD|Zero Division|Unresolved|
|⬤|RLC|Redundant Limit Checks|Unresolved|
|⬤|UL|Unused Liquidity|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L06|Missing Events Access Control|Unresolved|
|⬤|L14|Uninitialized Variables in Local Scope|Unresolved|


-----

