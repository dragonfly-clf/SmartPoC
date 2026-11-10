#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L473,474,476,472,481

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L473,474,476,472,481|


DEAD
marketingWallet
walletToWalletTransferWithoutFee
charityWallet
developerWallet


##### Recommendation

Add the constant attribute to state variables that never change.


-----

