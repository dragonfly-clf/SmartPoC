#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1076

##### Description

The contract owner has the authority to increase total fees over the allowed limit of
25%. The owner may take advantage of it by calling the setSellFee function with a
high percentage value. This will have as a result the contract to behave like a
honeypot.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1076|

```
  function setBuyFee(uint256 buyTaxFee, uint256 buyLiquidityFee) external
onlyOwner {
    _buyTaxFee = buyTaxFee;
    _buyLiquidityFee = buyLiquidityFee;
  }
  function setSellFee(uint256 sellTaxFee, uint256 sellLiquidityFee) external
onlyOwner {
    _sellTaxFee = sellTaxFee;
    _sellLiquidityFee = sellLiquidityFee;
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

