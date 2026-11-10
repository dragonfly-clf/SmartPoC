#### MC - Missing Check

**Criticality** medium

**Location** contract.sol#L1027, 1050

##### Description

The contract is processing variables that have not properly sanitized and checked
that they form the proper shape. These variables may produce vulnerability issues.
The contract owner has the authority to set the _liquidityFee and _fundFee to zero.
Hence, the swapAndLiquify will always be reverted.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1027, 1050|

```
function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
    uint256 feeTotal = _liquidityFee + _fundFee;
    uint256 fundBalance =
contractTokenBalance.mul(_fundFee).div(feeTotal);
    uint256 liquidityBalance = contractTokenBalance - fundBalance;

```

##### Recommendation

The contract should properly check the variables according to the required
specifications.


-----

