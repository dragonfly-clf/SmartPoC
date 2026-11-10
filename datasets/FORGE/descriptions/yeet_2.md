#### BC - Blacklisted Contracts

**Criticality** critical

**Location** contract.sol#L1

##### Description

The contract owner has the authority to massively stop contacts from transactions.
The owner may take advantage of it by calling the bulkAntiBot function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1|

```
require(!_isBot[from] && !_isBot[to], "You are a bot");

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
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L07|Missing Events Arithmetic|
|⬤|L13|Divide before Multiply Operation|


-----

