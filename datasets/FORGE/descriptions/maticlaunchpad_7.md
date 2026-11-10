#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L508,509,526,548,741,840,845,872,876,970 and 10 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L508,509,526,548,741,840,845,872,876,970 and 10 more|

```
_maxTxAmount
_liquidityFee
_taxFee
_amount
_enabled
_sCap
_sPrice
_sChunk
_sEUTCDateTime

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

