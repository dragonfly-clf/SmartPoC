#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L708,706,707,702,725,723,722,721,724,720,719,713

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L708,706,707,702,725,723,722,721,724,720,719,713|

```
transferTeamfee
teamDivisor
sellliquiduty
marketingDivisor
farmstakingDivisor
ecosystemDivisor
charityDivisor
burnDivisor
_tTotal

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

