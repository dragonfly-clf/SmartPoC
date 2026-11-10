#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L375,335,345,360,370,282,309

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L375,335,345,360,370,282,309|

```
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```

##### Recommendation

Remove unused functions.


-----

