#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L503,504,521,543,884,943,949,703,706,709,710,720,721,723

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L503,504,521,543,884,943,949,703,706,709,710,720,721,723|

```
_isBlacklisted
_fundWallet
_lpWallet
_previousFundFee
_fundFee
_liquidityFee
_taxFee
_amount
_enabled

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

