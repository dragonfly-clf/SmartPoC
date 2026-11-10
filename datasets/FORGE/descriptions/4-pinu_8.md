#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L406,416,435,449,495,505,468,478,353,381,522,1090,1412

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L406,416,435,449,495,505,468,478,353,381,522,1090,1412|

```
_mint
verifyCallResult
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

