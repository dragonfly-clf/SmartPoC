#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L116,103,106,109,112,86,96,20,75,78 and 1 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L116,103,106,109,112,86,96,20,75,78 and 1 more|

```
addLiquidity
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

