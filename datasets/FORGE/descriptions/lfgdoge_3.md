#### BC - Blacklisted Contracts

**Criticality** medium

**Location** contract.sol#L1

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the isbotBlackList function.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1|

```
require(!isbotBlackList[sender], "account is bot");

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Corrected 10 April 2022

The team has renounced ownership and the threats have been eliminated.


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


-----

