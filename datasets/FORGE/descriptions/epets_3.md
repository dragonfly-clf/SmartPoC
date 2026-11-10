#### BC - Blacklisted Contracts

**Criticality** critical

**Location** contract.sol#L425

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the blacklistAddress function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L425|

```
  function manage_blacklist(address[] calldata addresses, bool status) public
onlyOwner {
    require(addresses.length < 201,"GAS Error: max limit is 200
addresses");
    if(status){
       require(launchMode,"Cannot manually blacklist after launch");
    }
    for (uint256 i; i < addresses.length; ++i) {
       isBlacklisted[addresses[i]] = status;
    }
  }

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract, renouncing ownership or calling ​the
tradingStatus_launchmode function.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L07|Missing Events Arithmetic|
|⬤|L13|Divide before Multiply Operation|
|⬤|L14|Uninitialized Variables in Local Scope|


-----

