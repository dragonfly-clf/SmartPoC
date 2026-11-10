#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L191,294,247,255,256,694,743,753,758,763,768,414,415,416,417,41
8,420,421,422,424,425,427,428

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L191,294,247,255,256,694,743,753,758,763,768,414,415,416,417,41 8,420,421,422,424,425,427,428|

```
_allowances
_balances
_maxTxAmount
_totalSupply
_decimals
_symbol
_name
DEAD_NON_CHECKSUM
ZERO

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

