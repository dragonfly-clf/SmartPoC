19. Template variables
  The code should not be overwhelmed with copy-pasted variables,
  functions, and other structures. Variables that are mostly the same
  and used in the same places may be united into a structure.

```

-----

```
  Contract: FidoMeta.sol
  Variables: _community_charge, _ecoSysFee, _surcharge1, _surcharge2,
  _surcharge3
  Variables: _previousCommunityCharge, _previousEcoSysFee,
  _previousSurcharge1, _previousSurcharge2, _previousSurcharge3
  Variables: _ecoSysWallet, _surcharge_1_Wallet, _surcharge_2_Wallet,
  _surcharge_3_Wallet
  Variables: takeCommunityCharge, takeEcosysFee, takeSurcharge1,
  takeSurcharge2, takeSurcharge3
  Recommendation: unite the variables into structures.
  Status: Acknowledged
