#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L251,252,268,287,638,433,441,442,443,445,446,447,449,450,451,45
3,454,455,458,459

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L251,252,268,287,638,433,441,442,443,445,446,447,449,450,451,45 3,454,455,458,459|

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

