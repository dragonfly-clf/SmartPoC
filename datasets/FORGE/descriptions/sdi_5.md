#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L142,245,198,206,207,628,638,680,689,694,699,709,364,365,366,36
7,369,370,371,373,374,377,378

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L142,245,198,206,207,628,638,680,689,694,699,709,364,365,366,36 7,369,370,371,373,374,377,378|

```
_allowances
_balances
_maxTxAmount
_totalSupply
_decimals
_symbol
_name
ZERO
DEAD

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

