L01. Floating Pragma
  Contracts should be deployed with the same compiler version and flags
  that they have been tested with thoroughly. Locking the pragma helps
  to ensure that contracts do not accidentally get deployed using, for
  example, an outdated compiler version that might introduce bugs that
  affect the contract system negatively.
  Path:
  ./contracts/ByTradeToken
              www.hacken.io

```

-----

```
  Recommendation: It is recommended to lock the Solidity pragma
  version. See more: SWC-103.
  Status: Reported
