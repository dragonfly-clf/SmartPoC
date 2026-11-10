#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L503,504,521,543,911,1015,1021,1234,1238,1242,1245,1249,1253,7
12,716,737

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L503,504,521,543,911,1015,1021,1234,1238,1242,1245,1249,1253,7 12,716,737|

```
_maxTxAmount
_liquidityFee
_taxFee
_selltokenswap
_farmsstakingAddress
_teamAddress
_charityAddress
_ecosystemAddress
_marketingAddress

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

