#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L79,81,112,1027,1339,1346,1358,1372,1242,1606,1777,1778,1477,1
478,2324

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L79,81,112,1027,1339,1346,1358,1372,1242,1606,1777,1778,1477,1 478,2324|

```
_account
MCGRewardsSellFee
MCGRewardsBuyFee
MCGRewardsSell
MCGRewardsBuy
_contractAddress
UpdatestakeAddress
magnitude
_owner

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

