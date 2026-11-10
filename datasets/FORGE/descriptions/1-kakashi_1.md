#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L685, 691, 696

**Status** Resolved

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxFeePercent, setBurnFee and
setAdvestisementFeePercentage function with a high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L685, 691, 696|
|Status|Resolved|

```
function setTaxFeePercent(uint256 buyTaxFee, uint256 sellTaxFee) external
onlyOwner() {
    _buyTaxFee = buyTaxFee;
    _sellTaxFee = sellTaxFee;
  }

```
```
function setBurnFee(uint256 buyBurnFee, uint256 sellBurnFee) external
onlyOwner() {
    _buyBurnFee = buyBurnFee;
    _sellBurnFee = sellBurnFee;
  }

```
```
function setAdvestisementFeePercent(uint256 buyAdvestisementFee, uint256
sellAdvestisementFee) external onlyOwner() {
    _sellAdvestisementFee = sellAdvestisementFee;
    _buyAdvestisementFee = buyAdvestisementFee;
  }

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Updated 06 June 2022
The team has renounced ownership and resolved the issues.


-----

#### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|


-----

