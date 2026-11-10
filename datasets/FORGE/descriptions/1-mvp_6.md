#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L208,209,225,244,609,390,398,399,400,402,403,404,406,407,408,4
10,411,412,415,416

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L208,209,225,244,609,390,398,399,400,402,403,404,406,407,408,4 10,411,412,415,416|

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

