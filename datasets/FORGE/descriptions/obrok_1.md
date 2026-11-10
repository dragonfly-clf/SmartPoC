#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** https://bscscan.com/address/0x205afd08cefe438377a0abc5a20cb4462e1a8c5c
#code#L285

##### Description

The contract owner has the authority to increase fees over a reasonable limit. The
owner may take advantage of it by calling the updateFee function with high
percentage values.

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0x205afd08cefe438377a0abc5a20cb4462e1a8c5c #code#L285|

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
renouncing ownership.


-----

