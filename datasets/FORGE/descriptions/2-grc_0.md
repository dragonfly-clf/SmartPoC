#### ZD - Zero Division

**Criticality** Critical

**Location** GlobalReserveCoin.sol#L1407

**Status** Unresolved

#### Description

The contract is using variables that may be set to zero as denominators. This can lead to

unpredictable and potentially harmful results, such as a transaction revert.

The variable `_FeesTotal` could potentially hold the value of zero if both all fees are set

to zero.
```
 uint256 LP_Tokens = Tokens * (_Fee__Buy_Liquidity +
 _Fee__Sell_Liquidity) / _FeesTotal / 2;

#### Recommendation

```
It is important to handle division by zero appropriately in the code to avoid unintended

behavior and to ensure the reliability and safety of the contract. The contract should ensure

that the divisor is always non-zero before performing a division operation. It should prevent

the variables to be set to zero, or should not allow the execution of the corresponding

statements.


-----

