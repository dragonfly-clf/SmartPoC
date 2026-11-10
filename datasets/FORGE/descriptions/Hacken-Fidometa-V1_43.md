22. Repeated code
  The functions include the same operation (updating r-space balance of
  the sender) that could be moved to _doTransfer function.
  Contract: FidoMeta.sol
  Functions: _transferFromExcluded, _transferToExcluded,
  _transferStandard, _transferBothExcluded

```

-----

```
  Recommendation: move the operation to _doTransfer function.
  Status: New
