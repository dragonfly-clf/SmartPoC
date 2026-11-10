#### ST - Stops Transactions

|Criticality|Medium|
|---|---|
|Location|CamKingToken.sol#L626|
|Status|Unresolved|


##### Description


The contract owner has the authority to stop the transactions for all users excluding
the owner. The owner may take advantage of it by setting the _maxTxAmount to
zero.


##### Recommendation


The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply. The
team should carefully manage the private keys of the owner’s account. We strongly
recommend a powerful security mechanism that will prevent a single user from
accessing the contract admin functions. That risk can be prevented by temporarily
locking the contract or renouncing ownership.


-----

### Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|PTRP|Potential Transfer Revert Propagation|Unresolved|
|⬤|DDP|Decimal Division Precision|Unresolved|
|⬤|ZD|Zero Division|Unresolved|
|⬤|PVC|Price Volatility Concern|Unresolved|
|⬤|RSML|Redundant SafeMath Library|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L16|Validate Variable Setters|Unresolved|
|⬤|L17|Usage of Solidity Assembly|Unresolved|
|⬤|L19|Stable Compiler Version|Unresolved|


-----

