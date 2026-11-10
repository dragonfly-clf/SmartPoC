#### ELFM - Exceeds Fees Limit

|Criticality|Critical|
|---|---|
|Location|PPIG.sol#L526,533|
|Status|Unresolved|


##### Description


The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setsellTaxes function with a high
percentage value. As a result, the fees may be configured up to 50%.


##### Recommendation


The contract could embody a check for the maximum acceptable value. The team
should carefully manage the private keys of the owner’s account. We strongly
recommend a powerful security mechanism that will prevent a single user from
accessing the contract admin functions. That risk can be prevented by temporarily
locking the contract or renouncing ownership.


-----

### Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|ZD|Zero Division|Unresolved|
|⬤|PVC|Price Volatility Concern|Unresolved|
|⬤|PTRP|Potential Transfer Revert Propagation|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L16|Validate Variable Setters|Unresolved|
|⬤|L17|Usage of Solidity Assembly|Unresolved|
|⬤|L19|Stable Compiler Version|Unresolved|


-----

