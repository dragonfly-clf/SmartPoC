#### L05 - Unused State Variable

**Criticality** minor

**Location** contract.sol#L835,836,837,838,840,841,842,843,845,846,847,848

##### Description

There are segments that contain unused state variables.

|Criticality|minor|
|---|---|
|Location|contract.sol#L835,836,837,838,840,841,842,843,845,846,847,848|

```
charityTaxWallet
liquidityTaxWallet
marketingTaxWallet
devTaxWallet
charityTaxSell
liquidityTaxSell
marketingTaxSell
devTaxSell
charityTaxBuy

```
...


##### Recommendation

Remove unused state variables.


-----

