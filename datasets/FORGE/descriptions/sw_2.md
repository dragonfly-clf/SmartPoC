#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor / informative

**Location** contract.sol#L783,787,750,771,744,779,502,775,507,500

**Status** Unresolved

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L783,787,750,771,744,779,502,775,507,500|
|Status|Unresolved|


-----

- Allow constant variable name/symbol/decimals to be lowercase.

- Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.


_setTaxFee
_setBurnFee
_amount
_getTaxFee
_getMaxTxAmount
_burnFee
_getBurnFee
_max_tx_size
_taxFee
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)

