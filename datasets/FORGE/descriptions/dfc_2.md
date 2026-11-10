#### BC - Blacklisted Contracts

**Criticality** medium

**Location** contract.sol#L917

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the setBlacklist function.

|Criticality|medium|
|---|---|
|Location|contract.sol#L917|

```
require(!blacklist[from], "DFC: Account is blacklisted");

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
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|


-----

