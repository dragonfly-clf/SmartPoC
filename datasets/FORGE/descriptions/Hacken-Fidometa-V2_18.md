6. Vested assets should be unlocked automatically

```

-----

```
  The function should calculate the actual withdrawable amount for the
  user. To improve user experience, it is better to implement automatic
  unlock of the corresponding vesting if assets are ready for
  unlocking.
  Contract: FidoMeta.sol
  Function: _transfer
  Recommendation: check if the users may unlock tokens and unlock them.
  Status: Mitigated (with customer notice)
