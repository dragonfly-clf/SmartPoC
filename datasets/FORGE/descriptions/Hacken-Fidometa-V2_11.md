6. A new vesting period may not be created
  locks mapping may not be cleared on finishing of the vesting period
  because of rounding division to the floor, so the owner will not be
  able to set new vesting for the same user. Example:

```
   - `transaction_1: admin do transferWithLock 4 tokens`

   - `transaction_2 (on 4[th]` `vesting month): user does unlock`

   - `transaction_3 (on 5[th]` `vesting month): user does unlock`

   - `transaction_4: admin tries transferWithLock any amount`

   - `result: transaction_4 will fail`
```
  This could lead to no possibility of creating new vesting for the
  user.
  Contract: FidoMeta.sol
  Functions: transferWithLock, unlock
  Recommendation: delete locks’ item on the last unlocking, check the
  case.
  Status: Fixed (Revised Commit: cfa7cbe)
 