#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L88,195,338,395,396,397,398,399,400,407 and 13 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L88,195,338,395,396,397,398,399,400,407 and 13 more|

```
_symbol
_name
genesis_block
_decimals
_amount
_to
_tokenAddr
_enabled
_burn

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

