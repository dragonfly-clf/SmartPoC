#### CR - Code Repetition

**Criticality** minor

**Location** contract.sol#L806,1044

##### Description

There are code segments that are repetitive in the contract. Those segments
increase the code size of the contract unnecessarily. The code segment in
getBalanceAbleSell() and in the transfer method are exactly the same.

|Criticality|minor|
|---|---|
|Location|contract.sol#L806,1044|

```
string memory buy = "buy";
string memory sell = "sell";
uint256 allowedAmount = 0;
for(uint256 i = 0; i < _buyHistories[from].length; i++) {
  History memory _history = _buyHistories[from][i];
  if (keccak256(bytes(_history.status)) == keccak256(bytes(buy))) {
    allowedAmount = allowedAmount.add(_history.amount);
  }
  if (keccak256(bytes(_history.status)) == keccak256(bytes(sell))) {
    allowedAmount = allowedAmount.sub(_history.amount);
  }
}

```

##### Recommendation

Create an internal function that contains the code segment and remove it from all
the sections.


-----

