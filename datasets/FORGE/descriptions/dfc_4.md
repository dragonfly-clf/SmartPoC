#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L7,184,185,202,867,871,875,879,883,887,893,899

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L7,184,185,202,867,871,875,879,883,887,893,899|

```
_address
_discountedTransferFee
_transferFee
_feeCollector
MINIMUM_LIQUIDITY
PERMIT_TYPEHASH
DOMAIN_SEPARATOR
WETH

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

