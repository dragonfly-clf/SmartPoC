#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L147,716,721,726,731,736,741,746,383,384,390,392,393,394,395,3
96,397,398,399,400,404,405,406,407,408,409,837,838,839

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L147,716,721,726,731,736,741,746,383,384,390,392,393,394,395,3 96,397,398,399,400,404,405,406,407,408,409,837,838,839|

```
_to
_amount
_token
DeadAddress
Community
Fund
LPPower
LPHolder
Liquidity

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)