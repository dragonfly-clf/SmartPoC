#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L408,340,350,365,375,390,400,287,314,780

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L408,340,350,365,375,390,400,287,314,780|

```
_setupDecimals
sendValue
isContract
functionStaticCall
functionCallWithValue
functionCall
_verifyCallResult

```
...


##### Recommendation

Remove unused functions.