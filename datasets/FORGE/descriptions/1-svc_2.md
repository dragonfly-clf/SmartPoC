#### BC - Blacklisted Contracts

**Criticality** medium

**Location** contract.sol#L1002

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the enableBlacklist function.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1002|

```
require(!isBlacklisted(msg.sender), "CoinToken: sender blacklisted");
require(!isBlacklisted(recipient), "CoinToken: recipient blacklisted");
require(!isBlacklisted(tx.origin), "CoinToken: sender blacklisted");

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
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L05|Unused State Variable|
|⬤|L13|Divide before Multiply Operation|
|⬤|L14|Uninitialized Variables in Local Scope|


-----

