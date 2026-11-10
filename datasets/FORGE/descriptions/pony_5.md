#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L687,685,686,681,704,702,701,700,703,699,698,692

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L687,685,686,681,704,702,701,700,703,699,698,692|

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

