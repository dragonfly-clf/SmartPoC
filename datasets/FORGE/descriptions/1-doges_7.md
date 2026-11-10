#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L120,80,84,88,92,110,114,99,103,68 and 5 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L120,80,84,88,92,110,114,99,103,68 and 5 more|

```
mul
div
_msgData
sendValue
isContract
functionStaticCall
functionDelegateCall
functionCallWithValue
functionCall

```
...


##### Recommendation

Remove unused functions.


-----

