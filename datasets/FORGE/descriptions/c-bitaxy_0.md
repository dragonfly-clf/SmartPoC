##### ELFM - Exceeds Fees Limit

|Criticality|Critical|
|---|---|
|Location|CryptoBitaxy.sol#L901,905,909,913|
|Status|Unresolved|


###### Description


The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the following functions with a high
percentage value:

 - `setTaxFeePercent`

 - `setLiquidityFeePercent`

 - `setChartityFeePercent`

 - `setBurnFeePercent`


-----

###### Recommendation


The contract could embody a check for the maximum acceptable value. The team
should carefully manage the private keys of the owner’s account. We strongly
recommend a powerful security mechanism that will prevent a single user from
accessing the contract admin functions. That risk can be prevented by temporarily
locking the contract or renouncing ownership.


-----

#### Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|CO|Code Optimization|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L16|Validate Variable Setters|Unresolved|
|⬤|L17|Usage of Solidity Assembly|Unresolved|


-----

