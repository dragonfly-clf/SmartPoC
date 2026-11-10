#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L608,610,623,977,609,1092,583,1071,566,628,1088,607,160,1069,
564,550,565,546,237,606,611,1070,1049,158,191,986,1096,579,547,545

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L608,610,623,977,609,1092,583,1071,566,628,1088,607,160,1069, 564,550,565,546,237,606,611,1070,1049,158,191,986,1096,579,547,545|


_name
_decimals
feeDenominator
_address
_flag
MINIMUM_LIQUIDITY
DOMAIN_SEPARATOR
_addr
_treasuryReceiver
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

