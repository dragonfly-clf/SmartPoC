#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L237,281,285,196,189,128,161,241,249,201,207,245,233,118,157

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L237,281,285,196,189,128,161,241,249,201,207,245,233,118,157|

```
_owner
_value
_to
FeeAddress
_spender
_subtractedValue
_addedValue
_FeeAddress
_from

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

