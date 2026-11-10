#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L586,1136,1135,612,1110,653,1164,650,154,1173,624,1168,1137,3
55,191,1023,649,1032,393,153,171,652,347,611,654,1095,651

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L586,1136,1135,612,1110,653,1164,650,154,1173,624,1168,1137,3 55,191,1023,649,1032,393,153,171,652,347,611,654,1095,651|

```
_initRebaseStartTime
_addr
_flag
_totalSupply
DEAD
_token
_lastRebasedTime
MINIMUM_LIQUIDITY
_minPeriod

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

