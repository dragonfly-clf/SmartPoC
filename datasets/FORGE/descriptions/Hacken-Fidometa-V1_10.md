5. Missing management of excluded accounts
   According to the current algorithm, all excluded accounts should be
   added to _excluded array and _isExcludedFromReward mapping, but in
   the function adding to _excluded is missed.
   This could lead to wrong rates calculation, unexpected contract
   behavior, and possible double spending.
   Contract: FidoMeta.sol
   Function: setServiceWallet
   Recommendation: carefully manage all excluded accounts.
   Status: New
  