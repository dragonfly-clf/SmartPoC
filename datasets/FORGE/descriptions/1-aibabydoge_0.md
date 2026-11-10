#### ULTW - Transfers Liquidity to Team Wallet

|Criticality|Minor / Informative|
|---|---|
|Location|AIBBDOGE.sol#L738,944|
|Status|Unresolved|


##### Description


The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees collected from the contract.
The owner may take advantage of it by calling the claimStuckBNB and
```
forceSwap methods.

```

##### Recommendation


The contract could embody a check for the maximum amount of funds that can be
swapped. Since a huge amount may volatile the token's price. The team should
carefully manage the private keys of the owner’s account. We strongly recommend
a powerful security mechanism that will prevent a single user from accessing the
contract admin functions. That risk can be prevented by temporarily locking the
contract or renouncing ownership.


-----

### Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|PVC|Price Volatility Concern|Unresolved|
|⬤|PTRP|Potential Transfer Revert Propagation|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L16|Validate Variable Setters|Unresolved|
|⬤|L19|Stable Compiler Version|Unresolved|
|⬤|L20|Succeeded Transfer Check|Unresolved|


-----

