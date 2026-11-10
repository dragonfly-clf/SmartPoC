#### BC - Blacklists Addresses

**Criticality** critical

**Location** contract.sol#L2034

**Status** Unresolved

##### Description

The contract owner has the authority to stop addresses from transactions. The
owner may take advantage of it by calling the multipleBotlistAddress function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L2034|
|Status|Unresolved|

```
require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');

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
|⬤|PVC|Price Volatility Concern|Unresolved|
|⬤|RSML|Redundant SafeMath Library|Unresolved|
|⬤|US|Untrusted Source|Unresolved|
|⬤|MDA|Misleading Dead Address|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L05|Unused State Variable|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L12|Using Variables before Declaration|Unresolved|
|⬤|L14|Uninitialized Variables in Local Scope|Unresolved|
|⬤|L15|Local Scope Variable Shadowing|Unresolved|


-----

