#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L360,320,330,345,355,267,294,239,212,228

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L360,320,330,345,355,267,294,239,212,228|

```
mod
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

