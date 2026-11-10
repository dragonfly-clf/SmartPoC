#### ELFM - Exceeds Fees Limit

|Criticality|Critical|
|---|---|
|Location|ZeusPet.sol#L231|
|Status|Multisign|


##### Description


The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setFeePercent function with a high
percentage value.


##### Recommendation


The contract could embody a check for the maximum acceptable value. The team
should carefully manage the private keys of the owner’s account. We strongly
recommend a powerful security mechanism that will prevent a single user from
accessing the contract admin functions. Some suggestions are:

 - Introduce a time-locker mechanism with a reasonable delay.

 - Introduce a multi-sign wallet so that many addresses will confirm the action.

 - Introduce a governance model where users will vote about the actions.

 - Renouncing the ownership will eliminate the threads but it is non-reversible.


##### Team Update


The team has implemented our recommendation by adopting a multi-signature
wallet at the following transaction
[https://bscscan.com/tx/0xdee6c8c9d2325b6127a516f1c2aeb281a4434424888b34](https://bscscan.com/tx/0xdee6c8c9d2325b6127a516f1c2aeb281a4434424888b347a3616a5860f513dd4)
[7a3616a5860f513dd4](https://bscscan.com/tx/0xdee6c8c9d2325b6127a516f1c2aeb281a4434424888b347a3616a5860f513dd4)


-----

### Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|IDI|Immutable Declaration Improvement|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L16|Validate Variable Setters|Unresolved|
|⬤|L18|Multiple Pragma Directives|Unresolved|
|⬤|L19|Stable Compiler Version|Unresolved|


-----

