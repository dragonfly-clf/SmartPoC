#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L39,66,111,118,120,121,122,123,126,127,128,129,130

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L39,66,111,118,120,121,122,123,126,127,128,129,130|

```
_swapPairList
_mainPair
_swapRouter
BUSD
BUSDaddress
_sellMarketingFee
_sellLPFee
_buyMarketingFee
_buyLPFee

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

