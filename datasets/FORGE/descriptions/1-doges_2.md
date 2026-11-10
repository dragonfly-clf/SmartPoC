#### BC - Blacklisted Contracts

**Criticality** critical

**Location** contract.sol#L634

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the blacklist_Add_Wallets function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L634|

```
function blacklist_Add_Wallets(address[] calldata addresses) external onlyOwner
{
  uint256 startGas;
  uint256 gasUsed;
for (uint256 i; i < addresses.length; ++i) {
  if(gasUsed < gasleft()) {
  startGas = gasleft();
  if(!_isBlacklisted[addresses[i]]){
  _isBlacklisted[addresses[i]] = true;}
  gasUsed = startGas - gasleft();
}
}
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Corrected on 7th March 2022

The team has renounced ownership and the threat is no longer applicable.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L05|Unused State Variable|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L07|Missing Events Arithmetic|
|⬤|L14|Uninitialized Variables in Local Scope|


-----

