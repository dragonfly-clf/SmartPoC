#### MTS - Manipulate Total Supply

**Criticality** medium

**Location** contract.sol#L565

##### Description

Owner is able to manipulate total supply. This change will have a direct impact on
the token price and Market Cap.

|Criticality|medium|
|---|---|
|Location|contract.sol#L565|

```
function manualrebase() external onlyOwner {
  require(!inSwap, "Try again");
  rebase();
}

```

##### Recommendation

The contract owner should carefully manage the adjustment of the circulating
supply (increases or decreases), according to the token’s price fluctuations.


-----

