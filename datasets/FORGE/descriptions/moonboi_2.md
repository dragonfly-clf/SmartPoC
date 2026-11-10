#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** medium

**Location** contract.sol#L1438

##### Description

The contract owner has the authority to remove liquidity pool tokens and transfer
them to the dev’s wallet. The owner may take advantage by following these steps:

1. Call TeamRemoveLiquidity(false)

2. Call ​TeamWithdrawALLMarketingBNB()

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1438|


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L07|Missing Events Arithmetic|


-----

