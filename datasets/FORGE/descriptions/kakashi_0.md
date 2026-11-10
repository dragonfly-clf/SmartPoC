#### ST - Stop Transactions

**Criticality** minor

**Location** contract.sol#L903, 943, 949

##### Description

The contract owner has the authority to stop transactions for all users. The owner
may take advantage of it by setting _taxFee, _liquidityFee or _fundFeeAmount
to a higher value than 100.

|Criticality|minor|
|---|---|
|Location|contract.sol#L903, 943, 949|

```
function _getTValues(uint256 tAmount) private view returns (uint256, uint256,
uint256) {
    uint256 tFee = calculateTaxFee(tAmount);
    uint256 tLiquidity = calculateLiquidityFee(tAmount);
    uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);

```
```
function calculateTaxFee(uint256 _amount) private view returns (uint256) {
    return _amount.mul(_taxFee).div(
       10**2
    );
  }

```
```
function calculateLiquidityFee(uint256 _amount) private view returns (uint256)
{
    return _amount.mul(_liquidityFee + _fundFee).div(
       10**2
    );
  }

```

-----

##### Recommendation

The contract could embody a check for not allowing setting the _taxFee,
```
_liquidityFee and _fundFeeAmount more than a reasonable amount. A

```
suggested implementation could check that the maximum amount should be more
than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

