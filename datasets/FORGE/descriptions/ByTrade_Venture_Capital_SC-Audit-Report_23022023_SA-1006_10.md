L06. Functions that Can Be Declared External
  In order to save Gas, public functions that are never called from the
  same contract should be declared as external.
  Path:
  ./contracts/ByTradeToken: pause(), unpause(), addToBlacklist(),
  removeFromBlacklist(), transfer(), transferFrom(), approve(),
  increaseAllowance(), decreaseAllowance()
  Recommendation: Use the external attribute for functions that are
  never called from the contract.
  Status: Reported
              www.hacken.io

```

-----

```
