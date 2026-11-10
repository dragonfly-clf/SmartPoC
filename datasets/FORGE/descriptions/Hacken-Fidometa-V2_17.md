5. Burn wallet could be changed
  The burn wallet (surcharge1) should never be changed. As
  documentation provides info that this wallet is only for unused fees,
  the owner should not have the ability to change it and claim the next
  fees that should be burned. Moreover, to save Gas, it is better to
  burn assets by decreasing user balance and changing the supply of
  tokens.
  Contract: FidoMeta.sol
  Recommendation: implement burning as decreasing of _rTotal and
  _tTotal or mention in documentation that this charge may change its
  purpose in future.
  Status: Fixed (Revised Commit: 7bb7d6d)
