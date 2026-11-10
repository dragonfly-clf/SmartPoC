#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L138,241,194,202,203,623,671,680,685,690 and 25 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L138,241,194,202,203,623,671,680,685,690 and 25 more|

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

