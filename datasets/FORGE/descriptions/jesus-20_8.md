#### L14 - Uninitialized Variables in Local Scope

**Criticality** Minor / Informative

**Location** Jesus.sol#L545

**Status** Unresolved

#### Description

Using an uninitialized local variable can lead to unpredictable behavior and potentially

cause errors in the contract. It's important to always initialize local variables with

appropriate values before using them.
```
 uint256 tokensForBurn;

#### Recommendation

```
By initializing local variables before using them, the contract ensures that the functions

behave as expected and avoid potential issues.


-----

