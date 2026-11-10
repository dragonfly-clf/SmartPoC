#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L264,265,281,302,991,997,1066,1070,1074,1078,1082,1087,1091,1
125,1129,1133,1138,1143,1166,1185,1191,1196,1202,1208,476,479,482,483,485
,486,488,489,491,494,498,503,504,505,506,507,516

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L264,265,281,302,991,997,1066,1070,1074,1078,1082,1087,1091,1 125,1129,1133,1138,1143,1166,1185,1191,1196,1202,1208,476,479,482,483,485,486,488,489,491,494,498,503,504,505,506,507,516|

```
_isEnabledBuyBackAndBurn
_buyBackMaxTimeForHistories
_buyBackTimeInterval
_buyBackDivisor
_isAutoBuyBack
_sellHistories
_maxTxAmount
_addressFees
_buyBackRangeRate

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

