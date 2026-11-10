#### MC - Missing Check

**Criticality** minor

**Location** contract.sol#L470, 478, 491

##### Description

The contract is processing variables that have not properly sanitized and checked
that they form the proper shape. These variables may produce vulnerability issues.

|Criticality|minor|
|---|---|
|Location|contract.sol#L470, 478, 491|

```
if (swapEnabled && !swapping && sender != pair && fee > 0) swapForFees();

```

In the above code segment, the contract guarantees that at least one of the
sellTaxes.marketing or sellTaxes.liquidity variables will have a non zero value. So,
the next code segment will be executed without any problem.

```
function swapForFees() private inSwap {
    uint256 contractBalance = balanceOf(address(this));
    if (contractBalance >= swapThreshold) {
       // Split the contract balance into halves
       uint256 denominator = (sellTaxes.marketing + sellTaxes.liquidity)
* 2;
       uint256 tokensToAddLiquidityWith = contractBalance *
sellTaxes.liquidity / denominator;

```

But, in the following code segment, the execution would be reverted if the
sellTaxes.marketing has a zero value.

```
uint256 deltaBalance = address(this).balance - initialBalance;
uint256 unitBalance= deltaBalance / (denominator - sellTaxes.liquidity);

```

##### Recommendation

The contract should properly check the variables according to the required
specifications.


-----

