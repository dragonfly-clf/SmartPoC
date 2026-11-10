#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L38,1120,1123,1124,1125,1126,1127,1128,1129,1130

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L38,1120,1123,1124,1125,1126,1127,1128,1129,1130|


routerAddress
marketingAddress
burnBuyFee
burnSellFee
liquidityBuyFee
liquiditySellFee
marketingBuyFee
marketingSellFee
maxSupply
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

