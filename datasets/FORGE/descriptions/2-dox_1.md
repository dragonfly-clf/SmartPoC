#### ZD - Zero Division

**Criticality** Medium

**Location** contracts/Twelve_Days_Of_Xmas.sol#L268,284

**Status** Unresolved

#### Description

The contract uses variables that may be set to zero as denominators. This can lead to

unpredictable and potentially harmful results, such as a transaction revert.

Specifically, the totalBNBFee variable can be zero if the fees are set to zero.
```
 uint256 totalBNBFee = totalFee;
 …
 uint256 amountBNBMarketing = (amountBNB * marketingFee) /
 totalBNBFee;
 uint256 amountBNBDevelopment = (amountBNB * otherFee) / totalBNBFee;

#### Recommendation

```
It is important to handle division by zero appropriately in the code to avoid unintended

behavior and to ensure the reliability and safety of the contract. The contract should ensure

that the divisor is always non-zero before performing a division operation. It should prevent

the variables from being set to zero, or should not allow the execution of the corresponding

statements.


-----

