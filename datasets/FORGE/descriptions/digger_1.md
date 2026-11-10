#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L614

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the set_sell_multiplier function with
a high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L614|

```
uint256 multiplier = 100;
if(isSell){
  multiplier = sellMultiplier;
}
uint256 feeAmount = rAmount.div(feeDenominator *
100).mul(totalFee).mul(multiplier);

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

