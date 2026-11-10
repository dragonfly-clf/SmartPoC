#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L450,385,398,417,437,321,353,33,293,268 and 1 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L450,385,398,417,437,321,353,33,293,268 and 1 more|

```
mod
ceil
_msgData
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```
...


##### Recommendation

Remove unused functions.


-----

