1. Missing event for changing _fee_rate
   Contracts: POC_ERC20.sol, POC_BEP20.sol

```

-----

```
     Functions: _fee_rate_set
  Changing critical values should be followed by the event emitting for
  better tracking off-chain.
  Recommendation: Please emit events on the critical values changing.
  Status: fixed
