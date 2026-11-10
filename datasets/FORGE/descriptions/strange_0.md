#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L632,676

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setFees or setDeadBlocks function
with a high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L632,676|

```
function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256
_reflectionFee, uint256 _marketingFee, uint256 _feeDenominator) external
authorized {
  liquidityFee = _liquidityFee;
  buybackFee = _buybackFee;
  reflectionFee = _reflectionFee;
  marketingFee = _marketingFee;
  totalFee =
_liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingFee);
  feeDenominator = _feeDenominator;
}
//
function setDeadBlocks(uint256 _deadBlocks) external authorized {
  deadBlocks = _deadBlocks;
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
|⬤|L05|Unused State Variable|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|


-----

