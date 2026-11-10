#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1355

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the TeamSetTaxes function with a high
percentage value to buyTax, sellTax or transferTax.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1355|

```
function TeamSetTaxes(uint8 burnTaxes, uint8 liquidityTaxes, uint8
stakingTaxes,uint8 buyTax, uint8 sellTax, uint8 transferTax) public onlyOwner{
  uint8 totalTax=burnTaxes+liquidityTaxes+stakingTaxes;
  require(totalTax==100, "burn+liq+marketing needs to equal 100%");
  _burnTax=burnTaxes;
  _liquidityTax=liquidityTaxes;
  _stakingTax=stakingTaxes;
  _buyTax=buyTax;
  _sellTax=sellTax;
  _transferTax=transferTax;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

