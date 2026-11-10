#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1045, 1049, 1054, 1060

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setReflectionFee, setLiquidityFee,
setMarketingFee, and setBurnPercent functions with a high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1045, 1049, 1054, 1060|

```
function setReflectionFee(uint256 fee) public onlyOwner {
  _taxFee = fee;
}

```
```
function setLiquidityFee(uint256 fee) public onlyOwner {
  _liquidityFee = fee;
}

```
```
function setMarketingFee(uint256 fee) public onlyOwner {
  _marketingFee = fee;
}

```
```
function setBurnPercent(uint256 fee) public onlyOwner {
  _BurnFee = fee;
}

```

-----

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
|⬤|BLC|Business Logic Concern|
|⬤|CO|Code Optimization|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|
|⬤|L11|Unnecessary Boolean equality|
|⬤|L13|Divide before Multiply Operation|


-----

