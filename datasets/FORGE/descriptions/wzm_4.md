#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L55,75,133,142,150,161,176,189

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L55,75,133,142,150,161,176,189|

```
_value
_from
_extraData
_spender
_to
tokenRecipient
owned

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

