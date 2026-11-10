#### ST - Stop Transactions

**Criticality** medium

**Location** contract.sol#L773

##### Description

Users are not able to sell more than 70% of their holdings every day.

|Criticality|medium|
|---|---|
|Location|contract.sol#L773|

```
function checkLimit(address sender,
    address recipient,
    uint256 amount) internal {
    if (recipient == pair && !_isFeeExempt[sender]) {
       uint256 limitSell =
balanceOf(sender).mul(maxSellPerDay).div(10000);
       require(amount <= limitSell, "Alpha Protocol: Cant Sell More Than
Allowed Per Day");
       if (block.timestamp > lastSell[sender].timestamp +
TwentyFourHours) {
         lastSell[sender].timestamp = block.timestamp;
         lastSell[sender].amount = amount;
       } else if ((block.timestamp < lastSell[sender].timestamp +
TwentyFourHours) && (block.timestamp > lastSell[sender].timestamp)) {
         require(lastSell[sender].amount + amount <= limitSell, "Alpha
Protocol: Cant Sell More Than Allowed Per Day");
         lastSell[sender].amount = lastSell[sender].amount + amount;
       }
    }
  }

```

##### Recommendation

The team should embody a method which allows the users to sell more than a
reasonable amount of tokens in a short timespan.


-----

