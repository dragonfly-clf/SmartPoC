#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L221,222,238,257,609,403,411,412,413,415 and 10 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L221,222,238,257,609,403,411,412,413,415 and 10 more|

```
_walletMax
_maxTxAmount
_totalDistributionShares
_totalTaxIfSelling
_totalTaxIfBuying
_teamShare
_marketingShare
_liquidityShare
_sellTeamFee

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

