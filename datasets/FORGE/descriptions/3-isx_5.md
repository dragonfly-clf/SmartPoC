#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L1062,1068,1126,1065,1064,1063,1060,1067,1066

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1062,1068,1126,1065,1064,1063,1060,1067,1066|


maxBuybackFee
minMxTxPercentage
dead
maxTaxFee
maxBurnFee
maxWalletFee
mintedByMoonDeploy
minMxWalletPercentage
maxLiqFee


##### Recommendation

Add the constant attribute to state variables that never change.


-----

