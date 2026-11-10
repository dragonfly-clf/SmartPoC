#### Contract Inconsistency

**Criticality** critical

The contract contains a lot of segments that create inconsistency and cannot
guarantee a clear business logic. The contract could contain better naming
conventions and clean up the business logic functionality. The following are some
code excerpts that are creating inconsistency.

The expression does not imply that the Chief_Security_Officer is not allowed to
trade.

|Criticality|critical|
|---|---|

```
require(from != Chief_Security_Officer || to != Chief_Security_Officer,
    "Security personnel is not allowed to trade");

```

The expression does not imply that the addresses in the Security_Manager list
are not allowed to trade.

```
require(!Security_Manager[from] || !Security_Manager[to],
    "Security personnel is not allowed to trade");

```

Pure declaration of variables that have been defined as functions.

```
_tokenTransfer(from,to,amount,takeAllFees);
restoreAllFees;

```

Missing naming conventions that is making the code unreadable.

```
uint256 private pi1;
uint256 private pi2;
uint256 private bpf;
uint256 private brf;
uint256 private spfiinu;

```

-----

