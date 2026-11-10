#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L175,135,139,143,147,165,169,154,158,123,129

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L175,135,139,143,147,165,169,154,158,123,129|

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

