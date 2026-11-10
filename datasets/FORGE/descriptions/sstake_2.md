#### MAL - Misused Algorithmic Logic

**Criticality** minor

**Location** contract.sol#L518

##### Description

The algorithmic flow does not follow the required business logic.

In the following statement the third and the forth if will never be fulfilled since an
unsigned integer is either less than or greater/equal to 365 days. Hence, always the
first two if statements will be fulified.

|Criticality|minor|
|---|---|
|Location|contract.sol#L518|

```
if (deltaTimeFromInit < (365 days)) {
  rebaseRate = 2355;
} else if (deltaTimeFromInit >= (365 days)) {
  rebaseRate = 211;
} else if (deltaTimeFromInit >= ((15 * 365 days) / 10)) {
  rebaseRate = 14;
} else if (deltaTimeFromInit >= (7 * 365 days)) {
  rebaseRate = 2;
}

```

##### Recommendation

The algorithm should be reshaped so it will match to the business logic.


-----

