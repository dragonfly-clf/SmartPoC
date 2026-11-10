#### MT - Mints Tokens

|Criticality|Critical|
|---|---|
|Location|BRICS.sol#L501|
|Status|Renounced|


##### Description


The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the mint function. As a result, the contract tokens will be
highly inflated.


##### Recommendation


The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


##### Team Update 4 March


The team has renounced the ownership, hence the mint can not be executed from
now on.


-----

### Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|


-----

