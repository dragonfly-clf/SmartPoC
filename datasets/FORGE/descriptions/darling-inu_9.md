#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L121,81,85,89,93,111,115,100,104,69,75

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L121,81,85,89,93,111,115,100,104,69,75|

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


-----

