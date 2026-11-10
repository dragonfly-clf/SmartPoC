#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L646

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the updateFee function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L646|

```
function updateFee(uint256 _txFee,uint256 _burnFee,uint256 _charityFee)
onlyOwner() public{
  _TAX_FEE = _txFee* 100;
  _BURN_FEE = _burnFee * 100;
  _CHARITY_FEE = _charityFee* 100;
  ORIG_TAX_FEE = _TAX_FEE;
  ORIG_BURN_FEE = _BURN_FEE;
  ORIG_CHARITY_FEE = _CHARITY_FEE;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L07|Missing Events Arithmetic|


-----

