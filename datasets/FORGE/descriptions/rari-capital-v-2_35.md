## QSP-36 Hardcoded dependency contracts

#### Severity: Low Risk

 Status: Acknowledged

###### File(s) affected: rari-stable-pool-contracts/.../DydxPoolController.sol, rari-stable-pool-contracts/.../AavePoolController.sol, rari-stable-pool```
contracts/.../CompoundPoolController.sol

```

###### Description: Controllers of external contracts have hardcode addresses. In the extreme scenario where these contracts are replaced by new ones (hard upgrade) or the community capital
 migrates to similar ones (code fork), there is no way to upgrade the addresses of the controlled contracts.

 Recommendation: Add functions to update the controlled addresses, either by owner or governance.

