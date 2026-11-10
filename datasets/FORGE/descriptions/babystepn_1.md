#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L106,208,161,169,183,346,603,681,690,696,722,735,748,756,765,77
2,348,352,353,354,356,358,359,364,400

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L106,208,161,169,183,346,603,681,690,696,722,735,748,756,765,77 2,348,352,353,354,356,358,359,364,400|

```
maxFee
_markerPairs
_maxWalletAmount
_maxTxAmount
_totalSupply
_decimals
_symbol
_name
WBNB

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

