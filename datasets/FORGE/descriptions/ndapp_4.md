#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L170,375,440,776,797,802,807,812,821,826,832,855,864,869,874,87
9,884,889,893,330,331,342,343,381

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L170,375,440,776,797,802,807,812,821,826,832,855,864,869,874,87 9,884,889,893,330,331,342,343,381|

```
TwentyFourhours
ZERO
DEAD
_markerPairs
_isFeeExempt
_maxTxn
_nextRebase
_value
_enabled

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

