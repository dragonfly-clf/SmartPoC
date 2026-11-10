#### US - Untrusted Source

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|US|Untrusted Source|Unresolved|
|⬤|STC|Succeeded Transfer Check|Unresolved|
|⬤|BLC|Business Logic Concern|Unresolved|
|⬤|CR|Code Repetition|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L13|Divide before Multiply Operation|Unresolved|


-----

|Criticality|critical|
|---|---|
|Location|contract.sol#L852|
|Status|Unresolved|


##### Description

The contract uses an external contract in order to determine the transaction's flow.
The external contract is untrusted. As a result, it may produce security issues and
harm the transactions.


**IPinkAntiBot public pinkAntiBot;**


##### Recommendation

The contract should use a trusted external source. A trusted source could be either
a commonly recognized or an audited contract. The pointing addresses should not
be able to change after the initialization. In addition, it is recommended to enclose
every statement that uses external sources in try-catch statement. In order to avoid
anomalies in the transaction flow.


-----

