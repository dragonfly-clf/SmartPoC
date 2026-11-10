#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L626,634,643,648,788,1037,1041,1060,1066,565,566,567,570,571,
574,575,577,578,579,580,582,583,584,585,589,864

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L626,634,643,648,788,1037,1041,1060,1066,565,566,567,570,571, 574,575,577,578,579,580,582,583,584,585,589,864|


_delegates
BurnAddress
_liquidityFeeTotal
_taxFeeTotal
_BurnFeeTotal
_marketingFeeTotal
_liquidityFee
_BurnFee
_marketingFee
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

