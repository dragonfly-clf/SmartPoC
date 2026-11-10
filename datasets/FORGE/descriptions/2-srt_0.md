#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** https://bscscan.com/address/0x8983a6f5b70315f9373d39e14de5afeabf835588#c
ode#L285

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the updateFee function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0x8983a6f5b70315f9373d39e14de5afeabf835588#c ode#L285|

```
function updateFee(uint256 _txFee,uint256 _burnFee,address _FeeAddress)
onlyOwner public{
  txFee = _txFee;
  burnFee = _burnFee;
  FeeAddress = _FeeAddress;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

