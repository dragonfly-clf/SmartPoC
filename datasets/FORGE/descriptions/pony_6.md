#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L482,483,500,522,893,997,1003,1216,1220,1224,1227,1231,1235,6
91,695,716

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L482,483,500,522,893,997,1003,1216,1220,1224,1227,1231,1235,6 91,695,716|

```
_maxTxAmount
_liquidityFee
_taxFee
_selltokenswap
_farmsstakingAddress
_teamAddress
_airdropAddress
_foundation
_marketingAddress

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

