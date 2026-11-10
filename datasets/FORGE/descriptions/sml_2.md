#### ELFM - Exceeds Fees Limit

**Criticality** critical

**Location** contract.sol#L926,930,934

**Status** Unresolved

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the
setTaxFeePercent/setLiquidityFeePercent/setMoonFeeFeePercent function with a
high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L926,930,934|
|Status|Unresolved|

```
function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
  _taxFee = taxFee;
}
...
function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
  _liquidityFee = liquidityFee;
}
...
function setMoonFeePercent(uint256 moonFee) external onlyOwner() {
  _moonFee = moonFee;
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

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|RSML|Redundant SafeMath Library|Unresolved|
|⬤|RV|Randomization Vulnerability|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L05|Unused State Variable|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L11|Unnecessary Boolean equality|Unresolved|
|⬤|L13|Divide before Multiply Operation|Unresolved|
|⬤|L14|Uninitialized Variables in Local Scope|Unresolved|


-----

