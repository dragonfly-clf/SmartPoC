#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L682,1078

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L682,1078|


times = deltaTime.div(720)
liquidityBalance = _gonBalances[pair].div(_gonsPerFragment)


##### Recommendation

The multiplications should be prior to the divisions.