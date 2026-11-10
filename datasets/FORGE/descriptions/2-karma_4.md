#### MSC - Missing Sanity Check

**Criticality** Minor / Informative

**Location** Karma.sol#L639,640

**Status** Unresolved

#### Description

The contract is processing variables that have not been properly sanitized and checked that

they form the proper shape. These variables may produce vulnerability issues.

The `largeSwapThreshold` should be greater than the `smallSwapThreshold .`
```
 smallSwapThreshold = _amountS;
 largeSwapThreshold = _amountL;

#### Recommendation

```
The team is advised to properly check the variables according to the required

specifications.


-----

