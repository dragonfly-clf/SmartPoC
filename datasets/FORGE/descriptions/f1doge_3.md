#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L147,220,222,239,269,677,432,440,441,442,443,445,446,447,448,45
0,451,452,453,455,456,458,459,461,462

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L147,220,222,239,269,677,432,440,441,442,443,445,446,447,448,45 0,451,452,453,455,456,458,459,461,462|

```
_walletMax
_maxTxAmount
_maxDestroyAmount
_tFeeTotal
_totalTaxIfSelling
_totalTaxIfBuying
_totalDistributionShares
_teamShare
_marketingShare

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

