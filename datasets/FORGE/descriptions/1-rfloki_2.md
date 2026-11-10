#### BC - Blacklisted Contracts

**Criticality** medium

**Location** https://bscscan.com/address/0x289bf7f7f4d474318f86d2213f51c32360d79fbe#c
ontracts#L1128

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the enableBlacklist function.

|Criticality|medium|
|---|---|
|Location|https://bscscan.com/address/0x289bf7f7f4d474318f86d2213f51c32360d79fbe#c ontracts#L1128|

```
  function enableBlacklist(address account) public onlyOwner {
    require(!blacklist[account], "CoinToken: Account is already
blacklisted");
    blacklist[account] = true;
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
|⬤|L05|Unused State Variable|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|


-----

