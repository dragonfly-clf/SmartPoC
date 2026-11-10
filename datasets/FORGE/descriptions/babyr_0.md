#### ELFM - Exceeds Fees Limit

|Criticality|Minor / Informative|
|---|---|
|Location|fal tten/BabyShibarium.sol#L1757|
|Status|Unresolved|


##### Description


The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setFee function with a high
percentage value.


##### Recommendation


The contract could embody a check for the maximum acceptable value. The team
should carefully manage the private keys of the owner’s account. We strongly
recommend a powerful security mechanism that will prevent a single user from
accessing the contract admin functions. Some suggestions are:

 - Introduce a time-locker mechanism with a reasonable delay.

 - Introduce a multi-sign wallet so that many addresses will confirm the action.

 - Introduce a governance model where users will vote about the actions.

 - Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

### Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|PVC|Price Volatility Concern|Unresolved|
|⬤|PTRP|Potential Transfer Revert Propagation|Unresolved|
|⬤|RSML|Redundant SafeMath Library|Unresolved|
|⬤|RSK|Redundant Storage Keyword|Unresolved|
|⬤|IDI|Immutable Declaration Improvement|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L05|Unused State Variable|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L11|Unnecessary Boolean equality|Unresolved|
|⬤|L12|Using Variables before Declaration|Unresolved|
|⬤|L13|Divide before Multiply Operation|Unresolved|


-----

|⬤|L14|Uninitialized Variables in Local Scope|Unresolved|
|---|---|---|---|
|⬤|L15|Local Scope Variable Shadowing|Unresolved|
|⬤|L16|Validate Variable Setters|Unresolved|
|⬤|L19|Stable Compiler Version|Unresolved|


-----

