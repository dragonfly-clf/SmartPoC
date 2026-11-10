#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L128,157,161,189,196,201,207,118,233,237 and 20 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L128,157,161,189,196,201,207,118,233,237 and 20 more|

```
_FeeAddress
_burnFee
_txFee
_value
_subtractedValue
_spender
_addedValue
_to
_from

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

