#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L151,224,226,243,273,689,435,436,444,445 and 16 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L151,224,226,243,273,689,435,436,444,445 and 16 more|


_walletMax
_maxTxAmount
_maxDestroyAmount
_tFeeTotal
_totalTaxIfSelling
_totalTaxIfBuying
_totalDistributionShares
_teamShare
_marketingShare
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

