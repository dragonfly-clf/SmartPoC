#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L1144,1143,1149,1142,1140,1136,1150,1141,1139

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1144,1143,1149,1142,1140,1136,1150,1141,1139|


rewardSellFee
rewardBuyFee
rewardAddress
maxSupply
marketingSellFee
marketingBuyFee
marketingAddress
liquidityFee
burnFee


##### Recommendation

Add the constant attribute to state variables that never change.


-----

