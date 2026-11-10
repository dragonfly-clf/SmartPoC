#### ZD - Zero Division

**Criticality** Critical

**Location** KARMA.sol#L639

**Status** Unresolved

#### Description

The contract is using variables that may be set to zero as denominators. This can lead to

unpredictable and potentially harmful results, such as a transaction revert.
```
 function setBuyFeePercentages(uint256 _taxFeeonBuy, uint256
 _liquidityFeeonBuy, uint256 _marketingFeeonBuy, uint256
 _burnFeeOnBuy) external onlyOwner {
   taxFeeonBuy = _taxFeeonBuy;
   liquidityFeeonBuy = _liquidityFeeonBuy;
   marketingFeeonBuy = _marketingFeeonBuy;
   burnFeeOnBuy = _burnFeeOnBuy;
   totalBuyFees = taxFeeonBuy + liquidityFeeonBuy +
 marketingFeeonBuy + burnFeeOnBuy;
   require(totalBuyFees <= 100, "Buy fees cannot be greater than
 10%");
   emit BuyFeesChanged(taxFeeonBuy, liquidityFeeonBuy,
 marketingFeeonBuy);
 }
 ...
 uint256 liquidityAmount = tLiquidity * (liquidityFeeonBuy +
 liquidityFeeonSell) / (liquidityFeeonBuy + liquidityFeeonSell +
 burnFeeOnBuy + burnFeeOnSell);

#### Recommendation

```
It is important to handle division by zero appropriately in the code to avoid unintended

behavior and to ensure the reliability and safety of the contract. The contract should ensure

that the divisor is always non-zero before performing a division operation. It should prevent


-----

the variables to be set to zero, or should not allow the execution of the corresponding

statements.


-----

