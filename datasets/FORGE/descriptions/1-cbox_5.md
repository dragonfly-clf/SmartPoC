#### CR - Code Repetition

**Criticality** minor

**Location** contract.sol#L727

##### Description

There are code segments that are repetitive in the contract. Those segments
increase the code size of the contract unnecessarily.

The buyBox method calculates the prize reward according to the boxID. The prize
calculation statements are the same across the three boxes. The contract could
move the calculation in one method that accepts the box as a parameter. As a
result, the code size in the buyBox method will be decreased three times.

|Criticality|minor|
|---|---|
|Location|contract.sol#L727|

```
if(boxID==0)
{
    for(uint256 i = 0; i < box1.length; i++) {
       uint256 min = box1[i][0];
       uint256 max = box1[i][1];
       uint256 mult = box1[i][2];
//…

```

##### Recommendation

Create an internal function that contains the code segment and remove it from all
the sections.


-----

