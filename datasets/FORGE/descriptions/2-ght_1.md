#### MT - Mints Tokens

|Criticality|Critical|
|---|---|
|Location|GoldHunt.sol#L552|
|Status|Unresolved|


##### Description


The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the rebase function. As a result, the contract tokens will
be highly inflated.


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
|⬤|MVN|Μisleading Variables Naming|Unresolved|
|⬤|PVC|Price Volatility Concern|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L16|Validate Variable Setters|Unresolved|
|⬤|L18|Multiple Pragma Directives|Unresolved|
|⬤|L19|Stable Compiler Version|Unresolved|


-----

