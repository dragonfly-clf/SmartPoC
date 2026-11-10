#### L10 - State Variables in Loop

|Criticality|minor|
|---|---|
|Location|DiamondDexToken.sol#L1125|
|Status|unresolved|


##### Description


Costly operations inside a loop might waste gas, so optimizations are justified.
Incrementing state variables in a loop incurs a lot of gas because of expensive
SSTOREs, which might lead to an out-of-gas.


##### Recommendation


Use a local variable to hold the loop computation result.