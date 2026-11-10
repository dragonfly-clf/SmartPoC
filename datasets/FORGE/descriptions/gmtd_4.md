#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L138,241,194,202,203,630,640,644,650,692,701,706,711,721,360,36
1,362,363,365,366,367,369,370,373,374

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L138,241,194,202,203,630,640,644,650,692,701,706,711,721,360,36 1,362,363,365,366,367,369,370,373,374|

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
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

