#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L137,106,109,112,115,129,132,121,124,96 and 1 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L137,106,109,112,115,129,132,121,124,96 and 1 more|

```
sendValue
isContract
functionStaticCall
functionDelegateCall
functionCallWithValue
functionCall
_verifyCallResult

```
...


##### Recommendation

Remove unused functions.