1. Old wallets are not included back to changes and rewards
  These functions set new wallets and exclude them from charging but do
  not include the old ones back.
  Contract: FidoMeta.sol

```

-----

```
  Functions: setEcoSysWallet, setSurcharge_1_Wallet,
  setSurcharge_2_Wallet, setSurcharge_3_Wallet
  Recommendation: use excluding from charges and rewards only for
  service accounts.
  Status: Fixed (Revised Commit: 66f43e8)
