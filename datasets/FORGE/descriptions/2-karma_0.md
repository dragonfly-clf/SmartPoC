#### ZD - Zero Division

**Criticality** Critical

**Location** Karma.sol#L537,610

**Status** Renounced

#### Description

The contract is using variables that may be set to zero as denominators. This can lead to

unpredictable and potentially harmful results, such as a transaction revert.

If all fees are set to zero then `_totalFee` will be zero. As a result, the transaction will

revert due to zero division.
```
 uint256 proportionReflected = buying == true
   ? proportionFeeAmount.mul(reflectionFeeBuy).div(totalFeeBuy)
   : proportionFeeAmount.mul(reflectionFeeSell).div(totalFeeSell);
 uint256 totalBNBFee = _totalFee;
 uint256 amountBNBMarketing = amountBNB.mul(marketingFeeSell).div(
   totalBNBFee
 );

#### Recommendation

```
It is important to handle division by zero appropriately in the code to avoid unintended

behavior and to ensure the reliability and safety of the contract. The contract should ensure

that the divisor is always non-zero before performing a division operation. It should prevent

the variables to be set to zero, or should not allow the execution of the corresponding

statements.


-----

#### Team Update


The contract's ownership has been renounced. The information regarding the transaction


can be accessed through the following link:


[https://bscscan.com/tx/0x5d7c25dffae6304ff73e00f334feb8d419f22b15a48a022f18d51a49](https://bscscan.com/tx/0x5d7c25dffae6304ff73e00f334feb8d419f22b15a48a022f18d51a490d13b04f)


[0d13b04f.](https://bscscan.com/tx/0x5d7c25dffae6304ff73e00f334feb8d419f22b15a48a022f18d51a490d13b04f)


-----

