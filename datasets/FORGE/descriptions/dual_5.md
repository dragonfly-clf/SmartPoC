#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L361,525,526,543,644,648,652,656,593,595,744,772,920,923,929,9
33,937,948,714,1026,1175,1207,1220,1224,1228,1232,1236,1241,1245,1450,10
04,1005,1006,1007,1008,1010,1011,1012,1015,1031

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L361,525,526,543,644,648,652,656,593,595,744,772,920,923,929,9 33,937,948,714,1026,1175,1207,1220,1224,1228,1232,1236,1241,1245,1450,10 04,1005,1006,1007,1008,1010,1011,1012,1015,1031|

```
TwentyFourhours
ZeroWallet
_externalwallet
_gasFeeCollector
_marketingWalletAddress
AmountExternalFee
AmountGasFee
AmountMarketingFee
AmountTokenRewardsFee

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

