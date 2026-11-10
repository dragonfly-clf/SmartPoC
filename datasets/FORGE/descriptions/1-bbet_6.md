#### CR - Code Repetition

**Criticality** minor / informative

**Location** contract.sol#L915,938

**Status** Unresolved

##### Description

There are code segments that are repetitive in the contract. Those segments
increase the code size of the contract unnecessarily.

The following code segment is used in two functions. The _sellFeesByTime and
_buyFeesByTime functions.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L915,938|
|Status|Unresolved|


if (time >= launchTime + 180 days) {

return sellFeesInfo[launchTime + 180 days];
}
if (time >= launchTime + 150 days) {

return sellFeesInfo[launchTime + 150 days];
}
if (time >= launchTime + 120 days) {

return sellFeesInfo[launchTime + 120 days];
}
if (time >= launchTime + 90 days) {

return sellFeesInfo[launchTime + 90 days];
}
if (time >= launchTime + 60 days) {

return sellFeesInfo[launchTime + 60 days];
}
if (time >= launchTime + 30 days) {

return sellFeesInfo[launchTime + 30 days];


##### Recommendation

The contract could use an internal function that accepts the fee mapping as
argument. As a result, the repetitive methods will be removed.


-----

