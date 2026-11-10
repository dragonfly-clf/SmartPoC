#### MAL - Misused Algorithmic Logic

**Criticality** minor

**Location** contract.sol#L715

##### Description

The algorithmic flow does not follow the required business logic. In the following
statement the third and the forth if will never be fulfilled since an unsigned integer is
either less than or greater/equal to 365 days. Hence, always the first two if
statements will be fulfilled.

|Criticality|minor|
|---|---|
|Location|contract.sol#L715|

```
if (deltaTimeFromInit <= (365 days)) {
  rebaseRate = 19435595;
} else if (deltaTimeFromInit >= (365 days)) {
  rebaseRate = 9717797;
} else if (deltaTimeFromInit >= ((15 * 365 days) / 10)) {
  rebaseRate = 2858898;
} else if (deltaTimeFromInit >= (7 * 365 days)) {
  rebaseRate = 1929449;
}

```

##### Recommendation

The algorithm should be reshaped so it will match to the business logic.


-----

