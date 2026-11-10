#### BC - Blacklists Addresses

|Criticality|Medium|
|---|---|
|Location|CHITAVERSE.sol#L285|
|Status|Unresolved|


##### Description


The contract owner has the authority to stop addresses from transactions. The
owner may take advantage of it by calling the isBots function.


##### Recommendation


The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|ZD|Zero Division|Unresolved|
|⬤|PVC|Price Volatility Concern|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L13|Divide before Multiply Operation|Unresolved|
|⬤|L16|Validate Variable Setters|Unresolved|
|⬤|L19|Stable Compiler Version|Unresolved|


-----

