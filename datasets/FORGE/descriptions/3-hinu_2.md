#### BC - Blacklists Addresses

|Criticality|Medium|
|---|---|
|Location|contracts/honeyether.sol#L1874|
|Status|Unresolved|


##### Description


The contract owner has the authority to stop addresses from transactions. The
owner may take advantage of it by calling the blacklistAddress function.


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
|⬤|US|Untrusted Source|Unresolved|
|⬤|RS|Redundant Statements|Unresolved|
|⬤|CAA|Contract Address Assumption|Unresolved|
|⬤|PTRP|Potential Transfer Revert Propagation|Unresolved|
|⬤|DDP|Decimal Division Precision|Unresolved|
|⬤|RSML|Redundant SafeMath Library|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L05|Unused State Variable|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L11|Unnecessary Boolean equality|Unresolved|
|⬤|L12|Using Variables before Declaration|Unresolved|


-----

|⬤|L14|Uninitialized Variables in Local Scope|Unresolved|
|---|---|---|---|
|⬤|L15|Local Scope Variable Shadowing|Unresolved|
|⬤|L16|Validate Variable Setters|Unresolved|
|⬤|L19|Stable Compiler Version|Unresolved|
|⬤|L20|Succeeded Transfer Check|Unresolved|


-----

