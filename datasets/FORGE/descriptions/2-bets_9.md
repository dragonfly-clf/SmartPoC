#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L551,511,521,536,546,458,485,875,29,105,84,110,119,91,47,306,2
39,175,432,380,285,218,154,411,359,314,243,179,325,253,187,292,225,161,41
8,366,278,211,147,404,352,725,734,713,721,730,700,717

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L551,511,521,536,546,458,485,875,29,105,84,110,119,91,47,306,2 39,175,432,380,285,218,154,411,359,314,243,179,325,253,187,292,225,161,41 8,366,278,211,147,404,352,725,734,713,721,730,700,717|

```
substractPercentage
sqrrt
quadraticPricing
percentageOfTotal
percentageAmount
bondingCurve
average
remove
length

```
...


##### Recommendation

Remove unused functions.


-----

