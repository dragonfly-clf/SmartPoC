#### US - Untrusted Source

**Criticality** minor / informative

**Location** contract.sol#L2385

**Status** Unresolved

##### Description

The contract uses an external contract in order to determine the transaction's flow.
The external contract is untrusted. As a result it may produce security issues and
harm the transactions.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L2385|
|Status|Unresolved|

```
dividendTracker.distributeCAKEDividends(dividends);

```

##### Recommendation

The contract should use a trusted external source. A trusted source could be either
a commonly recognized or an audited contract. The contract could wrap this line of
code in try-catch block to avoid security issues.


-----

