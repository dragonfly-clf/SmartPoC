#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor / informative

**Location** contract.sol#L440,439,626,414,702,416,649,487,435,502,685,415,654,659,406,4
17,690,679,319,712,420,441,436,695

**Status** Unresolved

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L440,439,626,414,702,416,649,487,435,502,685,415,654,659,406,4 17,690,679,319,712,420,441,436,695|
|Status|Unresolved|

```
_yearCanMintAmount
_yearMintedAmount
_setMaxTxAmount
_decimals
_token
_symbol
_enabledBurnFee
_account
_maxTxAmount

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.8.17/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.8.17/style-guide.html#naming-convention)


-----

