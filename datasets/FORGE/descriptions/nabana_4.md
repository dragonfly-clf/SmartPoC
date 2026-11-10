#### US - Untrusted Source

|Criticality|Minor / Informative|
|---|---|
|Location|Nabana.sol#L1857|
|Status|Unresolved|


##### Description


The contract uses an external contract in order to determine the transaction's flow.
If the owner’s account is compromised, then the external contract could be set to
an untrusted source. This behavior can be combined with the fact that the contract
wraps the functions of the external contract in a try-catch block, while others do
not. As a result, it may produce inconsistency in the transactions.


##### Recommendation


The pointing addresses of the dividend tracker variable could be immutable, so it
cannot be compromised. If a mutation is required, an extra security measure is to
wrap in a try-catch block all calls to the external contract. Hence, the external call
errors will not propagate to the main contract.


-----

