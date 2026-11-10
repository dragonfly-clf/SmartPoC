#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L77,148,304,546,550,583,112,122,126,129 and 7 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L77,148,304,546,550,583,112,122,126,129 and 7 more|

```
_symbol
_name
deadAddress
_lastTrade
_decimals
_amount
_to
_tokenAddr
_timeInSeconds

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

