#### BC - Blacklists Addresses

|Criticality|Medium|
|---|---|
|Location|BEP20LUNAINU.sol#L431|
|Status|Unresolved|


##### Description


The contract owner has the authority to stop addresses from transactions. The
owner may take advantage of it by calling the blacklist_wallet function.


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
|⬤|DDP|Decimal Division Precision|Unresolved|
|⬤|PTRP|Potential Transfer Revert Propagation|Unresolved|
|⬤|PVC|Price Volatility Concern|Unresolved|
|⬤|RSML|Redundant SafeMath Library|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|


-----

