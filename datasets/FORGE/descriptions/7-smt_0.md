#### US - Untrusted Source

**Criticality** critical

**Location** contract.sol#L1293

**Status** Unresolved

##### Description

The contract uses an external contract in order to determine the transaction's flow.
The external contract is untrusted. As a result it may produce security issues and
harm the transactions.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1293|
|Status|Unresolved|


dividendTracker.distributeDividends(balanceRewardToken);


##### Recommendation

The contract should use a trusted external source. A trusted source could be either
a commonly recognized or an audited contract. The pointing addresses should not
be able to change after the initialization. Otherwise, the contract could wrap the
above code line in a try-catch block, in order to handle any case in which it may fail.


-----

