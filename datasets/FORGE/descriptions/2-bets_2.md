#### BC - Blacklisted Contracts

**Criticality** critical

**Location** contract.sol#L1273

##### Description

The contract owner has the authority to stop contracts from selling. The owner may
take advantage of it by calling the blacklistAddress function while the burn fee is
very high value. This will result in burning the tokens instead of selling them.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1273|

```
  function blackListAddresses(address[] memory addrs) external onlyOwner
returns (bool) {
    require(block.timestamp <= tradingActiveBlock + 28800, "Option
expired!");
    for(uint256 i = 0; i < addrs.length; i++) {
       _blackListAddr[addrs[i]] = true;
    }
    return true;
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
|⬤|CO|Code Optimization|
|⬤|L01|Public Function could be Declared External|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L05|Unused State Variable|
|⬤|L06|Missing Events Access Control|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|
|⬤|L15|Local Scope Variable Shadowing|


-----

