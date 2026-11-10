#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L52,317,323,330,318,416,150,163,164,165 and 2 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L52,317,323,330,318,416,150,163,164,165 and 2 more|

```
_decimals
_symbol
_name
_tTotal
_swapEnabled
_amount
_to
_tokenAddr
marketingAddressUpdated

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)