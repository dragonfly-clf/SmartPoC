#### RIC - Redundant If Condition

**Criticality** Minor / Informative

**Location** Token.sol#L398

**Status** Unresolved

#### Description

The contract is using an if statement to check if `feeAmount` is greater than zero within

the `takeTaxes` function. However, this check is redundant. However the `_transfer`

function already requires `amount` to be greater than zero. and if the `fee` variable is

zero, the function will return the `amount` variable in the previous check. Therefore, the

condition `if (feeAmount > 0)` will always evaluate to `true, making it`

unnecessary and potentially confusing.
```
 function takeTaxes(address from, bool isbuy, bool issell,
 uint256 amount) internal returns (uint256) {
   uint256 fee;
   if (isbuy) fee = buyfee; else if (issell) fee = sellfee;
 else fee = transferfee;
   if (fee == 0) return amount;
   uint256 feeAmount = amount * fee / fee_denominator;
   if (feeAmount > 0) {
      balance[address(this)] += feeAmount;
      emit Transfer(from, address(this), feeAmount);
   }
   return amount - feeAmount;
 }

#### Recommendation

```
It is recommended to remove the `if (feeAmount > 0)` statement, as it does not

affect the actual implementation and adds unnecessary complexity to the code. Simplifying

the function by removing this redundant check will make the contract easier to read,

understand, and maintain.


-----

