#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L747,750,753,756,759,762,903,960,992,1029,1293,1345,1171,118
4

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L747,750,753,756,759,762,903,960,992,1029,1293,1345,1171,118 4|

```
_isExcludedMaxTransactionAmount
deadAddress
_burnFrom
_fee
WETH
_vault
_owner
DOMAIN_SEPARATOR
_decimals

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

